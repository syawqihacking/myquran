import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myquran/data/db/user_database.dart';
import 'package:myquran/data/repositories/spiritual_repository.dart';
import 'package:path/path.dart' as p;

/// Local-midnight epoch day, mirroring KhatamRepository._epochDay.
int _epochDay(DateTime d) =>
    DateTime(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 86400000;

/// Lets drift's watch-stream notifications (delivered via the DB isolate's
/// port as macrotasks) drain before asserting on stream emissions.
Future<void> _flushStreams() async {
  for (var i = 0; i < 3; i++) {
    await pumpEventQueue();
  }
}

void main() {
  Future<({UserDatabase db, Directory dir})> openDb(String name) async {
    final dir =
        await Directory.systemTemp.createTemp('myquran_spiritual_$name');
    final db =
        UserDatabase(executor: NativeDatabase(File(p.join(dir.path, 'user.db'))));
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

  group('SajdaRepository', () {
    test('markSajda makes isSajdaDone return true', () async {
      await withDb('sajda_mark', (db) async {
        final repo = SajdaRepository(db);
        expect(await repo.isSajdaDone(1), isFalse);
        await repo.markSajda(1);
        expect(await repo.isSajdaDone(1), isTrue);
      });
    });

    test('markSajda dedupes repeated marks of the same ayah (unique ayahId)',
        () async {
      await withDb('sajda_dedupe', (db) async {
        final repo = SajdaRepository(db);
        await repo.markSajda(1);
        await repo.markSajda(1);
        expect(await repo.countSajdaDone(), 1);
      });
    });

    test('unmarkSajda clears the mark', () async {
      await withDb('sajda_unmark', (db) async {
        final repo = SajdaRepository(db);
        await repo.markSajda(1);
        await repo.unmarkSajda(1);
        expect(await repo.isSajdaDone(1), isFalse);
        expect(await repo.countSajdaDone(), 0);
      });
    });

    test('countSajdaDone counts several marks and one unmark correctly',
        () async {
      await withDb('sajda_count', (db) async {
        final repo = SajdaRepository(db);
        await repo.markSajda(1);
        await repo.markSajda(2);
        await repo.markSajda(3);
        await repo.unmarkSajda(2);
        expect(await repo.countSajdaDone(), 2);
        expect(await repo.isSajdaDone(1), isTrue);
        expect(await repo.isSajdaDone(2), isFalse);
        expect(await repo.isSajdaDone(3), isTrue);
      });
    });
  });

  group('KhatamRepository', () {
    test('setTarget without targetDate stores a 30-day-plan target', () async {
      await withDb('khatam_null_date', (db) async {
        final repo = KhatamRepository(db);
        final start = DateTime(2026, 8, 11);
        await repo.setTarget(startDate: start);
        final target = await repo.getTarget();
        expect(target, isNotNull);
        expect(target!.targetDate, isNull);
        expect(target.startDate, _epochDay(start));
      });
    });

    test('setTarget with targetDate stores the concrete khatam day', () async {
      await withDb('khatam_with_date', (db) async {
        final repo = KhatamRepository(db);
        final start = DateTime(2026, 8, 11);
        final end = DateTime(2026, 9, 10);
        await repo.setTarget(startDate: start, targetDate: end);
        final target = await repo.getTarget();
        expect(target, isNotNull);
        expect(target!.targetDate, _epochDay(end));
        expect(target.startDate, _epochDay(start));
      });
    });

    test('setTarget upserts the single id=0 row without duplicating', () async {
      await withDb('khatam_upsert', (db) async {
        final repo = KhatamRepository(db);
        await repo.setTarget(startDate: DateTime(2026, 8, 11));
        await repo.setTarget(
          startDate: DateTime(2026, 8, 12),
          targetDate: DateTime(2026, 9, 20),
        );
        final target = await repo.getTarget();
        expect(target, isNotNull);
        expect(target!.startDate, _epochDay(DateTime(2026, 8, 12)));
        expect(target.targetDate, _epochDay(DateTime(2026, 9, 20)));
        expect(await db.khatamTargets.count().getSingle(), 1);
      });
    });

    test('clearTarget removes the active target', () async {
      await withDb('khatam_clear', (db) async {
        final repo = KhatamRepository(db);
        await repo.setTarget(startDate: DateTime(2026, 8, 11));
        await repo.clearTarget();
        expect(await repo.getTarget(), isNull);
        expect(await db.khatamTargets.count().getSingle(), 0);
      });
    });
  });

  group('SurahPositionRepository', () {
    test('setPosition then getPosition round-trips', () async {
      await withDb('pos_set_get', (db) async {
        final repo = SurahPositionRepository(db);
        expect(await repo.getPosition(1), isNull);
        await repo.setPosition(1, 5);
        final pos = await repo.getPosition(1);
        expect(pos, isNotNull);
        expect(pos!.ayahId, 5);
      });
    });

    test('setPosition upserts an existing surah row', () async {
      await withDb('pos_upsert', (db) async {
        final repo = SurahPositionRepository(db);
        await repo.setPosition(1, 5);
        await repo.setPosition(1, 9);
        final pos = await repo.getPosition(1);
        expect(pos, isNotNull);
        expect(pos!.ayahId, 9);
        expect(await db.surahPositions.count().getSingle(), 1);
      });
    });

    test('watchPosition emits the current row, then updates', () async {
      await withDb('pos_watch', (db) async {
        final repo = SurahPositionRepository(db);
        final events = <SurahPosition?>[];
        final sub = repo.watchPosition(1).listen(events.add);
        await _flushStreams();
        // Initial emission reflects the empty table.
        expect(events, hasLength(1));
        expect(events.first, isNull);

        await repo.setPosition(1, 5);
        await _flushStreams();
        expect(events.last?.ayahId, 5);

        await repo.setPosition(1, 9);
        await _flushStreams();
        expect(events.last?.ayahId, 9);

        await sub.cancel();
      });
    });
  });
}
