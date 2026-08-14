import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/providers.dart';
import '../../data/services/prayer_time_service.dart';

/// Premium prayer-times card for the Beranda dashboard.
///
/// Shows all five daily prayers with the next upcoming prayer highlighted,
/// a live countdown timer, and a gradient background that adapts to the
/// theme.
class PrayerTimesCard extends ConsumerStatefulWidget {
  const PrayerTimesCard({super.key});

  @override
  ConsumerState<PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends ConsumerState<PrayerTimesCard> {
  late Timer _ticker;
  Duration _countdown = Duration.zero;
  String _nextLabel = '';

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
        setState(() {
          _countdown = diff;
          _nextLabel = next.label;
        });
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
    final theme = Theme.of(context);
    final scheduleAsync = ref.watch(prayerScheduleProvider);

    return scheduleAsync.when(
      loading: () => _buildShimmer(theme),
      error: (_, __) => const SizedBox.shrink(),
      data: (schedule) {
        // Seed initial values on first data.
        if (_nextLabel.isEmpty) {
          _nextLabel = schedule.nextPrayer.label;
          _countdown = schedule.countdown;
        }

        final nextIdx = schedule.nextPrayerIndex;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
                theme.colorScheme.tertiaryContainer.withValues(alpha: 0.45),
              ],
            ),
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.sp5, AppLayout.sp5, AppLayout.sp5, 0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppLayout.radiusSm),
                      ),
                      child: Icon(
                        Icons.mosque_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppLayout.sp3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.prayerTimesEyebrow,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                schedule.locationName,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Next prayer hero ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.sp5,
                  vertical: AppLayout.sp4,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppLayout.sp4,
                    horizontal: AppLayout.sp5,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.nextPrayerLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppLayout.sp1),
                            Text(
                              _nextLabel,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            S.prayerCountdownPrefix,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppLayout.sp1),
                          Text(
                            _formatCountdown(_countdown),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.tertiary,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Five-prayer row ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.sp3, 0, AppLayout.sp3, AppLayout.sp5,
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < schedule.entries.length; i++) ...[
                      Expanded(
                        child: _PrayerTimeChip(
                          entry: schedule.entries[i],
                          isNext: i == nextIdx,
                          isPast: i < nextIdx,
                        ),
                      ),
                      if (i < schedule.entries.length - 1)
                        const SizedBox(width: 4),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmer(ThemeData theme) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  String _formatCountdown(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h}j ${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}d';
    }
    return '${m}m ${s.toString().padLeft(2, '0')}d';
  }
}

/// Individual prayer chip in the five-prayer row.
class _PrayerTimeChip extends StatelessWidget {
  const _PrayerTimeChip({
    required this.entry,
    required this.isNext,
    required this.isPast,
  });

  final PrayerEntry entry;
  final bool isNext;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr =
        '${entry.time.hour.toString().padLeft(2, '0')}:${entry.time.minute.toString().padLeft(2, '0')}';

    return AnimatedContainer(
      duration: AppLayout.durBase,
      padding: const EdgeInsets.symmetric(
        vertical: AppLayout.sp2,
        horizontal: AppLayout.sp1,
      ),
      decoration: BoxDecoration(
        color: isNext
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppLayout.radiusSm),
        border: isNext
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.25),
              )
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot indicator.
          AnimatedContainer(
            duration: AppLayout.durBase,
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isNext
                  ? theme.colorScheme.primary
                  : isPast
                      ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: AppLayout.sp1),
          Text(
            entry.label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
              color: isNext
                  ? theme.colorScheme.primary
                  : isPast
                      ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                      : theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            timeStr,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
              color: isNext
                  ? theme.colorScheme.primary
                  : isPast
                      ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                      : theme.colorScheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
