import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/ratib_data.dart';
import '../../data/models/spiritual_content.dart';
import '../../data/providers.dart';
import '../../data/services/audio_service.dart';
import '../widgets/glass_pill.dart';
import '../widgets/liquid_glass.dart';
import '../widgets/quran_text_view.dart';

/// Ratibul Haddad (Stitch design): a pinned app bar, a scroll progress bar, an
/// intro card with a mosque watermark, numbered dhikr cards (type/repeat chip,
/// Arabic, transliteration, translation, interactive repeat counter), and a
/// fixed bottom audio bar streaming the Ratib Al-Haddad recitation.
class RatibulHaddadScreen extends StatefulWidget {
  const RatibulHaddadScreen({super.key});

  @override
  State<RatibulHaddadScreen> createState() => _RatibulHaddadScreenState();
}

class _RatibulHaddadScreenState extends State<RatibulHaddadScreen> {
  final ScrollController _scroll = ScrollController();
  double _progress = 0;

  /// Session-only repeat counters, keyed by item id (never persisted).
  final Map<int, int> _counts = {};

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

  int _countOf(int id) => _counts[id] ?? 0;

  void _increment(int id, int total) {
    final current = _countOf(id);
    if (current < total) {
      setState(() => _counts[id] = current + 1);
    }
  }

  void _reset(int id) {
    if (_countOf(id) > 0) {
      setState(() => _counts[id] = 0);
    }
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
              // Content fills the screen and scrolls behind the floating
              // glass header pills — exactly like the home header.
              Positioned.fill(
                child: Column(
                  children: [
                    _ProgressBar(progress: _progress),
                    Expanded(
                      child: Scrollbar(
                        controller: _scroll,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 760),
                            child: ListView.builder(
                              controller: _scroll,
                              // Bottom padding clears the fixed audio bar.
                              padding: const EdgeInsets.fromLTRB(
                                AppLayout.sp6,
                                AppLayout.sp10 + AppLayout.sp4,
                                AppLayout.sp6,
                                AppLayout.sp11,
                              ),
                              itemCount:
                                  ratibAlHaddadItems.length +
                                  2, // intro + items + footer
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return const _IntroCard();
                                }
                                if (index <= ratibAlHaddadItems.length) {
                                  final item = ratibAlHaddadItems[index - 1];
                                  return _RatibItemCard(
                                    item: item,
                                    number: index,
                                    count: _countOf(item.id),
                                    onIncrement: () =>
                                        _increment(item.id, item.repeatCount),
                                    onReset: () => _reset(item.id),
                                  );
                                }
                                return const _EndFooter();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Floating glass header pills, over the content.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _RatibAppBar(
                  onBack: () => Navigator.of(context).maybePop(),
                ),
              ),
              // Fixed bottom audio bar (overlays content, per design).
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: const _AudioBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// App bar (Stitch §TopAppBar): 40px back circle + centered title + spacer.
// ---------------------------------------------------------------------------

class _RatibAppBar extends StatelessWidget {
  const _RatibAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return GlassHeader(
      title: l10n.ratibulHaddadTitle,
      titleStyle: theme.textTheme.titleLarge?.copyWith(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5, // tracking-tight
        color: scheme.primary,
      ),
      leading: GlassPill(
        padding: EdgeInsets.zero,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onBack,
            tooltip: l10n.back,
            padding: EdgeInsets.zero,
            icon: Icon(Icons.arrow_back_rounded, color: scheme.primary),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress bar (same feature as the spiritual reader).
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
// Intro card (Stitch §Intro Card): mosque watermark + chip + title + desc.
// ---------------------------------------------------------------------------

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppLayout.sp6),
      child: Container(
        padding: const EdgeInsets.all(AppLayout.sp6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          border: Border.all(color: scheme.surfaceContainerHighest),
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
            // Mosque watermark, top-right, ~5% opacity.
            Positioned(
              top: -64,
              right: -64,
              child: Opacity(
                opacity: 0.05,
                child: Icon(
                  Icons.mosque_rounded,
                  size: 256,
                  color: scheme.primary,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppLayout.sp3,
                    vertical: AppLayout.sp1,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 16,
                        color: scheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: AppLayout.sp1),
                      Text(
                        l10n.ratibIntroChip,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppLayout.sp4),
                Text(
                  l10n.ratibulHaddadTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    height: 32 / 24,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: AppLayout.sp2),
                Text(
                  l10n.ratibIntroDesc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    height: 24 / 16,
                    color: scheme.onSurfaceVariant,
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
// Dhikr item card (Stitch §Dhikr List): number badge, type/repeat chip,
// Arabic, transliteration, translation, and an interactive repeat counter.
// ---------------------------------------------------------------------------

class _RatibItemCard extends StatefulWidget {
  const _RatibItemCard({
    required this.item,
    required this.number,
    required this.count,
    required this.onIncrement,
    required this.onReset,
  });

  final SpiritualItem item;
  final int number;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onReset;

  @override
  State<_RatibItemCard> createState() => _RatibItemCardState();
}

class _RatibItemCardState extends State<_RatibItemCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final item = widget.item;
    final isRepeat = item.repeatCount > 1;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppLayout.durBase,
        curve: Curves.easeOut,
        // Design hover: -translate-y-1.
        transform: _hovered ? Matrix4.translationValues(0, -4, 0) : null,
        margin: const EdgeInsets.only(bottom: AppLayout.sp4),
        padding: const EdgeInsets.all(AppLayout.sp6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          border: Border.all(color: scheme.surfaceContainerHighest),
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
            // Number badge + type/repeat chip.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primaryContainer,
                  ),
                  child: Text(
                    '${widget.number}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      height: 28 / 20,
                      fontWeight: FontWeight.w600,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const Spacer(),
                if (isRepeat)
                  _RepeatChip(count: item.repeatCount)
                else if (item.label.isNotEmpty)
                  _TypeChip(label: item.label),
              ],
            ),
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
                  color: scheme.outline,
                ),
              ),
              const SizedBox(height: AppLayout.sp4),
            ],
            // Translation (separated by a top border) + repeat counter.
            Container(
              padding: const EdgeInsets.only(top: AppLayout.sp4),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: scheme.surfaceContainerHighest),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      item.translation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        height: 24 / 16,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (isRepeat) ...[
                    const SizedBox(width: AppLayout.sp3),
                    _RepeatCounter(
                      count: widget.count,
                      total: item.repeatCount,
                      onIncrement: widget.onIncrement,
                      onReset: widget.onReset,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Number badge fill — primaryContainer, resolved at build time.
class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp3,
        vertical: AppLayout.sp1,
      ),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppLayout.radiusFull),
        border: Border.all(color: scheme.tertiary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_rounded, size: 16, color: scheme.tertiary),
          const SizedBox(width: AppLayout.sp1),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: scheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RepeatChip extends StatelessWidget {
  const _RepeatChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp3,
        vertical: AppLayout.sp1,
      ),
      decoration: BoxDecoration(
        color: scheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppLayout.radiusFull),
        border: Border.all(color: scheme.secondary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.repeat_rounded, size: 16, color: scheme.secondary),
          const SizedBox(width: AppLayout.sp1),
          Text(
            l10n.readNTimes(count),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: scheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Interactive repeat counter ("Hitung 0/N"). Tap to count up to N, small
// refresh button to reset. Session state only.
// ---------------------------------------------------------------------------

class _RepeatCounter extends StatelessWidget {
  const _RepeatCounter({
    required this.count,
    required this.total,
    required this.onIncrement,
    required this.onReset,
  });

  final int count;
  final int total;
  final VoidCallback onIncrement;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final done = count >= total;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Material(
          color: done ? scheme.secondaryContainer : scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppLayout.radiusSm),
          child: InkWell(
            onTap: onIncrement,
            borderRadius: BorderRadius.circular(AppLayout.radiusSm),
            child: Container(
              constraints: const BoxConstraints(minWidth: 60),
              padding: const EdgeInsets.all(AppLayout.sp2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.counterLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.outline,
                    ),
                  ),
                  const SizedBox(height: AppLayout.sp1),
                  Text(
                    '$count/$total',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      height: 28 / 20,
                      fontWeight: FontWeight.w600,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppLayout.sp1),
        IconButton(
          onPressed: onReset,
          tooltip: l10n.counterReset,
          icon: Icon(Icons.refresh_rounded, size: 16, color: scheme.outline),
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom audio bar (Stitch §Audio Playback Control). Streams a single
// continuous Ratib Al-Haddad file via `ratibAudioServiceProvider`: the play
// button toggles play/pause/resume and the timing shows real position/duration.
// ---------------------------------------------------------------------------

class _AudioBar extends ConsumerStatefulWidget {
  const _AudioBar();

  @override
  ConsumerState<_AudioBar> createState() => _AudioBarState();
}

class _AudioBarState extends ConsumerState<_AudioBar> {
  StreamSubscription<AudioPlaybackState>? _sub;
  AudioPlaybackState _state = const AudioPlaybackState.idle();

  @override
  void initState() {
    super.initState();
    _sub = ref.read(ratibAudioServiceProvider).stateStream.listen((state) {
      if (!mounted) return;
      setState(() => _state = state);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  bool get _isPlaying =>
      _state.status == AudioStatus.playing ||
      _state.status == AudioStatus.buffering;

  void _toggle() {
    final service = ref.read(ratibAudioServiceProvider);
    switch (_state.status) {
      case AudioStatus.playing:
      case AudioStatus.buffering:
        service.pause();
      case AudioStatus.paused:
        service.resume();
      case AudioStatus.idle:
        service.play();
    }
  }

  /// Real position/duration as `mm:ss / mm:ss` (all platforms).
  String get _timing {
    String fmt(Duration d) {
      final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$m:$s';
    }

    return '${fmt(_state.position)} / ${fmt(_state.duration)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final buffering = _state.status == AudioStatus.buffering;

    return Container(
      decoration: BoxDecoration(
        // Solid (near-opaque) surface — no BackdropFilter, which caused a
        // whole-screen blur on some Android GPUs. The bar stays readable on
        // its own, no frosted-glass needed.
        color: scheme.surface.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: scheme.surfaceContainerHighest)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.sp6,
            vertical: AppLayout.sp3,
          ),
          child: Row(
            children: [
              // Left: avatar + track title.
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppLayout.radiusSm),
                      ),
                      child: Icon(
                        Icons.graphic_eq_rounded,
                        size: 24,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: AppLayout.sp3),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.playingLabel.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.ratibFullTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Timing — real position/duration, on all platforms.
              Text(
                _timing,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.outline,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: AppLayout.sp4),
              // Play/pause toggle (spinner while buffering).
              _PlayButton(
                playing: _isPlaying,
                buffering: buffering,
                onTap: _toggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 48px play/pause button inside a 56px decorative gold progress ring. Shows a
/// small spinner while buffering.
class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.playing,
    required this.buffering,
    required this.onTap,
  });

  final bool playing;
  final bool buffering;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CustomPaint(
              painter: _ProgressRingPainter(
                track: scheme.surfaceContainerHighest,
                progress: scheme.tertiaryFixedDim,
                sweep: 0.75, // decorative, mirrors the design's ring
              ),
            ),
          ),
          Material(
            color: scheme.primary,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 48,
                height: 48,
                child: buffering
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: scheme.onPrimary,
                        ),
                      )
                    : Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 28,
                        color: scheme.onPrimary,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({
    required this.track,
    required this.progress,
    required this.sweep,
  });

  final Color track;
  final Color progress;
  final double sweep;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 2;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, trackPaint);
    if (sweep > 0) {
      final progressPaint = Paint()
        ..color = progress
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * sweep,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      oldDelegate.track != track ||
      oldDelegate.progress != progress ||
      oldDelegate.sweep != sweep;
}

// ---------------------------------------------------------------------------
// End footer
// ---------------------------------------------------------------------------

class _EndFooter extends StatelessWidget {
  const _EndFooter();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            'Selesai membaca ${l10n.ratibulHaddadTitle}',
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
            label: l10n.back,
          ),
        ],
      ),
    );
  }
}
