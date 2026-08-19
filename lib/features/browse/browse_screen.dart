import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/db/quran_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/quran_repositories.dart';
import '../../data/repositories/user_repositories.dart';
import '../reader/reader_screen.dart';
import '../widgets/ayah_number_badge.dart';
import '../widgets/liquid_glass.dart';
import '../widgets/quran_text_view.dart';

/// Segments of the unified Al-Qur'an page (the list tabs). Pencarian bukan
/// segmen — ia mode yang menimpa area daftar (lihat [BrowseState.searchOpen]).
enum BrowseSegment { surah, juz, favorit }

/// Full state of the browse page: which list tab is active and whether the
/// inline search panel is open. Owned by the shell so it survives IndexedStack
/// switches and can be driven from outside (Ctrl+K, Beranda quick access).
class BrowseState {
  const BrowseState({
    this.segment = BrowseSegment.surah,
    this.searchOpen = false,
  });

  final BrowseSegment segment;
  final bool searchOpen;

  BrowseState copyWith({BrowseSegment? segment, bool? searchOpen}) {
    return BrowseState(
      segment: segment ?? this.segment,
      searchOpen: searchOpen ?? this.searchOpen,
    );
  }
}

/// Satu halaman untuk semua navigasi baca (design §2): daftar surah, juz, dan
/// favorit lewat segmen, plus pencarian yang dibuka lewat bilah pencarian atau
/// ikon search.
class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({
    super.key,
    required this.state,
    required this.focusTick,
  });

  /// Lives in the shell: the page listens to it for rebuilds and external
  /// state changes (Ctrl+K, Beranda quick access).
  final ValueNotifier<BrowseState> state;

  /// Bumped by the shell on every Ctrl+K so the Cari field re-focuses even
  /// when the search panel is already open.
  final int focusTick;

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onState);
  }

  @override
  void dispose() {
    widget.state.removeListener(_onState);
    super.dispose();
  }

  void _onState() => setState(() {});

  void _selectSegment(BrowseSegment segment) {
    widget.state.value = BrowseState(segment: segment, searchOpen: false);
  }

  void _toggleSearch() {
    widget.state.value =
        widget.state.value.copyWith(searchOpen: !widget.state.value.searchOpen);
  }

  void _openSearchPanel() {
    widget.state.value = widget.state.value.copyWith(searchOpen: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state.value;
    final showSurah = !state.searchOpen && state.segment == BrowseSegment.surah;
    final showJuz = !state.searchOpen && state.segment == BrowseSegment.juz;
    final showFavorit =
        !state.searchOpen && state.segment == BrowseSegment.favorit;
    final isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BrowseAppBar(
            searchOpen: state.searchOpen,
            onToggleSearch: _toggleSearch,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppLayout.sp6,
                AppLayout.sp5,
                AppLayout.sp6,
                isMobile
                    ? glassNavClearance + MediaQuery.paddingOf(context).bottom
                    : AppLayout.sp8,
              ),
              children: [
                // The design's inline search bar. Tapping it opens the search
                // panel (which owns the real field, auto-focused). While the
                // panel is open the bar is hidden — the panel's own field
                // takes its place below the tabs.
                if (!state.searchOpen) ...[
                  _SearchBarTrigger(onTap: _openSearchPanel),
                  const SizedBox(height: AppLayout.sp4),
                ],
                _SegmentTabs(segment: state.segment, onChanged: _selectSegment),
                const SizedBox(height: AppLayout.sp5),
                // Visibility(maintainState) keeps each panel alive so the
                // search query and segment state survive switching tabs/views.
                Visibility(
                  visible: showSurah,
                  maintainState: true,
                  child: const _SurahList(),
                ),
                Visibility(
                  visible: showJuz,
                  maintainState: true,
                  child: const _JuzList(),
                ),
                Visibility(
                  visible: showFavorit,
                  maintainState: true,
                  child: const _FavoritList(),
                ),
                Visibility(
                  visible: state.searchOpen,
                  maintainState: true,
                  child: _SearchTab(
                    active: state.searchOpen,
                    focusTick: widget.focusTick,
                    onClose: _toggleSearch,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pinned app bar (Stitch Daftar Surah §1)
// ---------------------------------------------------------------------------

/// Pinned top bar: centered "Al-Qur'an" title with the search action on the
/// right. Mirrors the home app bar so the shell's settings gear can sit below
/// it the same way (see app.dart). The hamburger from the Stitch design is
/// omitted: the shell already owns navigation (sidebar on desktop, bottom bar
/// on mobile), so a drawer affordance here would be a dead button.
class _BrowseAppBar extends StatelessWidget {
  const _BrowseAppBar({
    required this.searchOpen,
    required this.onToggleSearch,
  });

  final bool searchOpen;
  final VoidCallback onToggleSearch;

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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            S.browseTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
          Positioned(
            right: 0,
            child: GlassTouchButton(
              radius: AppLayout.radiusFull,
              child: IconButton(
                tooltip: searchOpen ? S.closeSearch : S.openSearch,
                isSelected: searchOpen,
                onPressed: onToggleSearch,
                icon: Icon(Icons.search_rounded, color: scheme.primary),
                selectedIcon: Icon(Icons.close_rounded, color: scheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inline search bar (Stitch Daftar Surah §2)
// ---------------------------------------------------------------------------

/// The design's full-width rounded search bar. Not a real field — it opens the
/// search panel (which auto-focuses its own field). Hover turns the border
/// primary, echoing the design's focus state on desktop.
class _SearchBarTrigger extends StatefulWidget {
  const _SearchBarTrigger({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_SearchBarTrigger> createState() => _SearchBarTriggerState();
}

class _SearchBarTriggerState extends State<_SearchBarTrigger> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GlassTouchButton(
        radius: AppLayout.radiusFull,
        child: AnimatedContainer(
          duration: AppLayout.durBase,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppLayout.radiusFull),
            border: Border.all(
              color: _hovered ? scheme.primary : scheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppLayout.radiusFull),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppLayout.radiusFull),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.sp4,
                  vertical: AppLayout.sp3,
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: scheme.outline),
                    const SizedBox(width: AppLayout.sp3),
                    Text(
                      S.browseSearchHint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Segment tabs (Stitch Daftar Surah §3)
// ---------------------------------------------------------------------------

/// Surah / Juz / Favorit tabs: headline-sized labels, a 2px primary underline
/// on the active tab, and a thin divider under the whole strip.
class _SegmentTabs extends StatelessWidget {
  const _SegmentTabs({required this.segment, required this.onChanged});

  final BrowseSegment segment;
  final ValueChanged<BrowseSegment> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          // Thin divider under the whole tab strip.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TabButton(
                label: S.surahSegment,
                selected: segment == BrowseSegment.surah,
                onTap: () => onChanged(BrowseSegment.surah),
              ),
              const SizedBox(width: AppLayout.sp6),
              _TabButton(
                label: S.juzSegment,
                selected: segment == BrowseSegment.juz,
                onTap: () => onChanged(BrowseSegment.juz),
              ),
              const SizedBox(width: AppLayout.sp6),
              _TabButton(
                label: S.favoritSegment,
                selected: segment == BrowseSegment.favorit,
                onTap: () => onChanged(BrowseSegment.favorit),
              ),
            ],
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp1),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? scheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 20,
              height: 28 / 20,
              fontWeight: FontWeight.w600,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared card surface (Stitch Daftar Surah §4)
// ---------------------------------------------------------------------------

/// Rounded-xl card on `surfaceContainerLowest` with a soft emerald shadow.
/// On hover the shadow deepens and a primary @ 10% border appears.
class _HoverCard extends StatefulWidget {
  const _HoverCard({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppLayout.durBase,
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(AppLayout.sp4),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          border: Border.all(
            color: _hovered
                ? scheme.primary.withValues(alpha: 0.10)
                : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: _hovered ? 0.08 : 0.04),
              blurRadius: _hovered ? 32 : 20,
              offset: Offset(0, _hovered ? 12 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Surah list
// ---------------------------------------------------------------------------

class _SurahList extends ConsumerWidget {
  const _SurahList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final surahs = ref.watch(surahListProvider);

    return surahs.when(
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(48),
        child: CircularProgressIndicator(),
      )),
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
              _SurahCard(
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

class _SurahCard extends StatelessWidget {
  const _SurahCard({required this.surah, required this.onTap});

  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _HoverCard(
      onTap: onTap,
      child: _SurahRowContent(
        surah: surah,
        metaTrailing: '${surah.ayahCount} ${S.ayatCount}',
      ),
    );
  }
}

/// The card's inner row: number badge, name + meta column, Arabic name.
/// Shared by the surah list and the Favorit tab (which swaps the meta
/// trailing text for a bookmark count).
class _SurahRowContent extends StatelessWidget {
  const _SurahRowContent({required this.surah, required this.metaTrailing});

  final Surah surah;
  final String metaTrailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isFirst = surah.id == 1;
    final isMakki = surah.revelationType == 0;
    final isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

    return Row(
      children: [
        _NumberBadge(number: surah.id, isFirst: isFirst),
        const SizedBox(width: AppLayout.sp4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                surah.nameLatin,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  height: 28 / 20,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              _MetaRow(
                translation: surah.nameIndonesian,
                trailing: metaTrailing,
                meta: isMakki ? S.makkiyah : S.madaniyah,
                isMakki: isMakki,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppLayout.sp3),
        // Arabic name (Amiri, primary). Sized down on mobile so the row stays
        // readable; right-aligned at the card edge like the design.
        Flexible(
          child: QTextDisplay(
            text: surah.nameArabic,
            step: isMobile ? 5 : 7,
            color: scheme.primary,
            maxLines: 1,
            overflow: TextOverflow.clip,
            alignment: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// 48×48 circle number badge with a faint dot-grid watermark. Al-Fatihah
/// (surah 1) uses the sage `secondaryContainer`; the rest use `surfaceContainer`.
class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number, required this.isFirst});

  final int number;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bg = isFirst ? scheme.secondaryContainer : scheme.surfaceContainer;
    final fg = isFirst ? scheme.onSecondaryContainer : scheme.onSurfaceVariant;

    return Container(
      width: 48,
      height: 48,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle dot-grid watermark (design: 1px dots on a 6px grid @ 5%).
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(painter: _DotGridPainter(color: fg)),
            ),
          ),
          Text(
            '$number',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 20,
              height: 1,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 6.0;
    const radius = 1.0;
    var y = spacing / 2;
    while (y < size.height) {
      var x = spacing / 2;
      while (x < size.width) {
        canvas.drawCircle(Offset(x, y), radius, paint);
        x += spacing;
      }
      y += spacing;
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => oldDelegate.color != color;
}

/// Uppercase meta line: translation • X Ayat • Makkiyah/Madaniyah icon.
class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.translation,
    required this.trailing,
    required this.meta,
    required this.isMakki,
  });

  final String translation;
  final String trailing;
  final String meta;
  final bool isMakki;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final style = theme.textTheme.labelSmall?.copyWith(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: scheme.onSurfaceVariant,
    );
    return Wrap(
      spacing: AppLayout.sp2,
      runSpacing: AppLayout.sp1,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(translation.toUpperCase(), style: style),
        const _MetaDot(),
        Text(trailing.toUpperCase(), style: style),
        const _MetaDot(),
        Tooltip(
          message: meta,
          child: Icon(
            isMakki ? Icons.location_city_rounded : Icons.mosque_rounded,
            size: 16,
            color: isMakki ? scheme.tertiary : scheme.secondary,
          ),
        ),
      ],
    );
  }
}

class _MetaDot extends StatelessWidget {
  const _MetaDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Juz list
// ---------------------------------------------------------------------------

class _JuzList extends ConsumerWidget {
  const _JuzList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final juzs = ref.watch(juzListProvider);
    final surahs = ref.watch(surahListProvider);
    final surahMap = surahs.value == null
        ? <int, Surah>{}
        : {for (final s in surahs.value!) s.id: s};

    return juzs.when(
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(48),
        child: CircularProgressIndicator(),
      )),
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
              _JuzRow(
                juz: list[i],
                range: _juzRange(surahMap, list[i]),
              ),
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

class _JuzRow extends StatelessWidget {
  const _JuzRow({required this.juz, required this.range});

  final JuzInfo juz;
  final String range;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return _HoverCard(
      onTap: () => openSurah(context, juz.firstSurahId,
          initialAyahId: juz.firstAyahId),
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

// ---------------------------------------------------------------------------
// Favorit tab
// ---------------------------------------------------------------------------

/// Favorit = surah yang punya minimal satu penanda ayat. Dibaca dari
/// [bookmarksProvider] yang sudah ada (tanpa plumbing baru); setiap baris
/// membuka surah ke ayat penanda pertama. Kosong → empty state yang sopan.
class _FavoritList extends ConsumerWidget {
  const _FavoritList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookmarks = ref.watch(bookmarksProvider);

    return bookmarks.when(
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(48),
        child: CircularProgressIndicator(),
      )),
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
        if (ids.isEmpty) return const _FavoritEmpty();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < ids.length; i++) ...[
              if (i > 0) const SizedBox(height: AppLayout.sp3),
              _FavoritRow(
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

class _FavoritRow extends StatelessWidget {
  const _FavoritRow({
    required this.surah,
    required this.firstAyahId,
    required this.count,
  });

  final Surah surah;
  final int firstAyahId;
  final int count;

  @override
  Widget build(BuildContext context) {
    return _HoverCard(
      onTap: () => openSurah(context, surah.id, initialAyahId: firstAyahId),
      child: _SurahRowContent(
        surah: surah,
        metaTrailing: '$count ${S.penandaCount}',
      ),
    );
  }
}

class _FavoritEmpty extends StatelessWidget {
  const _FavoritEmpty();

  @override
  Widget build(BuildContext context) {
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
          Text(S.favoritEmptyTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppLayout.sp2),
          Text(
            S.favoritEmptyMessage,
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

// ---------------------------------------------------------------------------
// Search tab (moved from the old search overlay)
// ---------------------------------------------------------------------------

class _SearchTab extends ConsumerStatefulWidget {
  const _SearchTab({
    required this.active,
    required this.focusTick,
    required this.onClose,
  });

  /// Whether the search panel is currently open. Drives auto-focus when it
  /// becomes visible (and unfocus when hidden again).
  final bool active;

  /// Shell-driven counter; on change the field re-focuses (Ctrl+K).
  final int focusTick;

  /// Closes the search panel (header toggle, Esc, segment switch).
  final VoidCallback onClose;

  @override
  ConsumerState<_SearchTab> createState() => _SearchTabState();
}

enum _RowKind { surah, ayah }

class _SearchRow {
  const _SearchRow(this.kind, this.index);

  final _RowKind kind;

  /// Index into [_SearchTabState._surahs] or `_ayahs`.
  final int index;
}

class _SearchTabState extends ConsumerState<_SearchTab> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _searchNode = FocusNode();
  Timer? _debounce;

  List<Surah> _surahs = const [];
  List<SearchResult> _ayahs = const [];
  bool _loading = false;
  bool _searched = false;
  int _selected = -1;

  /// Flattened visible rows (surah rows then ayah rows).
  List<_SearchRow> get _rows => [
        for (var i = 0; i < _surahs.length; i++) _SearchRow(_RowKind.surah, i),
        for (var i = 0; i < _ayahs.length; i++) _SearchRow(_RowKind.ayah, i),
      ];

  @override
  void initState() {
    super.initState();
    _searchNode.onKeyEvent = _handleKey;
    if (widget.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.active) _searchNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(_SearchTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusTick != oldWidget.focusTick) {
      // Shell asked to open/reopen search (Ctrl+K): focus even if the panel
      // is already open but the field lost focus in between.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.active) _searchNode.requestFocus();
      });
    } else if (widget.active && !oldWidget.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.active) _searchNode.requestFocus();
      });
    } else if (!widget.active && oldWidget.active) {
      _searchNode.unfocus();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _searchNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _move(1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _move(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _activateIndex(_selected >= 0 ? _selected : 0);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onClose();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _run(q));
    setState(() {
      _searched = q.trim().isNotEmpty;
      _selected = -1;
      if (!_searched) {
        _surahs = const [];
        _ayahs = const [];
      }
    });
  }

  Future<void> _run(String q) async {
    final query = q.trim();
    if (query.isEmpty) return;
    setState(() => _loading = true);
    final results = await Future.wait([
      ref.read(searchRepositoryProvider).search(query, limit: 12),
      ref.read(surahRepositoryProvider).searchByName(query),
    ]);
    if (!mounted) return;
    setState(() {
      _ayahs = results[0] as List<SearchResult>;
      _surahs = results[1] as List<Surah>;
      _loading = false;
    });
  }

  void _move(int delta) {
    final rows = _rows;
    if (rows.isEmpty) return;
    setState(() {
      _selected = (_selected + delta + rows.length) % rows.length;
    });
  }

  void _activate(_SearchRow row) {
    if (row.kind == _RowKind.surah) {
      openSurah(context, _surahs[row.index].id);
    } else {
      final r = _ayahs[row.index];
      openSurah(context, r.surahId, initialAyahId: r.ayahId);
    }
  }

  void _activateIndex(int i) {
    final rows = _rows;
    if (i < 0 || i >= rows.length) return;
    _activate(rows[i]);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          focusNode: _searchNode,
          onChanged: _onChanged,
          onSubmitted: (_) =>
              _activateIndex(_selected >= 0 ? _selected : 0),
          decoration: InputDecoration(
            hintText: S.browseSearchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            prefixIconColor: scheme.outline,
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _controller.clear();
                      _onChanged('');
                      _searchNode.requestFocus();
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
              borderSide: BorderSide(color: scheme.primary),
            ),
          ),
        ),
        const SizedBox(height: AppLayout.sp3),
        _buildResults(),
      ],
    );
  }

  Widget _buildResults() {
    final theme = Theme.of(context);
    final rows = _rows;

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_searched) {
      return _PopularSurahs(onTap: (id) => openSurah(context, id));
    }
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppLayout.sp9),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppLayout.sp3),
            Text(S.noResultsTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppLayout.sp1),
            Text(
              S.noResultsHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final hasSurah = _surahs.isNotEmpty;
    final hasAyah = _ayahs.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasSurah) ...[
          const _GroupHeader(S.searchGroupSurah),
          for (var i = 0; i < _surahs.length; i++)
            _SurahResultRow(
              surah: _surahs[i],
              selected: _selected == _flatIndex(_RowKind.surah, i),
              onTap: () => _activateIndex(_flatIndex(_RowKind.surah, i)),
            ),
        ],
        if (hasAyah) ...[
          _GroupHeader(
            _ayahs.first.matchKind == 'arabic'
                ? S.searchGroupAyah
                : S.searchGroupTranslation,
          ),
          for (var i = 0; i < _ayahs.length; i++)
            _AyahResultRow(
              result: _ayahs[i],
              selected: _selected == _flatIndex(_RowKind.ayah, i),
              onTap: () => _activateIndex(_flatIndex(_RowKind.ayah, i)),
            ),
        ],
      ],
    );
  }

  /// Flattened index of the row for keyboard navigation.
  int _flatIndex(_RowKind kind, int i) {
    var n = 0;
    for (var k = 0; k < _rows.length; k++) {
      if (_rows[k].kind == kind && _rows[k].index == i) return n;
      n++;
    }
    return -1;
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppLayout.sp4, AppLayout.sp4, AppLayout.sp4, AppLayout.sp1),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.tertiary,
        ),
      ),
    );
  }
}

class _SurahResultRow extends StatelessWidget {
  const _SurahResultRow({
    required this.surah,
    required this.selected,
    required this.onTap,
  });

  final Surah surah;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _ResultTile(
      selected: selected,
      onTap: onTap,
      child: Row(
        children: [
          QTextDisplay(text: surah.nameArabic, step: 3),
          const SizedBox(width: AppLayout.sp4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(surah.nameLatin, style: theme.textTheme.titleMedium),
                Text(
                  surah.nameIndonesian,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _AyahResultRow extends StatelessWidget {
  const _AyahResultRow({
    required this.result,
    required this.selected,
    required this.onTap,
  });

  final SearchResult result;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _ResultTile(
      selected: selected,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${result.surahNameLatin} • Ayat ${result.ayahNumber} • Juz ${result.juz}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: AppLayout.sp1),
          QTextDisplay(text: result.arabicSnippet, step: 2),
          if (result.translationSnippet.isNotEmpty) ...[
            const SizedBox(height: AppLayout.sp1),
            Text(
              result.translationSnippet,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected ? theme.colorScheme.surfaceContainerLow : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.sp4,
            vertical: AppLayout.sp2,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PopularSurahs extends ConsumerWidget {
  const _PopularSurahs({required this.onTap});

  final void Function(int surahId) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahs = ref.watch(surahListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GroupHeader(S.popularSurahs),
        if (surahs.value == null)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          for (final s in surahs.value!.take(6))
            _SurahResultRow(surah: s, selected: false, onTap: () => onTap(s.id)),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared hover tile + navigation helper (also used by Beranda)
// ---------------------------------------------------------------------------

/// Hoverable, ripple-free list tile used across the read lists.
class HoverTile extends StatefulWidget {
  const HoverTile({super.key, required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<HoverTile> createState() => _HoverTileState();
}

class _HoverTileState extends State<HoverTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
        hoverColor: Colors.transparent,
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
          child: widget.child,
        ),
      ),
    );
  }
}

/// Pushes the reader for [surahId], optionally scrolled to an ayah.
void openSurah(BuildContext context, int surahId, {int? initialAyahId}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ReaderScreen(surahId: surahId, initialAyahId: initialAyahId),
    ),
  );
}