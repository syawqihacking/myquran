import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/models/asmaul_husna_data.dart';
import '../widgets/quran_text_view.dart';

/// Asmaul Husna — 99 nama Allah beserta artinya.
///
/// Grid responsif (2 kolom di layar kecil, lebih banyak di layar lebar) dengan
/// kartu per nama: teks Arab besar, transliterasi, dan nomor kecil (01–99).
/// Ketuk kartu membuka detail dalam modal bottom sheet — Arab besar,
/// transliterasi, arti, dan catatan (hanya bila tersedia). Pencarian nama atau
/// arti tersedia untuk memudahkan menelusuri 99 nama.
class AsmaulHusnaScreen extends StatefulWidget {
  const AsmaulHusnaScreen({super.key});

  @override
  State<AsmaulHusnaScreen> createState() => _AsmaulHusnaScreenState();
}

class _AsmaulHusnaScreenState extends State<AsmaulHusnaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<AsmaulHusna> get _filtered {
    final q = _query.trim().toLowerCase();
    return [
      for (final n in asmaulHusnaItems)
        if (q.isEmpty ||
            n.transliteration.toLowerCase().contains(q) ||
            n.translation.toLowerCase().contains(q))
          n,
    ];
  }

  void _openDetail(AsmaulHusna name) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppLayout.radiusLg),
        ),
      ),
      builder: (_) => _AsmaulHusnaDetail(name: name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _AsmaulHusnaAppBar(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final cols = width < 700 ? 2 : (width < 1100 ? 3 : 4);
                  const gap = AppLayout.sp4;
                  final contentWidth = width - AppLayout.sp6 * 2;
                  final itemWidth = (contentWidth - gap * (cols - 1)) / cols;

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppLayout.sp6,
                      AppLayout.sp4,
                      AppLayout.sp6,
                      AppLayout.sp8,
                    ),
                    children: [
                      Text(
                        S.asmaulHusnaTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppLayout.sp2),
                      Text(
                        S.asmaulHusnaCaption,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppLayout.sp5),
                      _buildSearch(scheme),
                      const SizedBox(height: AppLayout.sp5),
                      if (filtered.isEmpty)
                        const _AsmaulHusnaEmpty()
                      else
                        Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (final n in filtered)
                              SizedBox(
                                width: itemWidth,
                                child: _AsmaulHusnaCard(
                                  name: n,
                                  onTap: () => _openDetail(n),
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
          hintText: S.asmaulHusnaSearchHint,
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
}

// ---------------------------------------------------------------------------
// App bar: back + centered title (Stitch §1 pattern).
// ---------------------------------------------------------------------------

class _AsmaulHusnaAppBar extends StatelessWidget {
  const _AsmaulHusnaAppBar({required this.onBack});

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
              S.asmaulHusnaTitle,
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
// Grid card: number badge, Arabic (large), transliteration.
// ---------------------------------------------------------------------------

class _AsmaulHusnaCard extends StatefulWidget {
  const _AsmaulHusnaCard({required this.name, required this.onTap});

  final AsmaulHusna name;
  final VoidCallback onTap;

  @override
  State<_AsmaulHusnaCard> createState() => _AsmaulHusnaCardState();
}

class _AsmaulHusnaCardState extends State<_AsmaulHusnaCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final name = widget.name;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppLayout.durBase,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          border: Border.all(
            color: _hovered
                ? scheme.primary.withValues(alpha: 0.4)
                : scheme.surfaceContainerHigh,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: _hovered ? 0.08 : 0.04),
              blurRadius: _hovered ? 24 : 16,
              offset: Offset(0, _hovered ? 8 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppLayout.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppLayout.sp4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _IdBadge(id: name.id),
                  ),
                  const SizedBox(height: AppLayout.sp3),
                  QTextDisplay(
                    text: name.arabic,
                    step: 4,
                    alignment: TextAlign.center,
                    color: scheme.onSurface,
                  ),
                  const SizedBox(height: AppLayout.sp2),
                  Text(
                    name.transliteration,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _hovered
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
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

// ---------------------------------------------------------------------------
// Number badge (01–99).
// ---------------------------------------------------------------------------

class _IdBadge extends StatelessWidget {
  const _IdBadge({required this.id});

  final int id;

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
        color: scheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppLayout.radiusSm),
      ),
      child: Text(
        id.toString().padLeft(2, '0'),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: scheme.secondary,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail modal bottom sheet: Arabic besar, transliterasi, arti, catatan.
// ---------------------------------------------------------------------------

class _AsmaulHusnaDetail extends StatelessWidget {
  const _AsmaulHusnaDetail({required this.name});

  final AsmaulHusna name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final maxHeight = MediaQuery.of(context).size.height * 0.8;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppLayout.sp6,
            AppLayout.sp3,
            AppLayout.sp6,
            AppLayout.sp6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle.
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                  ),
                ),
              ),
              const SizedBox(height: AppLayout.sp4),
              Row(
                children: [
                  _IdBadge(id: name.id),
                  const SizedBox(width: AppLayout.sp3),
                  Expanded(
                    child: Text(
                      S.asmaulHusnaTitle,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppLayout.sp5),
              // Arabic, large and centered.
              QTextDisplay(
                text: name.arabic,
                step: 6,
                alignment: TextAlign.center,
                color: scheme.primary,
              ),
              const SizedBox(height: AppLayout.sp3),
              Text(
                name.transliteration,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: AppLayout.sp6),
              _DetailSection(
                label: S.asmaulHusnaArti,
                child: Text(
                  name.translation,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 17,
                    height: 26 / 17,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              // Catatan, hanya bila tersedia.
              if (name.note.isNotEmpty) ...[
                const SizedBox(height: AppLayout.sp5),
                _DetailSection(
                  label: S.asmaulHusnaCatatan,
                  child: Text(
                    name.note,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      height: 23 / 15,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppLayout.sp6),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(S.asmaulHusnaClose),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppLayout.sp4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: scheme.tertiary,
            ),
          ),
          const SizedBox(height: AppLayout.sp2),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state (pencarian tanpa hasil).
// ---------------------------------------------------------------------------

class _AsmaulHusnaEmpty extends StatelessWidget {
  const _AsmaulHusnaEmpty();

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
          Text(S.asmaulHusnaEmpty, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppLayout.sp1),
          Text(
            S.asmaulHusnaEmptyHint,
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