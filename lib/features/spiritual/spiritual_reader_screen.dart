import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/models/spiritual_content.dart';
import '../widgets/liquid_glass.dart';
import '../widgets/quran_text_view.dart';

/// Reader screen for spiritual content (Tahlil, Doa, Ratib Al-Haddad),
/// remodeled to the Stitch "Tahlil & Doa" design: a pinned app bar, a scroll
/// progress bar, a header card with an Islamic geometric watermark, numbered
/// card tiles (badge + title, Arabic, transliteration, translation, repeat
/// chip), and an audio FAB that honestly reports "coming soon".
///
/// Used from three places — the Tahlil hub, the Ratib hub, and the Doa Harian
/// detail — so the header card derives its title/description from the passed
/// [title]/[subtitle] (with a dedicated Tahlil copy when the title matches).
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

  /// The Tahlil hub passes `S.tahlilTitle`; give that screen the design's
  /// dedicated header copy, and fall back to title/subtitle for everyone else
  /// (Ratib, Doa Harian detail).
  bool get _isTahlil => widget.title == S.tahlilTitle;

  void _showComingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(S.audioComingSoon),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1800),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).maybePop(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: scheme.surface,
          body: Stack(
            children: [
              Column(
                children: [
                  _TopBar(
                    title: widget.title,
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  _ProgressBar(progress: _progress),
                  Expanded(
                    child: Scrollbar(
                      controller: _scroll,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.fromLTRB(
                              AppLayout.sp6,
                              AppLayout.sp4,
                              AppLayout.sp6,
                              AppLayout.sp8,
                            ),
                            itemCount: widget.items.length + 2, // header + items + footer
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return _SpiritualHeader(
                                  title:
                                      _isTahlil ? S.tahlilHeaderTitle : widget.title,
                                  description:
                                      _isTahlil ? S.tahlilHeaderDesc : widget.subtitle,
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
                ],
              ),
              // Gradient fade from the surface behind the FAB (design §FAB).
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          scheme.surface,
                          scheme.surface.withValues(alpha: 0.9),
                          scheme.surface.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: _AudioFab(onPressed: _showComingSoon),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar (Stitch §1): back + centered title, no more_vert.
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      height: AppLayout.sp10,
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp2),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: S.back,
            icon: const Icon(Icons.arrow_back_rounded),
            color: scheme.primary,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
                height: 28 / 20,
                fontWeight: FontWeight.w600,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 48), // balances the back button
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress bar (kept — existing scroll-progress feature).
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
// Header card (Stitch §2): watermark pattern + title + description + count.
// ---------------------------------------------------------------------------

class _SpiritualHeader extends StatelessWidget {
  const _SpiritualHeader({
    required this.title,
    required this.description,
    required this.itemCount,
  });

  final String title;
  final String description;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppLayout.sp6),
      child: Container(
        padding: const EdgeInsets.all(AppLayout.sp6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Subtle 8-pointed-star watermark at ~5% opacity (prayer_screen
            // pattern), echoing the design's geometric background.
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(
                  painter: _GeometricPatternPainter(color: scheme.primary),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    height: 32 / 24,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: AppLayout.sp3),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    height: 24 / 16,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppLayout.sp4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppLayout.sp3,
                    vertical: AppLayout.sp1,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                  ),
                  child: Text(
                    '$itemCount bacaan',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Item tile (Stitch §3): numbered card with Arabic, transliteration,
// translation, and an optional repeat chip.
// ---------------------------------------------------------------------------

class _SpiritualItemTile extends StatelessWidget {
  const _SpiritualItemTile({required this.item, required this.number});

  final SpiritualItem item;
  final int number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final item = this.item;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppLayout.sp4),
      child: Container(
        padding: const EdgeInsets.all(AppLayout.sp6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Number badge + title.
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.secondaryContainer,
                  ),
                  child: Text(
                    '$number',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: AppLayout.sp3),
                Expanded(
                  child: Text(
                    item.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      height: 28 / 20,
                      fontWeight: FontWeight.w600,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            // Short instruction note, when present (e.g. "Lanjut membaca
            // Al-Fatihah").
            if (item.note.isNotEmpty) ...[
              const SizedBox(height: AppLayout.sp2),
              Text(
                item.note,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.tertiary,
                ),
              ),
            ],
            const SizedBox(height: AppLayout.sp6),
            // Arabic, Amiri, right-aligned.
            QTextDisplay(
              text: item.arabic,
              step: 4,
              alignment: TextAlign.right,
              color: scheme.onSurface,
            ),
            const SizedBox(height: AppLayout.sp6),
            // Transliteration (only when present).
            if (item.transliteration.isNotEmpty) ...[
              Text(
                item.transliteration,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  height: 24 / 16,
                  fontStyle: FontStyle.italic,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: AppLayout.sp3),
            ],
            // Translation.
            Text(
              item.translation,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                height: 24 / 16,
                color: scheme.onSurfaceVariant,
              ),
            ),
            // Repeat chip (only when repeated).
            if (item.repeatCount > 1) ...[
              const SizedBox(height: AppLayout.sp6),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppLayout.sp3,
                    vertical: AppLayout.sp1,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                  ),
                  child: Text(
                    S.readNTimes(item.repeatCount),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6, // tracking-wider on label-sm
                      color: scheme.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Audio FAB (Stitch §FAB): 56px primary circle with a strong shadow. Audio is
// not available yet — the tap gives honest "coming soon" feedback.
// ---------------------------------------------------------------------------

class _AudioFab extends StatelessWidget {
  const _AudioFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: S.audioPlay,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.play_arrow_rounded, size: 28),
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
          LiquidGlassButton.filled(
            onPressed: () => Navigator.of(context).maybePop(),
            label: S.back,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Islamic geometric watermark: a grid of 8-pointed stars (two squares per
// cell, one rotated 45°). Purely decorative — same pattern as the qibla card.
// ---------------------------------------------------------------------------

class _GeometricPatternPainter extends CustomPainter {
  const _GeometricPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const cell = 56.0;
    for (var y = -cell; y < size.height + cell; y += cell) {
      for (var x = -cell; x < size.width + cell; x += cell) {
        final c = Offset(x + cell / 2, y + cell / 2);
        final r = cell * 0.34;
        _drawSquare(canvas, paint, c, r, 0);
        _drawSquare(canvas, paint, c, r, math.pi / 4);
      }
    }
  }

  void _drawSquare(
    Canvas canvas,
    Paint paint,
    Offset center,
    double r,
    double rotation,
  ) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a = rotation + i * math.pi / 2;
      final p = center + Offset(math.cos(a), math.sin(a)) * r;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GeometricPatternPainter oldDelegate) =>
      oldDelegate.color != color;
}