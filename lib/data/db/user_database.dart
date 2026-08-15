import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/app_constants.dart';

part 'user_database.g.dart';

@DataClassName('Bookmark')
@TableIndex(name: 'idx_bookmarks_ayah', columns: {#ayahId})
class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ayahId => integer()();
  IntColumn get createdAt => integer()(); // epoch ms

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LastRead')
class LastReads extends Table {
  IntColumn get id =>
      integer().withDefault(const Constant(0)).customConstraint('CHECK (id = 0)')();
  IntColumn get ayahId => integer()();
  IntColumn get updatedAt => integer()(); // epoch ms

  @override
  Set<Column> get primaryKey => {id};
}

class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('Reciter')
class Reciters extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get style => text()();

  /// Phase-2 audio seam: URL template with `{SSS}` (surah, 3-digit) and
  /// `{AAA}` (ayah, 3-digit) placeholders, e.g. everyayah.com.
  TextColumn get urlTemplate => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Phase-2 audio seam: per-ayah files keyed by (ayah, reciter).
class AyahAudio extends Table {
  IntColumn get ayahId => integer()();
  IntColumn get reciterId => integer()();
  TextColumn get filePathOrUrl => text()();
  IntColumn get durationMs => integer().nullable()();

  /// Phase-2 audio seam: last time this file was played (epoch seconds).
  IntColumn get lastAccessedAt => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [{ayahId, reciterId}];
}

/// One row per ayah the user has already performed sujud tilawah on.
/// The unique key on [ayahId] dedupes repeated marks.
@DataClassName('SajdaLogEntry')
class SajdaLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ayahId => integer()();
  IntColumn get createdAt => integer()(); // epoch seconds

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{ayahId}];
}

/// The single active khatam target. Mirrors the `LastReads` single-row
/// pattern: `id` is pinned to 0 via CHECK, so `setTarget` is an upsert and
/// there is never more than one active row (no `active` flag needed).
@DataClassName('KhatamTarget')
class KhatamTargets extends Table {
  IntColumn get id =>
      integer().withDefault(const Constant(0)).customConstraint('CHECK (id = 0)')();
  IntColumn get targetDate => integer().nullable()(); // epoch day; null = 30-day plan
  IntColumn get startDate => integer()(); // epoch day
  IntColumn get createdAt => integer()(); // epoch seconds

  @override
  Set<Column> get primaryKey => {id};
}

/// Per-surah reading position (restore point when reopening a surah).
@DataClassName('SurahPosition')
class SurahPositions extends Table {
  IntColumn get surahId => integer()();
  IntColumn get ayahId => integer()();
  IntColumn get updatedAt => integer()(); // epoch ms

  @override
  Set<Column> get primaryKey => {surahId};
}

/// One row per (day, ayah) the user actually read; the unique key dedupes
/// re-reads of the same ayah within the same day.
@DataClassName('ReadingLogEntry')
class ReadingLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get epochDay => integer()(); // local-midnight epoch day
  IntColumn get juz => integer()();
  IntColumn get ayahId => integer()();
  IntColumn get createdAt => integer()(); // epoch seconds
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [{epochDay, ayahId}];
}

/// Bookmarked daily prayers (doa harian), keyed by the doa slug — a separate
/// store from ayah bookmarks so the two lists never mix.
@DataClassName('DoaBookmark')
class DoaBookmarks extends Table {
  TextColumn get doaId => text()();
  IntColumn get createdAt => integer()(); // epoch ms

  @override
  Set<Column> get primaryKey => {doaId};
}

/// Runtime-created user database (bookmarks, last-read, meta, audio seam).
@DriftDatabase(tables: [
  Bookmarks,
  LastReads,
  AppMeta,
  Reciters,
  AyahAudio,
  ReadingLog,
  SajdaLog,
  KhatamTargets,
  SurahPositions,
  DoaBookmarks,
])
class UserDatabase extends _$UserDatabase {
  /// `executor` is injectable for tests; production opens `user.db` in the
  /// app support directory.
  UserDatabase({QueryExecutor? executor}) : super(executor ?? _open());

  @override
  int get schemaVersion => AppConstants.userDbSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedReciters(this);
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(readingLog);
          if (from < 3) {
            await m.createTable(sajdaLog);
            await m.createTable(khatamTargets);
            await m.createTable(surahPositions);
            await m.addColumn(reciters, reciters.urlTemplate);
            await m.addColumn(ayahAudio, ayahAudio.lastAccessedAt);
            await _seedReciters(this);
          }
          if (from < 4) await m.createTable(doaBookmarks);
        },
      );

  /// Deletes all user-generated data in one transaction: reading log, khatam
  /// target, sujud marks, per-surah positions, bookmarks, last-read, and the
  /// audio cache. App-managed rows (`app_meta`, the seeded qari list) and the
  /// read-only `quran.db` are left untouched.
  Future<void> resetAll() async {
    await transaction(() async {
      await delete(bookmarks).go();
      await delete(lastReads).go();
      await delete(readingLog).go();
      await delete(sajdaLog).go();
      await delete(khatamTargets).go();
      await delete(surahPositions).go();
      await delete(ayahAudio).go();
      await delete(doaBookmarks).go();
    });
  }

  /// Seeds the default qari list (idempotent upsert keyed on the PK). Runs on
  /// fresh DBs (after `createAll`) and on the v2→v3 upgrade (after the
  /// `url_template` column is added).
  ///
  /// URL templates use the everyayah.com directory names (verified reachable);
  /// `{SSS}` = surah (3-digit), `{AAA}` = ayah (3-digit).
  static Future<void> _seedReciters(UserDatabase db) async {
    await db.batch((b) {
      b.insertAllOnConflictUpdate(db.reciters, [
        RecitersCompanion.insert(
          id: const Value(1),
          name: 'Mishary Rashid Alafasy',
          style: 'Murattal',
          urlTemplate: const Value(
              'https://everyayah.com/data/Alafasy_128kbps/{SSS}{AAA}.mp3'),
        ),
        RecitersCompanion.insert(
          id: const Value(2),
          name: 'Abdul Basit',
          style: 'Murattal',
          urlTemplate: const Value(
              'https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/{SSS}{AAA}.mp3'),
        ),
        RecitersCompanion.insert(
          id: const Value(3),
          name: 'Al-Husary',
          style: 'Murattal',
          urlTemplate: const Value(
              'https://everyayah.com/data/Husary_128kbps/{SSS}{AAA}.mp3'),
        ),
        RecitersCompanion.insert(
          id: const Value(4),
          name: 'Abdurrahmaan As-Sudais',
          style: 'Murattal',
          urlTemplate: const Value(
              'https://everyayah.com/data/Abdurrahmaan_As-Sudais_192kbps/{SSS}{AAA}.mp3'),
        ),
      ]);
    });
  }

  static QueryExecutor _open() {
    return LazyDatabase(() async {
      final dir = Directory(p.join(
          (await getApplicationSupportDirectory()).path, AppConstants.dbSubDir));
      await dir.create(recursive: true);
      final file = File(p.join(dir.path, AppConstants.userDbFile));
      return NativeDatabase.createInBackground(
        file,
        setup: (db) => db.execute('PRAGMA journal_mode = WAL'),
      );
    });
  }
}
