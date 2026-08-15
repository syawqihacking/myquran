import 'dart:ui' show ImageFilter;

import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/models/amalan_ibadah_data.dart';
import '../../data/providers.dart';

/// Filter chips in the Stitch design's order. `null` = "Semua".
const List<(DeedCategory?, String)> _amalanChips = [
  (null, S.amalanCatSemua),
  (DeedCategory.wajib, S.amalanCatWajib),
  (DeedCategory.sunnah, S.amalanCatSunnah),
  (DeedCategory.dzikir, S.amalanCatDzikir),
  (DeedCategory.sosial, S.amalanCatSosial),
];

/// Height of the pinned search+chips header (search 48 + gap 12 + chips 32 +
/// vertical padding 16, with a little slack).
const double _stickyHeaderHeight = 112;

/// Amalan Ibadah (Stitch "Daily Deeds"): a pinned app bar, a glass goal-progress
/// card, a sticky search bar + category chips, and a responsive grid of deed
/// cards (1/2/3 columns). Completion is persisted per day in
/// shared_preferences (`amalan_ibadah_yyyy-MM-dd`), so it survives restarts and
/// resets each new day. The design's "Learn More" links open a real detail
/// sheet with penjelasan + dalil — no dead buttons.
class AmalanIbadahScreen extends ConsumerStatefulWidget {
  const AmalanIbadahScreen({super.key});

  @override
  ConsumerState<AmalanIbadahScreen> createState() =>
      _AmalanIbadahScreenState();
}

class _AmalanIbadahScreenState extends ConsumerState<AmalanIbadahScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';
  DeedCategory? _category; // null = Semua

  /// Completed deed ids for today (persisted per-day).
  final Set<String> _completed = {};

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// Per-day storage key, e.g. `amalan_ibadah_2026-08-15`.
  String _storageKey(DateTime day) {
    final y = day.year.toString().padLeft(4, '0');
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return 'amalan_ibadah_$y-$m-$d';
  }

  Future<void> _loadToday() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getStringList(_storageKey(DateTime.now())) ?? const [];
    if (mounted) {
      setState(() => _completed.addAll(saved));
    }
  }

  Future<void> _toggle(String id) async {
    final prefs = ref.read(sharedPreferencesProvider);
    setState(() {
      if (!_completed.add(id)) {
        _completed.remove(id);
      }
    });
    await prefs.setStringList(
      _storageKey(DateTime.now()),
      _completed.toList(),
    );
  }

  List<Deed> get _filtered {
    final q = _query.trim().toLowerCase();
    return [
      for (final d in amalanDeeds)
        if ((_category == null || d.category == _category) &&
            (q.isEmpty ||
                d.title.toLowerCase().contains(q) ||
                d.description.toLowerCase().contains(q)))
          d,
    ];
  }

  void _showDetail(Deed deed) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _DeedDetailSheet(deed: deed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final filtered = _filtered;
    final done = _completed.length;
    final total = amalanDeeds.length;
    final progress = total == 0 ? 0.0 : done / total;

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
                _AmalanAppBar(onBack: () => Navigator.of(context).maybePop()),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // Header + glass goal-progress card.
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppLayout.sp6,
                            AppLayout.sp5,
                            AppLayout.sp6,
                            0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _HeaderTitle(),
                              const SizedBox(height: AppLayout.sp4),
                              _GoalProgressCard(
                                done: done,
                                total: total,
                                progress: progress,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Sticky search + filter chips.
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _StickySearchHeader(
                          query: _query,
                          category: _category,
                          searchController: _searchController,
                          searchFocus: _searchFocus,
                          onQueryChanged: (v) => setState(() => _query = v),
                          onCategoryChanged: (c) =>
                              setState(() => _category = c),
                        ),
                      ),
                      // Responsive deed grid (1/2/3 columns).
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppLayout.sp6,
                          AppLayout.sp5,
                          AppLayout.sp6,
                          AppLayout.sp8,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final cols =
                                  width < 700 ? 1 : (width < 1100 ? 2 : 3);
                              const gap = AppLayout.sp6;
                              final itemWidth =
                                  (width - gap * (cols - 1)) / cols;

                              if (filtered.isEmpty) {
                                return const _DeedsEmpty();
                              }
                              return Wrap(
                                spacing: gap,
                                runSpacing: gap,
                                children: [
                                  for (final deed in filtered)
                                    SizedBox(
                                      width: itemWidth,
                                      child: _DeedCard(
                                        deed: deed,
                                        completed:
                                            _completed.contains(deed.id),
                                        onToggle: () => _toggle(deed.id),
                                        onLearnMore: () => _showDetail(deed),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
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
// App bar (same pattern as Doa Harian): back + centered title + spacer.
// ---------------------------------------------------------------------------

class _AmalanAppBar extends StatelessWidget {
  const _AmalanAppBar({required this.onBack});

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
              S.amalanIbadahTitle,
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
// Header title (design: headline-lg-mobile 24px mobile / 32px desktop).
// ---------------------------------------------------------------------------

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wide =
        MediaQuery.sizeOf(context).width >= AppConstants.mobileBreakpoint;
    return Text(
      S.amalanIbadahTitle,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontSize: wide ? 32 : 24,
        height: (wide ? 40 : 32) / (wide ? 32 : 24),
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Glass "Daily Goal Progress" card (rounded-xl, white/90 blur, border, soft
// shadow) with a live X/Y badge and an animated progress bar.
// ---------------------------------------------------------------------------

class _GoalProgressCard extends StatelessWidget {
  const _GoalProgressCard({
    required this.done,
    required this.total,
    required this.progress,
  });

  final int done;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppLayout.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(AppLayout.sp6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            border: Border.all(color: scheme.surfaceContainerHighest),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.amalanGoalProgress,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            height: 28 / 20,
                            fontWeight: FontWeight.w600,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          S.amalanGoalSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            height: 24 / 16,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppLayout.sp3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppLayout.sp3,
                      vertical: AppLayout.sp1,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                    ),
                    child: Text(
                      S.amalanProgress(done, total),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppLayout.sp4),
              // Animated progress bar (track highest, fill primary, 500ms).
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        width: constraints.maxWidth * progress,
                        height: 8,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sticky search bar + filter chips (pinned below the app bar).
// ---------------------------------------------------------------------------

class _StickySearchHeader extends SliverPersistentHeaderDelegate {
  _StickySearchHeader({
    required this.query,
    required this.category,
    required this.searchController,
    required this.searchFocus,
    required this.onQueryChanged,
    required this.onCategoryChanged,
  });

  final String query;
  final DeedCategory? category;
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<DeedCategory?> onCategoryChanged;

  @override
  double get minExtent => _stickyHeaderHeight;

  @override
  double get maxExtent => _stickyHeaderHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      color: scheme.surface.withValues(alpha: 0.95),
      padding: const EdgeInsets.fromLTRB(
        AppLayout.sp6,
        AppLayout.sp2,
        AppLayout.sp6,
        AppLayout.sp2,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSearch(theme, scheme),
          const SizedBox(height: AppLayout.sp3),
          _buildChips(theme, scheme),
        ],
      ),
    );
  }

  Widget _buildSearch(ThemeData theme, ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        // Design inset shadow: inset_0_2px_4px rgba(0,0,0,0.02).
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
      ),
      child: TextField(
        controller: searchController,
        focusNode: searchFocus,
        onChanged: onQueryChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: S.amalanSearchHint,
          prefixIcon: const Icon(Icons.search_rounded),
          prefixIconColor: scheme.outline,
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    searchController.clear();
                    onQueryChanged('');
                    searchFocus.requestFocus();
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
            borderRadius: BorderRadius.circular(AppLayout.radiusMd),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppLayout.radiusMd),
            borderSide: BorderSide(color: scheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildChips(ThemeData theme, ColorScheme scheme) {
    return ScrollConfiguration(
      behavior: _ChipScrollBehavior(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < _amalanChips.length; i++) ...[
              if (i > 0) const SizedBox(width: AppLayout.sp3),
              _FilterChip(
                label: _amalanChips[i].$2,
                selected: category == _amalanChips[i].$1,
                onTap: () => onCategoryChanged(_amalanChips[i].$1),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_StickySearchHeader oldDelegate) =>
      oldDelegate.query != query ||
      oldDelegate.category != category ||
      oldDelegate.searchController != searchController ||
      oldDelegate.searchFocus != searchFocus;
}

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

class _FilterChip extends StatefulWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
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
            horizontal: AppLayout.sp4,
            vertical: AppLayout.sp2,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppLayout.radiusFull),
            border: selected
                ? null
                : Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.3),
                  ),
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
// Deed card: quarter-circle accent, 48px icon, custom checkbox, title +
// category badge, description (max 2 lines), and a "Pelajari" footer link.
// ---------------------------------------------------------------------------

class _DeedCard extends StatefulWidget {
  const _DeedCard({
    required this.deed,
    required this.completed,
    required this.onToggle,
    required this.onLearnMore,
  });

  final Deed deed;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback onLearnMore;

  @override
  State<_DeedCard> createState() => _DeedCardState();
}

class _DeedCardState extends State<_DeedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final deed = widget.deed;
    final completed = widget.completed;

    // Stitch JS toggle: completed → primary/5, incomplete → tertiary-container/10.
    final accentColor = completed
        ? scheme.primary.withValues(alpha: 0.05)
        : scheme.tertiaryContainer.withValues(alpha: 0.10);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppLayout.durBase,
        curve: Curves.easeOut,
        transform: _hovered ? Matrix4.translationValues(0, -4, 0) : null,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          border: Border.all(color: scheme.surfaceContainerHighest),
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
            // Decorative quarter-circle accent, top-right.
            Positioned(
              top: 0,
              right: 0,
              child: AnimatedContainer(
                duration: AppLayout.durBase,
                curve: Curves.easeOut,
                transform: _hovered
                    ? Matrix4.diagonal3Values(1.1, 1.1, 1)
                    : null,
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(96),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon + checkbox row.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.sp6,
                    AppLayout.sp6,
                    AppLayout.sp6,
                    0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _IconBadge(completed: completed, icon: deed.icon),
                      const Spacer(),
                      _DeedCheckbox(
                        checked: completed,
                        onChanged: widget.onToggle,
                      ),
                    ],
                  ),
                ),
                // Title + category badge + description.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.sp6,
                    AppLayout.sp4,
                    AppLayout.sp6,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              deed.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 20,
                                height: 28 / 20,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppLayout.sp2),
                          _CategoryBadge(label: deed.category.label),
                        ],
                      ),
                      const SizedBox(height: AppLayout.sp2),
                      Text(
                        deed.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          height: 24 / 16,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Footer: "Pelajari" link (opens the detail sheet).
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.sp6,
                    AppLayout.sp4,
                    AppLayout.sp6,
                    AppLayout.sp6,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: scheme.surfaceContainerHighest),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _LearnMoreButton(onTap: widget.onLearnMore),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.completed, required this.icon});

  final bool completed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppLayout.durBase,
      curve: Curves.easeOut,
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        // Stitch JS toggle: completed → secondary-container/primary,
        // incomplete → surface-container/on-surface-variant.
        color: completed ? scheme.secondaryContainer : scheme.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 24,
        color: completed ? scheme.primary : scheme.onSurfaceVariant,
      ),
    );
  }
}

class _DeedCheckbox extends StatelessWidget {
  const _DeedCheckbox({required this.checked, required this.onChanged});

  final bool checked;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: checked ? S.amalanToggleUndone : S.amalanToggleDone,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onChanged,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(6), // comfortable hit area
            child: AnimatedContainer(
              duration: AppLayout.durBase,
              curve: Curves.easeOut,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: checked ? scheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: checked ? scheme.primary : scheme.outline,
                  width: 2,
                ),
              ),
              child: checked
                  ? const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppLayout.radiusSm),
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 10,
          height: 14 / 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _LearnMoreButton extends StatelessWidget {
  const _LearnMoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.sp2,
          vertical: AppLayout.sp1,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            S.amalanLearnMore,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_rounded, size: 16),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail bottom sheet (the design's "Learn More" target — real content).
// ---------------------------------------------------------------------------

class _DeedDetailSheet extends StatelessWidget {
  const _DeedDetailSheet({required this.deed});

  final Deed deed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppLayout.sp6,
          0,
          AppLayout.sp6,
          AppLayout.sp8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    deed.icon,
                    size: 24,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: AppLayout.sp3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deed.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        deed.category.label.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppLayout.sp5),
            Text(
              S.amalanDetailPenjelasan,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: AppLayout.sp1),
            Text(
              deed.penjelasan,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                height: 24 / 16,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppLayout.sp4),
            Text(
              S.amalanDetailDalil,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: AppLayout.sp1),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppLayout.sp4),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                border: Border.all(color: scheme.surfaceContainerHighest),
              ),
              child: Text(
                deed.dalil,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  height: 24 / 16,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state + ambient background glow.
// ---------------------------------------------------------------------------

class _DeedsEmpty extends StatelessWidget {
  const _DeedsEmpty();

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
          Text(S.amalanEmpty, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppLayout.sp1),
          Text(
            S.amalanEmptyHint,
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