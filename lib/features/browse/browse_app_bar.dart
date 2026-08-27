import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/glass_pill.dart' show GlassHeader, GlassPill;
import '../widgets/glass_touch_button.dart';

/// Pinned top bar: centered "Al-Qur'an" title with the search action on the
/// right. Mirrors the home app bar so the shell's settings gear can sit below
/// it the same way (see app.dart). The hamburger from the Stitch design is
/// omitted: the shell already owns navigation (sidebar on desktop, bottom bar
/// on mobile), so a drawer affordance here would be a dead button.
class BrowseAppBar extends StatelessWidget {
  const BrowseAppBar({super.key, required this.searchOpen, required this.onToggleSearch});

  final bool searchOpen;
  final VoidCallback onToggleSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return GlassHeader(
      title: l10n.browseTitle,
      titleStyle: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: scheme.primary,
      ),
      trailing: GlassPill(
        padding: EdgeInsets.zero,
        child: GlassTouchButton(
          radius: AppLayout.radiusFull,
          child: IconButton(
            tooltip: searchOpen ? l10n.closeSearch : l10n.openSearch,
            isSelected: searchOpen,
            onPressed: onToggleSearch,
            icon: Icon(Icons.search_rounded, color: scheme.primary),
            selectedIcon: Icon(Icons.close_rounded, color: scheme.primary),
          ),
        ),
      ),
    );
  }
}
