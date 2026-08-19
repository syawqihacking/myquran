import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import 'liquid_glass.dart';

/// Floating liquid-glass pill for the app's pinned headers: a soft drop
/// shadow + a rounded [LiquidGlassLens] that sizes to its content, so each
/// pill stays compact (title text + padding, or the action button) instead
/// of stretching to fill the parent.
///
/// Used in pairs by the header pattern — a compact title pill centered on
/// screen, with action pills (back / search) at the edges — on the home,
/// browse and detail screens.
class GlassPill extends StatelessWidget {
  const GlassPill({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppLayout.sp4,
      vertical: AppLayout.sp2,
    ),
  });

  /// Content wrapped by the glass.
  final Widget child;

  /// Inner padding. Pass [EdgeInsets.zero] for button pills so they stay
  /// exactly as big as the button.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
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
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Floating glass header: a compact [GlassPill] title centered on screen,
/// with an optional action pill ([leading] back / [trailing] search) pinned
/// to the edge — each pill is its own compact liquid-glass lens, never a
/// shared full-width bar. The whole header is inset from the screen edges
/// (sp4) so it floats instead of spanning edge-to-edge — the shared pattern
/// behind the home, browse and detail-screen headers.
///
/// The side opposite an action pill is balanced with a spacer of the same
/// width, so the title stays visually centered.
class GlassHeader extends StatelessWidget {
  const GlassHeader({
    super.key,
    required this.title,
    required this.titleStyle,
    this.leading,
    this.trailing,
    this.leadingBalanceWidth = AppLayout.sp9,
    this.trailingBalanceWidth = AppLayout.sp9,
  });

  /// Header title text.
  final String title;

  /// Style applied to the title (each screen keeps its own typography).
  final TextStyle? titleStyle;

  /// Action pill pinned to the left edge (e.g. a back button).
  final Widget? leading;

  /// Action pill pinned to the right edge (e.g. a search button).
  final Widget? trailing;

  /// Width of the invisible spacer balancing [leading] (matches the pill).
  final double leadingBalanceWidth;

  /// Width of the invisible spacer balancing [trailing] (matches the pill).
  final double trailingBalanceWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Inset from the screen edges so the pills float, not span edge-to-edge.
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp4,
        vertical: AppLayout.sp2,
      ),
      child: SizedBox(
        // Pins the header row to the action pill's height so the centered
        // title pill and the edge pill share one line.
        height: AppLayout.sp10 + AppLayout.sp2,
        child: Row(
          children: [
            if (leading != null)
              leading!
            else
              SizedBox(width: leadingBalanceWidth),
            // Title pill — compact, wraps only the text + its own padding.
            Expanded(
              child: Center(
                child: GlassPill(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                  ),
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else
              SizedBox(width: trailingBalanceWidth),
          ],
        ),
      ),
    );
  }
}