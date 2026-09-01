import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_layout.dart';

/// A 3D Liquid Glass Capsule container matching the 3D Liquid Glass aesthetic
/// of [NavGlassBubble] and [LiquidGlassSwitch].
///
/// Features:
/// - Convex 3D curved glass lens with backdrop blur
/// - Shimmering top specular highlight arc (convex dome reflection)
/// - Bottom ambient caustic bounce glow
/// - Double-walled glossy border rim
/// - Ambient drop shadow + neon/colored bloom glow
/// - Spring press deformation / haptic response on tap
class LiquidGlassCapsule extends StatefulWidget {
  const LiquidGlassCapsule({
    super.key,
    required this.child,
    this.onTap,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.glowColor,
    this.borderRadius,
    this.showGlow = true,
    this.showSpecular = true,
    this.haptic = true,
    this.interactive = true,
  });

  /// The child content placed inside the glass capsule (e.g. Row of icon + text).
  final Widget child;

  /// Tap callback. If null, the capsule is non-interactive.
  final VoidCallback? onTap;

  /// Optional fixed height (defaults to child's natural height or standard button height).
  final double? height;

  /// Optional fixed width.
  final double? width;

  /// Internal padding for the child.
  final EdgeInsetsGeometry? padding;

  /// External margin around the capsule.
  final EdgeInsetsGeometry? margin;

  /// Custom base tint for the glass body.
  final Color? backgroundColor;

  /// Custom rim border color.
  final Color? borderColor;

  /// Custom neon bloom glow color.
  final Color? glowColor;

  /// Custom border radius (defaults to stadium capsule: height / 2 or 999).
  final BorderRadius? borderRadius;

  /// Whether to show the bottom neon caustic glow.
  final bool showGlow;

  /// Whether to show the top specular curved highlight reflection.
  final bool showSpecular;

  /// Whether to trigger haptic feedback on tap.
  final bool haptic;

  /// Whether this capsule responds to touch gestures.
  final bool interactive;

  @override
  State<LiquidGlassCapsule> createState() => _LiquidGlassCapsuleState();
}

class _LiquidGlassCapsuleState extends State<LiquidGlassCapsule>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap == null || !widget.interactive) return;
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onTap == null || !widget.interactive) return;
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (widget.onTap == null || !widget.interactive) return;
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    if (widget.haptic) {
      HapticFeedback.selectionClick();
    }
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;

    final primaryGlow = widget.glowColor ?? scheme.primary;
    final activeBase = widget.backgroundColor ??
        scheme.primary.withValues(
          alpha: isDark ? 0.22 : 0.15,
        );

    final effectiveBorder = widget.borderColor ??
        Colors.white.withValues(
          alpha: isDark ? 0.45 : 0.65,
        );

    final isClickable = widget.onTap != null && widget.interactive;

    return MouseRegion(
      cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: isClickable ? _handleTap : null,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            final scale = _scaleAnimation.value * (_isHovered && isClickable ? 1.02 : 1.0);

            return Transform.scale(
              scale: scale,
              child: Container(
                margin: widget.margin,
                width: widget.width,
                height: widget.height,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final h = widget.height ??
                        (constraints.hasBoundedHeight && constraints.maxHeight > 0
                            ? constraints.maxHeight
                            : 44.0);
                    final radius = widget.borderRadius ?? BorderRadius.circular(h / 2);

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        boxShadow: [
                          // 1. Ambient soft drop shadow
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                            blurRadius: 6.0,
                            offset: const Offset(0, 2.0),
                          ),
                          // 2. 3D Neon / Emerald caustic bloom glow
                          if (widget.showGlow)
                            BoxShadow(
                              color: primaryGlow.withValues(
                                alpha: (isDark ? 0.35 : 0.22) * (_isHovered ? 1.3 : 1.0),
                              ),
                              blurRadius: _isHovered ? 14.0 : 10.0,
                              spreadRadius: _isHovered ? 1.0 : 0.5,
                              offset: const Offset(0, 1.0),
                            ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: radius,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: radius,
                              color: activeBase,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: isDark ? 0.22 : 0.38),
                                  activeBase,
                                  primaryGlow.withValues(
                                    alpha: isDark ? 0.16 : 0.12,
                                  ),
                                ],
                                stops: const [0.0, 0.45, 1.0],
                              ),
                              border: Border.all(
                                color: effectiveBorder,
                                width: 1.2,
                              ),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                // 1. Top Specular Highlight Arc (Convex glass reflection)
                                if (widget.showSpecular)
                                  Positioned(
                                    top: 1.5,
                                    left: 8.0,
                                    right: 8.0,
                                    height: h * 0.36,
                                    child: IgnorePointer(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(h * 0.18),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white.withValues(alpha: isDark ? 0.55 : 0.78),
                                              Colors.white.withValues(alpha: 0.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                // 2. Bottom Ambient Caustic Bounce
                                if (widget.showSpecular)
                                  Positioned(
                                    bottom: 1.5,
                                    left: 10.0,
                                    right: 10.0,
                                    height: h * 0.26,
                                    child: IgnorePointer(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(h * 0.13),
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              primaryGlow.withValues(alpha: isDark ? 0.35 : 0.45),
                                              Colors.white.withValues(alpha: 0.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                // 3. Capsule Child Content
                                Padding(
                                  padding: widget.padding ??
                                      const EdgeInsets.symmetric(
                                        horizontal: AppLayout.sp4,
                                        vertical: AppLayout.sp2 + 2,
                                      ),
                                  child: widget.child,
                                ),
                              ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Ready-to-use 3D Liquid Glass Button with icons, labels, and color presets.
class LiquidGlassButton extends StatelessWidget {
  const LiquidGlassButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.color,
    this.textColor,
    this.glowColor,
    this.height = 44,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    this.showGlow = true,
  });

  /// Button label string.
  final String label;

  /// Optional leading icon.
  final Widget? icon;

  /// Tap callback. If null, the button is disabled.
  final VoidCallback? onPressed;

  /// Custom background color.
  final Color? color;

  /// Custom text/icon color.
  final Color? textColor;

  /// Custom neon bloom glow color.
  final Color? glowColor;

  /// Height of the capsule button.
  final double height;

  /// Optional width of the button.
  final double? width;

  /// Content padding.
  final EdgeInsetsGeometry padding;

  /// Whether to show the bottom neon caustic glow.
  final bool showGlow;

  /// Filled solid primary variant.
  factory LiquidGlassButton.filled({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    Widget? icon,
    Color? color,
    Color? textColor,
    Color? glowColor,
    double height = 44,
    double? width,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    bool showGlow = true,
  }) {
    return LiquidGlassButton(
      key: key,
      onPressed: onPressed,
      label: label,
      icon: icon,
      color: color,
      textColor: textColor,
      glowColor: glowColor,
      height: height,
      width: width,
      padding: padding,
      showGlow: showGlow,
    );
  }

  /// Tonal emerald / secondary variant.
  factory LiquidGlassButton.tonal({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    Widget? icon,
    Color? color,
    Color? textColor,
    double height = 44,
    double? width,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  }) {
    return LiquidGlassButton(
      key: key,
      onPressed: onPressed,
      label: label,
      icon: icon,
      color: color,
      textColor: textColor,
      height: height,
      width: width,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final effectiveTextColor = textColor ??
        (isDark ? const Color(0xFF67E8B5) : const Color(0xFF064E3B));

    return LiquidGlassCapsule(
      onTap: onPressed,
      height: height,
      width: width,
      padding: padding,
      backgroundColor: color ??
          scheme.primary.withValues(
            alpha: isDark ? 0.24 : 0.16,
          ),
      glowColor: glowColor ?? scheme.primary,
      showGlow: showGlow && onPressed != null,
      child: Row(
        mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(
                color: effectiveTextColor,
                size: 18,
              ),
              child: icon!,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: effectiveTextColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
