import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/providers.dart';
import '../../data/repositories/reading_history_repository.dart';
import '../../data/repositories/user_repositories.dart';
import '../reader/reader_screen.dart';
import '../widgets/liquid_glass.dart';
import '../widgets/quran_text_view.dart';

/// Favorit & Penanda (Stitch remodel): a pinned app bar, two tabs, and the
/// design's ayah cards (Favorit = bookmarked ayats) and position rows
/// (Penanda = recently-read surahs). Both lists stay lazy (ListView.builder).
class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

enum _BookmarksTab { favorit, penanda }

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  _BookmarksTab _tab = _BookmarksTab.favorit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BookmarksAppBar(),
          _Tabs(
            tab: _tab,
            onSelect: (t) => setState(() => _tab = t),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppLayout.durBase,
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _tab == _BookmarksTab.favorit
                  ? const _FavoritContent(key: ValueKey('favorit'))
                  : const _PenandaContent(key: ValueKey('penanda')),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pinned app bar + tabs
// ---------------------------------------------------------------------------

/// Pinned bar with the centered title only — a shell view has no back arrow
/// (dead button), and search belongs to Al-Qur'an pages.
class _BookmarksAppBar extends StatelessWidget {
  const _BookmarksAppBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      height: AppLayout.sp10,
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp6),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Center(
        child: Text(
          S.bookmarksTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.primary,
          ),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.tab, required this.onSelect});

  final _BookmarksTab tab;
  final ValueChanged<_BookmarksTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          _TabButton(
            label: S.favoritTab,
            selected: tab == _BookmarksTab.favorit,
            onTap: () => onSelect(_BookmarksTab.favorit),
          ),
          _TabButton(
            label: S.penandaTab,
            selected: tab == _BookmarksTab.penanda,
            onTap: () => onSelect(_BookmarksTab.penanda),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppLayout.durBase,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: AppLayout.sp3),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? scheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Favorit tab — bookmarked ayats as the design's ayah cards
// ---------------------------------------------------------------------------

class _FavoritContent extends ConsumerWidget {
  const _FavoritContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);
    final isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

    return bookmarks.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Text(S.statsError, style: Theme.of(context).textTheme.bodyMedium),
      ),
      data: (list) {
        if (list.isEmpty) {
          return _EmptyState(
            icon: Icons.favorite_border_rounded,
            title: S.bookmarksFavoritEmptyTitle,
            message: S.bookmarksFavoritEmptyMessage,
            onStart: () => _openSurah(context, 1),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            isMobile ? AppLayout.sp3 : AppLayout.sp6,
            AppLayout.sp5,
            isMobile ? AppLayout.sp3 : AppLayout.sp6,
            isMobile
                ? glassNavClearance + MediaQuery.paddingOf(context).bottom
                : AppLayout.sp8,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final e = list[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == list.length - 1 ? 0 : AppLayout.sp4,
              ),
              child: _FavoritCard(
                entry: e,
                onOpen: () =>
                    _openSurah(context, e.surah.id, initialAyahId: e.ayah.id),
                onShare: () => _shareAyah(context, e),
                onUnfavorite: () => _confirmDelete(context, ref, e),
              ),
            );
          },
        );
      },
    );
  }
}

class _FavoritCard extends StatefulWidget {
  const _FavoritCard({
    required this.entry,
    required this.onOpen,
    required this.onShare,
    required this.onUnfavorite,
  });

  final BookmarkEntry entry;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onUnfavorite;

  @override
  State<_FavoritCard> createState() => _FavoritCardState();
}

class _FavoritCardState extends State<_FavoritCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final entry = widget.entry;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onOpen,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        child: AnimatedContainer(
          duration: AppLayout.durBase,
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppLayout.sp5),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            border: Border.all(color: scheme.surfaceContainerLow),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: _hovered ? 0.09 : 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _SurahChip(
                    label:
                        '${entry.surah.nameLatin}: ${entry.ayah.ayahNumber}',
                  ),
                  const Spacer(),
                  _CardActionButton(
                    icon: Icons.favorite_rounded,
                    tooltip: S.removeBookmark,
                    color: scheme.error,
                    onPressed: widget.onUnfavorite,
                  ),
                  _CardActionButton(
                    icon: Icons.share_rounded,
                    tooltip: S.shareAyah,
                    onPressed: widget.onShare,
                  ),
                ],
              ),
              const SizedBox(height: AppLayout.sp4),
              // Arabic, right-aligned in primary (design quran-text).
              QTextDisplay(
                text: entry.ayah.textUthmani,
                step: 4,
                color: scheme.primary,
              ),
              const SizedBox(height: AppLayout.sp3),
              Text(
                entry.ayah.translation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sage pill chip "Al-Baqarah: 255" (secondaryContainer).
class _SurahChip extends StatelessWidget {
  const _SurahChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp3,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppLayout.radiusFull),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Penanda tab — recently-read surahs as the design's position rows
// ---------------------------------------------------------------------------

class _PenandaContent extends ConsumerWidget {
  const _PenandaContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentSurahsProvider);
    final isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

    return recent.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Text(S.statsError, style: Theme.of(context).textTheme.bodyMedium),
      ),
      data: (list) {
        if (list.isEmpty) {
          return _EmptyState(
            icon: Icons.bookmark_border_rounded,
            title: S.bookmarksPenandaEmptyTitle,
            message: S.bookmarksPenandaEmptyMessage,
            onStart: () => _openSurah(context, 1),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            isMobile ? AppLayout.sp3 : AppLayout.sp6,
            AppLayout.sp5,
            isMobile ? AppLayout.sp3 : AppLayout.sp6,
            isMobile
                ? glassNavClearance + MediaQuery.paddingOf(context).bottom
                : AppLayout.sp8,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == list.length - 1 ? 0 : AppLayout.sp4,
              ),
              child: _PenandaRow(
                item: item,
                isFirst: index == 0,
                onOpen: () => _openSurah(
                  context,
                  item.surah.id,
                  initialAyahId: item.lastAyahId,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PenandaRow extends StatefulWidget {
  const _PenandaRow({
    required this.item,
    required this.isFirst,
    required this.onOpen,
  });

  final RecentSurahRead item;
  final bool isFirst;
  final VoidCallback onOpen;

  @override
  State<_PenandaRow> createState() => _PenandaRowState();
}

class _PenandaRowState extends State<_PenandaRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final item = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onOpen,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        child: AnimatedContainer(
          duration: AppLayout.durBase,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.sp5,
            vertical: AppLayout.sp4,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? scheme.surfaceContainerLow
                : scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            border: Border(
              left: BorderSide(color: scheme.primary, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _PositionBadge(filled: widget.isFirst),
              const SizedBox(width: AppLayout.sp4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.surah.nameLatin,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        height: 28 / 20,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppLayout.sp1),
                    Text(
                      S.juzPage(item.surah.firstJuz, item.surah.firstPage),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppLayout.sp3),
              Text(
                _relativeTime(item.lastReadAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PositionBadge extends StatelessWidget {
  const _PositionBadge({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? scheme.primaryContainer : scheme.surfaceContainer,
      ),
      child: Icon(
        filled ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        size: 20,
        color: filled ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared bits
// ---------------------------------------------------------------------------

/// One circular card-header action (20px icon, circular hover).
class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        foregroundColor: color ?? scheme.onSurfaceVariant,
        hoverColor: scheme.surfaceContainerHighest,
        fixedSize: const Size(36, 36),
        padding: EdgeInsets.zero,
      ),
      icon: Icon(icon, size: 20),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.onStart,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.sp6,
          vertical: AppLayout.sp8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 44,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppLayout.sp4),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppLayout.sp2),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppLayout.sp6),
            LiquidGlassButton.filled(
              onPressed: onStart,
              icon: const Icon(Icons.menu_book_rounded, size: 18),
              label: S.startReading,
            ),
          ],
        ),
      ),
    );
  }
}

/// "Hari ini" / "Kemarin" / "N hari lalu" / "N mgg lalu" from epoch seconds.
String _relativeTime(int epochSeconds) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final diff = now - epochSeconds;
  if (diff < 86400) return S.todayLabel;
  if (diff < 172800) return S.yesterdayLabel;
  final days = diff ~/ 86400;
  if (days < 7) return S.daysAgo(days);
  return S.weeksAgo(days ~/ 7);
}

/// No share_plus dependency yet — share copies the ayah and confirms with a
/// SnackBar (same pattern as the home daily verse and reader cards).
Future<void> _shareAyah(BuildContext context, BookmarkEntry entry) async {
  await Clipboard.setData(
    ClipboardData(
      text: '${entry.ayah.textUthmani}\n\n"${entry.ayah.translation}"\n'
          '${entry.surah.nameLatin} : ${entry.ayah.ayahNumber}',
    ),
  );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(S.copyAyahDone),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1800),
      ),
    );
}

/// The heart on a Favorit card removes the bookmark — with the same confirm
/// dialog the old list used, so a favorite is never lost by a stray tap.
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

void _openSurah(BuildContext context, int surahId, {int? initialAyahId}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ReaderScreen(surahId: surahId, initialAyahId: initialAyahId),
    ),
  );
}