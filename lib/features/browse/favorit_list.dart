import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../data/db/quran_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/user_repositories.dart';
import 'browse_utils.dart';
import 'hover_card.dart';
import 'surah_row_content.dart';

/// Favorit = surah yang punya minimal satu penanda ayat. Dibaca dari
/// [bookmarksProvider] yang sudah ada (tanpa plumbing baru); setiap baris
/// membuka surah ke ayat penanda pertama. Kosong → empty state yang sopan.
class FavoritList extends ConsumerWidget {
  const FavoritList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookmarks = ref.watch(bookmarksProvider);

    return bookmarks.when(
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
      data: (entries) {
        final bySurah = <int, List<BookmarkEntry>>{};
        for (final e in entries) {
          bySurah.putIfAbsent(e.surah.id, () => []).add(e);
        }
        final ids = bySurah.keys.toList()..sort();
        if (ids.isEmpty) return const FavoritEmpty();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < ids.length; i++) ...[
              if (i > 0) const SizedBox(height: AppLayout.sp3),
              FavoritRow(
                surah: bySurah[ids[i]]!.first.surah,
                firstAyahId: bySurah[ids[i]]!.first.ayah.id,
                count: bySurah[ids[i]]!.length,
              ),
            ],
          ],
        );
      },
    );
  }
}

class FavoritRow extends StatelessWidget {
  const FavoritRow({
    super.key,
    required this.surah,
    required this.firstAyahId,
    required this.count,
  });

  final Surah surah;
  final int firstAyahId;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return HoverCard(
      onTap: () => openSurah(context, surah.id, initialAyahId: firstAyahId),
      child: SurahRowContent(
        surah: surah,
        metaTrailing: '$count ${l10n.penandaCount}',
      ),
    );
  }
}

class FavoritEmpty extends StatelessWidget {
  const FavoritEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppLayout.sp10),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_border_rounded,
              size: 28,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppLayout.sp4),
          Text(l10n.favoritEmptyTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppLayout.sp2),
          Text(
            l10n.favoritEmptyMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
