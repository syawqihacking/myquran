import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/models/doa_harian_data.dart';
import '../../data/models/spiritual_content.dart';
import '../../data/providers.dart';
import '../widgets/quran_text_view.dart';
import 'spiritual_reader_screen.dart';

/// Doa Harian (Stitch "Doa Harian" screen): a pinned app bar, a full-width
/// search field, single-select category chips, and a responsive grid of prayer
/// cards (1/2/3 columns). Each card opens the spiritual reader with that one
/// doa; the bookmark button is its own store (`doa_bookmarks`), separate from
/// ayah bookmarks.
class DoaHarianScreen extends ConsumerStatefulWidget {
  const DoaHarianScreen({super.key});

  @override
  ConsumerState<DoaHarianScreen> createState() => _DoaHarianScreenState();
}

class _DoaHarianScreenState extends ConsumerState<DoaHarianScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';
  String _category = doaCategories.first;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<DoaHarian> get _filtered {
    final q = _query.trim().toLowerCase();
    return [
      for (final d in doaHarianItems)
        if (d.category == _category &&
            (q.isEmpty ||
                d.title.toLowerCase().contains(q) ||
                d.translation.toLowerCase().contains(q)))
          d,
    ];
  }

  void _openReader(DoaHarian doa) {
    final index = doaHarianItems.indexOf(doa);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SpiritualReaderScreen(
          title: doa.title,
          subtitle: doa.category,
          items: [
            SpiritualItem(
              id: index + 1,
              title: doa.title,
              arabic: doa.arabic,
              translation: doa.translation,
            ),
          ],
          icon: Icons.wb_sunny_rounded,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bookmarkedIds =
        ref.watch(doaBookmarkIdsProvider).value ?? const <String>{};
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          // Ambient radial gradients (design: primary 3% top-right & bottom-left).
          Positioned(
            top: -140,
            right: -140,
            child: _AmbientGlow(color: scheme.primary.withValues(alpha: 0.03)),
          ),
          Positioned(
            bottom: -140,
            left: -140,
            child: _AmbientGlow(color: scheme.primary.withValues(alpha: 0.03)),
          ),
          SafeArea(
            child: Column(
              children: [
                _DoaAppBar(onBack: () => Navigator.of(context).maybePop()),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final cols = width < 700 ? 1 : (width < 1100 ? 2 : 3);
                      const gap = AppLayout.sp6;
                      final contentWidth = width - AppLayout.sp6 * 2;
                      final itemWidth =
                          (contentWidth - gap * (cols - 1)) / cols;

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppLayout.sp6,
                          AppLayout.sp4,
                          AppLayout.sp6,
                          AppLayout.sp8,
                        ),
                        children: [
                          _buildSearch(scheme),
                          const SizedBox(height: AppLayout.sp4),
                          _buildChips(),
                          const SizedBox(height: AppLayout.sp5),
                          if (filtered.isEmpty)
                            const _DoaEmpty()
                          else
                            Wrap(
                              spacing: gap,
                              runSpacing: gap,
                              children: [
                                for (final d in filtered)
                                  SizedBox(
                                    width: itemWidth,
                                    child: _DoaCard(
                                      doa: d,
                                      bookmarked:
                                          bookmarkedIds.contains(d.id),
                                      onToggleBookmark: () => ref
                                          .read(doaBookmarkRepositoryProvider)
                                          .toggleBookmark(d.id),
                                      onTap: () => _openReader(d),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(ColorScheme scheme) {
    return AnimatedContainer(
      duration: AppLayout.durBase,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppLayout.radiusFull),
        // A soft ring echoing the design's focus ring (primary/20).
        boxShadow: _searchFocus.hasFocus
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.15),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onChanged: (v) => setState(() => _query = v),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: S.doaSearchHint,
          prefixIcon: const Icon(Icons.search_rounded),
          prefixIconColor: scheme.outline,
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                    _searchFocus.requestFocus();
                  },
                  tooltip: S.cancel,
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: scheme.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppLayout.sp3,
            horizontal: AppLayout.sp4,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppLayout.radiusFull),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppLayout.radiusFull),
            borderSide: BorderSide(color: scheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildChips() {
    return ScrollConfiguration(
      behavior: _ChipScrollBehavior(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < doaCategories.length; i++) ...[
              if (i > 0) const SizedBox(width: AppLayout.sp3),
              _CategoryChip(
                label: doaCategories[i],
                selected: _category == doaCategories[i],
                onTap: () => setState(() => _category = doaCategories[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// App bar (Stitch §1): back + centered title. The design's more_vert is
// omitted — no dead buttons.
// ---------------------------------------------------------------------------

class _DoaAppBar extends StatelessWidget {
  const _DoaAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      height: AppLayout.sp10,
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp2),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: S.back,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              S.doaHarianTitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
                height: 28 / 20,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 48), // balances the back button
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category chips (Stitch §2): horizontal scroll, single select.
// ---------------------------------------------------------------------------

/// Hides the horizontal scrollbar but keeps mouse-drag scrolling.
class _ChipScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class _CategoryChip extends StatefulWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selected = widget.selected;
    final bg = selected
        ? scheme.primary
        : (_hovered ? scheme.secondaryContainer : scheme.surfaceContainerHighest);
    final fg = selected
        ? scheme.onPrimary
        : (_hovered ? scheme.onSecondaryContainer : scheme.onSurfaceVariant);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppLayout.durBase,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.sp5,
            vertical: AppLayout.sp2,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppLayout.radiusFull),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6, // 0.05em on label-sm (12px)
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Prayer card (Stitch §3): 4px accent bar, title + bookmark, Arabic, chip.
// ---------------------------------------------------------------------------

class _DoaCard extends StatefulWidget {
  const _DoaCard({
    required this.doa,
    required this.bookmarked,
    required this.onToggleBookmark,
    required this.onTap,
  });

  final DoaHarian doa;
  final bool bookmarked;
  final VoidCallback onToggleBookmark;
  final VoidCallback onTap;

  @override
  State<_DoaCard> createState() => _DoaCardState();
}

class _DoaCardState extends State<_DoaCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final doa = widget.doa;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppLayout.durBase,
        curve: Curves.easeOut,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          border: Border.all(color: scheme.surfaceContainerHigh),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: _hovered ? 0.08 : 0.04),
              blurRadius: _hovered ? 32 : 20,
              offset: Offset(0, _hovered ? 12 : 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 4px vertical accent bar (primary/20 → primary on hover).
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: AppLayout.durBase,
                width: 4,
                color: _hovered
                    ? scheme.primary
                    : scheme.primary.withValues(alpha: 0.2),
              ),
            ),
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppLayout.radiusMd),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.sp4,
                    AppLayout.sp5,
                    AppLayout.sp5,
                    AppLayout.sp5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              doa.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 20,
                                height: 28 / 20,
                                fontWeight: FontWeight.w600,
                                color: _hovered
                                    ? scheme.primary
                                    : scheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppLayout.sp2),
                          _BookmarkButton(
                            bookmarked: widget.bookmarked,
                            onPressed: widget.onToggleBookmark,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppLayout.sp4),
                      // Arabic, Amiri, right-aligned, on-surface @ 0.9.
                      QTextDisplay(
                        text: doa.arabic,
                        step: 4,
                        alignment: TextAlign.right,
                        color: scheme.onSurface.withValues(alpha: 0.9),
                      ),
                      const SizedBox(height: AppLayout.sp4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppLayout.sp2,
                            vertical: AppLayout.sp1,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.secondaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius:
                                BorderRadius.circular(AppLayout.radiusSm),
                          ),
                          child: Text(
                            doa.category.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              color: scheme.secondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({
    required this.bookmarked,
    required this.onPressed,
  });

  final bool bookmarked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: bookmarked ? S.doaBookmarkRemove : S.doaBookmarkAdd,
      child: Material(
        color: bookmarked ? scheme.secondaryContainer : scheme.surface,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(
              bookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              size: 20,
              color: bookmarked ? scheme.primary : scheme.outline,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state + ambient background glow.
// ---------------------------------------------------------------------------

class _DoaEmpty extends StatelessWidget {
  const _DoaEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppLayout.sp10),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 40,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppLayout.sp3),
          Text(S.doaEmpty, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppLayout.sp1),
          Text(
            S.doaEmptyHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 480,
        height: 480,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [color, color, Colors.transparent],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
      ),
    );
  }
}