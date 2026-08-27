import 'package:flutter/material.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../data/providers.dart';

/// The bar's settings icon → reading options that don't need a dedicated
/// button (translation toggle, jump to ayah, tajwid, bookmark, sujud, murottal).
class ReaderSettingsMenu extends StatelessWidget {
  const ReaderSettingsMenu({
    super.key,
    required this.showTranslation,
    required this.onToggleTranslation,
    required this.onJump,
    required this.tajwidColor,
    required this.onToggleTajwid,
    required this.currentAyahNumber,
    required this.isCurrentBookmarked,
    required this.onToggleBookmark,
    required this.isCurrentSajda,
    required this.isCurrentSajdaDone,
    required this.onToggleSajda,
    required this.murottalState,
    required this.onMurottalTap,
  });

  final bool showTranslation;
  final VoidCallback onToggleTranslation;
  final VoidCallback onJump;
  final bool tajwidColor;
  final VoidCallback onToggleTajwid;
  final int? currentAyahNumber;
  final bool isCurrentBookmarked;
  final VoidCallback onToggleBookmark;
  final bool isCurrentSajda;
  final bool isCurrentSajdaDone;
  final VoidCallback onToggleSajda;
  final MurottalDownloadState murottalState;
  final VoidCallback onMurottalTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    // Murottal status → icon + label for the menu row.
    final (IconData murottalIcon, String murottalLabel, Color murottalColor) =
        switch (murottalState.status) {
      MurottalDownloadStatus.downloading => (
          Icons.close_rounded,
          l10n.murottalCancel,
          scheme.primary,
        ),
      MurottalDownloadStatus.downloaded => (
          Icons.download_done_rounded,
          l10n.murottalDownloaded,
          scheme.tertiaryFixedDim,
        ),
      MurottalDownloadStatus.error => (
          Icons.error_outline_rounded,
          l10n.murottalDownloadFailed,
          scheme.error,
        ),
      MurottalDownloadStatus.notDownloaded => (
          Icons.download_rounded,
          l10n.murottalDownload,
          scheme.onSurfaceVariant,
        ),
    };

    return PopupMenuButton<String>(
      tooltip: l10n.readerSettings,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        foregroundColor: scheme.onSurfaceVariant,
        hoverColor: scheme.surfaceContainerHighest,
      ),
      icon: const Icon(Icons.settings_rounded, size: 24),
      onSelected: (v) {
        if (v == 'translation') onToggleTranslation();
        if (v == 'jump') onJump();
        if (v == 'tajwid') onToggleTajwid();
        if (v == 'bookmark') onToggleBookmark();
        if (v == 'sajda') onToggleSajda();
        if (v == 'murottal') onMurottalTap();
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'translation',
          child: Row(
            children: [
              Icon(
                showTranslation
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppLayout.sp3),
              Text(showTranslation ? l10n.hideTranslation : l10n.showTranslationLabel),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'jump',
          child: Row(
            children: [
              Icon(Icons.unfold_more_rounded,
                  size: 20, color: scheme.onSurfaceVariant),
              const SizedBox(width: AppLayout.sp3),
              Text(l10n.jumpToAyah),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'tajwid',
          child: Row(
            children: [
              Icon(
                Icons.palette_rounded,
                size: 20,
                color: tajwidColor
                    ? scheme.tertiaryFixedDim
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppLayout.sp3),
              Expanded(child: Text(l10n.tajwidColorLabel)),
              if (tajwidColor)
                Icon(Icons.check_rounded, size: 18, color: scheme.tertiary),
            ],
          ),
        ),
        if (currentAyahNumber != null)
          PopupMenuItem(
            value: 'bookmark',
            child: Row(
              children: [
                Icon(
                  isCurrentBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 20,
                  color: isCurrentBookmarked
                      ? scheme.tertiaryFixedDim
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppLayout.sp3),
                Expanded(
                  child: Text(
                    isCurrentBookmarked ? l10n.removeBookmark : l10n.bookmarkAyah,
                  ),
                ),
              ],
            ),
          ),
        if (isCurrentSajda)
          PopupMenuItem(
            value: 'sajda',
            child: Row(
              children: [
                Text(
                  '\u06E9', // ۩ — place-of-sajdah glyph
                  style: TextStyle(
                    fontFamily: AppConstants.fontQuran,
                    fontSize: 18,
                    height: 1.0,
                    color: isCurrentSajdaDone
                        ? scheme.tertiary
                        : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppLayout.sp3),
                Expanded(
                  child: Text(
                    isCurrentSajdaDone ? l10n.sujudUnmark : l10n.sujudMark,
                  ),
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'murottal',
          child: Row(
            children: [
              Icon(murottalIcon, size: 20, color: murottalColor),
              const SizedBox(width: AppLayout.sp3),
              Expanded(child: Text(murottalLabel)),
            ],
          ),
        ),
      ],
    );
  }
}
