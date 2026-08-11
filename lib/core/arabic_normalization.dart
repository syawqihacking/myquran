/// Arabic normalization for search.
///
/// MUST match the Python seed (`tool/build_db.py`, function `normalize`) byte
/// for byte — the same rules and test vectors. See `test/arabic_normalization_test.dart`.
library;

// NOTE: the Python seed runs `unicodedata.normalize("NFC", ...)` before folding.
// NFC is a no-op on this corpus (the Arabic block has no canonical composition
// pairs in U+0600..U+06FF), so folding rules alone give byte-identical output
// to the seeded index. If the source ever gains non-canonical sequences, both
// sides must add NFC again.

const Map<String, String> _arabicFolds = {
  '\u0623': '\u0627', // أ -> ا
  '\u0625': '\u0627', // إ -> ا
  '\u0622': '\u0627', // آ -> ا
  '\u0671': '\u0627', // ٱ (alef wasla) -> ا
  '\u0624': '\u0627', // ؤ -> ا
  '\u0649': '\u064A', // ى -> ي
  '\u0629': '\u0647', // ة -> ه
};

/// Combining marks (Unicode category Mn/Me) that occur in Quranic Arabic
/// beyond the ranges already stripped wholesale. Dart has no Unicode
/// category API, so the union of the relevant ranges is used.
bool _isCombiningMark(int cp) {
  if (cp >= 0x064B && cp <= 0x065F) return true; // Arabic harakat etc.
  if (cp >= 0x08D3 && cp <= 0x08E2) return true; // extended Arabic marks
  if (cp >= 0x0300 && cp <= 0x036F) return true; // defensive, general marks
  return false;
}

/// Normalized Arabic search key (design spec §6; mirrors the Python seed).
String normalizeArabic(String input) {
  final out = StringBuffer();
  var skipAyaDigits = false; // U+06DD followed by Arabic-Indic digits
  var afterTatweel = false; // U+0640 directly precedes a dagger alef U+0670

  for (final rune in input.runes) {
    final cp = rune;
    // 3. tatweel is always dropped; "ـٰ" (tatweel + dagger) is dropped
    // entirely, whereas a bare dagger alef folds to a full alef.
    if (cp == 0x0640) {
      afterTatweel = true;
      continue;
    }
    if (cp == 0x0670) {
      if (afterTatweel) {
        afterTatweel = false;
        continue;
      }
      out.write('\u0627');
      continue;
    }
    final folded = _arabicFolds[String.fromCharCode(cp)];
    if (folded != null) {
      afterTatweel = false;
      out.write(folded);
      continue;
    }
    // 3. Quranic annotation signs (incl. U+06E5/U+06E6).
    if ((cp >= 0x06D6 && cp <= 0x06ED) || (cp >= 0x08F0 && cp <= 0x08FF)) {
      continue;
    }
    // 3. U+06DD END OF AYAH + immediately-following Arabic-Indic digits.
    if (cp == 0x06DD) {
      skipAyaDigits = true;
      continue;
    }
    if (skipAyaDigits) {
      if (cp >= 0x0660 && cp <= 0x0669) continue;
      skipAyaDigits = false;
    }
    // 2. combining marks.
    if (_isCombiningMark(cp)) continue;
    // 4. format chars to drop / replace.
    if (cp == 0x061C || (cp >= 0x200C && cp <= 0x200F)) continue;
    if (cp == 0x00A0 || cp == 0x200B) {
      afterTatweel = false;
      out.write(' ');
      continue;
    }
    afterTatweel = false;
    out.writeCharCode(cp);
  }

  // 6. collapse whitespace runs to one space; trim.
  return out.toString().trim().replaceAll(RegExp(r'\s+'), ' ');
}

final RegExp _ftsMetaChars = RegExp(r'["*^:(){}~\-]');

/// Builds a safe FTS5 MATCH expression from a normalized query.
///
/// Each word becomes `(search_ar : "word"* OR translation : "word"*)`;
/// words are joined with AND. Metacharacters are escaped out of the input.
String buildFtsQuery(String query) {
  final tokens = normalizeArabic(query)
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .map((t) => t.replaceAll(_ftsMetaChars, ' ').trim())
      .where((t) => t.isNotEmpty)
      .toList();
  if (tokens.isEmpty) return '';
  return tokens
      .map((t) => '(search_ar : "$t"* OR translation : "$t"*)')
      .join(' AND ');
}

/// True when the string contains Arabic script (UI hint for keyboard/highlight).
bool isArabicText(String text) {
  for (final rune in text.runes) {
    if ((rune >= 0x0600 && rune <= 0x06FF) ||
        (rune >= 0x0750 && rune <= 0x077F) ||
        (rune >= 0x08A0 && rune <= 0x08FF)) {
      return true;
    }
  }
  return false;
}
