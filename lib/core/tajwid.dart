/// Tajwid (recitation rules) coloring decoder.
///
/// The Uthmani Quran text stored in the DB (`text_uthmani`) already embeds the
/// tajwid annotation marks (small high marks U+06D6–U+06ED) because the seed
/// downloads with `marks=true`. This decoder reads those marks at runtime to
/// produce colored ranges — no DB change, no schema bump.
///
/// Pure and dependency-free (no Flutter imports) so it is trivially
/// unit-testable.
library;

/// The tajwid rules this decoder recognizes (MVP scope).
enum TajwidRule { mad, ghunnah, qalqalah }

/// A contiguous colored span of the Uthmani text.
///
/// [start] and [end] are code-unit indices into the original string; the span
/// is `text.substring(start, end)` and always includes the base letter AND its
/// combining marks (harakat, shadda, sukun) as one grapheme cluster, so no
/// diacritic is ever orphaned into the wrong color.
class TajwidRange {
  const TajwidRange({
    required this.start,
    required this.end,
    required this.rule,
  });

  final int start;
  final int end;
  final TajwidRule rule;
}

// ---- Codepoints -----------------------------------------------------------

const int _fatha = 0x064E;
const int _kasra = 0x0650;
const int _damma = 0x064F;
const int _shadda = 0x0651;
const int _sukun = 0x0652;

const int _alef = 0x0627;
const int _ya = 0x064A;
const int _waw = 0x0648;
const int _nun = 0x0646;
const int _mim = 0x0645;

/// Small high qaf-lam mark (authoritative qalqalah annotation).
const int _qalqalahMark = 0x06D7;

/// Qalqalah letters: ق ط ب ج د.
const Set<int> _qalqalahLetters = {0x0642, 0x0637, 0x0628, 0x062C, 0x062F};

/// Combining marks (Mn/Me) that attach to a base letter in Quranic Arabic.
///
/// U+06DD (END OF AYAH) and U+06E9 (PLACE OF SAJDAH) live inside the
/// annotation range but are standalone glyphs, not combining marks — they must
/// never attach to a neighboring cluster (which would drag them into a colored
/// range).
bool _isCombiningMark(int cp) {
  if (cp >= 0x064B && cp <= 0x065F) return true; // harakat, shadda, sukun...
  if (cp >= 0x06D6 && cp <= 0x06ED) {
    // Quranic annotation signs; U+06DD/U+06E9 are standalone.
    if (cp == 0x06DD || cp == 0x06E9) return false;
    return true;
  }
  if (cp >= 0x08D3 && cp <= 0x08E2) return true; // extended Arabic marks
  if (cp >= 0x0300 && cp <= 0x036F) return true; // general combining marks
  return false;
}

/// A grapheme cluster: one base letter plus its attached combining marks.
class _Cluster {
  _Cluster(this.baseCp, this.start, this.end);

  final int baseCp;
  final int start;
  int end;
  final Set<int> marks = <int>{};
}

/// Decodes tajwid ranges from Uthmani text.
///
/// Iterates by grapheme cluster (base letter + combining marks), never raw
/// code units, so a colored range always includes the base letter and its
/// diacritics together. The end-of-ayah marker (U+06DD + Arabic-Indic digits)
/// and the sajda glyph (U+06E9) never match a rule and are never colored.
/// Ranges are well-formed (start < end, within bounds) and non-overlapping.
List<TajwidRange> decodeTajwid(String textUthmani) {
  final clusters = <_Cluster>[];
  _Cluster? current;

  var i = 0;
  while (i < textUthmani.length) {
    final cp = textUthmani.codeUnitAt(i);
    final unitCount = (cp >= 0xD800 && cp <= 0xDBFF) ? 2 : 1;
    if (_isCombiningMark(cp)) {
      if (current != null) {
        current.marks.add(cp);
        current.end = i + unitCount;
      }
    } else {
      current = _Cluster(cp, i, i + unitCount);
      clusters.add(current);
    }
    i += unitCount;
  }

  final ranges = <TajwidRange>[];
  for (final c in clusters) {
    final rule = _ruleFor(c);
    if (rule != null) {
      ranges.add(TajwidRange(start: c.start, end: c.end, rule: rule));
    }
  }
  return ranges;
}

TajwidRule? _ruleFor(_Cluster c) {
  // Mad thabi'i: fatha+alef, kasra+ya, damma+waw.
  if (c.baseCp == _alef && c.marks.contains(_fatha)) return TajwidRule.mad;
  if (c.baseCp == _ya && c.marks.contains(_kasra)) return TajwidRule.mad;
  if (c.baseCp == _waw && c.marks.contains(_damma)) return TajwidRule.mad;

  // Ghunnah: shadda on nun or mim.
  if ((c.baseCp == _nun || c.baseCp == _mim) && c.marks.contains(_shadda)) {
    return TajwidRule.ghunnah;
  }

  // Qalqalah: small high qaf-lam mark, or sukun on a qalqalah letter.
  //
  // The qalqalah mark (U+06D7) is a combining mark that in the Tanzil Uthmani
  // text is often positioned AFTER the following space (before the end-of-ayah
  // marker), so it attaches to a space cluster rather than the qalqalah letter.
  // Requiring the base to be a qalqalah letter prevents coloring a bare space
  // (or the end-of-ayah glyph) — the mark is only meaningful on a qalqalah
  // letter, and the sukun-on-qalqalah-letter rule below already covers the
  // letter itself.
  if (_qalqalahLetters.contains(c.baseCp) && c.marks.contains(_qalqalahMark)) {
    return TajwidRule.qalqalah;
  }
  if (_qalqalahLetters.contains(c.baseCp) && c.marks.contains(_sukun)) {
    return TajwidRule.qalqalah;
  }

  return null;
}
