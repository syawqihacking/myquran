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
import '../reader/reader_screen.dart';
import '../widgets/ayah_number_badge.dart';
import '../widgets/quran_text_view.dart';

/// Segments of the unified Al-Qur'an page (the list tabs). Pencarian bukan
/// segmen — ia mode yang menimpa area daftar (lihat [BrowseState.searchOpen]).
enum BrowseSegment { surah, juz }

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

/// Satu halaman untuk semua navigasi baca (design §2): daftar surah dan juz
/// lewat segmen, plus pencarian ayat/terjemahan yang dibuka lewat ikon search.
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
    widget.state.value = widget.state.value
        .copyWith(searchOpen: !widget.state.value.searchOpen);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.state.value;
    final showSurah = !state.searchOpen && state.segment == BrowseSegment.surah;
    final showJuz = !state.searchOpen && state.segment == BrowseSegment.juz;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp6,
        vertical: AppLayout.sp8,
      ),
      children: [
        Text(
          S.browseEyebrow,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: AppLayout.sp2),
        Row(
          children: [
            Expanded(
              child: Text(S.browseTitle, style: theme.textTheme.displaySmall),
            ),
            IconButton(
              tooltip: state.searchOpen ? S.closeSearch : S.openSearch,
              isSelected: state.searchOpen,
              onPressed: _toggleSearch,
              icon: const Icon(Icons.search_rounded),
              selectedIcon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        const SizedBox(height: AppLayout.sp2),
        Text(
          S.browseCaption,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppLayout.sp6),
        _SegmentControl(segment: state.segment, onChanged: _selectSegment),
        const SizedBox(height: AppLayout.sp5),
        // Visibility(maintainState) keeps each panel alive so the search
        // query and segment state survive switching tabs / views.
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
          visible: state.searchOpen,
          maintainState: true,
          child: _SearchTab(
            active: state.searchOpen,
            focusTick: widget.focusTick,
            onClose: _toggleSearch,
          ),
        ),
      ],
    );
  }
}

class _SegmentControl extends StatelessWidget {
  const _SegmentControl({required this.segment, required this.onChanged});

  final BrowseSegment segment;
  final ValueChanged<BrowseSegment> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<BrowseSegment>(
      segments: const [
        ButtonSegment(value: BrowseSegment.surah, label: Text(S.surahSegment)),
        ButtonSegment(value: BrowseSegment.juz, label: Text(S.juzSegment)),
      ],
      selected: {segment},
      onSelectionChanged: (s) => onChanged(s.first),
      showSelectedIcon: false,
      expandedInsets: EdgeInsets.zero,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        ),
        side: WidgetStatePropertyAll(
          BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [...list.map((s) => _SurahRow(surah: s))],
        );
      },
    );
  }
}

class _SurahRow extends StatelessWidget {
  const _SurahRow({required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = surah.revelationType == 0 ? S.makkiyah : S.madaniyah;

    return HoverTile(
      onTap: () => openSurah(context, surah.id),
      child: Row(
        children: [
          QTextDisplay(text: surah.nameArabic, step: 5),
          const SizedBox(width: AppLayout.sp4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(surah.nameLatin, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  '$meta · ${surah.ayahCount} ${S.ayatCount}',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...list.map((j) {
              final first = surahMap[j.firstSurahId];
              final last = surahMap[j.lastSurahId];
              final range = first == null || last == null
                  ? ''
                  : '${first.nameLatin} — ${last.nameLatin}';
              return _JuzRow(juz: j, range: range);
            }),
          ],
        );
      },
    );
  }
}

class _JuzRow extends StatelessWidget {
  const _JuzRow({required this.juz, required this.range});

  final JuzInfo juz;
  final String range;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HoverTile(
      onTap: () => openSurah(context, juz.firstSurahId,
          initialAyahId: juz.firstAyahId),
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
            child: Text(
              toArabicIndic(juz.juz),
              style: TextStyle(
                fontFamily: AppConstants.fontQuran,
                fontSize: 22,
                color: theme.colorScheme.tertiary,
              ),
            ),
          ),
          const SizedBox(width: AppLayout.sp4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Juz ${juz.juz}', style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  range,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppConstants.searchCardWidth,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              focusNode: _searchNode,
              onChanged: _onChanged,
              onSubmitted: (_) =>
                  _activateIndex(_selected >= 0 ? _selected : 0),
              decoration: InputDecoration(
                hintText: S.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                ),
              ),
            ),
            const SizedBox(height: AppLayout.sp3),
            _buildResults(),
          ],
        ),
      ),
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
