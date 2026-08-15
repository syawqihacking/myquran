import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/providers.dart';
import '../../data/services/prayer_time_service.dart';

/// Jadwal Sholat — the horizontally scrollable strip of the five daily
/// prayers (Stitch Beranda §5).
///
/// The next upcoming prayer is highlighted on the deep-emerald
/// `primaryContainer` with a pulsing gold dot and a live per-second countdown
/// underneath the time; prayers that have already passed sit at reduced
/// opacity. A header row carries the section title and the schedule location.
class PrayerTimesCard extends ConsumerStatefulWidget {
  const PrayerTimesCard({super.key});

  @override
  ConsumerState<PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends ConsumerState<PrayerTimesCard> {
  late Timer _ticker;
  Duration _countdown = Duration.zero;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final schedule = ref.read(prayerScheduleProvider).value;
      if (schedule != null && mounted) {
        final now = DateTime.now();
        final next = schedule.nextPrayer;
        final diff = next.time.isAfter(now)
            ? next.time.difference(now)
            : next.time.add(const Duration(days: 1)).difference(now);
        setState(() => _countdown = diff);
      }
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(prayerScheduleProvider);

    return scheduleAsync.when(
      loading: () => _buildPlaceholder(context),
      error: (_, __) => const SizedBox.shrink(),
      data: (schedule) {
        // Seed the initial countdown so the strip isn't empty for one tick.
        if (!_seeded) {
          _seeded = true;
          _countdown = schedule.countdown;
        }

        final nextIdx = schedule.nextPrayerIndex;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(locationName: schedule.locationName),
            const SizedBox(height: AppLayout.sp3),
            SizedBox(
              height: 92,
              child: ScrollConfiguration(
                // Match the design: no visible scrollbar on the strip.
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  // Top padding gives the gold pulse dot room to breathe.
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  itemCount: schedule.entries.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppLayout.sp3),
                  itemBuilder: (context, i) {
                    final entry = schedule.entries[i];
                    final isNext = i == nextIdx;
                    return _PrayerCard(
                      entry: entry,
                      isNext: isNext,
                      isPast: i < nextIdx,
                      countdownText:
                          isNext ? _formatCountdown(_countdown) : null,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(locationName: ''),
        const SizedBox(height: AppLayout.sp3),
        SizedBox(
          height: 92,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppLayout.radiusMd),
            ),
          ),
        ),
      ],
    );
  }

  /// `-H:MM:SS` countdown (e.g. `-0:45:00`), styled to match the design.
  String _formatCountdown(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '-$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

/// Formats a prayer [time] as a fixed-width `HH:MM` string.
String _formatPrayerTime(DateTime time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

// ── Section header ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.locationName});

  final String locationName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            S.prayerScheduleTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (locationName.isNotEmpty)
          Text(
            locationName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

// ── Prayer card ──────────────────────────────────────────────────────────

/// A single prayer in the strip: label + time, and for the next prayer the
/// highlighted emerald container, the gold pulse dot, and the live countdown.
class _PrayerCard extends StatelessWidget {
  const _PrayerCard({
    required this.entry,
    required this.isNext,
    required this.isPast,
    this.countdownText,
  });

  final PrayerEntry entry;
  final bool isNext;
  final bool isPast;
  final String? countdownText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final timeStr = _formatPrayerTime(entry.time);

    return AnimatedContainer(
      duration: AppLayout.durBase,
      width: 100,
      decoration: BoxDecoration(
        color: isNext
            ? scheme.primaryContainer
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
        border: Border.all(
          color: isNext
              ? scheme.primaryFixedDim.withValues(alpha: 0.35)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: isNext ? 0.10 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isNext)
            const Positioned(top: -8, right: -8, child: _PulseDot()),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.sp1,
              vertical: AppLayout.sp3,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  entry.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isNext
                        ? scheme.onPrimaryContainer
                        : isPast
                            ? scheme.onSurfaceVariant.withValues(alpha: 0.75)
                            : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppLayout.sp1),
                Text(
                  timeStr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    color: isNext
                        ? scheme.onPrimaryContainer
                        : isPast
                            ? scheme.onSurface.withValues(alpha: 0.7)
                            : scheme.onSurface,
                    fontWeight: isNext ? FontWeight.w700 : FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (countdownText != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    countdownText!,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color:
                          scheme.onPrimaryContainer.withValues(alpha: 0.85),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pulsing gold dot ─────────────────────────────────────────────────────

/// The small gold dot that marks the next prayer (Stitch "animate-pulse").
class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).colorScheme.tertiaryFixed;
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: gold,
          boxShadow: [
            BoxShadow(
              color: gold.withValues(alpha: 0.6),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
