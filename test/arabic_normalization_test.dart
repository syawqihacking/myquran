import 'package:flutter_test/flutter_test.dart';
import 'package:myquran/core/arabic_normalization.dart';

/// Mirrors `tool/build_db.py` NORMALIZE_VECTORS exactly — the Dart and Python
/// sides must agree byte-for-byte, otherwise search breaks.
void main() {
  group('normalizeArabic', () {
    const vectors = <(String, String)>[
      ('بِسْمِ ٱللَّهِ', 'بسم الله'),
      ('ٱلرَّحْمَـٰنِ', 'الرحمن'),
      ('الَّذِينَ', 'الذين'),
      ('وَمَا أَدْرَاكَ', 'وما ادراك'),
      ('ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ', 'الحمد لله رب العلمين'),
      ('الرَّحِيمِ', 'الرحيم'),
      ('مَلِكِ يَوْمِ الدِّينِ', 'ملك يوم الدين'),
      ('صِرَٰطَ', 'صراط'),
    ];

    for (final (input, expected) in vectors) {
      test('"$input" -> "$expected"', () {
        expect(normalizeArabic(input), expected);
      });
    }
  });

  group('buildFtsQuery', () {
    test('joins words with AND over both columns', () {
      final q = buildFtsQuery('الرحمن الرحيم');
      expect(q, '(search_ar : "الرحمن"* OR translation : "الرحمن"*) AND '
          '(search_ar : "الرحيم"* OR translation : "الرحيم"*)');
    });

    test('returns empty for empty/whitespace input', () {
      expect(buildFtsQuery('   '), '');
      expect(buildFtsQuery(''), '');
    });

    test('escapes FTS5 metacharacters', () {
      final q = buildFtsQuery('"الرحمن":*');
      expect(q.contains('"الرحمن"*'), isTrue);
      expect(q.contains('"*"'), isFalse);
    });
  });

  group('isArabicText', () {
    test('detects Arabic script', () {
      expect(isArabicText('الرحمن'), isTrue);
      expect(isArabicText('القرآن الكريم'), isTrue);
    });

    test('rejects non-Arabic text', () {
      expect(isArabicText('rahman'), isFalse);
      expect(isArabicText('123'), isFalse);
    });
  });
}
