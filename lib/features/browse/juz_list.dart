import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../data/db/quran_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/quran_repositories.dart';
import '../widgets/ayah_number_badge.dart';
import 'browse_utils.dart';
import 'hover_card.dart';

class JuzList extends ConsumerWidget {
  const JuzList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final juzs = ref.watch(juzListProvider);
    final surahs = ref.watch(surahListProvider);
    final surahMap = surahs.value == null
        ? <int, Surah>{}
        : {for (final s in surahs.value!) s.id: s};

    return juzs.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Text('Gagal memuat data.', style: theme.textTheme.bodyMedium),
        ),
      ),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < list.length; i++) ...[
              if (i > 0) const SizedBox(height: AppLayout.sp3),
              JuzRow(juz: list[i], range: _juzRange(surahMap, list[i])),
            ],
          ],
        );
      },
    );
  }

  String _juzRange(Map<int, Surah> surahMap, JuzInfo juz) {
    final first = surahMap[juz.firstSurahId];
    final last = surahMap[juz.lastSurahId];
    if (first == null || last == null) return '';
    return '${first.nameLatin} — ${last.nameLatin}';
  }
}

class JuzRow extends StatelessWidget {
  const JuzRow({super.key, required this.juz, required this.range});

  final JuzInfo juz;
  final String range;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return HoverCard(
      onTap: () =>
          openSurah(context, juz.firstSurahId, initialAyahId: juz.firstAyahId),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              toArabicIndic(juz.juz),
              style: TextStyle(
                fontFamily: AppConstants.fontQuran,
                fontSize: 22,
                color: scheme.tertiary,
                letterSpacing: 0, // never letter-space Arabic
              ),
            ),
          ),
          const SizedBox(width: AppLayout.sp4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Juz ${juz.juz}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    height: 28 / 20,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  range,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppLayout.sp3),
          Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
