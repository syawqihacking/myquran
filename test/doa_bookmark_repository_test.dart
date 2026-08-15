import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myquran/data/db/user_database.dart';
import 'package:myquran/data/models/doa_harian_data.dart';
import 'package:myquran/data/repositories/user_repositories.dart';
import 'package:path/path.dart' as p;

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
        await Directory.systemTemp.createTemp('myquran_doa_bookmark_$name');
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

  group('DoaBookmarkRepository', () {
    test('toggleBookmark adds then removes the same doa', () async {
      await withDb('doa_toggle', (db) async {
        final repo = DoaBookmarkRepository(db);
        final id = doaHarianItems.first.id;

        expect(await repo.isBookmarked(id), isFalse);

        await repo.toggleBookmark(id);
        expect(await repo.isBookmarked(id), isTrue);
        expect(await db.doaBookmarks.count().getSingle(), 1);

        await repo.toggleBookmark(id);
        expect(await repo.isBookmarked(id), isFalse);
        expect(await db.doaBookmarks.count().getSingle(), 0);
      });
    });

    test('toggleBookmark stores distinct rows per doa', () async {
      await withDb('doa_distinct', (db) async {
        final repo = DoaBookmarkRepository(db);
        final a = doaHarianItems[0].id;
        final b = doaHarianItems[1].id;

        await repo.toggleBookmark(a);
        await repo.toggleBookmark(b);
        expect(await db.doaBookmarks.count().getSingle(), 2);

        await repo.toggleBookmark(a);
        expect(await db.doaBookmarks.count().getSingle(), 1);
        expect(await repo.isBookmarked(b), isTrue);
      });
    });

    test('watchBookmarkedIds emits the initial set, then updates', () async {
      await withDb('doa_watch', (db) async {
        final repo = DoaBookmarkRepository(db);
        final a = doaHarianItems[0].id;
        final b = doaHarianItems[1].id;

        final events = <Set<String>>[];
        final sub = repo.watchBookmarkedIds().listen(events.add);
        await _flushStreams();
        // Initial emission reflects the empty table.
        expect(events, hasLength(1));
        expect(events.first, isEmpty);

        await repo.toggleBookmark(a);
        await _flushStreams();
        expect(events.last, {a});

        await repo.toggleBookmark(b);
        await _flushStreams();
        expect(events.last, {a, b});

        await repo.toggleBookmark(a);
        await _flushStreams();
        expect(events.last, {b});

        await sub.cancel();
      });
    });

    test('isBookmarked is false for an unknown doa id', () async {
      await withDb('doa_unknown', (db) async {
        final repo = DoaBookmarkRepository(db);
        expect(await repo.isBookmarked('doa-tidak-ada'), isFalse);
      });
    });
  });

  group('DoaHarian data integrity', () {
    test('every doa has a unique id, Arabic text and translation', () {
      final ids = doaHarianItems.map((d) => d.id).toSet();
      expect(ids.length, doaHarianItems.length,
          reason: 'doa ids must be unique');
      for (final d in doaHarianItems) {
        expect(d.title, isNotEmpty);
        expect(d.arabic, isNotEmpty, reason: '${d.id}: Arabic text missing');
        expect(d.translation, isNotEmpty,
            reason: '${d.id}: translation missing');
        expect(doaCategories, contains(d.category),
            reason: '${d.id}: unknown category');
      }
    });

    test('default category matches the first entry', () {
      expect(doaCategories, isNotEmpty);
      expect(doaCategories.first, 'Populer');
    });
  });
}