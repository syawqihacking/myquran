import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myquran/core/app_constants.dart';
import 'package:myquran/data/db/user_database.dart';
import 'package:path/path.dart' as p;

/// Regression guard for the shared-`schemaVersion` bug.
///
/// When `AppConstants.schemaVersion` was shared by both drift databases, the
/// runtime `user.db` (created at user_version 1) was forced through drift's
/// schema-upgrade machinery after the quran.db asset bump (version 2). With no
/// `onUpgrade` in `UserDatabase.migration`, drift threw
/// "_defaultOnUpdate: bumped the schema version without a strategy", breaking
/// bookmarks/last-read at startup.
///
/// The version spaces are now decoupled (`quranDbSchemaVersion` vs
/// `userDbSchemaVersion`); an on-disk user.db at version 1 must reopen cleanly.
void main() {
  test('existing user.db at user_version 1 opens without migration error',
      () async {
    final dir = await Directory.systemTemp.createTemp('myquran_userdb_test');
    final file = File(p.join(dir.path, 'user.db'));
    try {
      // Fresh DB is created by drift at the current schema version.
      final db = UserDatabase(executor: NativeDatabase(file));
      await db.customStatement(
          'INSERT INTO app_meta ("key", "value") VALUES (?, ?)', ['k', 'v']);
      await db.close();

      // Simulate the pre-bump on-disk state (schema unchanged, user_version 1).
      // If userDbSchemaVersion is ever raised without an onUpgrade strategy,
      // the reopen below fails drift's "no migration strategy" check.
      final raw = UserDatabase(executor: NativeDatabase(file));
      await _downgradeTo(raw, 1);
      await raw.close();

      // Reopen: must NOT hit drift's "_defaultOnUpdate" migration error.
      final reopened = UserDatabase(executor: NativeDatabase(file));
      final rows = await reopened
          .customSelect(
            'SELECT value FROM app_meta WHERE "key" = ?',
            variables: [Variable.withString('k')],
          )
          .get();
      expect(rows.single.read<String>('value'), 'v');
      // The onUpgrade 1→2 migration must have created reading_log.
      await reopened
          .customSelect('SELECT * FROM reading_log LIMIT 1')
          .get();
      await reopened.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('fresh user.db is created at the current schema version', () async {
    final dir = await Directory.systemTemp.createTemp('myquran_userdb_test2');
    final file = File(p.join(dir.path, 'user.db'));
    try {
      final db = UserDatabase(executor: NativeDatabase(file));
      // onCreate runs `m.createAll()` — the full runtime schema must exist.
      await db.customSelect('SELECT * FROM bookmarks LIMIT 1').get();
      await db.customSelect('SELECT * FROM last_reads LIMIT 1').get();
      await db.customSelect('SELECT * FROM app_meta LIMIT 1').get();
      await db.customSelect('SELECT * FROM reading_log LIMIT 1').get();
      await db.customSelect('SELECT * FROM sajda_log LIMIT 1').get();
      await db.customSelect('SELECT * FROM khatam_targets LIMIT 1').get();
      await db.customSelect('SELECT * FROM surah_positions LIMIT 1').get();
      // onCreate must also seed the default qari list.
      final reciters = await db.select(db.reciters).get();
      expect(reciters.length, 4);
      expect(reciters.first.name, 'Mishary Rashid Alafasy');
      expect(
        reciters.first.urlTemplate,
        'https://everyayah.com/data/Alafasy_128kbps/{SSS}{AAA}.mp3',
      );
      await db.close();
      expect(_readUserVersion(file), AppConstants.userDbSchemaVersion);
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('user.db at user_version 2 migrates to v3 (new tables, columns, seed)',
      () async {
    final dir = await Directory.systemTemp.createTemp('myquran_userdb_v3');
    final file = File(p.join(dir.path, 'user.db'));
    try {
      // Build a fresh v3 DB, then downgrade it to the v2 on-disk shape so the
      // reopen below exercises the real v2→v3 onUpgrade path.
      final fresh = UserDatabase(executor: NativeDatabase(file));
      await fresh.close();

      final raw = UserDatabase(executor: NativeDatabase(file));
      await _downgradeTo(raw, 2);
      await raw.close();

      // Reopen: drift must run the v2→v3 migration.
      final db = UserDatabase(executor: NativeDatabase(file));
      // New tables exist.
      await db.customSelect('SELECT * FROM sajda_log LIMIT 1').get();
      await db.customSelect('SELECT * FROM khatam_targets LIMIT 1').get();
      await db.customSelect('SELECT * FROM surah_positions LIMIT 1').get();
      // New columns exist.
      await db.customSelect('SELECT url_template FROM reciters LIMIT 1').get();
      await db
          .customSelect('SELECT last_accessed_at FROM ayah_audio LIMIT 1')
          .get();
      // Migration re-seeds the 4 qari with verified templates.
      final reciters = await db.select(db.reciters).get();
      expect(reciters.length, 4);
      final byId = {for (final r in reciters) r.id: r};
      expect(byId[1]!.name, 'Mishary Rashid Alafasy');
      expect(byId[1]!.urlTemplate,
          'https://everyayah.com/data/Alafasy_128kbps/{SSS}{AAA}.mp3');
      expect(byId[2]!.name, 'Abdul Basit');
      expect(byId[2]!.urlTemplate,
          'https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/{SSS}{AAA}.mp3');
      expect(byId[3]!.name, 'Al-Husary');
      expect(byId[3]!.urlTemplate,
          'https://everyayah.com/data/Husary_128kbps/{SSS}{AAA}.mp3');
      expect(byId[4]!.name, 'Abdurrahmaan As-Sudais');
      expect(byId[4]!.urlTemplate,
          'https://everyayah.com/data/Abdurrahmaan_As-Sudais_192kbps/{SSS}{AAA}.mp3');
      await db.close();
      expect(_readUserVersion(file), AppConstants.userDbSchemaVersion);
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('resetAll clears user data but keeps app-managed rows', () async {
    final dir = await Directory.systemTemp.createTemp('myquran_userdb_reset');
    final file = File(p.join(dir.path, 'user.db'));
    try {
      final db = UserDatabase(executor: NativeDatabase(file));

      // Seed one row in every user-generated table.
      await db.into(db.bookmarks).insert(
          BookmarksCompanion.insert(ayahId: 1, createdAt: 1));
      await db.into(db.lastReads).insert(
          LastRead(id: 0, ayahId: 1, updatedAt: 1));
      await db.into(db.readingLog).insert(ReadingLogCompanion.insert(
          epochDay: 1, juz: 1, ayahId: 1, createdAt: 1));
      await db.into(db.sajdaLog).insert(
          SajdaLogCompanion.insert(ayahId: 1, createdAt: 1));
      await db.into(db.khatamTargets).insert(
          KhatamTarget(id: 0, targetDate: null, startDate: 1, createdAt: 1));
      await db.into(db.surahPositions).insert(
          SurahPosition(surahId: 1, ayahId: 1, updatedAt: 1));
      await db.into(db.ayahAudio).insert(AyahAudioCompanion.insert(
          ayahId: 1, reciterId: 1, filePathOrUrl: 'file:///tmp/a.mp3'));
      await db.customStatement(
          'INSERT INTO app_meta ("key", "value") VALUES (?, ?)', ['k', 'v']);

      await db.resetAll();

      // All user-generated tables are empty.
      expect(await db.bookmarks.count().getSingle(), 0);
      expect(await db.lastReads.count().getSingle(), 0);
      expect(await db.readingLog.count().getSingle(), 0);
      expect(await db.sajdaLog.count().getSingle(), 0);
      expect(await db.khatamTargets.count().getSingle(), 0);
      expect(await db.surahPositions.count().getSingle(), 0);
      expect(await db.ayahAudio.count().getSingle(), 0);

      // App-managed rows survive: seeded qari list and app_meta.
      expect(await db.reciters.count().getSingle(), 4);
      final meta = await db
          .customSelect(
            'SELECT value FROM app_meta WHERE "key" = ?',
            variables: [Variable.withString('k')],
          )
          .get();
      expect(meta.single.read<String>('value'), 'v');

      await db.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });
}

/// Reads the SQLite header user_version (bytes 60-63, big-endian) — the same
/// mechanism `QuranDatabase._readUserVersion` uses for its asset gate.
int _readUserVersion(File file) {
  final raf = file.openSync(mode: FileMode.read);
  try {
    raf.setPositionSync(60);
    final buf = raf.readSync(4);
    if (buf.length < 4) return 0;
    return (buf[0] << 24) | (buf[1] << 16) | (buf[2] << 8) | buf[3];
  } finally {
    raf.closeSync();
  }
}

/// Downgrades a freshly-created (v3) user.db to the on-disk shape of an older
/// schema version, so reopening exercises the real `onUpgrade` path instead of
/// re-running `onCreate` against an already-v3 schema.
Future<void> _downgradeTo(UserDatabase raw, int version) async {
  // v3-only tables.
  await raw.customStatement('DROP TABLE IF EXISTS sajda_log');
  await raw.customStatement('DROP TABLE IF EXISTS khatam_targets');
  await raw.customStatement('DROP TABLE IF EXISTS surah_positions');
  // v3-only columns.
  await raw.customStatement('ALTER TABLE reciters DROP COLUMN url_template');
  await raw.customStatement(
      'ALTER TABLE ayah_audio DROP COLUMN last_accessed_at');
  // v2-only table (absent in v1).
  if (version < 2) {
    await raw.customStatement('DROP TABLE IF EXISTS reading_log');
  }
  // No reciter seed existed before v3 — clear rows so the migration must
  // re-seed them.
  await raw.customStatement('DELETE FROM reciters');
  await raw.customStatement('PRAGMA user_version = $version');
}