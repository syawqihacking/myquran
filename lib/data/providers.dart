import 'dart:convert' show jsonDecode;
import 'dart:io' show HttpException;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_constants.dart';
import '../core/app_strings.dart';
import '../core/quran_palette.dart';
import '../core/window_state_service.dart';
import 'db/quran_database.dart';
import 'db/user_database.dart';
import 'models/learning_data.dart';
import 'models/adzan_voice.dart';
import 'repositories/quran_repositories.dart';
import 'repositories/reading_history_repository.dart';
import 'repositories/reading_stats_repository.dart';
import 'repositories/personality_repository.dart';
import 'repositories/spiritual_repository.dart';
import 'repositories/user_repositories.dart';
import 'services/audio_service.dart';
import 'services/just_audio_service.dart';
import 'services/murottal_download_service.dart';
import 'services/notification_service.dart';
import 'services/prayer_time_service.dart';

/// Overridden in `main()` with the awaited instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
    (ref) => throw UnimplementedError('overridden in main'));

/// Persists/restores the desktop window geometry across sessions.
final windowStateServiceProvider = Provider<WindowStateService>(
    (ref) => WindowStateService(ref.watch(sharedPreferencesProvider)));

final quranDatabaseProvider = Provider<QuranDatabase>((ref) {
  final db = QuranDatabase();
  ref.onDispose(db.close);
  return db;
});

final userDatabaseProvider = Provider<UserDatabase>((ref) {
  final db = UserDatabase();
  ref.onDispose(db.close);
  return db;
});

final surahRepositoryProvider =
    Provider((ref) => SurahRepository(ref.watch(quranDatabaseProvider)));

final ayahRepositoryProvider =
    Provider((ref) => AyahRepository(ref.watch(quranDatabaseProvider)));

final searchRepositoryProvider =
    Provider((ref) => SearchRepository(ref.watch(quranDatabaseProvider)));

final bookmarkRepositoryProvider = Provider((ref) => BookmarkRepository(
      ref.watch(userDatabaseProvider),
      ref.watch(quranDatabaseProvider),
    ));

final lastReadRepositoryProvider =
    Provider((ref) => LastReadRepository(ref.watch(userDatabaseProvider)));

final doaBookmarkRepositoryProvider =
    Provider((ref) => DoaBookmarkRepository(ref.watch(userDatabaseProvider)));

final readingStatsRepositoryProvider =
    Provider((ref) => ReadingStatsRepository(ref.watch(userDatabaseProvider)));

final sajdaRepositoryProvider =
    Provider((ref) => SajdaRepository(ref.watch(userDatabaseProvider)));

final khatamRepositoryProvider =
    Provider((ref) => KhatamRepository(ref.watch(userDatabaseProvider)));

final surahPositionRepositoryProvider =
    Provider((ref) => SurahPositionRepository(ref.watch(userDatabaseProvider)));

final readingHistoryRepositoryProvider = Provider((ref) =>
    ReadingHistoryRepository(
      ref.watch(userDatabaseProvider),
      ref.watch(quranDatabaseProvider),
    ));

/// Reading stats, auto-refreshing: emits immediately and re-emits whenever
/// `reading_log` changes (no manual `invalidate` needed from the reader).
final readingStatsProvider = StreamProvider<ReadingStats>(
    (ref) => ref.watch(readingStatsRepositoryProvider).watchStats());

// ---- Phase 2 spiritual/reading-history streams ----------------------------

/// Sujud tilawah marks (reader + stats).
final sajdaLogProvider = StreamProvider<List<SajdaLogEntry>>(
    (ref) => ref.watch(sajdaRepositoryProvider).watchSajdaLog());

final sajdaCountProvider = FutureProvider<int>(
    (ref) => ref.watch(sajdaRepositoryProvider).countSajdaDone());

/// The single active khatam target (nullable — no target yet).
final khatamTargetProvider = StreamProvider<KhatamTarget?>(
    (ref) => ref.watch(khatamRepositoryProvider).watchTarget());

/// Recently-read surahs for the Beranda reading-history list.
final recentSurahsProvider = StreamProvider<List<RecentSurahRead>>(
    (ref) => ref.watch(readingHistoryRepositoryProvider).watchRecentSurahs(
        limit: 5));

/// Ayah-read counts per day for the stats calendar (30 days, oldest first).
final dailyActivityProvider = FutureProvider<List<({int epochDay, int count})>>(
    (ref) => ref.watch(readingHistoryRepositoryProvider).getDailyActivity());

final personalityRepositoryProvider = Provider((ref) => PersonalityRepository(
      ref.watch(userDatabaseProvider),
      ref.watch(quranDatabaseProvider),
    ));

/// Personality analysis, auto-refreshing: emits immediately and re-emits
/// whenever `reading_log` changes. Null = no reading data yet (honest empty
/// state on the screen).
final personalityProvider = StreamProvider<PersonalityAnalysis?>(
    (ref) => ref.watch(personalityRepositoryProvider).watchAnalysis());

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = JustAudioService(
    ayahRepository: ref.watch(ayahRepositoryProvider),
    // Offline murottal: playback falls back to the local file when the ayah
    // has been downloaded, otherwise it streams (and caches) from the network.
    localFileFor: ref.watch(murottalDownloadServiceProvider).localFileFor,
    // First (default) reciter's URL template from the user DB; the service
    // appends the qurancdn fallback itself. Empty on any DB hiccup.
    resolveUrlTemplates: () async {
      final db = ref.read(userDatabaseProvider);
      try {
        final reciters = await db.select(db.reciters).get();
        if (reciters.isEmpty) return const [];
        reciters.sort((a, b) => a.id.compareTo(b.id));
        final template = reciters.first.urlTemplate;
        return [
          if (template != null && template.trim().isNotEmpty) template.trim(),
        ];
      } catch (_) {
        return const [];
      }
    },
  );
  ref.onDispose(service.dispose);
  return service;
});

// ---- Offline murottal (download a surah's recitation for offline playback) --

/// The download service singleton. Resolves the same URL templates as the
/// audio service (first/default reciter from the user DB).
final murottalDownloadServiceProvider = Provider<MurottalDownloadService>((ref) {
  return MurottalDownloadService(
    resolveUrlTemplates: () async {
      final db = ref.read(userDatabaseProvider);
      try {
        final reciters = await db.select(db.reciters).get();
        if (reciters.isEmpty) return const [];
        reciters.sort((a, b) => a.id.compareTo(b.id));
        final template = reciters.first.urlTemplate;
        return [
          if (template != null && template.trim().isNotEmpty) template.trim(),
        ];
      } catch (_) {
        return const [];
      }
    },
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

    final ayahs =
        await ref.read(ayahRepositoryProvider).watchAyahs(surahId).first;
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
    } catch (_) {
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
    final ids = state.entries
        .where((e) => e.value.status == MurottalDownloadStatus.downloaded)
        .map((e) => e.key)
        .toList()
      ..sort();
    ref.read(sharedPreferencesProvider).setString(_key, ids.join(','));
  }
}

final murottalDownloadProvider =
    NotifierProvider<MurottalDownloadController, Map<int, MurottalDownloadState>>(
        MurottalDownloadController.new);

final prayerTimeServiceProvider = Provider<PrayerTimeService>(
    (ref) => PrayerTimeService());

/// Streams prayer schedule, refreshing every 30 seconds for live countdown.
/// Uses GPS location with Jakarta fallback if permission is denied.
final prayerScheduleProvider = StreamProvider<PrayerSchedule>((ref) async* {
  final service = ref.watch(prayerTimeServiceProvider);

  // Try to get the device location; fall back to Jakarta.
  double lat = -6.2088;
  double lng = 106.8456;
  String locName = 'Jakarta';

  try {
    final perm = await Geolocator.checkPermission();
    LocationPermission effectivePerm = perm;
    if (perm == LocationPermission.denied) {
      effectivePerm = await Geolocator.requestPermission();
    }
    if (effectivePerm == LocationPermission.whileInUse ||
        effectivePerm == LocationPermission.always) {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
      lat = pos.latitude;
      lng = pos.longitude;
      // Resolve the coordinates to a real place name; keep the generic label
      // when the lookup fails (offline / rate-limited).
      locName = await _reverseGeocode(lat, lng) ?? 'Lokasi Anda';
    }
  } catch (_) {
    // Keep Jakarta defaults.
  }

  // Emit immediately, then every 30 s so the countdown stays fresh.
  while (true) {
    yield service.calculate(
      latitude: lat,
      longitude: lng,
      now: DateTime.now(),
      locationName: locName,
    );
    await Future<void>.delayed(const Duration(seconds: 30));
  }
});

/// Reverse-geocodes coordinates to a short place name ("Bandung, Indonesia")
/// via the free Nominatim (OpenStreetMap) endpoint. Returns null when the
/// lookup fails (offline, rate-limited, or no address) so callers can fall
/// back to a generic label. Results are cached per rounded coordinate to stay
/// well within Nominatim's 1 req/s policy.
final Map<String, String> _geocodeCache = {};

Future<String?> _reverseGeocode(double lat, double lng) async {
  final key = '${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)}';
  final cached = _geocodeCache[key];
  if (cached != null) return cached;

  try {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?format=jsonv2&lat=$lat&lon=$lng&zoom=10&accept-language=id',
    );
    final res = await http
        .get(uri, headers: const {'User-Agent': 'MyQuran/1.0 (prayer times)'})
        .timeout(const Duration(seconds: 5));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final address = data['address'] as Map<String, dynamic>?;
    if (address == null) return null;
    final city = (address['city'] ??
            address['town'] ??
            address['village'] ??
            address['county'] ??
            address['state'])
        as String?;
    final country = address['country'] as String?;
    if (city == null) return null;
    final name = country == null ? city : '$city, $country';
    _geocodeCache[key] = name;
    return name;
  } catch (_) {
    return null;
  }
}

// ---- Prayer notifications --------------------------------------------------

/// The notification service singleton.
final prayerNotificationsProvider =
    Provider<NotificationService>((ref) => NotificationService());

/// The selected adzan voice id (persisted; defaults to the first voice).
final selectedAdzanVoiceProvider =
    NotifierProvider<AdzanVoiceController, String>(AdzanVoiceController.new);

class AdzanVoiceController extends Notifier<String> {
  static const _key = 'adzan_voice_id';

  @override
  String build() {
    return ref.watch(sharedPreferencesProvider).getString(_key) ??
        adzanVoices.first.id;
  }

  Future<void> select(String id) async {
    state = id;
    await ref.read(sharedPreferencesProvider).setString(_key, id);
  }
}

/// Whether daily prayer-time notifications are enabled (persisted).
final prayerNotificationsEnabledProvider =
    NotifierProvider<PrayerNotificationsController, bool>(
        PrayerNotificationsController.new);

class PrayerNotificationsController extends Notifier<bool> {
  static const _key = 'prayer_notifications_enabled';

  @override
  bool build() {
    return ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;
  }

  /// Enables/disables notifications. Enabling first requests the runtime
  /// permissions; returns false (and stays off) when the user denies them.
  Future<bool> setEnabled(bool enabled) async {
    if (enabled) {
      final ok =
          await ref.read(prayerNotificationsProvider).requestPermissions();
      if (!ok) return false;
    }
    state = enabled;
    await ref.read(sharedPreferencesProvider).setBool(_key, enabled);
    return true;
  }
}

/// Keeps the scheduled notifications in sync with the toggle and the current
/// prayer schedule. Watched at the app root so it stays alive for the whole
/// session; the service itself skips redundant rescheduling.
final prayerNotificationSyncProvider = Provider<void>((ref) {
  final enabled = ref.watch(prayerNotificationsEnabledProvider);
  final voiceId = ref.watch(selectedAdzanVoiceProvider);
  final schedule = ref.watch(prayerScheduleProvider).value;
  final service = ref.watch(prayerNotificationsProvider);
  if (!enabled) {
    service.cancelAll();
    service.stopAdzanService();
    return;
  }
  if (schedule != null) {
    service.schedulePrayers(schedule, voiceId: voiceId);
    service.startAdzanService(schedule, voiceId: voiceId);
  }
});

/// Whether the daily Dzikir Pagi & Petang reminder notifications are enabled
/// (persisted).
final dzikirReminderEnabledProvider =
    NotifierProvider<DzikirReminderController, bool>(
        DzikirReminderController.new);

class DzikirReminderController extends Notifier<bool> {
  static const _key = 'dzikir_reminder_enabled';

  @override
  bool build() {
    return ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;
  }

  /// Enables/disables the dzikir reminders. Enabling first requests the runtime
  /// permissions; returns false (and stays off) when the user denies them.
  Future<bool> setEnabled(bool enabled) async {
    if (enabled) {
      final ok =
          await ref.read(prayerNotificationsProvider).requestPermissions();
      if (!ok) return false;
    }
    state = enabled;
    await ref.read(sharedPreferencesProvider).setBool(_key, enabled);
    return true;
  }
}

/// Keeps the dzikir reminder notifications in sync with the toggle. Watched at
/// the app root so it stays alive for the whole session.
final dzikirReminderSyncProvider = Provider<void>((ref) {
  final enabled = ref.watch(dzikirReminderEnabledProvider);
  final service = ref.watch(prayerNotificationsProvider);
  if (enabled) {
    service.scheduleDzikirReminders();
  } else {
    service.cancelDzikirReminders();
  }
});

// ---- Streams -------------------------------------------------------------

final surahListProvider = StreamProvider<List<Surah>>(
    (ref) => ref.watch(surahRepositoryProvider).watchSurahs());

final surahByIdProvider = FutureProvider.family<Surah?, int>(
    (ref, id) => ref.watch(surahRepositoryProvider).getSurah(id));

final ayahsProvider = StreamProvider.family<List<Ayah>, int>(
    (ref, surahId) => ref.watch(ayahRepositoryProvider).watchAyahs(surahId));

final juzListProvider = FutureProvider<List<JuzInfo>>(
    (ref) => ref.watch(ayahRepositoryProvider).getJuzInfos());

/// Resolved detail behind the last-read bookmark (Home hero).
final lastReadDetailProvider = FutureProvider<({Ayah ayah, Surah surah})?>(
    (ref) async {
  final lastRead = await ref.watch(lastReadProvider.future);
  if (lastRead == null) return null;
  final ayah = await ref.watch(ayahRepositoryProvider).getAyah(lastRead.ayahId);
  if (ayah == null) return null;
  final surah =
      await ref.watch(surahRepositoryProvider).getSurah(ayah.surahId);
  if (surah == null) return null;
  return (ayah: ayah, surah: surah);
});

/// Ayat Hari Ini — a deterministic day-of-year rotation over a handful of
/// beloved ayahs, resolved straight from the offline `quran.db` (no new DB
/// plumbing). Falls back to Al-Insyirah 5, the design's example verse.
final dailyAyahProvider =
    FutureProvider<({Ayah ayah, Surah surah})>((ref) async {
  const picks = [
    (surah: 94, ayah: 5), // Al-Insyirah 5 — sesudah kesulitan ada kemudahan
    (surah: 13, ayah: 28), // Ar-Ra'd 28 — hati tenteram dengan mengingat Allah
    (surah: 65, ayah: 3), // At-Talaq 3 — tawakal, Allah mencukupkan
    (surah: 2, ayah: 286), // Al-Baqarah 286 — sesuai kesanggupan
    (surah: 3, ayah: 139), // Ali 'Imran 139 — jangan lemah dan bersedih
    (surah: 94, ayah: 6), // Al-Insyirah 6 — kemudahan yang kedua
  ];
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
  final pick = picks[dayOfYear % picks.length];

  final ayahRepo = ref.read(ayahRepositoryProvider);
  final surahRepo = ref.read(surahRepositoryProvider);

  // Resolve the pick, falling back to Al-Insyirah 5 (the design's verse).
  var ayah = await ayahRepo.getAyahByNumber(pick.surah, pick.ayah);
  ayah ??= await ayahRepo.getAyahByNumber(94, 5);
  if (ayah == null) {
    throw StateError('Daily-verse ayah missing from quran.db');
  }
  final surah = await surahRepo.getSurah(ayah.surahId);
  if (surah == null) {
    throw StateError('Surah ${ayah.surahId} missing from quran.db');
  }
  return (ayah: ayah, surah: surah);
});

final bookmarksProvider = StreamProvider<List<BookmarkEntry>>(
    (ref) => ref.watch(bookmarkRepositoryProvider).watchBookmarks());

/// Bookmarked daily-prayer slugs (doa harian), auto-refreshing on toggle.
final doaBookmarkIdsProvider = StreamProvider<Set<String>>(
    (ref) => ref.watch(doaBookmarkRepositoryProvider).watchBookmarkedIds());

final lastReadProvider = StreamProvider<LastRead?>(
    (ref) => ref.watch(lastReadRepositoryProvider).watch());

// ---- Settings ------------------------------------------------------------

class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.quranFontStep = AppConstants.defaultQuranFontStep,
    this.showTranslation = true,
    this.alignArabicRight = true,
    this.tafsirOpenByDefault = false,
    this.restoreLastRead = true,
    this.paperTheme = PaperTheme.hangat,
    this.tajwidColor = false,
  });

  final ThemeMode themeMode;
  final int quranFontStep;
  final bool showTranslation;
  final bool alignArabicRight;
  final bool tafsirOpenByDefault;
  final bool restoreLastRead;
  final PaperTheme paperTheme;
  final bool tajwidColor;

  SettingsState copyWith({
    ThemeMode? themeMode,
    int? quranFontStep,
    bool? showTranslation,
    bool? alignArabicRight,
    bool? tafsirOpenByDefault,
    bool? restoreLastRead,
    PaperTheme? paperTheme,
    bool? tajwidColor,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      quranFontStep: quranFontStep ?? this.quranFontStep,
      showTranslation: showTranslation ?? this.showTranslation,
      alignArabicRight: alignArabicRight ?? this.alignArabicRight,
      tafsirOpenByDefault: tafsirOpenByDefault ?? this.tafsirOpenByDefault,
      restoreLastRead: restoreLastRead ?? this.restoreLastRead,
      paperTheme: paperTheme ?? this.paperTheme,
      tajwidColor: tajwidColor ?? this.tajwidColor,
    );
  }
}

class SettingsController extends Notifier<SettingsState> {
  static const _kThemeMode = 'theme_mode';
  static const _kFontStep = 'quran_font_step';
  static const _kShowTranslation = 'show_translation';
  static const _kAlign = 'align_arabic_right';
  static const _kTafsirDefault = 'tafsir_open_default';
  static const _kRestoreLastRead = 'restore_last_read';
  static const _kPaperTheme = 'paper_theme';
  static const _kTajwid = 'tajwid_color';

  @override
  SettingsState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return SettingsState(
      themeMode: ThemeMode.values.asNameMap()[prefs.getString(_kThemeMode)] ??
          ThemeMode.system,
      quranFontStep: prefs.getInt(_kFontStep) ??
          AppConstants.defaultQuranFontStep,
      showTranslation: prefs.getBool(_kShowTranslation) ?? true,
      alignArabicRight: prefs.getBool(_kAlign) ?? true,
      tafsirOpenByDefault: prefs.getBool(_kTafsirDefault) ?? false,
      restoreLastRead: prefs.getBool(_kRestoreLastRead) ?? true,
      paperTheme:
          PaperTheme.values.asNameMap()[prefs.getString(_kPaperTheme)] ??
              PaperTheme.hangat,
      tajwidColor: prefs.getBool(_kTajwid) ?? false,
    );
  }

  void _save() {
    final prefs = ref.read(sharedPreferencesProvider);
    final s = state;
    prefs.setString(_kThemeMode, s.themeMode.name);
    prefs.setInt(_kFontStep, s.quranFontStep);
    prefs.setBool(_kShowTranslation, s.showTranslation);
    prefs.setBool(_kAlign, s.alignArabicRight);
    prefs.setBool(_kTafsirDefault, s.tafsirOpenByDefault);
    prefs.setBool(_kRestoreLastRead, s.restoreLastRead);
    prefs.setString(_kPaperTheme, s.paperTheme.name);
    prefs.setBool(_kTajwid, s.tajwidColor);
  }

  void setThemeMode(ThemeMode m) {
    state = state.copyWith(themeMode: m);
    _save();
  }

  void setFontStep(int step) {
    final clamped = step < AppConstants.minQuranFontStep
        ? AppConstants.minQuranFontStep
        : (step > AppConstants.maxQuranFontStep
            ? AppConstants.maxQuranFontStep
            : step);
    state = state.copyWith(quranFontStep: clamped);
    _save();
  }

  void resetFontStep() => setFontStep(AppConstants.defaultQuranFontStep);

  void setShowTranslation(bool v) {
    state = state.copyWith(showTranslation: v);
    _save();
  }

  void setAlignArabicRight(bool v) {
    state = state.copyWith(alignArabicRight: v);
    _save();
  }

  void setTafsirOpenByDefault(bool v) {
    state = state.copyWith(tafsirOpenByDefault: v);
    _save();
  }

  void setRestoreLastRead(bool v) {
    state = state.copyWith(restoreLastRead: v);
    _save();
  }

  void setPaperTheme(PaperTheme p) {
    state = state.copyWith(paperTheme: p);
    _save();
  }

  void setTajwidColor(bool v) {
    state = state.copyWith(tajwidColor: v);
    _save();
  }
}

final settingsProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);

// ---- Pusat Belajar progress -------------------------------------------------

/// Persisted progress for one course: the set of completed lesson indices and
/// the epoch-ms of the most recent completion (drives the "Lanjutkan Belajar"
/// hero ordering).
class CourseProgress {
  const CourseProgress({required this.completed, required this.updatedAt});

  final Set<int> completed;
  final int updatedAt;
}

/// Loads/saves per-course learning progress in shared_preferences under
/// `learning_progress_<courseId>` (a JSON string). Follows the amalan_ibadah
/// persistence pattern — survives restarts, no extra dependencies.
class LearningProgressController
    extends Notifier<Map<String, CourseProgress>> {
  static const _prefix = 'learning_progress_';

  @override
  Map<String, CourseProgress> build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final out = <String, CourseProgress>{};
    for (final course in learningCourses) {
      final raw = prefs.getString('$_prefix${course.id}');
      if (raw == null) continue;
      final parsed = _decode(raw);
      if (parsed != null) out[course.id] = parsed;
    }
    return out;
  }

  void _save(String courseId) {
    final prefs = ref.read(sharedPreferencesProvider);
    final p = state[courseId];
    if (p == null) {
      prefs.remove('$_prefix$courseId');
    } else {
      prefs.setString('$_prefix$courseId', _encode(p));
    }
  }

  /// Marks [lessonIndex] of [course] done (or undone when [done] is false).
  void markLesson(Course course, int lessonIndex, {required bool done}) {
    final current = state[course.id] ??
        const CourseProgress(completed: {}, updatedAt: 0);
    final completed = Set<int>.from(current.completed);
    if (done) {
      completed.add(lessonIndex);
    } else {
      completed.remove(lessonIndex);
    }
    final updated = CourseProgress(
      completed: completed,
      updatedAt: done
          ? DateTime.now().millisecondsSinceEpoch
          : current.updatedAt,
    );
    state = {...state, course.id: updated};
    _save(course.id);
  }

  bool isCompleted(String courseId, int lessonIndex) =>
      state[courseId]?.completed.contains(lessonIndex) ?? false;

  int completedCount(String courseId) =>
      state[courseId]?.completed.length ?? 0;

  /// Index of the first uncompleted lesson in [course] (0 when all done).
  int nextLessonIndex(Course course) {
    final completed = state[course.id]?.completed ?? const <int>{};
    for (var i = 0; i < course.lessons.length; i++) {
      if (!completed.contains(i)) return i;
    }
    return 0;
  }

  /// The most recently updated in-progress course (≥1 lesson done, not all
  /// done). Null when the user has no in-progress course — the hero is then
  /// hidden entirely (honest, no fabricated "continue" state).
  Course? get continueCourse {
    Course? best;
    int? bestAt;
    for (final course in learningCourses) {
      final p = state[course.id];
      if (p == null || p.completed.isEmpty) continue;
      if (p.completed.length >= course.lessons.length) continue;
      if (bestAt == null || p.updatedAt > bestAt) {
        best = course;
        bestAt = p.updatedAt;
      }
    }
    return best;
  }

  static String _encode(CourseProgress p) {
    final lessons = p.completed.toList()..sort();
    return '{"lessons":[${lessons.join(',')}],"updatedAt":${p.updatedAt}}';
  }

  static CourseProgress? _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final lessons = decoded['lessons'];
      final updatedAt = decoded['updatedAt'];
      if (lessons is! List || updatedAt is! int) return null;
      final completed = <int>{
        for (final l in lessons)
          if (l is int) l,
      };
      return CourseProgress(completed: completed, updatedAt: updatedAt);
    } catch (_) {
      return null;
    }
  }
}

final learningProgressProvider =
    NotifierProvider<LearningProgressController, Map<String, CourseProgress>>(
        LearningProgressController.new);

// ---- Profil Pengguna ---------------------------------------------------------

/// The user's display name, persisted in shared_preferences under
/// `profile_name`. Defaults to "Pengguna" — honest, no fabricated identity.
class ProfileNameController extends Notifier<String> {
  static const _kName = 'profile_name';

  @override
  String build() =>
      ref.read(sharedPreferencesProvider).getString(_kName) ??
      S.profileNameDefault;

  /// Saves the trimmed name; empty input falls back to the default.
  void setName(String name) {
    final value = name.trim();
    state = value.isEmpty ? S.profileNameDefault : value;
    ref.read(sharedPreferencesProvider).setString(_kName, state);
  }
}

final profileNameProvider =
    NotifierProvider<ProfileNameController, String>(ProfileNameController.new);

/// Distinct surahs the user has read, derived from `reading_log` joined to the
/// ayah table (bounded to the 200 most recent rows like the history repo).
/// Auto-refreshes on `reading_log` changes via the drift table stream.
final surahsReadCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(userDatabaseProvider);
  final ayahRepo = ref.watch(ayahRepositoryProvider);
  final recent = user.select(user.readingLog)..limit(200);
  return recent.watch().asyncMap((entries) async {
    if (entries.isEmpty) return 0;
    final ayahs = await ayahRepo.getAyahsByIds(
        entries.map((e) => e.ayahId).toSet().toList());
    return ayahs.map((a) => a.surahId).toSet().length;
  });
});

/// Recently-read surahs for the Profil "Riwayat Bacaan Terakhir" list.
final profileRecentSurahsProvider = StreamProvider<List<RecentSurahRead>>(
    (ref) => ref.watch(readingHistoryRepositoryProvider).watchRecentSurahs(
        limit: 8));
