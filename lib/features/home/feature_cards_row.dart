import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../learning/learning_screen.dart';
import '../spiritual/doa_setelah_sholat_screen.dart';

/// Two side-by-side feature cards: Pusat Belajar (left) and Doa Setelah
/// Sholat (right). Both use the app's primary/theme-consistent green palette.
class FeatureCardsRow extends StatelessWidget {
  const FeatureCardsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: LearningTile()),
        SizedBox(width: AppLayout.sp3),
        Expanded(child: DoaSetelahSholatTile()),
      ],
    );
  }
}

/// Compact vertical tile for Pusat Belajar.
class LearningTile extends StatefulWidget {
  const LearningTile();

  @override
  State<LearningTile> createState() => LearningTileState();
}

class LearningTileState extends State<LearningTile> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.975 : (_hovered ? 1.015 : 1.0),
          duration: AppLayout.durQuick,
          curve: Curves.easeOutCubic,
          child: Material(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppLayout.radiusLg),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const LearningScreen()),
              ),
              child: AnimatedContainer(
                duration: AppLayout.durBase,
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(AppLayout.sp4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppLayout.radiusLg),
                  border: Border.all(
                    color: _hovered
                        ? scheme.primary.withValues(alpha: 0.5)
                        : scheme.outlineVariant,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        size: 24,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppLayout.sp3),
                    Text(
                      S.learningHomeEntryTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      S.learningHomeEntrySubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
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

/// Compact vertical tile for Doa Setelah Sholat.
class DoaSetelahSholatTile extends StatefulWidget {
  const DoaSetelahSholatTile();

  @override
  State<DoaSetelahSholatTile> createState() => DoaSetelahSholatTileState();
}

class DoaSetelahSholatTileState extends State<DoaSetelahSholatTile> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.975 : (_hovered ? 1.015 : 1.0),
          duration: AppLayout.durQuick,
          curve: Curves.easeOutCubic,
          child: Material(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppLayout.radiusLg),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DoaSetelahSholatScreen(),
                ),
              ),
              child: AnimatedContainer(
                duration: AppLayout.durBase,
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(AppLayout.sp4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppLayout.radiusLg),
                  border: Border.all(
                    color: _hovered
                        ? scheme.primary.withValues(alpha: 0.5)
                        : scheme.outlineVariant,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                      ),
                      child: Icon(
                        Icons.back_hand_rounded,
                        size: 24,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppLayout.sp3),
                    Text(
                      S.doaSetelahSholatHomeTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      S.doaSetelahSholatHomeSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
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
