import 'package:flutter/material.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../data/db/quran_database.dart';
import '../widgets/quran_text_view.dart';

/// The card's inner row: number badge, name + meta column, Arabic name.
/// Shared by the surah list and the Favorit tab (which swaps the meta
/// trailing text for a bookmark count).
class SurahRowContent extends StatelessWidget {
  const SurahRowContent({super.key, required this.surah, required this.metaTrailing});

  final Surah surah;
  final String metaTrailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isFirst = surah.id == 1;
    final isMakki = surah.revelationType == 0;
    final isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

    return Row(
      children: [
        NumberBadge(number: surah.id, isFirst: isFirst),
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
              MetaRow(
                translation: surah.nameIndonesian,
                trailing: metaTrailing,
                meta: isMakki ? l10n.makkiyah : l10n.madaniyah,
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
class NumberBadge extends StatelessWidget {
  const NumberBadge({super.key, required this.number, required this.isFirst});

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
              child: CustomPaint(painter: DotGridPainter(color: fg)),
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

class DotGridPainter extends CustomPainter {
  const DotGridPainter({required this.color});

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
  bool shouldRepaint(DotGridPainter oldDelegate) => oldDelegate.color != color;
}

/// Uppercase meta line: translation • X Ayat • Makkiyah/Madaniyah icon.
class MetaRow extends StatelessWidget {
  const MetaRow({
    super.key,
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
        const MetaDot(),
        Text(trailing.toUpperCase(), style: style),
        const MetaDot(),
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

class MetaDot extends StatelessWidget {
  const MetaDot({super.key});

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
