import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_constants.dart';
import '../core/window_state_service.dart';
import 'db/quran_database.dart';
import 'db/user_database.dart';
import 'repositories/quran_repositories.dart';
import 'repositories/reading_history_repository.dart';
import 'repositories/reading_stats_repository.dart';
import 'repositories/spiritual_repository.dart';
import 'repositories/user_repositories.dart';
import 'services/audio_service.dart';

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

final audioServiceProvider = Provider<AudioService>((ref) {
  final s = NoopAudioService();
  ref.onDispose(s.dispose);
  return s;
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

final bookmarksProvider = StreamProvider<List<BookmarkEntry>>(
    (ref) => ref.watch(bookmarkRepositoryProvider).watchBookmarks());

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
  });

  final ThemeMode themeMode;
  final int quranFontStep;
  final bool showTranslation;
  final bool alignArabicRight;
  final bool tafsirOpenByDefault;
  final bool restoreLastRead;

  SettingsState copyWith({
    ThemeMode? themeMode,
    int? quranFontStep,
    bool? showTranslation,
    bool? alignArabicRight,
    bool? tafsirOpenByDefault,
    bool? restoreLastRead,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      quranFontStep: quranFontStep ?? this.quranFontStep,
      showTranslation: showTranslation ?? this.showTranslation,
      alignArabicRight: alignArabicRight ?? this.alignArabicRight,
      tafsirOpenByDefault: tafsirOpenByDefault ?? this.tafsirOpenByDefault,
      restoreLastRead: restoreLastRead ?? this.restoreLastRead,
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
}

final settingsProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);
