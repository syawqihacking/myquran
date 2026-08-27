import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/dzikir_content.dart';
import '../../data/models/dzikir_pagi_petang_data.dart';
import '../../data/models/spiritual_content.dart';
import '../widgets/glass_pill.dart';
import '../widgets/quran_text_view.dart';
import 'spiritual_reader_screen.dart';

/// Dzikir Pagi & Petang — a screen with a Pagi/Petang toggle (chip row) and a
/// responsive grid of dhikr cards. Each card opens the spiritual reader with
/// that single dhikr (Arabic, transliteration, translation, repeat count).
/// Matches the Doa Harian / Amalan Ibadah visual language.
class DzikirPagiPetangScreen extends StatefulWidget {
  const DzikirPagiPetangScreen({super.key});

  @override
  State<DzikirPagiPetangScreen> createState() => _DzikirPagiPetangScreenState();
}

class _DzikirPagiPetangScreenState extends State<DzikirPagiPetangScreen> {
  DzikirTime _time = DzikirTime.pagi;

  List<DzikirItem> get _filtered => [
    for (final d in dzikirPagiPetangItems)
      if (d.time == _time) d,
  ];

  void _openReader(DzikirItem dzikir) {
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SpiritualReaderScreen(
          title: dzikir.title,
          subtitle: _time == DzikirTime.pagi ? l10n.dzikirPagi : l10n.dzikirPetang,
          items: [
            SpiritualItem(
              id: dzikir.id,
              title: dzikir.title,
              arabic: dzikir.arabic,
              transliteration: dzikir.transliteration,
              translation: dzikir.translation,
              note: dzikir.note,
              repeatCount: dzikir.repeatCount,
            ),
          ],
          icon: _time == DzikirTime.pagi
              ? Icons.wb_sunny_rounded
              : Icons.nights_stay_rounded,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Content fills the screen and scrolls behind the floating glass
            // header pills — exactly like the home header.
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final cols = width < 700 ? 1 : (width < 1100 ? 2 : 3);
                  const gap = AppLayout.sp6;
                  final contentWidth = width - AppLayout.sp6 * 2;
                  final itemWidth = (contentWidth - gap * (cols - 1)) / cols;

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppLayout.sp6,
                      AppLayout.sp10 + AppLayout.sp5,
                      AppLayout.sp6,
                      AppLayout.sp8,
                    ),
                    children: [
                      Text(
                        l10n.dzikirTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppLayout.sp2),
                      Text(
                        l10n.dzikirCaption,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppLayout.sp5),
                      _buildChips(),
                      const SizedBox(height: AppLayout.sp5),
                      if (filtered.isEmpty)
                        const _DzikirEmpty()
                      else
                        Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (final d in filtered)
                              SizedBox(
                                width: itemWidth,
                                child: _DzikirCard(
                                  dzikir: d,
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
            // Floating glass header pills, over the content.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _DzikirAppBar(
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChips() {
    final l10n = AppLocalizations.of(context)!;
    return ScrollConfiguration(
      behavior: _ChipScrollBehavior(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _TimeChip(
              label: l10n.dzikirPagi,
              icon: Icons.wb_sunny_rounded,
              selected: _time == DzikirTime.pagi,
              onTap: () => setState(() => _time = DzikirTime.pagi),
            ),
            const SizedBox(width: AppLayout.sp3),
            _TimeChip(
              label: l10n.dzikirPetang,
              icon: Icons.nights_stay_rounded,
              selected: _time == DzikirTime.petang,
              onTap: () => setState(() => _time = DzikirTime.petang),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// App bar (Stitch §1): back + centered title.
// ---------------------------------------------------------------------------

class _DzikirAppBar extends StatelessWidget {
  const _DzikirAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return GlassHeader(
      title: l10n.dzikirTitle,
      titleStyle: theme.textTheme.titleLarge?.copyWith(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.primary,
      ),
      leading: GlassPill(
        padding: EdgeInsets.zero,
        child: IconButton(
          onPressed: onBack,
          tooltip: l10n.back,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Time toggle chips (Pagi / Petang).
// ---------------------------------------------------------------------------

/// Hides the horizontal scrollbar but keeps mouse-drag scrolling.
class _ChipScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

class _TimeChip extends StatefulWidget {
  const _TimeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_TimeChip> createState() => _TimeChipState();
}

class _TimeChipState extends State<_TimeChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selected = widget.selected;
    final bg = selected
        ? scheme.primary
        : (_hovered
              ? scheme.secondaryContainer
              : scheme.surfaceContainerHighest);
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: fg),
              const SizedBox(width: AppLayout.sp1),
              Text(
                widget.label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dhikr card (Stitch §3): accent bar, title, Arabic, repeat chip.
// ---------------------------------------------------------------------------

class _DzikirCard extends StatefulWidget {
  const _DzikirCard({required this.dzikir, required this.onTap});

  final DzikirItem dzikir;
  final VoidCallback onTap;

  @override
  State<_DzikirCard> createState() => _DzikirCardState();
}

class _DzikirCardState extends State<_DzikirCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dzikir = widget.dzikir;

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
            // 4px vertical accent bar.
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
                      Text(
                        dzikir.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 20,
                          height: 28 / 20,
                          fontWeight: FontWeight.w600,
                          color: _hovered ? scheme.primary : scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppLayout.sp4),
                      QTextDisplay(
                        text: dzikir.arabic,
                        step: 4,
                        alignment: TextAlign.right,
                        color: scheme.onSurface.withValues(alpha: 0.9),
                      ),
                      const SizedBox(height: AppLayout.sp4),
                      if (dzikir.repeatCount > 1) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppLayout.sp2,
                              vertical: AppLayout.sp1,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.secondaryContainer.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppLayout.radiusSm,
                              ),
                            ),
                            child: Text(
                              l10n.readNTimes(dzikir.repeatCount),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                                color: scheme.secondary,
                              ),
                            ),
                          ),
                        ),
                      ],
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

// ---------------------------------------------------------------------------
// Empty state.
// ---------------------------------------------------------------------------

class _DzikirEmpty extends StatelessWidget {
  const _DzikirEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppLayout.sp10),
      child: Column(
        children: [
          Icon(
            Icons.self_improvement_rounded,
            size: 40,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppLayout.sp3),
          Text(l10n.dzikirEmpty, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
