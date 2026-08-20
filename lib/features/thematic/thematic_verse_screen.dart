import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../data/models/thematic_quran_data.dart';
import '../widgets/glass_pill.dart';
import 'thematic_verse_detail_screen.dart';

class ThematicVerseScreen extends StatefulWidget {
  const ThematicVerseScreen({super.key});

  @override
  State<ThematicVerseScreen> createState() => _ThematicVerseScreenState();
}

class _ThematicVerseScreenState extends State<ThematicVerseScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';
  ThemeGroup _selectedGroup = ThemeGroup.semua;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ThematicVerseDetailScreen(searchQuery: trimmed),
      ),
    );
  }

  List<QuranThemeCategory> get _filteredCategories {
    final q = _query.trim().toLowerCase();
    return kQuranThemeCategories.where((category) {
      final matchesGroup = _selectedGroup == ThemeGroup.semua ||
          category.group == _selectedGroup;
      if (!matchesGroup) return false;

      if (q.isEmpty) return true;
      final titleMatch = category.title.toLowerCase().contains(q);
      final descMatch = category.description.toLowerCase().contains(q);
      final keywordMatch =
          category.keywords.any((k) => k.toLowerCase().contains(q));
      return titleMatch || descMatch || keywordMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final filtered = _filteredCategories;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          // Ambient radial gradients matching the app's aesthetic
          Positioned(
            top: -120,
            right: -120,
            child: _AmbientGlow(color: scheme.primary.withValues(alpha: 0.04)),
          ),
          Positioned(
            bottom: -120,
            left: -120,
            child: _AmbientGlow(color: scheme.primary.withValues(alpha: 0.04)),
          ),
          SafeArea(
            child: Stack(
              children: [
                // Content scrolls behind the floating glass app bar
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final cols = width < 650 ? 1 : (width < 1000 ? 2 : 3);
                      const gap = AppLayout.sp4;
                      final contentWidth = width - AppLayout.sp6 * 2;
                      final itemWidth =
                          (contentWidth - gap * (cols - 1)) / cols;

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppLayout.sp6,
                          AppLayout.sp10 + AppLayout.sp5,
                          AppLayout.sp6,
                          AppLayout.sp8,
                        ),
                        children: [
                          // Search field
                          _buildSearchField(scheme),
                          const SizedBox(height: AppLayout.sp4),

                          // Direct Search in Quran action banner if user typed query
                          if (_query.trim().isNotEmpty) ...[
                            _buildQuranSearchBanner(scheme, theme),
                            const SizedBox(height: AppLayout.sp4),
                          ],

                          // Filter chips
                          _buildFilterChips(scheme, theme),
                          const SizedBox(height: AppLayout.sp5),

                          // Header count
                          Row(
                            children: [
                              Text(
                                'Daftar Tema',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHighest
                                      .withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(
                                    AppLayout.radiusFull,
                                  ),
                                ),
                                child: Text(
                                  '${filtered.length} Tema',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppLayout.sp4),

                          // Grid / Wrap of minimalist cards
                          if (filtered.isEmpty)
                            _buildEmptyState(scheme, theme)
                          else
                            Wrap(
                              spacing: gap,
                              runSpacing: gap,
                              children: [
                                for (final cat in filtered)
                                  SizedBox(
                                    width: itemWidth,
                                    child: _MinimalThemeCard(
                                      category: cat,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                ThematicVerseDetailScreen(
                                              category: cat,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                ),

                // Floating glass header
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _ThematicAppBar(
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ColorScheme scheme) {
    return AnimatedContainer(
      duration: AppLayout.durBase,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppLayout.radiusFull),
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
        onSubmitted: _submitSearch,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari tema (misal: sabar, rezeki, doa)...',
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
                  tooltip: 'Hapus',
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

  Widget _buildQuranSearchBanner(ColorScheme scheme, ThemeData theme) {
    return InkWell(
      onTap: () => _submitSearch(_query),
      borderRadius: BorderRadius.circular(AppLayout.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.sp4,
          vertical: AppLayout.sp3,
        ),
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          border: Border.all(
            color: scheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_outlined,
              size: 20,
              color: scheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cari ayat dengan teks "$_query" di Al-Qur\'an',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: scheme.primary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme scheme, ThemeData theme) {
    final groups = [
      (ThemeGroup.semua, 'Semua'),
      (ThemeGroup.ketenangan, 'Ketenangan Hati'),
      (ThemeGroup.sabarUjian, 'Sabar & Ujian'),
      (ThemeGroup.rezekiIbadah, 'Rezeki & Ibadah'),
      (ThemeGroup.keluargaSosial, 'Keluarga & Adab'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < groups.length; i++) ...[
            if (i > 0) const SizedBox(width: AppLayout.sp3),
            _FilterChip(
              label: groups[i].$2,
              selected: _selectedGroup == groups[i].$1,
              onTap: () => setState(() => _selectedGroup = groups[i].$1),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme scheme, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppLayout.sp8),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: scheme.outline,
            ),
            const SizedBox(height: AppLayout.sp3),
            Text(
              'Tidak ada tema yang cocok',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Gunakan pencarian bebas untuk mencari ayat di seluruh Al-Qur\'an',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (_query.isNotEmpty) ...[
              const SizedBox(height: AppLayout.sp4),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.search_rounded, size: 18),
                label: Text('Cari "$_query"'),
                onPressed: () => _submitSearch(_query),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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

    final bg = selected
        ? scheme.primary
        : scheme.surfaceContainerHighest.withValues(alpha: 0.5);
    final fg = selected ? scheme.onPrimary : scheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppLayout.durBase,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.sp4,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppLayout.radiusFull),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _MinimalThemeCard extends StatefulWidget {
  const _MinimalThemeCard({
    required this.category,
    required this.onTap,
  });

  final QuranThemeCategory category;
  final VoidCallback onTap;

  @override
  State<_MinimalThemeCard> createState() => _MinimalThemeCardState();
}

class _MinimalThemeCardState extends State<_MinimalThemeCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cat = widget.category;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppLayout.durBase,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          border: Border.all(
            color: _hovered
                ? scheme.primary.withValues(alpha: 0.5)
                : scheme.outlineVariant.withValues(alpha: 0.4),
            width: _hovered ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: _hovered ? 0.08 : 0.02),
              blurRadius: _hovered ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            child: Padding(
              padding: const EdgeInsets.all(AppLayout.sp4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Minimalist Icon container
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                    ),
                    child: Icon(
                      cat.icon,
                      color: scheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppLayout.sp4),

                  // Text info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                cat.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                borderRadius:
                                    BorderRadius.circular(AppLayout.radiusFull),
                              ),
                              child: Text(
                                '${cat.verses.length} ayat',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: scheme.outline.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThematicAppBar extends StatelessWidget {
  const _ThematicAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GlassHeader(
      title: 'Cari Berdasarkan Tema',
      titleStyle: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: scheme.onSurface,
      ),
      leading: GlassPill(
        padding: EdgeInsets.zero,
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Kembali',
          color: scheme.onSurface,
          onPressed: onBack,
        ),
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
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}
