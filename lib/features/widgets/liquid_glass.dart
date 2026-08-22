import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

import '../../core/app_layout.dart';

export 'package:liquid_glass_easy/liquid_glass_easy.dart'
    show
        LiquidGlassLens,
        LiquidGlassStyle,
        LiquidGlassShadow,
        LiquidGlassTouch,
        LiquidGlassFlex,
        LiquidGlassFlexAdvanced;

export 'package:liquid_glass_widgets/liquid_glass_widgets.dart'
    show
        GlassSwitch,
        GlassTabBar,
        GlassTab,
        GlassSegmentedControl,
        GlassSegment,
        GlassButton,
        GlassIconButton,
        GlassChip,
        GlassCard,
        GlassContainer,
        GlassSlider,
        GlassSearchBar,
        GlassTextField,
        GlassModalSheet,
        GlassDialog,
        GlassDialogAction,
        GlassPullDownButton,
        GlassMenu,
        GlassMenuItem,
        GlassBadge,
        GlassProgressIndicator,
        AdaptiveLiquidGlassLayer,
        LiquidGlassSettings;

export 'liquid_glass_switch.dart';
export 'liquid_glass_capsule.dart';
export 'glass_touch_button.dart';

/// Height of the floating bottom-nav pill (M3 NavigationBar default).
const double glassNavHeight = 80;

/// Corner radius of the floating bottom-nav pill.
const double glassNavCornerRadius = 28;

/// Bottom margin of the floating nav pill.
const double glassNavBottomMargin = AppLayout.sp3; // 12

/// Bottom clearance every screen's scrollable needs so its last item clears
/// the floating nav pill: pill height + bottom margin + a little breathing
/// room. Mobile screens add the system inset on top.
const double glassNavClearance = glassNavHeight + glassNavBottomMargin + 8;

/// Shared chrome look for the large glass surfaces: the home app bar, the
/// sticky audio player, and the floating bottom-nav pill.
///
/// The style is cached per brightness and per corner radius and reused: the
/// lens render object compares shape / appearance / refraction by identity,
/// so a stable instance means normal rebuilds never repaint the lens. (The
/// theme's surface tint differs between light and dark, hence one cache per
/// brightness; full-width bars use radius 0 and the nav pill passes its own.)
LiquidGlassStyle glassChromeStyle(
  BuildContext context, {
  double cornerRadius = 0,
}) {
  final scheme = Theme.of(context).colorScheme;
  final dark = Theme.of(context).brightness == Brightness.dark;
  final cache = dark ? _darkChromeStyles : _lightChromeStyles;
  final key = _ChromeKey(scheme, cornerRadius);
  return cache.putIfAbsent(key, () => _buildChromeStyle(scheme, cornerRadius));
}

/// Cache key that includes the actual color scheme, so switching theme (or
/// changing the seed color) always produces a style matching the current
/// palette instead of reusing a stale one.
class _ChromeKey {
  const _ChromeKey(this.scheme, this.cornerRadius);

  final ColorScheme scheme;
  final double cornerRadius;

  @override
  bool operator ==(Object other) =>
      other is _ChromeKey &&
      other.cornerRadius == cornerRadius &&
      other.scheme.surface == scheme.surface &&
      other.scheme.primary == scheme.primary &&
      other.scheme.onSurface == scheme.onSurface;

  @override
  int get hashCode => Object.hash(
        cornerRadius,
        scheme.surface,
        scheme.primary,
        scheme.onSurface,
      );
}

final Map<_ChromeKey, LiquidGlassStyle> _lightChromeStyles = {};
final Map<_ChromeKey, LiquidGlassStyle> _darkChromeStyles = {};

LiquidGlassStyle _buildChromeStyle(ColorScheme scheme, double cornerRadius) =>
    LiquidGlassStyle(
      shape: LiquidGlassShape.continuousRoundedRectangle(
        cornerRadius: cornerRadius,
        borderWidth: 1,
        lightDirection: 90, // light from above → brighter top rim
        lightIntensity: 1.0,
      ),
      appearance: LiquidGlassAppearance(
        color: scheme.surface.withValues(alpha: 0.72),
        blur: const LiquidGlassBlur(sigmaX: 2.5, sigmaY: 2.5),
        saturation: 1.2,
      ),
      refraction: const LiquidGlassRefraction(
        distortion: 0.13,
        distortionWidth: 34,
        magnification: 1.035,
        chromaticAberration: 0.003,
      ),
    );