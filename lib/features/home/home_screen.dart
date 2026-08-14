import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/providers.dart';
import '../../data/repositories/reading_history_repository.dart';
import '../browse/browse_screen.dart';
import '../widgets/ayah_number_badge.dart';
import '../widgets/quran_text_view.dart';
import 'prayer_times_card.dart';

/// Beranda (design §2/§13): header, last-read hero, reading history, and quick
/// access into the unified Al-Qur'an page (surah/juz lists + search) via the
/// shell callbacks.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    required this.onOpenSurahs,
    required this.onOpenJuzs,
  });

  final VoidCallback onOpenSurahs;
  final VoidCallback onOpenJuzs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp6,
        vertical: AppLayout.sp8,
      ),
      children: [
        const _HomeHeader(),
        const SizedBox(height: AppLayout.sp6),
        const PrayerTimesCard(),
        const SizedBox(height: AppLayout.sp6),
        const _ContinueHero(),
        const _ReadingHistory(),
        const SizedBox(height: AppLayout.sp7),
        _QuickAccess(onOpenSurahs: onOpenSurahs, onOpenJuzs: onOpenJuzs),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.homeEyebrow,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: AppLayout.sp2),
        Text(S.homeTitle, style: theme.textTheme.displaySmall),
        const SizedBox(height: AppLayout.sp2),
        Text(
          S.homeCaption,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _QuickAccess extends StatelessWidget {
  const _QuickAccess({
    required this.onOpenSurahs,
    required this.onOpenJuzs,
  });

  final VoidCallback onOpenSurahs;
  final VoidCallback onOpenJuzs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.quickAccessEyebrow,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppLayout.sp2),
        _QuickLink(
          icon: Icons.menu_book_rounded,
          title: S.surahListTitle,
          caption: S.quickSurahCaption,
          onTap: onOpenSurahs,
        ),
        const SizedBox(height: AppLayout.sp2),
        _QuickLink(
          icon: Icons.auto_stories_rounded,
          title: S.juzListTitle,
          caption: S.quickJuzCaption,
          onTap: onOpenJuzs,
        ),
      ],
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.title,
    required this.caption,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HoverTile(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppLayout.radiusMd),
            ),
            child: Icon(icon, color: theme.colorScheme.tertiary, size: 24),
          ),
          const SizedBox(width: AppLayout.sp4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  caption,
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
    );
  }
}

class _ContinueHero extends ConsumerWidget {
  const _ContinueHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final detail = ref.watch(lastReadDetailProvider);

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
      child: detail.when(
        loading: () => const SizedBox(height: 140),
        error: (_, __) => _HintCard(onStart: () => openSurah(context, 1)),
        data: (d) {
          if (d == null) {
            return _HintCard(onStart: () => openSurah(context, 1));
          }
          final surah = d.surah;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.continueEyebrow,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: AppLayout.sp3),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        QTextDisplay(text: surah.nameArabic, step: 6),
                        const SizedBox(height: AppLayout.sp2),
                        Text(
                          '${surah.nameLatin} · ${surah.nameIndonesian}',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.bookmark_rounded,
                    color: theme.colorScheme.tertiary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: AppLayout.sp5),
              Text(
                'Ayat ${toArabicIndic(d.ayah.ayahNumber)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppLayout.sp4),
              FilledButton.icon(
                onPressed: () => openSurah(context, surah.id,
                    initialAyahId: d.ayah.id),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text(S.continueButton),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.noHistoryTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppLayout.sp3),
        FilledButton.tonal(
          onPressed: onStart,
          child: const Text(S.startFromFatihah),
        ),
      ],
    );
  }
}

/// Riwayat baca: the 4 most recent surahs (the newest one already sits in the
/// hero above), each with a thin progress bar and a jump back to the last read
/// ayah. Renders nothing when there is no history beyond the hero.
class _ReadingHistory extends ConsumerWidget {
  const _ReadingHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recent = ref.watch(recentSurahsProvider);
    final hero = ref.watch(lastReadDetailProvider).value;

    final items = recent.value ?? const [];
    // The hero already surfaces the newest surah — skip it to avoid doubling.
    final rest = hero == null
        ? items
        : items.where((r) => r.surah.id != hero.surah.id).toList();
    if (rest.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppLayout.sp7),
        Text(
          S.historyEyebrow,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppLayout.sp3),
        for (final item in rest) ...[
          _HistoryRow(item: item),
          const SizedBox(height: AppLayout.sp2),
        ],
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item});

  final RecentSurahRead item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surah = item.surah;
    return HoverTile(
      onTap: () => openSurah(context, surah.id, initialAyahId: item.lastAyahId),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: QTextDisplay(
              text: surah.nameArabic,
              step: 2,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              alignment: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppLayout.sp4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${surah.nameLatin} · ${surah.nameIndonesian}',
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppLayout.sp2),
                _ThinProgress(progress: item.progress),
              ],
            ),
          ),
          const SizedBox(width: AppLayout.sp4),
          Text(
            '${item.readAyahCount}/${item.totalAyahCount}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: AppLayout.sp1),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

/// 3px reading progress bar (echoes the reader's progress strip).
class _ThinProgress extends StatelessWidget {
  const _ThinProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(1.5),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ),
    );
  }
}
