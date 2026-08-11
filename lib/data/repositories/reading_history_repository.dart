import 'package:drift/drift.dart';

import '../db/quran_database.dart';
import '../db/user_database.dart';
import 'quran_repositories.dart';

/// One surah the user has read recently, with progress and last-read info.
/// Used by the Home "Riwayat Baca" list.
class RecentSurahRead {
  const RecentSurahRead({
    required this.surah,
    required this.readAyahCount,
    required this.totalAyahCount,
    required this.lastAyahId,
    required this.lastReadAt,
  });

  final Surah surah;
  final int readAyahCount;
  final int totalAyahCount;
  final int lastAyahId;

  /// Epoch seconds of the most recent read in this surah.
  final int lastReadAt;

  double get progress =>
      totalAyahCount == 0 ? 0 : readAyahCount / totalAyahCount;
}

/// Reading history over `reading_log` (user.db), joined to ayah/surah details
/// from `quran.db` at read time (cross-DB join pattern like BookmarkRepository).
class ReadingHistoryRepository {
  ReadingHistoryRepository(UserDatabase user, QuranDatabase quran)
      : _user = user,
        _ayahs = AyahRepository(quran),
        _surahs = SurahRepository(quran);

  final UserDatabase _user;
  final AyahRepository _ayahs;
  final SurahRepository _surahs;

  /// Surahs with at least one logged read, most recently read first, each with
  /// progress (distinct ayahs read / total ayahs) and the last ayah read.
  ///
  /// The underlying query is bounded to the 200 most recent log rows before
  /// the cross-DB join, so a large `reading_log` never floods the join.
  Stream<List<RecentSurahRead>> watchRecentSurahs({int limit = 10}) {
    final recent = _user.select(_user.readingLog)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(200);
    return recent.watch().asyncMap((entries) async {
      if (entries.isEmpty) return <RecentSurahRead>[];

      final ayahs = await _ayahs.getAyahsByIds(
          entries.map((e) => e.ayahId).toSet().toList());
      final ayahById = {for (final a in ayahs) a.id: a};

      // Group log entries by surah (skip rows whose ayah is unknown).
      final bySurah = <int, List<ReadingLogEntry>>{};
      for (final e in entries) {
        final ayah = ayahById[e.ayahId];
        if (ayah == null) continue;
        bySurah.putIfAbsent(ayah.surahId, () => []).add(e);
      }
      if (bySurah.isEmpty) return <RecentSurahRead>[];

      final surahs = await _surahs.getSurahsByIds(bySurah.keys.toList());
      final surahById = {for (final s in surahs) s.id: s};

      final out = <RecentSurahRead>[];
      for (final entry in bySurah.entries) {
        final surah = surahById[entry.key];
        if (surah == null) continue;
        final log = entry.value;
        log.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        final last = log.last;
        out.add(RecentSurahRead(
          surah: surah,
          readAyahCount: log.map((e) => e.ayahId).toSet().length,
          totalAyahCount: surah.ayahCount,
          lastAyahId: last.ayahId,
          lastReadAt: last.createdAt,
        ));
      }

      out.sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));
      return out.take(limit).toList();
    });
  }

  /// Ayah-read counts per local-midnight epoch day for the last [days] days
  /// (including zero-count days), oldest first — ready for a calendar heatmap.
  Future<List<({int epochDay, int count})>> getDailyActivity(
      {int days = 30}) async {
    final now = DateTime.now();
    final today =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/
            86400000;
    final startDay = today - days + 1;

    final rows = await (_user.select(_user.readingLog)
          ..where((t) => t.epochDay.isBiggerOrEqualValue(startDay)))
        .get();

    final counts = <int, int>{};
    for (final r in rows) {
      counts[r.epochDay] = (counts[r.epochDay] ?? 0) + 1;
    }

    return [
      for (var d = startDay; d <= today; d++)
        (epochDay: d, count: counts[d] ?? 0),
    ];
  }
}