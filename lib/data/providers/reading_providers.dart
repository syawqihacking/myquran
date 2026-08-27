import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/quran_database.dart';
import '../db/user_database.dart';
import '../repositories/personality_repository.dart';
import '../repositories/quran_repositories.dart';
import '../repositories/reading_history_repository.dart';
import '../repositories/reading_stats_repository.dart';
import '../repositories/user_repositories.dart';
import 'database_providers.dart';

/// Reading stats, auto-refreshing: emits immediately and re-emits whenever
/// `reading_log` changes (no manual `invalidate` needed from the reader).
final readingStatsProvider = StreamProvider<ReadingStats>(
  (ref) => ref.watch(readingStatsRepositoryProvider).watchStats(),
);

// ---- Phase 2 spiritual/reading-history streams ----------------------------

/// Sujud tilawah marks (reader + stats).
final sajdaLogProvider = StreamProvider<List<SajdaLogEntry>>(
  (ref) => ref.watch(sajdaRepositoryProvider).watchSajdaLog(),
);

final sajdaCountProvider = FutureProvider<int>(
  (ref) => ref.watch(sajdaRepositoryProvider).countSajdaDone(),
);

/// The single active khatam target (nullable — no target yet).
final khatamTargetProvider = StreamProvider<KhatamTarget?>(
  (ref) => ref.watch(khatamRepositoryProvider).watchTarget(),
);

/// Recently-read surahs for the Beranda reading-history list.
final recentSurahsProvider = StreamProvider<List<RecentSurahRead>>(
  (ref) =>
      ref.watch(readingHistoryRepositoryProvider).watchRecentSurahs(limit: 5),
);

/// Ayah-read counts per day for the stats calendar (30 days, oldest first).
final dailyActivityProvider = FutureProvider<List<({int epochDay, int count})>>(
  (ref) => ref.watch(readingHistoryRepositoryProvider).getDailyActivity(),
);

final personalityRepositoryProvider = Provider(
  (ref) => PersonalityRepository(
    ref.watch(userDatabaseProvider),
    ref.watch(quranDatabaseProvider),
  ),
);

/// Personality analysis, auto-refreshing: emits immediately and re-emits
/// whenever `reading_log` changes. Null = no reading data yet (honest empty
/// state on the screen).
final personalityProvider = StreamProvider<PersonalityAnalysis?>(
  (ref) => ref.watch(personalityRepositoryProvider).watchAnalysis(),
);

// ---- Streams -------------------------------------------------------------

final surahListProvider = StreamProvider<List<Surah>>(
  (ref) => ref.watch(surahRepositoryProvider).watchSurahs(),
);

final surahByIdProvider = FutureProvider.family<Surah?, int>(
  (ref, id) => ref.watch(surahRepositoryProvider).getSurah(id),
);

final ayahsProvider = StreamProvider.family<List<Ayah>, int>(
  (ref, surahId) => ref.watch(ayahRepositoryProvider).watchAyahs(surahId),
);

final juzListProvider = FutureProvider<List<JuzInfo>>(
  (ref) => ref.watch(ayahRepositoryProvider).getJuzInfos(),
);

/// Resolved detail behind the last-read bookmark (Home hero).
final lastReadDetailProvider = FutureProvider<({Ayah ayah, Surah surah})?>((
  ref,
) async {
  final lastRead = await ref.watch(lastReadProvider.future);
  if (lastRead == null) return null;
  final ayah = await ref.watch(ayahRepositoryProvider).getAyah(lastRead.ayahId);
  if (ayah == null) return null;
  final surah = await ref.watch(surahRepositoryProvider).getSurah(ayah.surahId);
  if (surah == null) return null;
  return (ayah: ayah, surah: surah);
});

/// Ayat Hari Ini — a deterministic day-of-year rotation over a handful of
/// beloved ayahs, resolved straight from the offline `quran.db` (no new DB
/// plumbing). Falls back to Al-Insyirah 5, the design's example verse.
final dailyAyahProvider = FutureProvider<({Ayah ayah, Surah surah})>((
  ref,
) async {
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
  (ref) => ref.watch(bookmarkRepositoryProvider).watchBookmarks(),
);

/// Bookmarked daily-prayer slugs (doa harian), auto-refreshing on toggle.
final doaBookmarkIdsProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(doaBookmarkRepositoryProvider).watchBookmarkedIds(),
);

final lastReadProvider = StreamProvider<LastRead?>(
  (ref) => ref.watch(lastReadRepositoryProvider).watch(),
);
