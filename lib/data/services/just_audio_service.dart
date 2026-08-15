// ignore_for_file: experimental_member_use
// LockCachingAudioSource is the mandated caching mechanism (streams while
// caching, serves cached ayahs from disk); its @experimental marker is
// accepted for this feature.

import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../repositories/quran_repositories.dart';
import 'audio_service.dart';

/// Builds a recitation URL from a template containing `{SSS}` (surah,
/// zero-padded to 3 digits) and `{AAA}` (ayah, zero-padded to 3 digits)
/// placeholders, e.g. `https://everyayah.com/data/Alafasy_128kbps/{SSS}{AAA}.mp3`.
///
/// Pure and synchronous so it is trivially unit-testable.
String audioUrlFor(int surahId, int ayahNumber, String template) {
  final sss = surahId.toString().padLeft(3, '0');
  final aaa = ayahNumber.toString().padLeft(3, '0');
  return template.replaceAll('{SSS}', sss).replaceAll('{AAA}', aaa);
}

/// Documented fallback recitation source (verified live), used when the DB
/// reciter template is unavailable or its URL fails to load.
const kQurancdnFallbackTemplate =
    'https://audio.qurancdn.com/Alafasy/mp3/{SSS}{AAA}.mp3';

/// Real Quran recitation service backed by `just_audio` (+ media_kit on
/// Linux/Windows).
///
/// URL strategy:
///  1. the first/default reciter's `urlTemplate` from the user DB
///     (seeded with everyayah.com templates);
///  2. [kQurancdnFallbackTemplate] as a documented fallback, tried (with a
///     timeout) when the DB template's URL fails to load.
///
/// Caching: every ayah streams through a [LockCachingAudioSource] that caches
/// to `getApplicationSupportDirectory()/audio_cache/{SSS}{AAA}.mp3`; a cached
/// ayah is served straight from disk and never re-downloaded.
class JustAudioService implements AudioService {
  JustAudioService({
    required AyahRepository ayahRepository,
    required Future<List<String>> Function() resolveUrlTemplates,
    Future<String?> Function(int surahId, int ayahNumber)? localFileFor,
    AudioPlayer? player,
  })  : _ayahRepository = ayahRepository,
        _resolveUrlTemplates = resolveUrlTemplates,
        _localFileFor = localFileFor,
        _player = player ?? AudioPlayer(maxSkipsOnError: _maxSkipsOnError) {
    // Combine every just_audio signal into the single seam state stream.
    // Streams are re-read synchronously in [_emit] so each event (status,
    // index, position, duration) produces an up-to-date snapshot promptly.
    _player.playerStateStream.listen((_) => _emit());
    _player.currentIndexStream.listen((_) => _emit());
    _player.positionStream.listen((_) => _emit());
    _player.durationStream.listen((_) => _emit());
    _emit(status: AudioStatus.idle, ayahId: null);
  }

  /// Consecutive failed loads after which the player gives up (dead URLs
  /// auto-skip instead of halting the surah queue).
  static const _maxSkipsOnError = 8;

  /// Upper bound for loading one URL before trying the fallback template.
  /// just_audio's media_kit backend can hang (instead of throwing) when a URL
  /// fails to open, so the fallback needs a timeout to be reliable.
  static const _sourceLoadTimeout = Duration(seconds: 20);

  final AyahRepository _ayahRepository;
  final Future<List<String>> Function() _resolveUrlTemplates;

  /// Resolves a locally-downloaded murottal file for an ayah (absolute path)
  /// or null when the ayah is not stored offline. When non-null, playback uses
  /// the local file instead of streaming from the network.
  final Future<String?> Function(int surahId, int ayahNumber)? _localFileFor;

  final AudioPlayer _player;

  /// Global ayah ids in playlist order for the current queue; maps
  /// `_player.currentIndex` → ayah id. Empty when stopped.
  List<int> _queue = [];

  Directory? _cacheDir;
  bool _disposed = false;

  final StreamController<AudioPlaybackState> _controller =
      StreamController<AudioPlaybackState>.broadcast(sync: true);

  @override
  Stream<AudioPlaybackState> get stateStream => _controller.stream;

  @override
  Future<void> playAyah(int ayahId) async {
    _queue = [ayahId];
    // Flip off idle immediately so the reader's "coming soon" fallback never
    // fires for a real play request (the state must leave idle right away).
    _emit(status: AudioStatus.buffering, ayahId: ayahId);

    final ayah = await _ayahRepository.getAyah(ayahId);
    if (ayah == null) {
      _emit(status: AudioStatus.idle, ayahId: null);
      return;
    }

    final templates = await _resolveTemplates();
    if (templates.isEmpty) {
      _emit(status: AudioStatus.idle, ayahId: null);
      return;
    }

    final dir = await _ensureCacheDir();
    // Offline murottal: play the local file when this ayah has been
    // downloaded, otherwise stream (and cache) from the network.
    final local = _localFileFor != null
        ? await _localFileFor(ayah.surahId, ayah.ayahNumber)
        : null;
    if (local != null) {
      try {
        await _player
            .setAudioSource(
              AudioSource.file(local, tag: ayahId),
              preload: true,
            )
            .timeout(_sourceLoadTimeout);
        await _player.play();
        _emit();
        return;
      } catch (_) {
        // Fall through to streaming if the local file fails to load.
      }
    }
    for (final template in templates) {
      final url = audioUrlFor(ayah.surahId, ayah.ayahNumber, template);
      try {
        await _player
            .setAudioSource(
              LockCachingAudioSource(
                Uri.parse(url),
                cacheFile: _cacheFile(dir, ayah.surahId, ayah.ayahNumber),
                tag: ayahId,
              ),
              preload: true,
            )
            .timeout(_sourceLoadTimeout);
        await _player.play();
        _emit();
        return;
      } catch (_) {
        // Try the next template (the qurancdn fallback), then give up.
      }
    }
    _emit(status: AudioStatus.idle, ayahId: null);
  }

  @override
  Future<void> playSurahFrom(int surahId, int ayahId) async {
    _emit(status: AudioStatus.buffering, ayahId: ayahId);

    // Reuse the reader's existing repository stream (ordered by ayah number).
    final ayahs = await _ayahRepository.watchAyahs(surahId).first;
    if (ayahs.isEmpty) {
      _emit(status: AudioStatus.idle, ayahId: null);
      return;
    }

    final templates = await _resolveTemplates();
    if (templates.isEmpty) {
      _emit(status: AudioStatus.idle, ayahId: null);
      return;
    }
    final primaryTemplate = templates.first;

    final dir = await _ensureCacheDir();
    final sources = <AudioSource>[];
    for (final ayah in ayahs) {
      // Offline murottal: use the local file when this ayah has been
      // downloaded, otherwise stream (and cache) from the network.
      final local = _localFileFor != null
          ? await _localFileFor(ayah.surahId, ayah.ayahNumber)
          : null;
      if (local != null) {
        sources.add(AudioSource.file(local, tag: ayah.id));
      } else {
        sources.add(
          LockCachingAudioSource(
            Uri.parse(
              audioUrlFor(ayah.surahId, ayah.ayahNumber, primaryTemplate),
            ),
            cacheFile: _cacheFile(dir, ayah.surahId, ayah.ayahNumber),
            tag: ayah.id,
          ),
        );
      }
    }

    final startIndex = ayahs.indexWhere((a) => a.id == ayahId);
    _queue = [for (final ayah in ayahs) ayah.id];

    // `preload: false` is required by the media_kit backend; the initial
    // source loads when `play()` is called. Dead URLs in the queue auto-skip
    // thanks to `maxSkipsOnError` on the player.
    await _player.setAudioSources(
      sources,
      initialIndex: startIndex < 0 ? 0 : startIndex,
      preload: false,
    );
    await _player.play();
    _emit();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    _emit();
  }

  @override
  Future<void> resume() async {
    await _player.play();
    _emit();
  }

  @override
  Future<void> stop() async {
    _queue = [];
    await _player.stop();
    _emit(status: AudioStatus.idle, ayahId: null);
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_player.dispose());
    _controller.close();
  }

  // ---- Internals ----------------------------------------------------------

  /// Candidate templates, DB reciter first, qurancdn fallback always last.
  Future<List<String>> _resolveTemplates() async {
    final dbTemplates = await _resolveUrlTemplates();
    final templates = [...dbTemplates];
    if (!templates.contains(kQurancdnFallbackTemplate)) {
      templates.add(kQurancdnFallbackTemplate);
    }
    return templates;
  }

  Future<Directory> _ensureCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final dir = Directory(
      p.join((await getApplicationSupportDirectory()).path, 'audio_cache'),
    );
    await dir.create(recursive: true);
    _cacheDir = dir;
    return dir;
  }

  static File _cacheFile(Directory dir, int surahId, int ayahNumber) =>
      File(p.join(dir.path, audioUrlFor(surahId, ayahNumber, '{SSS}{AAA}.mp3')));

  AudioStatus _statusFromPlayer() {
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioStatus.idle;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        return AudioStatus.buffering;
      case ProcessingState.ready:
        return _player.playing ? AudioStatus.playing : AudioStatus.paused;
      case ProcessingState.completed:
        return _player.playing ? AudioStatus.playing : AudioStatus.idle;
    }
  }

  /// Maps the current playlist index to a global ayah id.
  int? get _currentAyahId {
    if (_queue.isEmpty) return null;
    final index = _player.currentIndex;
    if (index == null || index < 0 || index >= _queue.length) return null;
    return _queue[index];
  }

  void _emit({AudioStatus? status, int? ayahId}) {
    if (_disposed) return;
    _controller.add(AudioPlaybackState(
      status: status ?? _statusFromPlayer(),
      ayahId: ayahId ?? _currentAyahId,
      position: _player.position,
      duration: _player.duration ?? Duration.zero,
    ));
  }
}
