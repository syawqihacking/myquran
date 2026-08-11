import 'dart:math' as math;

import 'app_layout.dart';

/// Quran typography scale (design system §2.4).
///
/// Nine discrete steps S1..S9; default S5 = 38 px. All Arabic styles must use
/// `letterSpacing: 0` (Flutter issue #143975) — never letter-space Arabic.
const List<double> kQuranFontSizes = [24, 27, 30, 34, 38, 43, 48, 54, 60];
const List<double> kQuranLineHeights = [1.90, 1.90, 1.85, 1.80, 1.80, 1.75, 1.75, 1.70, 1.70];

double quranFontSize(int step) => kQuranFontSizes[step - 1];
double quranLineHeight(int step) => kQuranLineHeights[step - 1];

double _clamp(double v, double lo, double hi) => math.min(hi, math.max(lo, v));

/// Translation size follows the Quran size: clamp(14, round(q * 0.42), 22).
double translationFontSize(double quranSize) =>
    _clamp((quranSize * 0.42).roundToDouble(), 14, 22);

/// Vertical gap between ayah blocks: clamp(24, round(q * 0.85), 56).
double ayahGap(double quranSize) =>
    _clamp((quranSize * 0.85).roundToDouble(), 24, 56);

/// Gap between Arabic text and its translation: clamp(12, round(q * 0.40), 24).
double translationGap(double quranSize) =>
    _clamp((quranSize * 0.40).roundToDouble(), 12, 24);

/// Ayah-end marker diameter: clamp(28, round(q * 0.90), 56).
double ayahMarkerSize(double quranSize) =>
    _clamp((quranSize * 0.90).roundToDouble(), 28, 56);

/// Bismillah size: round(q * 0.92).
double bismillahSize(double quranSize) => (quranSize * 0.92).roundToDouble();

/// Reader text-column width: clamp(680, q * 21, 1040).
double readingWidth(double quranSize) =>
    _clamp(quranSize * 21, AppLayout.readerMinWidth, AppLayout.readerMaxWidth);
