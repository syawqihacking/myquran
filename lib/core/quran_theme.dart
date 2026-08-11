import 'package:flutter/material.dart';

import 'app_constants.dart';
import 'quran_palette.dart';

/// Builds the MyQuran theme (design system §1, §2).
///
/// Material 3, seed `#1D6B58`, `tonalSpot`, then role values are pinned with
/// `copyWith` so the palette is reproducible regardless of upstream drift.
ThemeData buildAppTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1D6B58),
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
  ).copyWith(
    // Pinned roles — light §1.3 / dark §1.4.
    primary: dark ? const Color(0xFFA8D4C0) : const Color(0xFF3B6B5C),
    onPrimary: dark ? const Color(0xFF0D3A2C) : const Color(0xFFFFFFFF),
    primaryContainer: dark ? const Color(0xFF2E5246) : const Color(0xFFD0EAE0),
    onPrimaryContainer: dark ? const Color(0xFFC4F0DD) : const Color(0xFF0A2A20),
    secondary: dark ? const Color(0xFFC0C9C1) : const Color(0xFF5A645D),
    onSecondary: dark ? const Color(0xFF262E28) : const Color(0xFFFFFFFF),
    secondaryContainer: dark ? const Color(0xFF3C453E) : const Color(0xFFDEE9E2),
    onSecondaryContainer: dark ? const Color(0xFFDCE6DC) : const Color(0xFF16201A),
    tertiary: dark ? const Color(0xFFE0BE45) : const Color(0xFF7A5B00),
    onTertiary: dark ? const Color(0xFF3A2E00) : const Color(0xFFFFFFFF),
    tertiaryContainer: dark ? const Color(0xFF544200) : const Color(0xFFF6E177),
    onTertiaryContainer: dark ? const Color(0xFFFBE16A) : const Color(0xFF241A00),
    error: dark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A),
    onError: dark ? const Color(0xFF690005) : const Color(0xFFFFFFFF),
    errorContainer: dark ? const Color(0xFF93000A) : const Color(0xFFFFDAD6),
    onErrorContainer: dark ? const Color(0xFFFFDAD6) : const Color(0xFF410002),
    surface: dark ? const Color(0xFF101410) : const Color(0xFFFAFBF8),
    surfaceContainerLowest: dark ? const Color(0xFF0B0E0B) : const Color(0xFFFFFFFF),
    surfaceContainerLow: dark ? const Color(0xFF181C18) : const Color(0xFFF3F5F1),
    surfaceContainer: dark ? const Color(0xFF1C211C) : const Color(0xFFEDEFEA),
    surfaceContainerHigh: dark ? const Color(0xFF262B26) : const Color(0xFFE7E9E4),
    surfaceContainerHighest: dark ? const Color(0xFF313631) : const Color(0xFFE1E4DE),
    onSurface: dark ? const Color(0xFFE0E4DE) : const Color(0xFF191C19),
    onSurfaceVariant: dark ? const Color(0xFFBFC6BE) : const Color(0xFF434744),
    outline: dark ? const Color(0xFF899189) : const Color(0xFF737874),
    outlineVariant: dark ? const Color(0xFF3E463F) : const Color(0xFFC3C8C2),
    inverseSurface: dark ? const Color(0xFFE0E4DE) : const Color(0xFF2E312E),
    onInverseSurface: dark ? const Color(0xFF2E312E) : const Color(0xFFEFF1EC),
    inversePrimary: dark ? const Color(0xFF3B6B5C) : const Color(0xFF9ED0BF),
    scrim: const Color(0xFF000000),
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: brightness,
    scaffoldBackgroundColor: scheme.surface,
    extensions: [dark ? QuranPalette.dark : QuranPalette.light],
    textTheme: _textTheme(scheme),
    visualDensity: VisualDensity.standard,
  );

  return base.copyWith(
    dividerColor: scheme.outlineVariant,
    // InkSparkle requires the framework shader `shaders/ink_sparkle.frag`,
    // which the Flutter tool (3.35.7) copies to flutter_assets but does not
    // register in AssetManifest — so rootBundle.load fails at runtime on
    // desktop/Skia. InkRipple is the supported fallback (no shader needed).
    splashFactory: InkRipple.splashFactory,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: scheme.primary,
      selectionColor: scheme.primary.withValues(alpha: 0.25),
      selectionHandleColor: scheme.primary,
    ),
    tooltipTheme: base.tooltipTheme.copyWith(
      waitDuration: const Duration(milliseconds: 500),
      textStyle: TextStyle(
        fontFamily: AppConstants.fontUi,
        color: scheme.onInverseSurface,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    focusColor: Colors.transparent,
    sliderTheme: base.sliderTheme.copyWith(
      activeTrackColor: scheme.primary,
      inactiveTrackColor: scheme.surfaceContainerHighest,
      thumbColor: scheme.primary,
      overlayColor: scheme.primary.withValues(alpha: 0.12),
    ),
  );
}

/// UI type scale (design system §2.3): Inter, Noto Sans Arabic fallback.
TextTheme _textTheme(ColorScheme scheme) {
  final onSurface = scheme.onSurface;
  TextStyle s(
    double size,
    double height,
    FontWeight weight, {
    double tracking = 0,
  }) {
    return TextStyle(
      fontFamily: AppConstants.fontUi,
      fontFamilyFallback: const [AppConstants.fontArabic],
      color: onSurface,
      fontSize: size,
      height: height,
      fontWeight: weight,
      letterSpacing: tracking,
    );
  }

  return TextTheme(
    displaySmall: s(36, 44 / 36, FontWeight.w600),
    headlineSmall: s(28, 36 / 28, FontWeight.w600),
    titleLarge: s(22, 28 / 22, FontWeight.w500),
    titleMedium: s(16, 24 / 16, FontWeight.w500),
    bodyLarge: s(16, 26 / 16, FontWeight.w400),
    bodyMedium: s(14, 22 / 14, FontWeight.w400),
    bodySmall: s(12, 18 / 12, FontWeight.w400),
    labelLarge: s(14, 20 / 14, FontWeight.w500),
    labelMedium: s(12, 16 / 12, FontWeight.w500),
    // Overline S — the only allowed tracking, Latin only.
    labelSmall: s(11, 16 / 11, FontWeight.w600, tracking: 0.4),
  );
}
