import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/tahlil_doa_data.dart';
import '../hijri/hijri_calendar_screen.dart';
import '../mosque/mosque_screen.dart';
import '../personality/personality_screen.dart';
import '../spiritual/amalan_ibadah_screen.dart';
import '../spiritual/asmaul_husna_screen.dart';
import '../spiritual/doa_harian_screen.dart';
import '../spiritual/ratibul_haddad_screen.dart';
import '../spiritual/spiritual_reader_screen.dart';
import '../spiritual/tasbih_digital_screen.dart';
import '../spiritual/zakat_calculator_screen.dart';
import '../thematic/thematic_verse_screen.dart';

/// Four equal quick-action tiles (Kiblat, Doa Harian, Zakat, Masjid Terdekat).
/// "Kiblat" opens the prayer screen; "Doa Harian" opens the spiritual view;
/// the rest are not built yet and show a "Segera hadir" SnackBar rather than
/// a placeholder screen.
class QuickActionsBento extends StatelessWidget {
  const QuickActionsBento({required this.onOpenPrayer});

  final VoidCallback onOpenPrayer;

  void _showMoreFeatures(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppLayout.radiusLg),
        ),
      ),
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        final theme = Theme.of(ctx);
        final scheme = theme.colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppLayout.sp4,
              AppLayout.sp3,
              AppLayout.sp4,
              AppLayout.sp6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp2),
                  child: Row(
                    children: [
                      Text(
                        'Fitur Lainnya',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppLayout.sp3),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppLayout.sp3,
                  crossAxisSpacing: AppLayout.sp2,
                  childAspectRatio: 0.68,
                  children: [
                    QuickActionTile(
                      icon: Icons.category_rounded,
                      label: 'Ayat Tematik',
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ThematicVerseScreen(),
                          ),
                        );
                      },
                    ),
                    QuickActionTile(
                      icon: Icons.monetization_on_rounded,
                      label: l10n.qaZakat,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ZakatCalculatorScreen(),
                          ),
                        );
                      },
                    ),
                    QuickActionTile(
                      icon: Icons.mosque_rounded,
                      label: l10n.qaMasjidTerdekat,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const MosqueScreen(),
                          ),
                        );
                      },
                    ),
                    QuickActionTile(
                      icon: Icons.psychology_rounded,
                      label: 'Kepribadian',
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const PersonalityScreen(),
                          ),
                        );
                      },
                    ),
                    QuickActionTile(
                      icon: Icons.calendar_month_rounded,
                      label: l10n.qaKalenderHijriah,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const HijriCalendarScreen(),
                          ),
                        );
                      },
                    ),
                    QuickActionTile(
                      icon: Icons.auto_stories_rounded,
                      label: l10n.tahlilTitle,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => SpiritualReaderScreen(
                              title: l10n.tahlilTitle,
                              subtitle: l10n.tahlilCaption,
                              items: tahlilDoaItems,
                              icon: Icons.auto_stories_rounded,
                            ),
                          ),
                        );
                      },
                    ),
                    QuickActionTile(
                      icon: Icons.brightness_5_rounded,
                      label: l10n.ratibTitle,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const RatibulHaddadScreen(),
                          ),
                        );
                      },
                    ),
                    QuickActionTile(
                      icon: Icons.checklist_rounded,
                      label: l10n.amalanIbadahTitle,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AmalanIbadahScreen(),
                          ),
                        );
                      },
                    ),
                    QuickActionTile(
                      icon: Icons.stars_rounded,
                      label: l10n.asmaulHusnaTitle,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AsmaulHusnaScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: QuickActionTile(
              icon: Icons.explore_rounded,
              label: l10n.qaKiblat,
              onTap: onOpenPrayer,
            ),
          ),
          const SizedBox(width: AppLayout.sp2),
          Expanded(
            child: QuickActionTile(
              icon: Icons.volunteer_activism_rounded,
              label: l10n.qaDoaHarian,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DoaHarianScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppLayout.sp2),
          Expanded(
            child: QuickActionTile(
              icon: Icons.fingerprint_rounded,
              label: 'Tasbih Digital',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const TasbihDigitalScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppLayout.sp2),
          Expanded(
            child: QuickActionTile(
              icon: Icons.grid_view_rounded,
              label: 'Lainnya',
              onTap: () => _showMoreFeatures(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// One bento tile: a sage 48px circle with a filled icon and a label below,
/// on a `surfaceContainerLowest` card with a soft shadow. The circle gently
/// scales up on hover (desktop delight).
class QuickActionTile extends StatefulWidget {
  const QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<QuickActionTile> createState() => QuickActionTileState();
}

class QuickActionTileState extends State<QuickActionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppLayout.durBase,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _hovered
              ? scheme.surfaceContainerLow
              : scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
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
              padding: const EdgeInsets.symmetric(
                vertical: AppLayout.sp3,
                horizontal: AppLayout.sp1,
              ),
              child: Column(
                children: [
                  AnimatedScale(
                    duration: AppLayout.durBase,
                    scale: _hovered ? 1.06 : 1.0,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: scheme.onSecondaryContainer,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppLayout.sp2),
                  Text(
                    widget.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
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
