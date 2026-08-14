import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../core/quran_palette.dart';
import '../../data/models/spiritual_content.dart';

/// Reader screen for spiritual content (Tahlil, Doa, Ratib Al-Haddad).
/// Mirrors the Quran reader's paper-column aesthetic while adapting layout
/// for discrete items (doa entries) rather than continuous surah text.
class SpiritualReaderScreen extends StatefulWidget {
  const SpiritualReaderScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final List<SpiritualItem> items;
  final IconData icon;

  @override
  State<SpiritualReaderScreen> createState() => _SpiritualReaderScreenState();
}

class _SpiritualReaderScreenState extends State<SpiritualReaderScreen> {
  final ScrollController _scroll = ScrollController();
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_updateProgress);
  }

  @override
  void dispose() {
    _scroll.removeListener(_updateProgress);
    _scroll.dispose();
    super.dispose();
  }

  void _updateProgress() {
    final max = _scroll.position.maxScrollExtent;
    final p = max > 0 ? (_scroll.offset / max).clamp(0.0, 1.0) : 0.0;
    if ((p - _progress).abs() > 0.002) {
      setState(() => _progress = p);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).maybePop(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              _TopBar(
                title: widget.title,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              _ProgressBar(progress: _progress),
              Expanded(
                child: Scrollbar(
                  controller: _scroll,
                  child: Padding(
                    padding: const EdgeInsets.all(AppLayout.sp6),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.quran.quranSurface,
                            borderRadius:
                                BorderRadius.circular(AppLayout.radiusLg),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppLayout.sp6,
                              vertical: AppLayout.sp6,
                            ),
                            itemCount: widget.items.length + 2, // header + items + footer
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return _SpiritualHeader(
                                  title: widget.title,
                                  subtitle: widget.subtitle,
                                  icon: widget.icon,
                                  itemCount: widget.items.length,
                                );
                              }
                              if (index <= widget.items.length) {
                                final item = widget.items[index - 1];
                                return _SpiritualItemTile(
                                  item: item,
                                  number: index,
                                );
                              }
                              // Footer
                              return _EndFooter(title: widget.title);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: AppLayout.readerTopBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: 'Kembali',
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 48), // balance the back button
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress bar
// ---------------------------------------------------------------------------

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: AppLayout.progressBarHeight,
      color: scheme.surfaceContainerHighest,
      child: LayoutBuilder(
        builder: (ctx, c) => AnimatedContainer(
          duration: AppLayout.durBase,
          curve: Curves.easeOut,
          width: c.maxWidth * progress,
          color: scheme.primary,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _SpiritualHeader extends StatelessWidget {
  const _SpiritualHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.itemCount,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppLayout.sp6),
      child: Column(
        children: [
          const SizedBox(height: AppLayout.sp6),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            ),
            child: Icon(
              icon,
              size: 36,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppLayout.sp4),
          Text(
            title,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppLayout.sp2),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppLayout.sp2),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.sp3,
              vertical: AppLayout.sp1,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppLayout.radiusFull),
            ),
            child: Text(
              '$itemCount bacaan',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppLayout.sp6),
          Divider(color: theme.colorScheme.outlineVariant),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Item tile
// ---------------------------------------------------------------------------

class _SpiritualItemTile extends StatefulWidget {
  const _SpiritualItemTile({
    required this.item,
    required this.number,
  });

  final SpiritualItem item;
  final int number;

  @override
  State<_SpiritualItemTile> createState() => _SpiritualItemTileState();
}

class _SpiritualItemTileState extends State<_SpiritualItemTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppLayout.sp4),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title bar
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(AppLayout.radiusMd),
              child: Padding(
                padding: const EdgeInsets.all(AppLayout.sp4),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius:
                            BorderRadius.circular(AppLayout.radiusSm),
                      ),
                      child: Text(
                        '${widget.number}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppLayout.sp3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: theme.textTheme.titleSmall,
                          ),
                          if (item.repeatCount > 1 || item.note.isNotEmpty)
                            Text(
                              item.note.isNotEmpty
                                  ? item.note
                                  : '${item.repeatCount}×',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: AppLayout.durBase,
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Arabic text (always visible)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.sp4,
              ),
              child: Text(
                item.arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: AppConstants.fontQuran,
                  fontSize: 26,
                  height: 2.0,
                  color: context.quran.quranInk,
                ),
              ),
            ),
            const SizedBox(height: AppLayout.sp3),
            // Expanded content: transliteration + translation
            AnimatedCrossFade(
              duration: AppLayout.durBase,
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.sp4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.transliteration.isNotEmpty) ...[
                      Text(
                        item.transliteration,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(height: AppLayout.sp3),
                    ],
                    Text(
                      item.translation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppLayout.sp4),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// End footer
// ---------------------------------------------------------------------------

class _EndFooter extends StatelessWidget {
  const _EndFooter({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppLayout.sp8),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppLayout.sp4),
          Text(
            'Selesai membaca $title',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppLayout.sp2),
          Text(
            'Semoga Allah menerima amalan kita. Aamiin.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppLayout.sp6),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Kembali ke Beranda'),
          ),
        ],
      ),
    );
  }
}
