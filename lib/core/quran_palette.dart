import 'package:flutter/material.dart';

/// Selectable reading-paper variants (design system §1.5).
///
/// All variants stay warm in both brightness modes — the chrome/paper split
/// is the identity device, and cold paper would break it. [hangat] is the
/// default; its dark surface is warmed past the original §1.5 value so it
/// reads as warm near-black rather than olive (paper-over-glass, §2.2).
enum PaperTheme { hangat, klasik, pucat }

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
    // Warm brown-black (not olive): the paper/glass split stays visible in
    // dark mode against the cool-olive chrome surface (§1.5 "warm near-black").
    quranSurface: Color(0xFF171510),
    quranInk: Color(0xFFF0EADA),
    quranInkSecondary: Color(0xFFBDB7A8),
    quranAccent: Color(0xFFC9A545),
    quranRule: Color(0xFF2C2B22),
    quranHighlight: Color(0x732E5246), // #2E5246 @ 45%
    quranBookmarkTint: Color(0x4D544200), // #544200 @ 30%
    quranHeaderGlow: Color(0x0DA8D4C0), // #A8D4C0 @ 5%
  );

  /// Klasik: aged, slightly deeper cream — reads like an old hand-bound
  /// edition. Warm and AA-safe in both modes.
  static const QuranPalette klasik = QuranPalette(
    quranSurface: Color(0xFFF7F0DE),
    quranInk: Color(0xFF211C0E),
    quranInkSecondary: Color(0xFF403A27),
    quranAccent: Color(0xFF7A5C00),
    quranRule: Color(0xFFE2D6B6),
    quranHighlight: Color(0x73D0EAE0),
    quranBookmarkTint: Color(0x4DF6E177),
    quranHeaderGlow: Color(0x0A3B6B5C),
  );

  static const QuranPalette klasikDark = QuranPalette(
    quranSurface: Color(0xFF1A1A12),
    quranInk: Color(0xFFEFE8D3),
    quranInkSecondary: Color(0xFFC0B9A6),
    quranAccent: Color(0xFFD1AD50),
    quranRule: Color(0xFF333027),
    quranHighlight: Color(0x732E5246),
    quranBookmarkTint: Color(0x4D544200),
    quranHeaderGlow: Color(0x0DA8D4C0),
  );

  /// Pucat: soft, airy warm-white — quieter, closer to the chrome paper,
  /// still warm (never cold) in both modes.
  static const QuranPalette pucat = QuranPalette(
    quranSurface: Color(0xFFFCFAF3),
    quranInk: Color(0xFF1F1C12),
    quranInkSecondary: Color(0xFF3D3A2F),
    quranAccent: Color(0xFF7C5E00),
    quranRule: Color(0xFFE9E3D2),
    quranHighlight: Color(0x73D0EAE0),
    quranBookmarkTint: Color(0x4DF6E177),
    quranHeaderGlow: Color(0x0A3B6B5C),
  );

  static const QuranPalette pucatDark = QuranPalette(
    // Same warm brown-black family as [dark] — quiet, never olive-green.
    quranSurface: Color(0xFF161510),
    quranInk: Color(0xFFF0ECDE),
    quranInkSecondary: Color(0xFFBDB9AC),
    quranAccent: Color(0xFFC5A243),
    quranRule: Color(0xFF2C2B23),
    quranHighlight: Color(0x732E5246),
    quranBookmarkTint: Color(0x4D544200),
    quranHeaderGlow: Color(0x0DA8D4C0),
  );

  /// Resolves the paper palette for a [PaperTheme] and brightness.
  /// [hangat] intentionally resolves to the canonical [light]/[dark] tokens.
  static QuranPalette of(PaperTheme theme, bool dark) {
    switch (theme) {
      case PaperTheme.hangat:
        return dark ? QuranPalette.dark : QuranPalette.light;
      case PaperTheme.klasik:
        return dark ? klasikDark : klasik;
      case PaperTheme.pucat:
        return dark ? pucatDark : pucat;
    }
  }

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
