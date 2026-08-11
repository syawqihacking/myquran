import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myquran/data/db/user_database.dart';
import 'package:myquran/data/repositories/reading_stats_repository.dart';
import 'package:path/path.dart' as p;

/// Local-midnight epoch day, mirroring ReadingStatsRepository.recordRead.
int _epochDay(DateTime d) =>
    DateTime(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 86400000;

/// Seeds a reading_log row for a specific day (bypassing the repo so tests can
/// control dates).
Future<void> _seed(
  UserDatabase db, {
  required int epochDay,
  required int ayahId,
  required int juz,
}) async {
  await db.into(db.readingLog).insert(
        ReadingLogCompanion.insert(
          epochDay: epochDay,
          juz: juz,
          ayahId: ayahId,
          createdAt: epochDay * 86400,
        ),
      );
}

void main() {
  Future<({UserDatabase db, Directory dir})> openDb(String name) async {
    final dir =
        await Directory.systemTemp.createTemp('myquran_reading_stats_$name');
    final db = UserDatabase(executor: NativeDatabase(File(p.join(dir.path, 'user.db'))));
    return (db: db, dir: dir);
  }

  Future<void> withDb(String name, Future<void> Function(UserDatabase) fn) async {
    final opened = await openDb(name);
    try {
      await fn(opened.db);
    } finally {
      await opened.db.close();
      await opened.dir.delete(recursive: true);
    }
  }

  final today = _epochDay(DateTime.now());
  final yesterday = today - 1;
  final twoDaysAgo = today - 2;
  final threeDaysAgo = today - 3;
  final fourDaysAgo = today - 4;

  test('recordRead dedupes same ayah within the same day', () async {
    await withDb('dedupe', (db) async {
      final repo = ReadingStatsRepository(db);
      await repo.recordRead(ayahId: 1, juz: 1);
      await repo.recordRead(ayahId: 1, juz: 1);

      var stats = await repo.getStats();
      expect(stats.todayAyahs, 1);
      expect(stats.totalAyahs, 1);

      await repo.recordRead(ayahId: 2, juz: 1);
      stats = await repo.getStats();
      expect(stats.todayAyahs, 2);
      expect(stats.totalAyahs, 2);
    });
  });

  test('streak counts consecutive days ending today', () async {
    await withDb('streak_full', (db) async {
      await _seed(db, epochDay: today, ayahId: 1, juz: 1);
      await _seed(db, epochDay: yesterday, ayahId: 2, juz: 1);
      await _seed(db, epochDay: twoDaysAgo, ayahId: 3, juz: 1);

      final stats = await ReadingStatsRepository(db).getStats();
      expect(stats.streakDays, 3);
    });
  });

  test('streak stops at a gap', () async {
    await withDb('streak_gap', (db) async {
      await _seed(db, epochDay: today, ayahId: 1, juz: 1);
      await _seed(db, epochDay: yesterday, ayahId: 2, juz: 1);
      await _seed(db, epochDay: fourDaysAgo, ayahId: 3, juz: 1);

      final stats = await ReadingStatsRepository(db).getStats();
      expect(stats.streakDays, 2);
    });
  });

  test('streak starts from yesterday when today has no rows', () async {
    await withDb('streak_from_yesterday', (db) async {
      await _seed(db, epochDay: yesterday, ayahId: 1, juz: 1);
      await _seed(db, epochDay: twoDaysAgo, ayahId: 2, juz: 1);
      await _seed(db, epochDay: threeDaysAgo, ayahId: 3, juz: 1);

      final stats = await ReadingStatsRepository(db).getStats();
      expect(stats.streakDays, 3);
    });
  });

  test('streak is zero when there are no consecutive rows', () async {
    await withDb('streak_zero', (db) async {
      await _seed(db, epochDay: threeDaysAgo, ayahId: 1, juz: 1);

      final stats = await ReadingStatsRepository(db).getStats();
      expect(stats.streakDays, 0);
    });
  });

  test('juzsRead counts distinct juz only', () async {
    await withDb('juz', (db) async {
      await _seed(db, epochDay: today, ayahId: 1, juz: 1);
      await _seed(db, epochDay: today, ayahId: 2, juz: 1);
      await _seed(db, epochDay: today, ayahId: 3, juz: 2);

      final stats = await ReadingStatsRepository(db).getStats();
      expect(stats.juzsRead, 2);
    });
  });

  test('totals across days and today count are sane', () async {
    await withDb('totals', (db) async {
      await _seed(db, epochDay: today, ayahId: 1, juz: 1);
      await _seed(db, epochDay: today, ayahId: 2, juz: 1);
      await _seed(db, epochDay: yesterday, ayahId: 3, juz: 2);
      await _seed(db, epochDay: yesterday, ayahId: 4, juz: 2);
      await _seed(db, epochDay: twoDaysAgo, ayahId: 5, juz: 3);

      final stats = await ReadingStatsRepository(db).getStats();
      expect(stats.todayAyahs, 2);
      expect(stats.totalAyahs, 5);
      expect(stats.totalDays, 3);
      expect(stats.streakDays, 3);
    });
  });
}
