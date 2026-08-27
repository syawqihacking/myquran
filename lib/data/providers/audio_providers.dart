import 'dart:async';
import 'dart:io' show HttpException;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/user_database.dart';
import '../services/audio_service.dart';
import '../services/just_audio_service.dart';
import '../services/murottal_download_service.dart';
import '../services/ratib_audio_service.dart';
import 'database_providers.dart';

// ---- Reciter (qari) selection --------------------------------------------------

/// All reciters from the user DB, sorted by id ascending. Feeds the reciter
/// picker UI.
final recitersProvider = FutureProvider<List<Reciter>>((ref) async {
  final db = ref.watch(userDatabaseProvider);
  final reciters = await db.select(db.reciters).get();
  reciters.sort((a, b) => a.id.compareTo(b.id));
  return reciters;
});

/// The selected reciter id, persisted in shared_preferences (defaults to
/// Alafasy, id 1). Playback and murottal downloads resolve the URL template
/// through this provider, so switching reciter takes effect immediately.
final selectedReciterProvider =
    NotifierProvider<SelectedReciterController, int>(
      SelectedReciterController.new,
    );

class SelectedReciterController extends Notifier<int> {
  static const _key = 'selected_reciter_id';

  @override
  int build() {
    return ref.watch(sharedPreferencesProvider).getInt(_key) ?? 1;
  }

  Future<void> select(int id) async {
    state = id;
    await ref.read(sharedPreferencesProvider).setInt(_key, id);
  }
}

/// Resolves the URL template for the currently selected reciter. Watches
/// [selectedReciterProvider] so the audio/murottal services pick up a reciter
/// change on the next playback. Prefers the selected reciter's template,
/// falling back to the first reciter (by id) with a usable template. Returns
/// an empty list when nothing is available — the audio service has its own
/// qurancdn fallback.
Future<List<String>> _resolveReciterTemplates(Ref ref) async {
  final db = ref.read(userDatabaseProvider);
  try {
    final reciters = await db.select(db.reciters).get();
    if (reciters.isEmpty) return const [];
    reciters.sort((a, b) => a.id.compareTo(b.id));

    final selectedId = ref.read(selectedReciterProvider);
    Reciter? selected;
    for (final r in reciters) {
      if (r.id == selectedId) {
        selected = r;
        break;
      }
    }
    final selectedTemplate = selected?.urlTemplate;
    if (selectedTemplate != null && selectedTemplate.trim().isNotEmpty) {
      return [selectedTemplate.trim()];
    }

    // Fallback: first reciter (by id) that has a usable template.
    for (final r in reciters) {
      final template = r.urlTemplate;
      if (template != null && template.trim().isNotEmpty) {
        return [template.trim()];
      }
    }
    return const [];
  } catch (e) {
    debugPrint('_resolveReciterTemplates: failed to resolve reciter URL templates — $e');
    return const [];
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = JustAudioService(
    ayahRepository: ref.watch(ayahRepositoryProvider),
    // Offline murottal: playback falls back to the local file when the ayah
    // has been downloaded, otherwise it streams (and caches) from the network.
    localFileFor: ref.watch(murottalDownloadServiceProvider).localFileFor,
    // The selected reciter's URL template from the user DB; the service
    // appends the qurancdn fallback itself. Empty on any DB hiccup.
    resolveUrlTemplates: () => _resolveReciterTemplates(ref),
  );
  ref.onDispose(service.dispose);
  return service;
});

class AudioPlaybackNotifier extends Notifier<AudioPlaybackState> {
  StreamSubscription<AudioPlaybackState>? _subscription;

  @override
  AudioPlaybackState build() {
    final service = ref.watch(audioServiceProvider);
    _subscription?.cancel();
    _subscription = service.stateStream.listen((newState) {
      state = newState;
    });
    ref.onDispose(() => _subscription?.cancel());
    return service.currentState;
  }
}

final audioPlaybackStateProvider =
    NotifierProvider<AudioPlaybackNotifier, AudioPlaybackState>(
      AudioPlaybackNotifier.new,
    );

/// Dedicated Ratib Al-Haddad audio service, kept separate from the Quran
/// `audioServiceProvider` so the two playback paths never interfere.
final ratibAudioServiceProvider = Provider<RatibAudioService>((ref) {
  final service = RatibAudioService();
  ref.onDispose(service.dispose);
  return service;
});

// ---- Offline murottal (download a surah's recitation for offline playback) --

/// The download service singleton. Resolves the same URL templates as the
/// audio service (the selected reciter from the user DB).
final murottalDownloadServiceProvider = Provider<MurottalDownloadService>((
  ref,
) {
  return MurottalDownloadService(
    resolveUrlTemplates: () => _resolveReciterTemplates(ref),
  );
});

/// Lifecycle of a surah's offline murottal download.
enum MurottalDownloadStatus { notDownloaded, downloading, downloaded, error }

/// Per-surah download state, surfaced to the UI.
class MurottalDownloadState {
  const MurottalDownloadState({
    this.status = MurottalDownloadStatus.notDownloaded,
    this.done = 0,
    this.total = 0,
    this.error,
  });

  final MurottalDownloadStatus status;
  final int done;
  final int total;
  final String? error;

  /// 0..1 download progress, or null when there is nothing to measure.
  double? get progress => total > 0 ? done / total : null;
}

/// Tracks per-surah murottal downloads and persists which surahs are fully
/// downloaded (shared_preferences, following the learning-progress pattern).
/// The persisted set is restored on startup so a downloaded surah stays marked
/// across restarts.
class MurottalDownloadController
    extends Notifier<Map<int, MurottalDownloadState>> {
  static const _key = 'murottal_downloaded_surahs';

  /// Surah ids the user has asked to cancel; checked between ayahs.
  final Set<int> _cancelled = {};

  @override
  Map<int, MurottalDownloadState> build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final raw = prefs.getString(_key);
    final downloaded = <int>{};
    if (raw != null) {
      for (final part in raw.split(',')) {
        final id = int.tryParse(part);
        if (id != null) downloaded.add(id);
      }
    }
    return {
      for (final id in downloaded)
        id: const MurottalDownloadState(
          status: MurottalDownloadStatus.downloaded,
        ),
    };
  }

  /// Starts (or resumes) downloading [surahId]. No-op while already
  /// downloading. On success the surah is marked downloaded and persisted; on
  /// failure it is marked `error` (never `downloaded`).
  Future<void> download(int surahId) async {
    final current = state[surahId] ?? const MurottalDownloadState();
    if (current.status == MurottalDownloadStatus.downloading) return;
    _cancelled.remove(surahId);

    final ayahs = await ref
        .read(ayahRepositoryProvider)
        .watchAyahs(surahId)
        .first;
    if (ayahs.isEmpty) return;

    state = {
      ...state,
      surahId: MurottalDownloadState(
        status: MurottalDownloadStatus.downloading,
        done: 0,
        total: ayahs.length,
      ),
    };

    final service = ref.read(murottalDownloadServiceProvider);
    try {
      await service.downloadSurah(
        surahId,
        ayahs,
        onProgress: (done) {
          if (_cancelled.contains(surahId)) return;
          state = {
            ...state,
            surahId: MurottalDownloadState(
              status: MurottalDownloadStatus.downloading,
              done: done,
              total: ayahs.length,
            ),
          };
        },
        isCancelled: () => _cancelled.contains(surahId),
      );

      if (_cancelled.contains(surahId)) {
        // Cancelled: remove the partial files and stay not-downloaded.
        await service.deleteSurah(surahId);
        _cancelled.remove(surahId);
        state = {...state, surahId: const MurottalDownloadState()};
        return;
      }

      // Verify every ayah is actually on disk before marking downloaded.
      final ok = await service.isSurahDownloaded(surahId, ayahs.length);
      if (!ok) throw HttpException('murottal download incomplete');
      _markDownloaded(surahId, ayahs.length);
    } catch (e) {
      debugPrint('MurottalDownloadController.build: download failed for surah $surahId — $e');
      _cancelled.remove(surahId);
      state = {
        ...state,
        surahId: MurottalDownloadState(
          status: MurottalDownloadStatus.error,
          done: 0,
          total: ayahs.length,
        ),
      };
    }
  }

  /// Requests cancellation of an in-flight download for [surahId].
  void cancel(int surahId) => _cancelled.add(surahId);

  /// Removes the downloaded files for [surahId] and forgets it.
  Future<void> delete(int surahId) async {
    _cancelled.remove(surahId);
    await ref.read(murottalDownloadServiceProvider).deleteSurah(surahId);
    state = {...state, surahId: const MurottalDownloadState()};
    _persist();
  }

  void _markDownloaded(int surahId, int total) {
    state = {
      ...state,
      surahId: MurottalDownloadState(
        status: MurottalDownloadStatus.downloaded,
        done: total,
        total: total,
      ),
    };
    _persist();
  }

  void _persist() {
    final ids =
        state.entries
            .where((e) => e.value.status == MurottalDownloadStatus.downloaded)
            .map((e) => e.key)
            .toList()
          ..sort();
    ref.read(sharedPreferencesProvider).setString(_key, ids.join(','));
  }
}

final murottalDownloadProvider =
    NotifierProvider<
      MurottalDownloadController,
      Map<int, MurottalDownloadState>
    >(MurottalDownloadController.new);
