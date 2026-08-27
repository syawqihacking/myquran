import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/providers.dart';
import '../../data/repositories/reading_history_repository.dart';
import '../browse/browse_screen.dart';
import '../widgets/quran_text_view.dart';

/// Riwayat baca: the 4 most recent surahs (the newest one already sits in the
/// hero above), each with a thin progress bar and a jump back to the last read
/// ayah. Renders nothing when there is no history beyond the hero.
class ReadingHistory extends ConsumerWidget {
  const ReadingHistory();

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
        Text(
          S.historyEyebrow,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppLayout.sp3),
        for (final item in rest) ...[
          HistoryRow(item: item),
          const SizedBox(height: AppLayout.sp2),
        ],
      ],
    );
  }
}

class HistoryRow extends StatelessWidget {
  const HistoryRow({required this.item});

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
                ThinProgress(progress: item.progress),
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
class ThinProgress extends StatelessWidget {
  const ThinProgress({required this.progress});

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
