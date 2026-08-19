import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Global switch to verify optical deformation during development.
const bool debugLiquidGlass = false;

/// Set to true once [ensureNavBubbleShader] has compiled the bubble program.
final ValueNotifier<bool> navBubbleShaderReady = ValueNotifier<bool>(false);

ui.FragmentProgram? _navBubbleProgram;

/// Compiles the local-lens shader once and caches it for every nav pill.
Future<void> ensureNavBubbleShader() async {
  if (_navBubbleProgram != null || navBubbleShaderReady.value) return;
  try {
    _navBubbleProgram =
        await ui.FragmentProgram.fromAsset('assets/shaders/nav_bubble.frag');
    navBubbleShaderReady.value = true;
    debugPrint('LiquidGlass: nav_bubble.frag compiled successfully.');
  } catch (e, stack) {
    debugPrint('Nav bubble shader failed: $e');
    debugPrintStack(stackTrace: stack);
  }
}

/// Minimal notifier that exposes a public [notify] so the ticker can wake
/// the layer every animation frame.
class _FrameNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

/// Integrated 3D Liquid Glass navigation capsule and optical deformation for
/// the floating bottom navigation bar.
class NavGlassBubble extends StatefulWidget {
  const NavGlassBubble({
    super.key,
    required this.selectedIndex,
    required this.itemCount,
    required this.child,
    this.onDestinationSelected,
    this.restStrength = 1.0,
    this.pressStrength = 1.0,
    this.radiusFactor = 0.40,
  });

  /// Currently selected destination (0-based).
  final int selectedIndex;

  /// Number of destinations.
  final int itemCount;

  /// The nav content the bubble magnifies (the `NavigationBar`).
  final Widget child;

  /// Callback when destination changes via slide or tap gesture.
  final ValueChanged<int>? onDestinationSelected;

  /// Lens strength at rest on the selected item.
  final double restStrength;

  /// Lens strength while the finger is down / during touch gesture.
  final double pressStrength;

  /// Optical radius as a fraction of one destination's width.
  final double radiusFactor;

  @override
  State<NavGlassBubble> createState() => _NavGlassBubbleState();
}

class _NavGlassBubbleState extends State<NavGlassBubble>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  final _FrameNotifier _frame = _FrameNotifier();

  ui.FragmentShader? _shader;

  Offset _center = Offset.zero; // pill-local logical px
  Offset _target = Offset.zero;
  double _strength = 1.0;
  double _targetStrength = 1.0;
  double _stretchX = 1;
  double _stretchY = 1;
  double _radius = 44;
  double _pillWidth = 0;
  double _pillHeight = 0;
  Duration? _lastElapsed;
  bool _down = false;

  double get _effectiveRestStrength =>
      debugLiquidGlass ? 1.25 : widget.restStrength;
  double get _effectivePressStrength =>
      debugLiquidGlass ? 1.50 : widget.pressStrength;

  @override
  void initState() {
    super.initState();
    ensureNavBubbleShader();
    navBubbleShaderReady.addListener(_onShaderReady);
    _onShaderReady();
    _targetStrength = _effectiveRestStrength;
    _strength = _effectiveRestStrength;
  }

  void _onShaderReady() {
    if (navBubbleShaderReady.value && _shader == null && mounted) {
      setState(() => _shader = _navBubbleProgram!.fragmentShader());
    }
  }

  @override
  void didUpdateWidget(NavGlassBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _target = _itemCenter(widget.selectedIndex);
      if (!_down) {
        _targetStrength = _effectiveRestStrength;
      }
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    navBubbleShaderReady.removeListener(_onShaderReady);
    super.dispose();
  }

  Offset _itemCenter(int index) {
    if (_pillWidth <= 0) return Offset.zero;
    return Offset(
      (index + 0.5) * _pillWidth / widget.itemCount,
      _pillHeight / 2,
    );
  }

  int _destinationIndexAt(double x) {
    if (_pillWidth <= 0) return widget.selectedIndex;
    final itemWidth = _pillWidth / widget.itemCount;
    return (x / itemWidth).floor().clamp(0, widget.itemCount - 1);
  }

  void _setTargetFromPointer(Offset local) {
    final inset = _radius * 0.5;
    _target = Offset(
      local.dx.clamp(inset, _pillWidth - inset),
      _pillHeight / 2,
    );
    _ticker.start();
  }

  void _onPointerDown(PointerDownEvent event) {
    _down = true;
    _targetStrength = _effectivePressStrength;
    _setTargetFromPointer(event.localPosition);
    final index = _destinationIndexAt(event.localPosition.dx);
    if (index != widget.selectedIndex) {
      HapticFeedback.selectionClick();
      widget.onDestinationSelected?.call(index);
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_down) {
      _setTargetFromPointer(event.localPosition);
      final index = _destinationIndexAt(event.localPosition.dx);
      if (index != widget.selectedIndex) {
        HapticFeedback.selectionClick();
        widget.onDestinationSelected?.call(index);
      }
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _down = false;
    final index = _destinationIndexAt(event.localPosition.dx);
    if (index != widget.selectedIndex) {
      HapticFeedback.selectionClick();
      widget.onDestinationSelected?.call(index);
    }
    _targetStrength = _effectiveRestStrength;
    _target = _itemCenter(widget.selectedIndex);
    _ticker.start();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _down = false;
    _targetStrength = _effectiveRestStrength;
    _target = _itemCenter(widget.selectedIndex);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final dt = _lastElapsed == null
        ? (1 / 60)
        : (elapsed - _lastElapsed!).inMicroseconds / 1e6;
    _lastElapsed = elapsed;

    final posK = 1 - math.exp(-18 * dt);
    final strK = 1 - math.exp(-20 * dt);
    _center = Offset.lerp(_center, _target, posK)!;
    _strength += (_targetStrength - _strength) * strK;

    // Fluid stretching along the travel axis
    final vel = (_target - _center) * 16;
    final speed = vel.distance;
    final stretch = (speed * 0.0008).clamp(0.0, 0.25);
    if (speed > 0.1) {
      if (vel.dx.abs() >= vel.dy.abs()) {
        _stretchX = 1 + stretch;
        _stretchY = 1 - stretch * 0.45;
      } else {
        _stretchY = 1 + stretch;
        _stretchX = 1 - stretch * 0.45;
      }
    } else {
      _stretchX += (1 - _stretchX) * strK;
      _stretchY += (1 - _stretchY) * strK;
    }

    _paint();
    if (_settled && !_down) _ticker.stop();
  }

  bool get _settled =>
      (_center - _target).distance < 0.4 &&
      (_strength - _targetStrength).abs() < 0.008 &&
      (_stretchX - 1).abs() < 0.01 &&
      (_stretchY - 1).abs() < 0.01;

  void _paint() {
    final shader = _shader;
    if (shader != null) {
      final renderBox = context.findRenderObject() as RenderBox?;
      final origin = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
      final media = MediaQuery.sizeOf(context);
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final centerGlobal = origin + _center;

      var i = 0;
      shader.setFloat(i++, media.width * dpr);
      shader.setFloat(i++, media.height * dpr);
      shader.setFloat(i++, centerGlobal.dx * dpr);
      shader.setFloat(i++, centerGlobal.dy * dpr);
      shader.setFloat(i++, _radius * dpr);
      shader.setFloat(i++, _strength);
      shader.setFloat(i++, _stretchX);
      shader.setFloat(i++, _stretchY);
      shader.setFloat(i++, 0.04);
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
    }
    _frame.notify();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    final shaderSupported = ui.ImageFilter.isShaderFilterSupported;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _pillWidth = constraints.maxWidth;
          _pillHeight = constraints.maxHeight;
          _radius =
              (constraints.maxWidth / widget.itemCount * widget.radiusFactor)
                  .clamp(24.0, 44.0);
          if (_target == Offset.zero && _pillWidth > 0) {
            _target = _itemCenter(widget.selectedIndex);
            _center = _target;
          }
          final capsuleWidth =
              (constraints.maxWidth / widget.itemCount * 0.78).clamp(54.0, 72.0);
          final capsuleHeight =
              (constraints.maxHeight * 0.70).clamp(42.0, 56.0);

          return ListenableBuilder(
            listenable: _frame,
            builder: (context, _) {
              final activeCenter =
                  _center == Offset.zero ? _itemCenter(widget.selectedIndex) : _center;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Sliding 3D Liquid Glass Capsule Indicator
                  if (_pillWidth > 0 && activeCenter != Offset.zero)
                    Positioned(
                      left: activeCenter.dx - (capsuleWidth / 2),
                      top: activeCenter.dy - (capsuleHeight / 2),
                      child: IgnorePointer(
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.diagonal3Values(
                              _stretchX, _stretchY, 1.0),
                          child: _NavGlassCapsule(
                            width: capsuleWidth,
                            height: capsuleHeight,
                            strength: _strength,
                            scheme: scheme,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ),

                  // 2. Nav content (icons, labels).
                  widget.child,

                  // 3. Optical deformation shader layer. Perf: only a small
                  //    box around the lens centre is filtered, not the whole
                  //    pill — the mask fades to exactly zero well inside
                  //    `_radius`, so outside the box the nav renders directly,
                  //    visually identical to the shader's passthrough, at a
                  //    fraction of the fill rate.
                  if (shaderSupported && _shader != null)
                    Builder(
                      builder: (context) {
                        final box = math.min(
                          _radius * 2.05,
                          math.min(_pillWidth, _pillHeight),
                        );
                        final left = (activeCenter.dx - box / 2)
                            .clamp(0.0, math.max(0.0, _pillWidth - box))
                            .toDouble();
                        final top = (activeCenter.dy - box / 2)
                            .clamp(0.0, math.max(0.0, _pillHeight - box))
                            .toDouble();
                        return Positioned(
                          left: left,
                          top: top,
                          width: box,
                          height: box,
                          child: IgnorePointer(
                            child: BackdropFilter(
                              filter: ui.ImageFilter.shader(_shader!),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// The 3D Liquid Glass active capsule indicator for the bottom navigation bar.
class _NavGlassCapsule extends StatelessWidget {
  const _NavGlassCapsule({
    required this.width,
    required this.height,
    required this.strength,
    required this.scheme,
    required this.isDark,
  });

  final double width;
  final double height;
  final double strength;
  final ColorScheme scheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(height / 2);
    final activeTint = scheme.primary.withValues(
      alpha: isDark ? 0.24 + (0.10 * strength) : 0.16 + (0.08 * strength),
    );

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: activeTint,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: isDark ? 0.20 : 0.35),
                  activeTint,
                  scheme.primary.withValues(
                    alpha: isDark ? 0.14 : 0.10,
                  ),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: isDark ? 0.40 + (0.15 * strength) : 0.65 + (0.15 * strength),
                ),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.08),
                  blurRadius: 6.0,
                  offset: const Offset(0, 2.0),
                ),
                BoxShadow(
                  color: scheme.primary.withValues(
                    alpha: (isDark ? 0.35 : 0.20) * strength.clamp(0.2, 1.0),
                  ),
                  blurRadius: 12.0,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 1.0),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Top Specular Highlight Arc
                Positioned(
                  top: 1.5,
                  left: 6.0,
                  right: 6.0,
                  height: height * 0.38,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(height * 0.19),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: isDark ? 0.55 : 0.75),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom ambient caustic bounce
                Positioned(
                  bottom: 1.5,
                  left: 8.0,
                  right: 8.0,
                  height: height * 0.25,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(height * 0.12),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          scheme.primary.withValues(alpha: isDark ? 0.30 : 0.40),
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
    );
  }
}