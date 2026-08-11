import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/providers.dart';
import '../../data/repositories/user_repositories.dart';
import '../reader/reader_screen.dart';
import '../widgets/ayah_number_badge.dart';
import '../widgets/quran_text_view.dart';

/// Bookmarks (design §20): entries grouped by surah, added-order within group.
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookmarks = ref.watch(bookmarksProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp6,
        vertical: AppLayout.sp8,
      ),
      children: [
        Text(
          S.bookmarksEyebrow,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: AppLayout.sp2),
        Text(S.bookmarksTitle, style: theme.textTheme.displaySmall),
        const SizedBox(height: AppLayout.sp2),
        Text(
          S.bookmarksCaption,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppLayout.sp6),
        ...bookmarks.when(
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
                child: Text('Gagal memuat data.', style: theme.textTheme.bodyMedium),
              ),
            ),
          ],
          data: (list) {
            if (list.isEmpty) return [_EmptyState(onStart: () => _openSurah(context, 1))];
            final groups = _groupBySurah(list);
            return [
              for (final g in groups) ...[
                _GroupHeader(entries: g),
                for (final e in g)
                  _BookmarkRow(
                    entry: e,
                    onTap: () =>
                        _openSurah(context, e.surah.id, initialAyahId: e.ayah.id),
                    onDelete: () => _confirmDelete(context, ref, e),
                  ),
              ],
            ];
          },
        ),
      ],
    );
  }

  List<List<BookmarkEntry>> _groupBySurah(List<BookmarkEntry> entries) {
    final groups = <int, List<BookmarkEntry>>{};
    for (final e in entries) {
      groups.putIfAbsent(e.surah.id, () => []).add(e);
    }
    return groups.values.toList();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BookmarkEntry entry,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.removeBookmarkConfirm),
        content: Text(
          '${entry.surah.nameLatin} • Ayat ${entry.ayah.ayahNumber}',
          style: Theme.of(ctx).textTheme.bodyMedium,
        ),
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
      await ref.read(bookmarkRepositoryProvider).toggleBookmark(entry.ayah.id);
    }
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.entries});

  final List<BookmarkEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surah = entries.first.surah;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppLayout.sp2, AppLayout.sp5, AppLayout.sp2, AppLayout.sp2),
      child: Row(
        children: [
          QTextDisplay(text: surah.nameArabic, step: 4),
          const SizedBox(width: AppLayout.sp3),
          Expanded(
            child: Text(
              '${surah.nameLatin} · ${entries.length}',
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: AppLayout.sp2),
          Container(
            height: 1,
            width: 64,
            color: theme.colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }
}

class _BookmarkRow extends StatefulWidget {
  const _BookmarkRow({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  final BookmarkEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<_BookmarkRow> createState() => _BookmarkRowState();
}

class _BookmarkRowState extends State<_BookmarkRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = widget.entry;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
        child: AnimatedContainer(
          duration: AppLayout.durBase,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.sp4,
            vertical: AppLayout.sp3,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? theme.colorScheme.surfaceContainerLow
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: AyahNumberBadge(
                  number: entry.ayah.ayahNumber,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppLayout.sp4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.surah.nameLatin} • Ayat ${entry.ayah.ayahNumber}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(height: AppLayout.sp1),
                    QTextDisplay(text: entry.ayah.textUthmani, step: 2),
                    const SizedBox(height: AppLayout.sp1),
                    Text(
                      entry.ayah.translation,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppLayout.sp2),
              IconButton(
                onPressed: widget.onDelete,
                tooltip: S.removeBookmark,
                icon: const Icon(Icons.bookmark_remove_rounded, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppLayout.sp10),
      child: Column(
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 44,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppLayout.sp4),
          Text(S.bookmarksEmptyTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppLayout.sp2),
          Text(
            S.bookmarksEmptyMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppLayout.sp6),
          FilledButton.tonal(
            onPressed: onStart,
            child: const Text(S.startReading),
          ),
        ],
      ),
    );
  }
}

void _openSurah(BuildContext context, int surahId, {int? initialAyahId}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ReaderScreen(surahId: surahId, initialAyahId: initialAyahId),
    ),
  );
}
