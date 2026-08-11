import 'package:flutter/material.dart';

/// The reading-surface ("paper") tokens (design system §1.5).
///
/// The reading column uses these; all chrome uses the M3 roles. This
/// chrome/paper split is the core identity device of the app.
@immutable
class QuranPalette extends ThemeExtension<QuranPalette> {
  const QuranPalette({
    required this.quranSurface,
    required this.quranInk,
    required this.quranInkSecondary,
    required this.quranAccent,
    required this.quranRule,
    required this.quranHighlight,
    required this.quranBookmarkTint,
    required this.quranHeaderGlow,
  });

  final Color quranSurface;
  final Color quranInk;
  final Color quranInkSecondary;
  final Color quranAccent;
  final Color quranRule;
  final Color quranHighlight;
  final Color quranBookmarkTint;
  final Color quranHeaderGlow;

  static const QuranPalette light = QuranPalette(
    quranSurface: Color(0xFFFDFAF2),
    quranInk: Color(0xFF211D12),
    quranInkSecondary: Color(0xFF3F3A2E),
    quranAccent: Color(0xFF8A6A00),
    quranRule: Color(0xFFE7E1D2),
    quranHighlight: Color(0x73D0EAE0), // #D0EAE0 @ 45%
    quranBookmarkTint: Color(0x4DF6E177), // #F6E177 @ 30%
    quranHeaderGlow: Color(0x0A3B6B5C), // #3B6B5C @ 4%
  );

  static const QuranPalette dark = QuranPalette(
    quranSurface: Color(0xFF151710),
    quranInk: Color(0xFFF0EADA),
    quranInkSecondary: Color(0xFFBDB7A8),
    quranAccent: Color(0xFFC9A545),
    quranRule: Color(0xFF2C2B22),
    quranHighlight: Color(0x732E5246), // #2E5246 @ 45%
    quranBookmarkTint: Color(0x4D544200), // #544200 @ 30%
    quranHeaderGlow: Color(0x0DA8D4C0), // #A8D4C0 @ 5%
  );

  @override
  QuranPalette copyWith({
    Color? quranSurface,
    Color? quranInk,
    Color? quranInkSecondary,
    Color? quranAccent,
    Color? quranRule,
    Color? quranHighlight,
    Color? quranBookmarkTint,
    Color? quranHeaderGlow,
  }) {
    return QuranPalette(
      quranSurface: quranSurface ?? this.quranSurface,
      quranInk: quranInk ?? this.quranInk,
      quranInkSecondary: quranInkSecondary ?? this.quranInkSecondary,
      quranAccent: quranAccent ?? this.quranAccent,
      quranRule: quranRule ?? this.quranRule,
      quranHighlight: quranHighlight ?? this.quranHighlight,
      quranBookmarkTint: quranBookmarkTint ?? this.quranBookmarkTint,
      quranHeaderGlow: quranHeaderGlow ?? this.quranHeaderGlow,
    );
  }

  @override
  QuranPalette lerp(QuranPalette? other, double t) {
    if (other == null) return this;
    return QuranPalette(
      quranSurface: Color.lerp(quranSurface, other.quranSurface, t)!,
      quranInk: Color.lerp(quranInk, other.quranInk, t)!,
      quranInkSecondary: Color.lerp(quranInkSecondary, other.quranInkSecondary, t)!,
      quranAccent: Color.lerp(quranAccent, other.quranAccent, t)!,
      quranRule: Color.lerp(quranRule, other.quranRule, t)!,
      quranHighlight: Color.lerp(quranHighlight, other.quranHighlight, t)!,
      quranBookmarkTint: Color.lerp(quranBookmarkTint, other.quranBookmarkTint, t)!,
      quranHeaderGlow: Color.lerp(quranHeaderGlow, other.quranHeaderGlow, t)!,
    );
  }
}

extension QuranThemeX on BuildContext {
  QuranPalette get quran => Theme.of(this).extension<QuranPalette>()!;
}
