import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import 'liquid_glass.dart';

/// A single option inside [GlassSegmented].
class GlassSegment<T> {
  const GlassSegment({required this.value, required this.label, this.icon});

  /// The value reported when this segment is selected.
  final T value;

  /// Short label shown under the icon.
  final String label;

  /// Optional leading icon (shown above the label, bottom-nav style).
  final IconData? icon;
}

/// Bottom-nav-style segmented control wrapped in the app's liquid-glass
/// chrome: a full-width [LiquidGlassLens] (glassChromeStyle + radiusFull +
/// useImpellerBackdrop + soft shadow — the same surface as the search pill)
/// holding a row of options, with a 3D liquid-glass capsule that slides to
/// the active option. Mirrors the bottom navigation's sliding glass capsule
/// ([NavGlassBubble]'s `_NavGlassCapsule`): the capsule is a convex glass
/// lens with a specular highlight arc, an ambient caustic bounce and a
/// primary glow, and it glides between segments with a springy ease.
///
/// Tapping a segment (or dragging horizontally across the control) selects
/// it; the active segment's icon + label render in the theme's primary color
/// on top of the capsule, the others stay muted.
class GlassSegmented<T> extends StatefulWidget {
  const GlassSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.height = 40,
  });

  /// The options, left to right.
  final List<GlassSegment<T>> segments;

  /// Currently selected value.
  final T selected;

  /// Called with the newly selected value.
  final ValueChanged<T> onSelectionChanged;

  /// Height of the control (the capsule insets 4px top/bottom).
  final double height;

  @override
  State<GlassSegmented<T>> createState() => _GlassSegmentedState<T>();
}

class _GlassSegmentedState<T> extends State<GlassSegmented<T>> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _indexOf(widget.selected);
  }

  @override
  void didUpdateWidget(GlassSegmented<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _selectedIndex = _indexOf(widget.selected);
    }
  }

  int _indexOf(T value) {
    final i = widget.segments.indexWhere((s) => s.value == value);
    return i < 0 ? 0 : i;
  }

  void _select(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    widget.onSelectionChanged(widget.segments[index].value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final segments = widget.segments;
    final n = segments.length;

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppLayout.radiusFull),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: LiquidGlassLens(
          style: glassChromeStyle(context, cornerRadius: AppLayout.radiusFull),
          useImpellerBackdrop: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final itemWidth = width / n;
              final capsuleWidth = itemWidth - 8;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Drag across the control selects like the bottom nav.
                onHorizontalDragUpdate: (d) {
                  final index = (d.localPosition.dx / itemWidth).floor().clamp(
                    0,
                    n - 1,
                  );
                  if (index != _selectedIndex) _select(index);
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Sliding 3D liquid-glass capsule indicator.
                    AnimatedPositioned(
                      duration: AppLayout.durPanel,
                      curve: Curves.easeOutCubic,
                      left: _selectedIndex * itemWidth + 4,
                      top: 4,
                      bottom: 4,
                      width: capsuleWidth,
                      child: IgnorePointer(
                        child: _GlassCapsule(scheme: scheme, isDark: isDark),
                      ),
                    ),
                    // Options row.
                    Row(
                      children: [
                        for (var i = 0; i < n; i++)
                          Expanded(
                            child: _GlassSegmentButton(
                              segment: segments[i],
                              active: i == _selectedIndex,
                              onTap: () => _select(i),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The 3D liquid-glass capsule indicator — the same convex lens language as
/// the bottom navigation's active capsule: a primary-tinted glass body with a
/// white specular arc on top, an ambient caustic bounce at the bottom, a
/// bright hairline rim and a soft drop + primary glow shadow.
class _GlassCapsule extends StatelessWidget {
  const _GlassCapsule({required this.scheme, required this.isDark});

  final ColorScheme scheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final activeTint = scheme.primary.withValues(
          alpha: isDark ? 0.26 : 0.18,
        );
        return ClipRRect(
          borderRadius: BorderRadius.circular(h / 2),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(h / 2),
                color: activeTint,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.20 : 0.35),
                    activeTint,
                    scheme.primary.withValues(alpha: isDark ? 0.14 : 0.10),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.40 : 0.65),
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
                      alpha: isDark ? 0.35 : 0.20,
                    ),
                    blurRadius: 12.0,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 1.0),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Top specular highlight arc (convex dome reflection).
                  Positioned(
                    top: 1.5,
                    left: 6.0,
                    right: 6.0,
                    height: h * 0.38,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(h * 0.19),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(
                              alpha: isDark ? 0.55 : 0.75,
                            ),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bottom ambient caustic bounce.
                  Positioned(
                    bottom: 1.5,
                    left: 8.0,
                    right: 8.0,
                    height: h * 0.25,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(h * 0.12),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            scheme.primary.withValues(
                              alpha: isDark ? 0.30 : 0.40,
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
        );
      },
    );
  }
}

/// One tappable option inside [GlassSegmented]: the active one renders its
/// icon + label in the theme's primary color on top of the capsule, the rest
/// stay muted.
class _GlassSegmentButton extends StatelessWidget {
  const _GlassSegmentButton({
    required this.segment,
    required this.active,
    required this.onTap,
  });

  final GlassSegment<dynamic> segment;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = active ? scheme.primary : scheme.onSurfaceVariant;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppLayout.radiusFull),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (segment.icon != null) ...[
              Icon(segment.icon, size: 16, color: color),
              const SizedBox(height: 2),
            ],
            Text(
              segment.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
