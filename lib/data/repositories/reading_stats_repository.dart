import 'package:drift/drift.dart';

import '../db/user_database.dart';

class ReadingStats {
  final int todayAyahs;
  final int totalAyahs;
  final int totalDays;
  final int streakDays;
  final int juzsRead; // 0..30 — distinct juz the user has touched
  const ReadingStats({
    required this.todayAyahs,
    required this.totalAyahs,
    required this.totalDays,
    required this.streakDays,
    required this.juzsRead,
  });
}

class ReadingStatsRepository {
  ReadingStatsRepository(this._db);
  final UserDatabase _db;

  /// Logs a read of [ayahId] (which lives in [juz]) today.
  /// Unique (epochDay, ayahId): re-reading the same ayah the same day records
  /// only one row. `insertOrIgnore` dedupes atomically — no check-then-insert
  /// race, so two concurrent calls for the same ayah can't throw.
  Future<void> recordRead({required int ayahId, required int juz}) async {
    final now = DateTime.now();
    final epochDay =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/
            86400000;
    await _db.into(_db.readingLog).insert(
          ReadingLogCompanion.insert(
            epochDay: epochDay,
            juz: juz,
            ayahId: ayahId,
            createdAt: now.millisecondsSinceEpoch ~/ 1000,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Aggregated stats. Counts run in SQL (`COUNT(*)` / `COUNT(DISTINCT …)`);
  /// only the distinct epoch-day list is fetched for the streak walk — never
  /// the full table.
  Future<ReadingStats> getStats() async {
    final now = DateTime.now();
    final today =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/
            86400000;

    final todayAyahs = await (_db.selectOnly(_db.readingLog)
          ..addColumns([countAll()])
          ..where(_db.readingLog.epochDay.equals(today)))
        .map((r) => r.read(countAll())!)
        .getSingle();

    final totals = await (_db.selectOnly(_db.readingLog)
          ..addColumns([
            countAll(),
            _db.readingLog.epochDay.count(distinct: true),
            _db.readingLog.juz.count(distinct: true),
          ]))
        .map((r) => (
              totalAyahs: r.read(countAll())!,
              totalDays:
                  r.read(_db.readingLog.epochDay.count(distinct: true))!,
              juzsRead: r.read(_db.readingLog.juz.count(distinct: true))!,
            ))
        .getSingle();

    final epochDays = (await _db.customSelect(
      'SELECT DISTINCT epoch_day FROM reading_log ORDER BY epoch_day DESC',
    ).get())
        .map((r) => r.read<int>('epoch_day'))
        .toSet();

    return ReadingStats(
      todayAyahs: todayAyahs,
      totalAyahs: totals.totalAyahs,
      totalDays: totals.totalDays,
      streakDays: _streakDays(epochDays, today),
      juzsRead: totals.juzsRead,
    );
  }

  /// Emits stats immediately, then re-emits whenever `reading_log` changes.
  /// Uses `tableUpdates` (a change signal, not a row fetch) so watching never
  /// materializes the table; `getStats` only reads, so there is no write loop.
  Stream<ReadingStats> watchStats() async* {
    yield await getStats();
    yield* _db
        .tableUpdates(TableUpdateQuery.onTable(_db.readingLog))
        .asyncMap((_) => getStats());
  }

  /// Walks back from [today] (or yesterday if today has no rows) while the
  /// day is present in [days], counting the consecutive run.
  int _streakDays(Set<int> days, int today) {
    var cursor = days.contains(today) ? today : today - 1;
    var count = 0;
    while (days.contains(cursor)) {
      count++;
      cursor--;
    }
    return count;
  }
}
