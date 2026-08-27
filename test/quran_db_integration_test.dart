import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myquran/data/db/quran_database.dart';
import 'package:myquran/data/repositories/quran_repositories.dart';
import 'package:path/path.dart' as p;

/// Integration test against the REAL prebuilt asset (`assets/db/quran.db.gz`).
///
/// Regression guard: the bundled DB must open with the drift schema and serve
/// every repository query. This is the exact path that failed when the SQL
/// table was named `tafsir` while drift expected `tafsirs` (schema validation
/// on open made the whole app show "Gagal memuat data").
void main() {
  late Directory tmp;
  late QuranDatabase db;

  setUpAll(() async {
    tmp = await Directory.systemTemp.createTemp('myquran_db_test');
    final file = File(p.join(tmp.path, 'quran.db'));
    final assetGz = File('assets/db/quran.db.gz');
    expect(assetGz.existsSync(), isTrue, reason: 'quran.db.gz asset must exist');
    final gzBytes = await assetGz.readAsBytes();
    final dbBytes = Uint8List.fromList(gzip.decode(gzBytes));
    await file.writeAsBytes(dbBytes);
    db = QuranDatabase(executor: NativeDatabase(file));
  });

  tearDownAll(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  test('opens with the drift schema (tafsir table name regression)', () async {
    final surahs = await SurahRepository(db).watchSurahs().first;
    expect(surahs.length, 114);
    expect(surahs.first.id, 1);
    expect(surahs.first.nameLatin, 'Al-Faatiha'); // Tanzil transliteration
    expect(surahs.first.nameIndonesian, 'Pembukaan');
  });

  test('ayahs query per surah', () async {
    final ayahs = await AyahRepository(db).watchAyahs(1).first;
    expect(ayahs.length, 7);
    expect(ayahs.first.ayahNumber, 1);
  });

  test('tafsir is readable (table exists with matching columns)', () async {
    final tafsir = await AyahRepository(db).getTafsir(1);
    expect(tafsir, isNotNull);
    expect(tafsir!.textLong, isNotEmpty);
  });

  test('full-text search works against ayah_fts', () async {
    final results = await SearchRepository(db).search('الرحمن', limit: 5);
    expect(results, isNotEmpty);
    expect(results.first.ayahId, greaterThanOrEqualTo(1));
  });

  test('juz ranges are computed (ROW_NUMBER window query)', () async {
    final juzs = await AyahRepository(db).getJuzInfos();
    expect(juzs.length, 30);
    expect(juzs.first.juz, 1);
    expect(juzs.first.firstAyahId, 1);
    expect(juzs.first.firstSurahId, 1);
    expect(juzs.last.juz, 30);
    expect(juzs.last.lastSurahId, 114);
  });

  test('surah name search (Latin and Indonesian)', () async {
    final repo = SurahRepository(db);
    final latin = await repo.searchByName('Al-Faatiha');
    expect(latin.single.id, 1);
    final indo = await repo.searchByName('Pembukaan');
    expect(indo.single.id, 1);
  });

  test('search snippets never null (contentless FTS5 regression)', () async {
    final results = await SearchRepository(db).search('rasul');
    expect(results, isNotEmpty);
    for (final r in results) {
      expect(r.arabicSnippet, isNotNull);
      expect(r.translationSnippet, isNotNull);
      expect(r.arabicSnippet, isNotEmpty);
      expect(r.translationSnippet, isNotEmpty);
    }
  });
}
