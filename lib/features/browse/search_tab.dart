import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/db/quran_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/quran_repositories.dart';
import '../widgets/quran_text_view.dart';
import 'browse_utils.dart';

class SearchTab extends ConsumerStatefulWidget {
  const SearchTab({
    super.key,
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
  ConsumerState<SearchTab> createState() => SearchTabState();
}

enum RowKind { surah, ayah }

class SearchRow {
  const SearchRow(this.kind, this.index);

  final RowKind kind;

  /// Index into [SearchTabState._surahs] or `_ayahs`.
  final int index;
}

class SearchTabState extends ConsumerState<SearchTab> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _searchNode = FocusNode();
  Timer? _debounce;

  List<Surah> _surahs = const [];
  List<SearchResult> _ayahs = const [];
  bool _loading = false;
  bool _searched = false;
  int _selected = -1;

  /// Flattened visible rows (surah rows then ayah rows).
  List<SearchRow> get _rows => [
    for (var i = 0; i < _surahs.length; i++) SearchRow(RowKind.surah, i),
    for (var i = 0; i < _ayahs.length; i++) SearchRow(RowKind.ayah, i),
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
  void didUpdateWidget(SearchTab oldWidget) {
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

  void _activate(SearchRow row) {
    if (row.kind == RowKind.surah) {
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
          onSubmitted: (_) => _activateIndex(_selected >= 0 ? _selected : 0),
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
      return PopularSurahs(onTap: (id) => openSurah(context, id));
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
          const GroupHeader(S.searchGroupSurah),
          for (var i = 0; i < _surahs.length; i++)
            SurahResultRow(
              surah: _surahs[i],
              selected: _selected == _flatIndex(RowKind.surah, i),
              onTap: () => _activateIndex(_flatIndex(RowKind.surah, i)),
            ),
        ],
        if (hasAyah) ...[
          GroupHeader(
            _ayahs.first.matchKind == 'arabic'
                ? S.searchGroupAyah
                : S.searchGroupTranslation,
          ),
          for (var i = 0; i < _ayahs.length; i++)
            AyahResultRow(
              result: _ayahs[i],
              selected: _selected == _flatIndex(RowKind.ayah, i),
              onTap: () => _activateIndex(_flatIndex(RowKind.ayah, i)),
            ),
        ],
      ],
    );
  }

  /// Flattened index of the row for keyboard navigation.
  int _flatIndex(RowKind kind, int i) {
    var n = 0;
    for (var k = 0; k < _rows.length; k++) {
      if (_rows[k].kind == kind && _rows[k].index == i) return n;
      n++;
    }
    return -1;
  }
}

class GroupHeader extends StatelessWidget {
  const GroupHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.sp4,
        AppLayout.sp4,
        AppLayout.sp4,
        AppLayout.sp1,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.tertiary,
        ),
      ),
    );
  }
}

class SurahResultRow extends StatelessWidget {
  const SurahResultRow({
    super.key,
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
    return ResultTile(
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
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class AyahResultRow extends StatelessWidget {
  const AyahResultRow({
    super.key,
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
    return ResultTile(
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

class ResultTile extends StatelessWidget {
  const ResultTile({
    super.key,
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
      color: selected
          ? theme.colorScheme.surfaceContainerLow
          : Colors.transparent,
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

class PopularSurahs extends ConsumerWidget {
  const PopularSurahs({super.key, required this.onTap});

  final void Function(int surahId) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahs = ref.watch(surahListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GroupHeader(S.popularSurahs),
        if (surahs.value == null)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          for (final s in surahs.value!.take(6))
            SurahResultRow(
              surah: s,
              selected: false,
              onTap: () => onTap(s.id),
            ),
        ],
      ],
    );
  }
}
