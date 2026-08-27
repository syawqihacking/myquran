import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../data/db/quran_database.dart';
import '../../data/providers.dart';
import 'browse_utils.dart';
import 'hover_card.dart';
import 'surah_row_content.dart';

class SurahList extends ConsumerWidget {
  const SurahList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final surahs = ref.watch(surahListProvider);

    return surahs.when(
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
              SurahCard(
                surah: list[i],
                onTap: () => openSurah(context, list[i].id),
              ),
            ],
          ],
        );
      },
    );
  }
}

class SurahCard extends StatelessWidget {
  const SurahCard({super.key, required this.surah, required this.onTap});

  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return HoverCard(
      onTap: onTap,
      child: SurahRowContent(
        surah: surah,
        metaTrailing: '${surah.ayahCount} ${l10n.ayatCount}',
      ),
    );
  }
}
