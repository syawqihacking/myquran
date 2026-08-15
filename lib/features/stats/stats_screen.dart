import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/db/user_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/reading_stats_repository.dart';
import '../personality/personality_screen.dart';

/// Statistik: reading stats (streak, today), khatam planner (target + ring),
/// 30-day reading calendar, and totals. Follows the house header (eyebrow +
/// displaySmall title + caption) and the `.when(loading/error/data)` Riverpod
/// pattern from the other screens.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(readingStatsProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp6,
        vertical: AppLayout.sp8,
      ),
      children: [
        Text(
          S.statsEyebrow,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: AppLayout.sp2),
        Text(S.statsTitle, style: theme.textTheme.displaySmall),
        const SizedBox(height: AppLayout.sp2),
        Text(
          S.statsCaption,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppLayout.sp6),
        ...stats.when(
          loading: () => const [
            Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            ),
          ],
          error: (e, _) => [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Text(S.statsError, style: theme.textTheme.bodyMedium),
              ),
            ),
          ],
          data: (s) => [
            _StreakCard(stats: s),
            const SizedBox(height: AppLayout.sp7),
            _KhatamCard(stats: s),
            const SizedBox(height: AppLayout.sp7),
            const _CalendarCard(),
            const SizedBox(height: AppLayout.sp7),
            _SummaryRow(stats: s),
            const SizedBox(height: AppLayout.sp7),
            const _PersonalityCard(),
            const SizedBox(height: AppLayout.sp8),
          ],
        ),
      ],
    );
  }
}

/// Hero card: streak (hari beruntun) + ayat dibaca hari ini.
/// Uses the continue-reading hero gradient (surfaceContainerLow →
/// primaryContainer@40%, radius-lg) from the home screen.
class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.stats});

  final ReadingStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        theme.colorScheme.surfaceContainerLow,
        theme.colorScheme.primaryContainer.withValues(alpha: 0.40),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(AppLayout.sp6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StatBlock(
                icon: Icons.local_fire_department_rounded,
                value: _formatCount(stats.streakDays),
                label: S.statsStreakLabel,
              ),
            ),
            const SizedBox(width: AppLayout.sp5),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(width: AppLayout.sp5),
            Expanded(
              child: _StatBlock(
                icon: Icons.auto_stories_rounded,
                value: _formatCount(stats.todayAyahs),
                label: S.statsTodayLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon + prominent number + label block used inside the hero card.
class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(height: AppLayout.sp2),
        Text(
          value,
          style: theme.textTheme.displaySmall?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: AppLayout.sp1),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Khatam card: progress ring (juzsRead dari 30) + interactive target planner.
/// The ring and the 3px progress bar (echoing the reader's progress bar) share
/// one animation; reduced motion disables it.
class _KhatamCard extends ConsumerWidget {
  const _KhatamCard({required this.stats});

  final ReadingStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final target = ref.watch(khatamTargetProvider).value;
    final progress = (stats.juzsRead / 30).clamp(0.0, 1.0);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 700);

    return Container(
      padding: const EdgeInsets.all(AppLayout.sp6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: duration,
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: v,
                          strokeWidth: 10,
                          strokeCap: StrokeCap.round,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${stats.juzsRead}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          Text(
                            S.statsJuzsOf,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppLayout.sp6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.statsKhatamEyebrow,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(height: AppLayout.sp3),
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: v,
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppLayout.sp3),
                      Text(
                        S.statsKhatamCaption,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppLayout.sp5),
          _KhatamPlanner(target: target, stats: stats),
        ],
      ),
    );
  }
}

/// The interactive half of the khatam card: set a target when none exists,
/// or show the plan ("Juz X hari ini"), days left, and a clear action.
class _KhatamPlanner extends ConsumerWidget {
  const _KhatamPlanner({required this.target, required this.stats});

  final KhatamTarget? target;
  final ReadingStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final t = target;
    if (t == null) {
      return Wrap(
        spacing: AppLayout.sp3,
        runSpacing: AppLayout.sp2,
        children: [
          FilledButton.tonalIcon(
            onPressed: () => ref.read(khatamRepositoryProvider).setTarget(
                  targetDate: null,
                  startDate: DateTime.now(),
                ),
            icon: const Icon(Icons.event_available_rounded, size: 18),
            label: const Text(S.khatamPlan30),
          ),
          OutlinedButton.icon(
            onPressed: () => _pickTargetDate(context, ref),
            icon: const Icon(Icons.calendar_month_rounded, size: 18),
            label: const Text(S.khatamPickDate),
          ),
        ],
      );
    }

    // Plan exists. "Juz hari ini" follows the plan calendar: day 1 = juz 1,
    // paced to finish all 30 juz by the target date (or 30 days for the
    // default plan). The ring above already reflects actual juzsRead, so this
    // line is the plan's pace.
    final todayEpoch = _epochDay(DateTime.now());
    final endEpoch = t.targetDate ?? t.startDate + 29;
    final elapsed = todayEpoch - t.startDate + 1; // 1-based day number
    final spanDays = max(1, endEpoch - t.startDate + 1); // inclusive plan span
    final juzPerDay = max(1.0, 30 / spanDays);
    final juzToday = (elapsed * juzPerDay).clamp(1, 30).round();
    final daysLeft = endEpoch - todayEpoch + 1; // inclusive of today
    final overdue = daysLeft <= 0;
    // "Tercapai" requires BOTH the plan date passing AND the khatam actually
    // finished — a passed date with juzsRead < 30 is overdue, not done.
    final reached = overdue && stats.juzsRead >= 30;

    final String title;
    final String subtitle;
    if (reached) {
      title = S.khatamDone;
      subtitle = S.statsKhatamCaption;
    } else if (overdue) {
      // Date passed but khatam unfinished — show how many juz remain.
      final remaining = 30 - stats.juzsRead;
      title = '${S.khatamDaysLeft} $remaining ${S.khatamJuz}';
      subtitle = S.statsKhatamCaption;
    } else {
      title = '${S.khatamJuz} $juzToday ${S.khatamJuzToday}';
      subtitle = '${S.khatamDaysLeft} ${_formatCount(daysLeft)} ${S.khatamDays}';
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppLayout.sp1),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: () => _confirmClearTarget(context, ref),
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
          label: const Text(S.khatamClear),
        ),
      ],
    );
  }

  Future<void> _pickTargetDate(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: today.add(const Duration(days: 30)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      helpText: S.khatamPickDate,
    );
    if (picked == null) return;
    await ref.read(khatamRepositoryProvider).setTarget(
          targetDate: picked,
          startDate: today,
        );
  }

  Future<void> _confirmClearTarget(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.khatamClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(S.remove),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(khatamRepositoryProvider).clearTarget();
    }
  }
}

/// 30-day reading calendar: one cell per day, intensity = ayahs read that day.
/// Calm by design — empty days are a quiet neutral, active days step up the
/// primary accent. The list from [dailyActivityProvider] is oldest first and
/// always ends today, so cell dates are derived from the index (no epoch-day
/// round-trip, which would drift across timezones).
class _CalendarCard extends ConsumerWidget {
  const _CalendarCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final days = ref.watch(dailyActivityProvider);

    return Container(
      padding: const EdgeInsets.all(AppLayout.sp6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.calendarEyebrow,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: AppLayout.sp2),
          Text(S.calendarTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppLayout.sp2),
          Text(
            S.calendarCaption,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppLayout.sp5),
          days.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, __) =>
                Text(S.statsError, style: theme.textTheme.bodyMedium),
            data: (list) => _HeatmapGrid(days: list),
          ),
        ],
      ),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  const _HeatmapGrid({required this.days});

  final List<({int epochDay, int count})> days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxCount = days.fold<int>(0, (m, d) => d.count > m ? d.count : m);
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 6.0;
            const cols = 15;
            final cell = (constraints.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < days.length; i++)
                  SizedBox(
                    width: cell,
                    height: cell,
                    child: _HeatCell(
                      count: days[i].count,
                      maxCount: maxCount,
                      date: today.subtract(
                        Duration(days: days.length - 1 - i),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: AppLayout.sp4),
        Row(
          children: [
            Text(
              S.calendarFew,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppLayout.sp2),
            _LegendDot(color: theme.colorScheme.surfaceContainerHighest),
            const SizedBox(width: AppLayout.sp1),
            _LegendDot(
              color: theme.colorScheme.primary.withValues(alpha: 0.35),
            ),
            const SizedBox(width: AppLayout.sp1),
            _LegendDot(
              color: theme.colorScheme.primary.withValues(alpha: 0.65),
            ),
            const SizedBox(width: AppLayout.sp1),
            _LegendDot(color: theme.colorScheme.primary),
            const SizedBox(width: AppLayout.sp2),
            Text(
              S.calendarMany,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({
    required this.count,
    required this.maxCount,
    required this.date,
  });

  final int count;
  final int maxCount;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color color;
    if (count == 0) {
      color = scheme.surfaceContainerHighest;
    } else {
      final t = maxCount > 0 ? (count / maxCount) : 1.0;
      color = scheme.primary.withValues(alpha: 0.25 + 0.75 * t);
    }
    return Tooltip(
      message: '${_formatDay(date)} · $count ${S.ayatCount}',
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

/// Compact summary: total hari membaca + total ayat dibaca, side by side,
/// with a small sujud-tilawah count line beneath.
class _SummaryRow extends ConsumerWidget {
  const _SummaryRow({required this.stats});

  final ReadingStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sujud = ref.watch(sajdaCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                value: _formatCount(stats.totalDays),
                label: S.statsTotalDaysLabel,
              ),
            ),
            const SizedBox(width: AppLayout.sp4),
            Expanded(
              child: _SummaryTile(
                value: _formatCount(stats.totalAyahs),
                label: S.statsTotalAyahsLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppLayout.sp3),
        sujud.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (count) => Row(
            children: [
              Text(
                '\u06E9', // ۩ — place-of-sajdah glyph
                style: TextStyle(
                  fontFamily: AppConstants.fontQuran,
                  fontSize: 16,
                  height: 1.0,
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: AppLayout.sp2),
              Text(
                '$count ${S.sujudOf}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppLayout.sp5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppLayout.sp1),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Local-midnight epoch day — mirrors the repositories' day encoding.
int _epochDay(DateTime d) =>
    DateTime(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 86400000;

const List<String> _monthShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _formatDay(DateTime d) => '${d.day} ${_monthShort[d.month - 1]}';

/// Indonesian thousands separator: 12345 → "12.345".
String _formatCount(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// Tappable entry card into the Analisis Kepribadian screen — house card
/// style (surfaceContainerLowest, radius-lg, outlineVariant border) like
/// `_KhatamCard`.
class _PersonalityCard extends StatelessWidget {
  const _PersonalityCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppLayout.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PersonalityScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppLayout.sp5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                ),
                child: Icon(Icons.psychology_rounded, color: scheme.primary),
              ),
              const SizedBox(width: AppLayout.sp4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.statsPersonalityTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      S.statsPersonalityCaption,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}