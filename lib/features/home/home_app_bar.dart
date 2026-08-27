import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/glass_pill.dart';
import '../widgets/liquid_glass.dart';

/// Floating glass header: the centered "Al-Qur'an" title and the search
/// action live in TWO separate compact liquid-glass pills — a title pill
/// and a search pill — NOT one full-width bar and not one shared lens.
/// Both are inset from the screen edges (sp4) and pinned at the top, so
/// scrolling content refracts through the glass behind them while the
/// title stays centered and the search button keeps working as before.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({required this.onOpenSearch});

  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      // Inset from the screen edges so the pills float, not span edge-to-edge.
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp4,
        vertical: AppLayout.sp2,
      ),
      child: SizedBox(
        // Pins the header row to the search button's height (48px) so the
        // centered title pill and the right-edge search pill share one line.
        height: AppLayout.sp10 + AppLayout.sp2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Title pill — compact, wraps only the text + its own padding.
            GlassPill(
              child: Text(
                l10n.browseTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ),
            // Search pill — compact, sized to the button.
            Positioned(
              right: 0,
              child: GlassPill(
                padding: EdgeInsets.zero,
                child: GlassTouchButton(
                  radius: AppLayout.radiusFull,
                  child: IconButton(
                    onPressed: onOpenSearch,
                    tooltip: l10n.openSearch,
                    icon: Icon(
                      Icons.search_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
