import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/glass_touch_button.dart';

/// The design's full-width rounded search bar. Not a real field — it opens the
/// search panel (which auto-focuses its own field). Hover turns the border
/// primary, echoing the design's focus state on desktop.
class SearchBarTrigger extends StatefulWidget {
  const SearchBarTrigger({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<SearchBarTrigger> createState() => SearchBarTriggerState();
}

class SearchBarTriggerState extends State<SearchBarTrigger> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GlassTouchButton(
        radius: AppLayout.radiusFull,
        child: AnimatedContainer(
          duration: AppLayout.durBase,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppLayout.radiusFull),
            border: Border.all(
              color: _hovered ? scheme.primary : scheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppLayout.radiusFull),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppLayout.radiusFull),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.sp4,
                  vertical: AppLayout.sp3,
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: scheme.outline),
                    const SizedBox(width: AppLayout.sp3),
                    Text(
                      l10n.browseSearchHint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
