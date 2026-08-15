import 'package:flutter/material.dart';

import 'app_constants.dart';
import 'quran_palette.dart';
import 'tajwid_palette.dart';

/// Builds the MyQuran theme — the "Sacred Path" design system.
///
/// A minimalist *spiritual modernist* look: deep emerald and warm gold over
/// vast near-white space, with subtle heritage (paper/gold) details carried
/// by the reading column. Material 3, seed `#064E3B`, `tonalSpot`, then role
/// values are pinned with `copyWith` so the palette is reproducible
/// regardless of upstream drift. Light mode is the primary spec; dark mode is
/// derived from it (deep emerald-tinted near-black surfaces, luminous emerald
/// primary, sage secondary, warm gold tertiary — never cold blue).
/// The [paper] theme selects which warm reading-surface variant the
/// [QuranPalette] extension resolves to (§1.5); chrome uses the M3 roles.
ThemeData buildAppTheme(
  Brightness brightness, {
  PaperTheme paper = PaperTheme.hangat,
}) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF064E3B),
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
  ).copyWith(
    // Pinned roles — light "Sacred Path" spec / derived dark.
    primary: dark ? const Color(0xFF95D3BA) : const Color(0xFF003527),
    onPrimary: dark ? const Color(0xFF002117) : const Color(0xFFFFFFFF),
    primaryContainer: dark ? const Color(0xFF0F5744) : const Color(0xFF064E3B),
    onPrimaryContainer: dark ? const Color(0xFFA8EED2) : const Color(0xFF80BEA6),
    secondary: dark ? const Color(0xFFA8CFBC) : const Color(0xFF416656),
    onSecondary: dark ? const Color(0xFF0A2F22) : const Color(0xFFFFFFFF),
    secondaryContainer: dark ? const Color(0xFF2F5545) : const Color(0xFFC3ECD7),
    onSecondaryContainer: dark ? const Color(0xFFC3ECD7) : const Color(0xFF476C5B),
    tertiary: dark ? const Color(0xFFE9C349) : const Color(0xFF735C00),
    onTertiary: dark ? const Color(0xFF241A00) : const Color(0xFFFFFFFF),
    tertiaryContainer: dark ? const Color(0xFF4E3D00) : const Color(0xFFCCA72F),
    onTertiaryContainer: dark ? const Color(0xFFFFE088) : const Color(0xFF4E3D00),
    error: dark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A),
    onError: dark ? const Color(0xFF690005) : const Color(0xFFFFFFFF),
    errorContainer: dark ? const Color(0xFF93000A) : const Color(0xFFFFDAD6),
    onErrorContainer: dark ? const Color(0xFFFFDAD6) : const Color(0xFF93000A),
    surface: dark ? const Color(0xFF0E1410) : const Color(0xFFF8F9FA),
    surfaceContainerLowest: dark ? const Color(0xFF090E0B) : const Color(0xFFFFFFFF),
    surfaceContainerLow: dark ? const Color(0xFF161C18) : const Color(0xFFF3F4F5),
    surfaceContainer: dark ? const Color(0xFF1A211C) : const Color(0xFFEDEEEF),
    surfaceContainerHigh: dark ? const Color(0xFF242B26) : const Color(0xFFE7E8E9),
    surfaceContainerHighest: dark ? const Color(0xFF2F3630) : const Color(0xFFE1E3E4),
    onSurface: dark ? const Color(0xFFDDE3DD) : const Color(0xFF191C1D),
    onSurfaceVariant: dark ? const Color(0xFFC2CBC3) : const Color(0xFF404944),
    outline: dark ? const Color(0xFF8C958D) : const Color(0xFF707974),
    outlineVariant: dark ? const Color(0xFF414A43) : const Color(0xFFBFC9C3),
    inverseSurface: dark ? const Color(0xFFDDE3DD) : const Color(0xFF2E3132),
    onInverseSurface: dark ? const Color(0xFF2F3630) : const Color(0xFFF0F1F2),
    inversePrimary: dark ? const Color(0xFF0B513D) : const Color(0xFF95D3BA),
    surfaceTint: dark ? const Color(0xFF95D3BA) : const Color(0xFF2B6954),
    // Fixed roles are mode-independent — pinned once for both.
    primaryFixed: const Color(0xFFB0F0D6),
    primaryFixedDim: const Color(0xFF95D3BA),
    onPrimaryFixed: const Color(0xFF002117),
    onPrimaryFixedVariant: const Color(0xFF0B513D),
    secondaryFixed: const Color(0xFFC3ECD7),
    secondaryFixedDim: const Color(0xFFA8CFBC),
    onSecondaryFixed: const Color(0xFF002115),
    onSecondaryFixedVariant: const Color(0xFF294E3F),
    tertiaryFixed: const Color(0xFFFFE088),
    tertiaryFixedDim: const Color(0xFFE9C349),
    onTertiaryFixed: const Color(0xFF241A00),
    onTertiaryFixedVariant: const Color(0xFF574500),
    scrim: const Color(0xFF000000),
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: brightness,
    scaffoldBackgroundColor: scheme.surface,
    extensions: [
      QuranPalette.of(paper, dark),
      TajwidPalette.of(dark),
    ],
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

/// Type scale (design system §2.3).
///
/// Headlines and labels use Plus Jakarta Sans (weight 600–700, tight
/// tracking) for a modern-spiritual feel; body/translations stay Inter with
/// Noto Sans Arabic fallback. Arabic Qur'an text never goes through this
/// theme — the reader sets `AppConstants.fontQuran` directly.
TextTheme _textTheme(ColorScheme scheme) {
  final onSurface = scheme.onSurface;
  // Literal family string: the font is registered by a parallel lane and is
  // resolvable after `flutter pub get`.
  const display = 'Plus Jakarta Sans';

  TextStyle s(
    double size,
    double height,
    FontWeight weight, {
    double tracking = 0,
    String? family,
  }) {
    return TextStyle(
      fontFamily: family ?? AppConstants.fontUi,
      fontFamilyFallback: const [AppConstants.fontArabic],
      color: onSurface,
      fontSize: size,
      height: height,
      fontWeight: weight,
      letterSpacing: tracking,
    );
  }

  return TextTheme(
    displaySmall: s(36, 44 / 36, FontWeight.w600, tracking: -0.5, family: display),
    headlineSmall: s(28, 36 / 28, FontWeight.w600, tracking: -0.25, family: display),
    titleLarge: s(22, 28 / 22, FontWeight.w600, tracking: -0.25, family: display),
    titleMedium: s(16, 24 / 16, FontWeight.w600, tracking: 0, family: display),
    bodyLarge: s(16, 26 / 16, FontWeight.w400),
    bodyMedium: s(14, 22 / 14, FontWeight.w400),
    bodySmall: s(12, 18 / 12, FontWeight.w400),
    labelLarge: s(14, 20 / 14, FontWeight.w600, tracking: 0.1, family: display),
    labelMedium: s(12, 16 / 12, FontWeight.w600, tracking: 0.3, family: display),
    // Overline S — the only allowed tracking, Latin only.
    labelSmall: s(11, 16 / 11, FontWeight.w600, tracking: 0.6, family: display),
  );
}
