import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myquran/core/tajwid.dart';
import 'package:myquran/data/db/quran_database.dart';
import 'package:myquran/data/repositories/quran_repositories.dart';
import 'package:path/path.dart' as p;

/// Golden + corpus tests for the tajwid decoder.
///
/// The decoder reads the tajwid annotation marks already embedded in the
/// Uthmani text (seed downloaded with `marks=true`), so these tests run against
/// the REAL bundled `assets/db/quran.db` to prove the decoder is not dead code
/// and produces well-formed, correctly-attached ranges.
void main() {
  late Directory tmp;
  late QuranDatabase db;

  setUpAll(() async {
    tmp = await Directory.systemTemp.createTemp('myquran_tajwid_test');
    final file = File(p.join(tmp.path, 'quran.db'));
    final asset = File('assets/db/quran.db');
    expect(asset.existsSync(), isTrue, reason: 'quran.db asset must exist');
    await file.writeAsBytes(await asset.readAsBytes());
    db = QuranDatabase(executor: NativeDatabase(file));
  });

  tearDownAll(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  group('decodeTajwid golden vectors', () {
    test('S2:19 exercises mad, ghunnah and qalqalah', () async {
      final ayah = (await AyahRepository(db).watchAyahs(2).first)[18];
      final ranges = decodeTajwid(ayah.textUthmani);
      expect(
        ranges.map((r) => '${r.rule.name}:${r.start}-${r.end}').toList(),
        ['mad:9-12', 'ghunnah:15-18', 'qalqalah:70-72', 'ghunnah:112-115'],
      );
      // The colored substrings are the actual letters + their diacritics.
      expect(ayah.textUthmani.substring(9, 12), 'يِّ'); // mad (kasra+ya)
      expect(ayah.textUthmani.substring(15, 18), 'مِّ'); // ghunnah (mim+shadda)
      expect(ayah.textUthmani.substring(70, 72), 'جْ'); // qalqalah (jim+sukun)
    });

    test('S112:3 qalqalah attaches to the letter, not a space', () async {
      final ayah = (await AyahRepository(db).watchAyahs(112).first)[2];
      final ranges = decodeTajwid(ayah.textUthmani);
      expect(ranges.map((r) => r.rule).toList(), [
        TajwidRule.qalqalah,
        TajwidRule.qalqalah,
      ]);
      // Both ranges must be real qalqalah letters (dal+sukun), never a space
      // or the end-of-ayah marker.
      for (final r in ranges) {
        final sub = ayah.textUthmani.substring(r.start, r.end);
        expect(sub, 'دْ', reason: 'qalqalah must color the letter, got "$sub"');
      }
    });

    test('plain text with no marks yields no ranges', () {
      expect(decodeTajwid('بِسْمِ'), isEmpty);
      expect(decodeTajwid(''), isEmpty);
    });
  });

  group('decodeTajwid over the full corpus', () {
    test('every rule fires and all ranges are well-formed', () async {
      final repo = AyahRepository(db);
      var mad = 0, ghunnah = 0, qalqalah = 0;
      var ayahsWithAny = 0;
      var totalAyahs = 0;
      var malformed = 0;

      for (var surah = 1; surah <= 114; surah++) {
        final ayahs = await repo.watchAyahs(surah).first;
        for (final a in ayahs) {
          totalAyahs++;
          final ranges = decodeTajwid(a.textUthmani);
          for (final r in ranges) {
            if (r.start < 0 ||
                r.end > a.textUthmani.length ||
                r.start >= r.end) {
              malformed++;
            }
            switch (r.rule) {
              case TajwidRule.mad:
                mad++;
              case TajwidRule.ghunnah:
                ghunnah++;
              case TajwidRule.qalqalah:
                qalqalah++;
            }
          }
          if (ranges.isNotEmpty) ayahsWithAny++;
        }
      }

      expect(totalAyahs, 6236);
      expect(malformed, 0, reason: 'no malformed ranges');
      expect(mad, greaterThan(0), reason: 'mad rule must fire on the corpus');
      expect(ghunnah, greaterThan(0),
          reason: 'ghunnah rule must fire on the corpus');
      expect(qalqalah, greaterThan(0),
          reason: 'qalqalah rule must fire on the corpus');
      expect(ayahsWithAny, greaterThan(4000),
          reason: 'most ayahs should have at least one colored range');
    });
  });
}
