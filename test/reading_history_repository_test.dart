import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myquran/data/db/quran_database.dart';
import 'package:myquran/data/db/user_database.dart';
import 'package:myquran/data/repositories/reading_history_repository.dart';
import 'package:path/path.dart' as p;

/// Local-midnight epoch day, mirroring ReadingHistoryRepository.getDailyActivity.
int _epochDay(DateTime d) =>
    DateTime(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 86400000;

/// Seeds a reading_log row directly (bypassing the repos) so tests control
/// epochDay and createdAt. Uses real ayah ids from the bundled quran.db so the
/// cross-DB join in watchRecentSurahs resolves.
Future<void> _seedRead(
  UserDatabase db, {
  required int epochDay,
  required int ayahId,
  required int juz,
  required int createdAt,
}) async {
  await db.into(db.readingLog).insert(
        ReadingLogCompanion.insert(
          epochDay: epochDay,
          juz: juz,
          ayahId: ayahId,
          createdAt: createdAt,
        ),
      );
}

void main() {
  Future<({UserDatabase user, QuranDatabase quran, Directory dir})>
      openDbs(String name) async {
    final dir = await Directory.systemTemp.createTemp('myquran_history_$name');
    final user =
        UserDatabase(executor: NativeDatabase(File(p.join(dir.path, 'user.db'))));
    final asset = File('assets/db/quran.db');
    expect(asset.existsSync(), isTrue, reason: 'quran.db asset must exist');
    final quranFile = File(p.join(dir.path, 'quran.db'));
    await quranFile.writeAsBytes(await asset.readAsBytes());
    final quran = QuranDatabase(executor: NativeDatabase(quranFile));
    return (user: user, quran: quran, dir: dir);
  }

  Future<void> withDbs(
    String name,
    Future<void> Function(UserDatabase user, QuranDatabase quran) fn,
  ) async {
    final opened = await openDbs(name);
    try {
      await fn(opened.user, opened.quran);
    } finally {
      await opened.user.close();
      await opened.quran.close();
      await opened.dir.delete(recursive: true);
    }
  }

  final today = _epochDay(DateTime.now());

  group('watchRecentSurahs', () {
    test('groups by surah, computes progress, most recent first', () async {
      await withDbs('recent_group', (user, quran) async {
        // Real ids from the bundled quran.db: surah 1 = ayahs 1-7,
        // surah 2 = ayahs 8-293.
        await _seedRead(user, epochDay: today, ayahId: 1, juz: 1, createdAt: 100);
        await _seedRead(user, epochDay: today, ayahId: 2, juz: 1, createdAt: 200);
        await _seedRead(user, epochDay: today, ayahId: 8, juz: 1, createdAt: 300);

        final repo = ReadingHistoryRepository(user, quran);
        final list = await repo.watchRecentSurahs().first;
        expect(list, hasLength(2));

        // Surah 2 read last -> listed first.
        expect(list[0].surah.id, 2);
        expect(list[0].readAyahCount, 1);
        expect(list[0].totalAyahCount, 286);
        expect(list[0].lastAyahId, 8);
        expect(list[0].lastReadAt, 300);
        expect(list[0].progress, closeTo(1 / 286, 1e-12));

        expect(list[1].surah.id, 1);
        expect(list[1].readAyahCount, 2);
        expect(list[1].totalAyahCount, 7);
        expect(list[1].lastAyahId, 2);
        expect(list[1].lastReadAt, 200);
        expect(list[1].progress, closeTo(2 / 7, 1e-12));
      });
    });

    test('counts distinct ayahs across multiple days within a surah', () async {
      await withDbs('recent_distinct', (user, quran) async {
        // Same ayah 1 read on two different days (allowed by the
        // (epochDay, ayahId) unique key) must not double-count.
        await _seedRead(user, epochDay: today, ayahId: 1, juz: 1, createdAt: 100);
        await _seedRead(
            user, epochDay: today - 1, ayahId: 1, juz: 1, createdAt: 200);
        await _seedRead(
            user, epochDay: today - 1, ayahId: 3, juz: 1, createdAt: 300);

        final repo = ReadingHistoryRepository(user, quran);
        final list = await repo.watchRecentSurahs().first;
        expect(list, hasLength(1));
        expect(list[0].surah.id, 1);
        expect(list[0].readAyahCount, 2); // ayahs {1, 3}, ayah 1 not doubled
        expect(list[0].lastAyahId, 3);
        expect(list[0].lastReadAt, 300);
      });
    });

    test('skips log rows whose ayah is not in quran.db', () async {
      await withDbs('recent_skip', (user, quran) async {
        await _seedRead(user, epochDay: today, ayahId: 1, juz: 1, createdAt: 100);
        await _seedRead(
            user, epochDay: today, ayahId: 999999, juz: 1, createdAt: 200);

        final repo = ReadingHistoryRepository(user, quran);
        final list = await repo.watchRecentSurahs().first;
        expect(list, hasLength(1));
        expect(list[0].surah.id, 1);
        expect(list[0].lastAyahId, 1);
      });
    });

    test('applies the limit, keeping the most recently read surahs', () async {
      await withDbs('recent_limit', (user, quran) async {
        // Surah 3 starts at ayah 294.
        await _seedRead(user, epochDay: today, ayahId: 1, juz: 1, createdAt: 100);
        await _seedRead(user, epochDay: today, ayahId: 8, juz: 1, createdAt: 200);
        await _seedRead(user, epochDay: today, ayahId: 294, juz: 2, createdAt: 300);

        final repo = ReadingHistoryRepository(user, quran);
        final list = await repo.watchRecentSurahs(limit: 2).first;
        expect(list, hasLength(2));
        expect(list[0].surah.id, 3);
        expect(list[1].surah.id, 2);
      });
    });

    test('returns an empty list when nothing has been read', () async {
      await withDbs('recent_empty', (user, quran) async {
        final repo = ReadingHistoryRepository(user, quran);
        final list = await repo.watchRecentSurahs().first;
        expect(list, isEmpty);
      });
    });
  });

  group('getDailyActivity', () {
    test('counts reads per day over the 30-day window, oldest first',
        () async {
      await withDbs('activity_counts', (user, quran) async {
        await _seedRead(user, epochDay: today, ayahId: 1, juz: 1, createdAt: 100);
        await _seedRead(user, epochDay: today, ayahId: 2, juz: 1, createdAt: 101);
        await _seedRead(
            user, epochDay: today - 2, ayahId: 3, juz: 1, createdAt: 102);
        await _seedRead(
            user, epochDay: today - 5, ayahId: 4, juz: 1, createdAt: 103);
        await _seedRead(
            user, epochDay: today - 5, ayahId: 5, juz: 1, createdAt: 104);

        final repo = ReadingHistoryRepository(user, quran);
        final days = await repo.getDailyActivity(days: 30);
        expect(days, hasLength(30));
        // Oldest first, anchored on the current local-midnight day.
        expect(days.first.epochDay, today - 29);
        expect(days.last.epochDay, today);
        // Days with activity carry the right counts.
        expect(days[29].count, 2);
        expect(days[27].count, 1);
        expect(days[24].count, 2);
        // Zero-count days stay in the list with count 0 (full-window heatmap).
        expect(days[28].count, 0);
        expect(days[0].count, 0);
        // Every returned entry is in ascending day order.
        for (var i = 1; i < days.length; i++) {
          expect(days[i].epochDay, days[i - 1].epochDay + 1);
        }
      });
    });

    test('excludes reads outside the requested window', () async {
      await withDbs('activity_window', (user, quran) async {
        await _seedRead(
            user, epochDay: today - 31, ayahId: 1, juz: 1, createdAt: 100);
        await _seedRead(user, epochDay: today, ayahId: 2, juz: 1, createdAt: 101);

        final repo = ReadingHistoryRepository(user, quran);
        final days = await repo.getDailyActivity(days: 30);
        expect(days, hasLength(30));
        expect(days.first.epochDay, today - 29);
        expect(days.map((d) => d.epochDay), isNot(contains(today - 31)));
        expect(days.last.count, 1);
        final total = days.fold<int>(0, (sum, d) => sum + d.count);
        expect(total, 1);
      });
    });
  });
}
