import 'package:flutter/material.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/db/quran_database.dart';
import '../../data/providers.dart';
import 'reader_settings_menu.dart';

/// Reader top bar (Stitch §1: back / surah title+meta / reading controls).
class ReaderTopBar extends StatelessWidget {
  const ReaderTopBar({
    super.key,
    required this.surah,
    required this.ayahCount,
    required this.fontStep,
    required this.showTranslation,
    required this.tajwidColor,
    required this.currentAyahNumber,
    required this.isCurrentBookmarked,
    required this.isCurrentSajda,
    required this.isCurrentSajdaDone,
    required this.onBack,
    required this.onFontSmaller,
    required this.onFontLarger,
    required this.onToggleZen,
    required this.onToggleBookmark,
    required this.onToggleSajda,
    required this.onToggleTranslation,
    required this.onToggleTajwid,
    required this.onJump,
    required this.murottalState,
    required this.onMurottalTap,
  });

  final Surah? surah;
  final int? ayahCount;
  final int fontStep;
  final bool showTranslation;
  final bool tajwidColor;
  final int? currentAyahNumber;
  final bool isCurrentBookmarked;
  final bool isCurrentSajda;
  final bool isCurrentSajdaDone;
  final VoidCallback onBack;
  final VoidCallback onFontSmaller;
  final VoidCallback onFontLarger;
  final VoidCallback onToggleZen;
  final VoidCallback onToggleBookmark;
  final VoidCallback onToggleSajda;
  final VoidCallback onToggleTranslation;
  final VoidCallback onToggleTajwid;
  final VoidCallback onJump;
  final MurottalDownloadState murottalState;
  final VoidCallback onMurottalTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      height: AppLayout.sp10,
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp2),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          BarIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: S.back,
            onPressed: onBack,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  surah?.nameLatin ?? '…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    height: 28 / 20,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
                if (ayahCount != null)
                  Text(
                    S.surahMeta(surah?.id ?? 0, ayahCount!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          BarIconButton(
            icon: Icons.text_decrease_rounded,
            tooltip: S.fontSmaller,
            onPressed: fontStep > AppConstants.minQuranFontStep
                ? onFontSmaller
                : null,
          ),
          BarIconButton(
            icon: Icons.text_increase_rounded,
            tooltip: S.fontLarger,
            onPressed: fontStep < AppConstants.maxQuranFontStep
                ? onFontLarger
                : null,
          ),
          const SizedBox(width: AppLayout.sp1),
          BarIconButton(
            icon: Icons.fullscreen_rounded,
            tooltip: S.zenEnter,
            onPressed: onToggleZen,
          ),
          const SizedBox(width: AppLayout.sp1),
          ReaderSettingsMenu(
            showTranslation: showTranslation,
            onToggleTranslation: onToggleTranslation,
            onJump: onJump,
            tajwidColor: tajwidColor,
            onToggleTajwid: onToggleTajwid,
            currentAyahNumber: currentAyahNumber,
            isCurrentBookmarked: isCurrentBookmarked,
            onToggleBookmark: onToggleBookmark,
            isCurrentSajda: isCurrentSajda,
            isCurrentSajdaDone: isCurrentSajdaDone,
            onToggleSajda: onToggleSajda,
            murottalState: murottalState,
            onMurottalTap: onMurottalTap,
          ),
          const SizedBox(width: AppLayout.sp2),
        ],
      ),
    );
  }
}

/// Circular bar icon button (design: 24px icon, onSurfaceVariant, circular
/// surfaceVariant hover).
class BarIconButton extends StatelessWidget {
  const BarIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        foregroundColor: scheme.onSurfaceVariant,
        disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
        hoverColor: scheme.surfaceContainerHighest,
        minimumSize: const Size(40, 40),
      ),
      icon: Icon(icon, size: 24),
    );
  }
}
