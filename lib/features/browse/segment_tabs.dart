import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';

/// Segments of the unified Al-Qur'an page (the list tabs). Pencarian bukan
/// segmen — ia mode yang menimpa area daftar (lihat [BrowseState.searchOpen]).
enum BrowseSegment { surah, juz, favorit }

/// Surah / Juz / Favorit tabs: headline-sized labels, a 2px primary underline
/// on the active tab, and a thin divider under the whole strip.
class SegmentTabs extends StatelessWidget {
  const SegmentTabs({super.key, required this.segment, required this.onChanged});

  final BrowseSegment segment;
  final ValueChanged<BrowseSegment> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          // Thin divider under the whole tab strip.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TabButton(
                label: l10n.surahSegment,
                selected: segment == BrowseSegment.surah,
                onTap: () => onChanged(BrowseSegment.surah),
              ),
              const SizedBox(width: AppLayout.sp6),
              TabButton(
                label: l10n.juzSegment,
                selected: segment == BrowseSegment.juz,
                onTap: () => onChanged(BrowseSegment.juz),
              ),
              const SizedBox(width: AppLayout.sp6),
              TabButton(
                label: l10n.favoritSegment,
                selected: segment == BrowseSegment.favorit,
                onTap: () => onChanged(BrowseSegment.favorit),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TabButton extends StatelessWidget {
  const TabButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp1),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? scheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 20,
              height: 28 / 20,
              fontWeight: FontWeight.w600,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
