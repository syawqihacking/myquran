import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../widgets/liquid_glass.dart';
import 'browse_app_bar.dart';
import 'favorit_list.dart';
import 'juz_list.dart';
import 'search_bar_trigger.dart';
import 'search_tab.dart';
import 'segment_tabs.dart';
import 'surah_list.dart';

export 'browse_utils.dart';
export 'segment_tabs.dart' show BrowseSegment;

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
  const BrowseScreen({super.key, required this.state, required this.focusTick});

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
    widget.state.value = widget.state.value.copyWith(
      searchOpen: !widget.state.value.searchOpen,
    );
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
      child: Stack(
        children: [
          // Content fills the screen and scrolls behind the floating glass
          // header pills — exactly like the home header.
          Positioned.fill(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppLayout.sp6,
                AppLayout.sp10 + AppLayout.sp5,
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
                  SearchBarTrigger(onTap: _openSearchPanel),
                  const SizedBox(height: AppLayout.sp4),
                ],
                SegmentTabs(segment: state.segment, onChanged: _selectSegment),
                const SizedBox(height: AppLayout.sp5),
                // Visibility(maintainState) keeps each panel alive so the
                // search query and segment state survive switching tabs/views.
                Visibility(
                  visible: showSurah,
                  maintainState: true,
                  child: const SurahList(),
                ),
                Visibility(
                  visible: showJuz,
                  maintainState: true,
                  child: const JuzList(),
                ),
                Visibility(
                  visible: showFavorit,
                  maintainState: true,
                  child: const FavoritList(),
                ),
                Visibility(
                  visible: state.searchOpen,
                  maintainState: true,
                  child: SearchTab(
                    active: state.searchOpen,
                    focusTick: widget.focusTick,
                    onClose: _toggleSearch,
                  ),
                ),
              ],
            ),
          ),
          // Floating glass header pills, over the scrolling content.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BrowseAppBar(
              searchOpen: state.searchOpen,
              onToggleSearch: _toggleSearch,
            ),
          ),
        ],
      ),
    );
  }
}
