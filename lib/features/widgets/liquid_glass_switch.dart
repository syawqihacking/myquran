import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A 3D Liquid Glass toggle switch matching Apple iOS 18 Liquid Glass aesthetics.
///
/// Features a vivid translucent glass track with an optical 3D curved glass
/// capsule lens thumb that refracts the track color at its rims (caustic green
/// rim when ON, ice-crystal rim when OFF), glossy specular highlights, and
/// liquid droplet stretching during drag/toggle transitions.
class LiquidGlassSwitch extends StatefulWidget {
  const LiquidGlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// Whether this switch is on or off.
  final bool value;

  /// Called when the user toggles the switch. If null, the switch is disabled.
  final ValueChanged<bool>? onChanged;

  /// Custom active tint override (defaults to iOS emerald green).
  final Color? activeColor;

  /// Custom inactive tint override (defaults to neutral frosted glass).
  final Color? inactiveColor;

  /// An optional focus node to manage keyboard focus.
  final FocusNode? focusNode;

  /// True if this widget will be selected as the initial focus.
  final bool autofocus;

  /// Semantic label for screen readers.
  final String? semanticLabel;

  @override
  State<LiquidGlassSwitch> createState() => _LiquidGlassSwitchState();
}

class _LiquidGlassSwitchState extends State<LiquidGlassSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _positionAnimation;

  bool _isPressed = false;
  double? _dragPosition; // 0.0 .. 1.0 during drag

  // Dimensions
  static const double _trackWidth = 58.0;
  static const double _trackHeight = 34.0;
  static const double _thumbPadding = 3.0;
  static const double _thumbWidth = 30.0;
  static const double _thumbHeight = 28.0;
  static const double _maxTravel = _trackWidth - _thumbWidth - (_thumbPadding * 2); // 22.0

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 320),
      value: widget.value ? 1.0 : 0.0,
      vsync: this,
    );

    _positionAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeOutBack,
    );
  }

  @override
  void didUpdateWidget(LiquidGlassSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onChanged != null;

  void _handleTap() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
    widget.onChanged!(!widget.value);
  }

  void _onPanStart(DragStartDetails details) {
    if (!_enabled) return;
    setState(() {
      _isPressed = true;
      _dragPosition = _controller.value;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_enabled) return;
    setState(() {
      final delta = details.primaryDelta ?? details.delta.dx;
      _dragPosition = ((_dragPosition ?? _controller.value) + (delta / _maxTravel)).clamp(0.0, 1.0);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_enabled) return;
    final position = _dragPosition ?? _controller.value;
    final velocity = details.primaryVelocity ?? details.velocity.pixelsPerSecond.dx;
    final bool targetValue;
    if (velocity.abs() > 100) {
      targetValue = velocity > 0;
    } else {
      targetValue = position >= 0.5;
    }
    setState(() {
      _isPressed = false;
      _dragPosition = null;
    });
    if (targetValue != widget.value) {
      HapticFeedback.selectionClick();
      widget.onChanged!(targetValue);
    } else {
      // Settle back to current state
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _onPanCancel() {
    if (!_enabled) return;
    setState(() {
      _isPressed = false;
      _dragPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Vibrant iOS Emerald Green / Mint
    final vividGreen = widget.activeColor ??
        (isDark ? const Color(0xFF30D158) : const Color(0xFF34C759));

    return Semantics(
      toggled: widget.value,
      label: widget.semanticLabel,
      enabled: _enabled,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        enabled: _enabled,
        onShowFocusHighlight: (v) {},
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _handleTap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          onTapDown: _enabled ? (_) => setState(() => _isPressed = true) : null,
          onTapCancel: _enabled ? () => setState(() => _isPressed = false) : null,
          onHorizontalDragStart: _onPanStart,
          onHorizontalDragUpdate: _onPanUpdate,
          onHorizontalDragEnd: _onPanEnd,
          onHorizontalDragCancel: _onPanCancel,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _positionAnimation,
              builder: (context, child) {
                final currentProgress = _dragPosition ?? _positionAnimation.value;
                final isMoving = _controller.isAnimating || _dragPosition != null;

                // Liquid Droplet physics: stretch horizontally during movement
                final stretchFactor = isMoving ? 1.20 : 1.0;
                final scaleX = stretchFactor * (_isPressed ? 1.06 : 1.0);
                final scaleY = _isPressed ? 0.90 : (isMoving ? 0.95 : 1.0);

                // Track colors (translucent frosted glass to vibrant emerald)
                final offTrackColor = widget.inactiveColor ??
                    (isDark
                        ? const Color(0xFF3A3A3C).withValues(alpha: 0.50)
                        : const Color(0xFFE5E5EA).withValues(alpha: 0.75));
                final onTrackColor = vividGreen.withValues(alpha: isDark ? 0.88 : 0.94);

                final currentTrackColor = Color.lerp(
                  offTrackColor,
                  onTrackColor,
                  currentProgress,
                )!;

                // Track rim border
                final borderRimColor = Color.lerp(
                  Colors.white.withValues(alpha: isDark ? 0.25 : 0.45),
                  vividGreen.withValues(alpha: isDark ? 0.65 : 0.85),
                  currentProgress,
                )!;

                return Opacity(
                  opacity: _enabled ? 1.0 : 0.5,
                  child: SizedBox(
                    width: _trackWidth,
                    height: _trackHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.centerLeft,
                      children: [
                        // 1. Translucent Glass Track Capsule
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(_trackHeight / 2),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(_trackHeight / 2),
                                  color: currentTrackColor,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      currentTrackColor,
                                      Color.lerp(
                                        currentTrackColor,
                                        isDark ? Colors.black : Colors.white,
                                        0.10,
                                      )!,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: borderRimColor,
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                    if (currentProgress > 0.05)
                                      BoxShadow(
                                        color: vividGreen.withValues(
                                          alpha: (isDark ? 0.55 : 0.40) * currentProgress,
                                        ),
                                        blurRadius: 10,
                                        spreadRadius: 1.0,
                                        offset: const Offset(0, 1),
                                      ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Inner glass highlight sheen on top track edge
                                    Positioned(
                                      top: 1.0,
                                      left: 8.0,
                                      right: 8.0,
                                      height: 1.5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(1.0),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withValues(alpha: 0.0),
                                              Colors.white.withValues(
                                                alpha: isDark ? 0.40 : 0.65,
                                              ),
                                              Colors.white.withValues(alpha: 0.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 2. 3D Curved Glass Pill Lens (Thumb)
                        Positioned(
                          left: _thumbPadding + (_maxTravel * currentProgress),
                          top: (_trackHeight - _thumbHeight) / 2,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.diagonal3Values(scaleX, scaleY, 1.0),
                            child: _CurvedGlassPillThumb(
                              progress: currentProgress,
                              isDark: isDark,
                              vividGreen: vividGreen,
                              width: _thumbWidth,
                              height: _thumbHeight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// The 3D curved glass pill/lens thumb element with caustic rim reflections,
/// specular highlights, and optical glass depth matching the reference image.
class _CurvedGlassPillThumb extends StatelessWidget {
  const _CurvedGlassPillThumb({
    required this.progress,
    required this.isDark,
    required this.vividGreen,
    required this.width,
    required this.height,
  });

  final double progress;
  final bool isDark;
  final Color vividGreen;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(height / 2);

    // Caustic rim refraction color: in the reference image, the glass rim has a thick vivid emerald green reflection on green track, crystal white when OFF
    final causticRimColor = Color.lerp(
      Colors.white.withValues(alpha: isDark ? 0.70 : 0.85),
      Color.lerp(Colors.white, vividGreen, 0.65)!.withValues(alpha: 0.95),
      progress,
    )!;

    // Body glass tone: CLEAR 3D GLASS (translucent, NOT opaque white)
    final glassBodyColor = Color.lerp(
      Colors.white.withValues(alpha: isDark ? 0.18 : 0.28),
      Colors.white.withValues(alpha: isDark ? 0.15 : 0.22),
      progress,
    )!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: glassBodyColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.40 : 0.55),
            glassBodyColor,
            Color.lerp(
              glassBodyColor,
              progress > 0.5 ? vividGreen : Colors.black,
              isDark ? 0.20 : 0.10,
            )!,
          ],
          stops: const [0.0, 0.40, 1.0],
        ),
        border: Border.all(
          color: causticRimColor,
          width: 2.0, // Thick 3D glass rim like reference image
        ),
        boxShadow: [
          // Soft ambient 3D drop shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.16),
            blurRadius: 6.0,
            offset: const Offset(0, 2.5),
          ),
          // Neon emerald caustic glow when ON
          if (progress > 0.05)
            BoxShadow(
              color: vividGreen.withValues(alpha: (isDark ? 0.55 : 0.40) * progress),
              blurRadius: 10.0,
              spreadRadius: 1.0,
              offset: const Offset(0, 1.0),
            ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Specular Curved Top Highlight (Convex Glass Dome Reflection)
          Positioned(
            top: 2.0,
            left: 4.0,
            right: 4.0,
            height: height * 0.42,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height * 0.21),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.75 : 0.90),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // 2. Caustic Edge Rim Light (Curved pill ring glow like in the reference image)
          Positioned(
            bottom: 2.0,
            left: 4.0,
            right: 4.0,
            height: height * 0.30,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height * 0.15),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color.lerp(
                      Colors.white.withValues(alpha: isDark ? 0.35 : 0.50),
                      vividGreen.withValues(alpha: 0.85),
                      progress,
                    )!,
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // 3. Inner Refraction Ring (Double-walled glass look)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular((height - 4.0) / 2),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.45),
                    width: 0.8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
