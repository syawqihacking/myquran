import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

import '../../core/app_layout.dart';

/// Touch response for small-to-medium buttons: a clear liquid-glass bubble
/// that swells locally at the touch point, pops on a quick click, and springs
/// back with a short wobble on release.
///
/// Tuned for controls between ~36px (icon buttons) and ~150px (cards):
///  * `holdScale: 0.08` — the button grows ~8% for as long as the finger is
///    down (a real bulge on a 48px circle ≈ 4px per edge).
///  * `tapScale: 0.06` — the one-shot pop that makes a fast click still read
///    as pressed glass.
///  * `grip: 0.88` — the swell concentrates around the finger, so a small
///    surface bubbles instead of distorting as a whole.
///  * `refractionBoost: 0.45` — the glass bends almost half again harder under
///    the press, the cue that reads as glass being compressed rather than a
///    rubber button popping.
///  * `magnificationBoost: 0.12` — the backdrop under the finger zooms ~12% at
///    full press, so the lens reads as a real magnifying glass rather than a
///    flat rubber swell.
///  * `stiffness: 300 / releaseDamping: 12` — soft while held, clearly
///    underdamped on release, so the recoil wobble is visible on a small
///    button rather than swallowed by a tight spring.
///
/// Deliberately lighter than the bottom-nav pill's static glass: a small
/// button may deform freely under a drag, but it stretches less than a full
/// panel would, so scrolling over a row of tiles never distorts them wildly.
const LiquidGlassTouch glassButtonTouch = LiquidGlassTouch(
  flex: LiquidGlassFlex(
    stretch: 13,
    squeeze: 0.72,
    lean: 0.3,
    grip: 0.88,
    compressInward: true,
    holdScale: 0.08,
    tapScale: 0.06,
    maxPull: 36,
    advanced: LiquidGlassFlexAdvanced(
      refractionBoost: 0.45,
      magnificationBoost: 0.12,
      stiffness: 300,
      damping: 22,
      releaseDamping: 12,
    ),
  ),
);

/// Faint liquid-glass pane for a wrapped button: a near-transparent lens that
/// adds real optical refraction (lens distortion, backdrop zoom, subtle
/// chromatic fringe) and a bright hairline rim without painting a visible pane
/// over the button's own surface. Cached per brightness + radius so rebuilds
/// never repaint the lens.
LiquidGlassStyle glassButtonStyle(
  BuildContext context, {
  double cornerRadius = AppLayout.radiusFull,
}) {
  final scheme = Theme.of(context).colorScheme;
  final dark = Theme.of(context).brightness == Brightness.dark;
  return _buttonStyles.putIfAbsent(
    (dark, cornerRadius),
    () => _buildButtonStyle(scheme, cornerRadius),
  );
}

final Map<(bool, double), LiquidGlassStyle> _buttonStyles = {};

LiquidGlassStyle _buildButtonStyle(ColorScheme scheme, double radius) =>
    LiquidGlassStyle(
      shape: LiquidGlassShape.continuousRoundedRectangle(
        cornerRadius: radius,
        borderWidth: 1,
        lightDirection: 90, // light from above → brighter top rim
        lightIntensity: 1.0,
      ),
      appearance: LiquidGlassAppearance(
        color: scheme.surface.withValues(alpha: 0.16),
        blur: const LiquidGlassBlur(sigmaX: 2.0, sigmaY: 2.0),
        saturation: 1.2,
      ),
      refraction: const LiquidGlassRefraction(
        distortion: 0.14,
        distortionWidth: 32,
        magnification: 1.04,
        chromaticAberration: 0.004,
      ),
    );

/// Wraps any tappable widget in a touch-driven liquid-glass lens so it
/// bubbles under the finger, pops on a quick click, and springs back on
/// release — while keeping the button's own ink splash, hover state and
/// semantics intact.
///
/// The lens listens translucently and never claims the gesture, so a
/// `Material`/`InkWell`/`IconButton`/`FilledButton` child keeps behaving
/// exactly as before; only its surface becomes liquid glass.
///
/// ## Sizing
///
/// `LiquidGlassLens` measures its glass from `constraints.biggest`, so a loose
/// parent (a `Stack`, an unbounded `Row`) would stretch the button to the
/// parent's max instead of its real footprint. This widget wraps the lens in
/// [_SizeToChild], a box that lays the lens out once to discover its natural
/// size, then again with tight constraints on the axes the parent leaves free.
/// Axes the parent already pins tight (an `Expanded`, a fixed `SizedBox`)
/// pass through unchanged, so wrapped buttons keep filling their slot exactly
/// as before.
///
/// ## Cost
///
/// Every wrapped button is one backdrop capture on Impeller, so use this on
/// primary interactions only — a button per list row (surah lists, bookmark
/// lists) would add one capture per visible row and tank scroll performance.
class GlassTouchButton extends StatelessWidget {
  const GlassTouchButton({
    super.key,
    required this.child,
    this.onTap,
    this.radius = AppLayout.radiusFull,
    this.touch = glassButtonTouch,
    this.style,
    this.useImpellerBackdrop = true,
    this.showShadow = true,
  });

  /// The button surface: a `Material`, `InkWell`, `IconButton`, `FilledButton`
  /// or any widget that already handles its own tap.
  final Widget child;

  /// Optional tap handler for when [child] is plain, non-interactive content.
  /// Keep the button's own gesture handling on [child]; passing both would
  /// fire twice.
  final VoidCallback? onTap;

  /// Corner radius of the glass outline. Use [AppLayout.radiusFull] for
  /// circles and capsules (IconButtons, pills, stadium FilledButtons).
  final double radius;

  /// How the button answers a finger. Defaults to [glassButtonTouch].
  final LiquidGlassTouch touch;

  /// Override the default light-glass look — e.g. a fully transparent style
  /// when the surface already carries its own decoration and only the
  /// deformation/refraction is wanted.
  final LiquidGlassStyle? style;

  /// Whether the lens reads the live backdrop through the Impeller fast path.
  /// Keep `true` unless the lens sits inside a non-Impeller pipeline.
  final bool useImpellerBackdrop;

  /// Whether a soft contact shadow is pooled under the rim, so the button
  /// reads as sitting *in* the surface rather than flat on it. Off for
  /// buttons that already carry their own outer shadow.
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return _SizeToChild(
      child: _shadow(
        LiquidGlassLens(
          style: style ?? glassButtonStyle(context, cornerRadius: radius),
          touch: touch,
          useImpellerBackdrop: useImpellerBackdrop,
          child: _tapTarget,
        ),
      ),
    );
  }

  /// A soft contact shadow pooled under the rim. `inset` tucks the halo in on
  /// small controls where a full-size one would read as a glow.
  Widget _shadow(Widget lens) {
    if (!showShadow) return lens;
    return LiquidGlassShadow(
      cornerRadius: radius,
      blur: 4,
      opacity: 0.16,
      inset: 2,
      child: lens,
    );
  }

  Widget get _tapTarget {
    final onTap = this.onTap;
    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: child,
      ),
    );
  }
}

/// Sizes its child (the lens) to the child's own natural footprint while
/// letting axes the parent pins tight pass through unchanged.
///
/// `LiquidGlassLens` sizes its glass from `constraints.biggest`; if it ever
/// received a loose constraint it would force the button to the parent's max.
/// This box lays the lens out twice in one pass:
///
///  1. With the parent's tight axes kept tight and every other axis unbounded,
///     so the lens's flex path is disabled and the button reports its real
///     size (never stretched by a loose `Stack` or an unbounded `Row`).
///  2. With the loose axes tightened to that measured size, so the lens's
///     `constraints.biggest` equals the button's footprint and the bubble
///     deformation is enabled.
///
/// A plain `IntrinsicWidth`/`IntrinsicHeight` pair cannot do this: the lens
/// renders through a `LayoutBuilder`, whose render object reports zero for
/// every intrinsic dimension, so the button would collapse to nothing.
class _SizeToChild extends SingleChildRenderObjectWidget {
  const _SizeToChild({super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderSizeToChild();

  @override
  void updateRenderObject(BuildContext context, _RenderSizeToChild renderObject) {}
}

class _RenderSizeToChild extends RenderProxyBox {
  @override
  void performLayout() {
    assert(child != null);
    final RenderBox box = child!;

    // Pass 1 — discover the natural footprint. Keep the axes the parent pins
    // tight (the button must keep filling them), unbind everything else so the
    // lens never stretches the button to a loose max.
    final BoxConstraints probe = BoxConstraints(
      minWidth: constraints.hasTightWidth ? constraints.minWidth : 0,
      maxWidth: constraints.hasTightWidth ? constraints.maxWidth : double.infinity,
      minHeight: constraints.hasTightHeight ? constraints.minHeight : 0,
      maxHeight: constraints.hasTightHeight ? constraints.maxHeight : double.infinity,
    );
    box.layout(probe, parentUsesSize: true);
    final Size natural = box.size;

    // Pass 2 — hand the lens its real footprint as tight constraints on the
    // free axes, clamped to the parent's bounds so a too-wide natural size
    // never overflows.
    final double w = constraints.hasTightWidth
        ? constraints.maxWidth
        : natural.width.clamp(
            0.0,
            constraints.hasBoundedWidth ? constraints.maxWidth : double.infinity,
          );
    final double h = constraints.hasTightHeight
        ? constraints.maxHeight
        : natural.height.clamp(
            0.0,
            constraints.hasBoundedHeight ? constraints.maxHeight : double.infinity,
          );
    box.layout(BoxConstraints.tight(Size(w, h)), parentUsesSize: true);
    size = constraints.constrain(box.size);
  }
}
