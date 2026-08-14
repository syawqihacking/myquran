import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/models/ratib_data.dart';
import '../../data/models/spiritual_content.dart';
import '../../data/models/tahlil_doa_data.dart';
import 'spiritual_reader_screen.dart';

/// Spiritual home — the browse page for Tahlil, Doa, and Ratib Al-Haddad.
class SpiritualScreen extends StatelessWidget {
  const SpiritualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp6,
        vertical: AppLayout.sp8,
      ),
      children: [
        Text(
          'IBADAH',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: AppLayout.sp2),
        Text('Wirid & Doa', style: theme.textTheme.displaySmall),
        const SizedBox(height: AppLayout.sp2),
        Text(
          'Tahlil, kumpulan doa harian, dan Ratib Al-Haddad lengkap dengan teks Arab dan terjemahan.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppLayout.sp7),

        // --- Tahlil & Doa card ---
        _SpiritualCard(
          icon: Icons.auto_stories_rounded,
          title: S.tahlilTitle,
          caption: S.tahlilCaption,
          gradient: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
            theme.colorScheme.tertiaryContainer.withValues(alpha: 0.4),
          ],
          onTap: () => _openReader(
            context,
            title: S.tahlilTitle,
            subtitle: S.tahlilCaption,
            items: tahlilDoaItems,
            icon: Icons.auto_stories_rounded,
          ),
        ),
        const SizedBox(height: AppLayout.sp4),

        // --- Ratib Al-Haddad card ---
        _SpiritualCard(
          icon: Icons.brightness_5_rounded,
          title: S.ratibTitle,
          caption: S.ratibCaption,
          gradient: [
            theme.colorScheme.tertiaryContainer.withValues(alpha: 0.6),
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
          ],
          onTap: () => _openReader(
            context,
            title: S.ratibTitle,
            subtitle: S.ratibCaption,
            items: ratibAlHaddadItems,
            icon: Icons.brightness_5_rounded,
          ),
        ),
        const SizedBox(height: AppLayout.sp7),

        // --- Info section ---
        Container(
          padding: const EdgeInsets.all(AppLayout.sp4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: AppLayout.sp3),
              Expanded(
                child: Text(
                  'Semua bacaan tersimpan offline — bisa dibaca kapan saja tanpa sambungan internet.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openReader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<SpiritualItem> items,
    required IconData icon,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SpiritualReaderScreen(
          title: title,
          subtitle: subtitle,
          items: items,
          icon: icon,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card widget for each spiritual category
// ---------------------------------------------------------------------------

class _SpiritualCard extends StatefulWidget {
  const _SpiritualCard({
    required this.icon,
    required this.title,
    required this.caption,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String caption;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  State<_SpiritualCard> createState() => _SpiritualCardState();
}

class _SpiritualCardState extends State<_SpiritualCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppLayout.durBase,
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppLayout.sp6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradient,
            ),
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            border: Border.all(
              color: _hovered
                  ? theme.colorScheme.primary.withValues(alpha: 0.4)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                ),
                child: Icon(
                  widget.icon,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppLayout.sp4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.caption,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
