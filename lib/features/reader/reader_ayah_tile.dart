import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../core/quran_scale.dart';
import '../../core/tajwid.dart';
import '../../data/db/quran_database.dart';
import '../widgets/quran_text_view.dart';

/// 4px circular ayah-number badge. The first ayah uses the secondary
/// container (emerald wash); the rest surfaceContainer.
class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number, required this.isFirst});

  final int number;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFirst ? scheme.secondaryContainer : scheme.surfaceContainer,
      ),
      child: Text(
        '$number',
        style: theme.textTheme.labelSmall?.copyWith(
          color: isFirst ? scheme.onSecondaryContainer : scheme.onSurface,
        ),
      ),
    );
  }
}

/// One quick action in the card header: 20px icon, onSurfaceVariant, circular
/// surfaceVariant hover (design §3).
class _AyahActionButton extends StatelessWidget {
  const _AyahActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        foregroundColor: color ?? scheme.onSurfaceVariant,
        hoverColor: scheme.surfaceContainerHighest,
        fixedSize: const Size(36, 36),
        padding: EdgeInsets.zero,
      ),
      icon: Icon(icon, size: 20),
    );
  }
}

/// Tafsir panel displayed inside an ayah tile.
class _TafsirPanel extends StatelessWidget {
  const _TafsirPanel({
    required this.ayahNumber,
    required this.tafsir,
    required this.loading,
    required this.onClose,
  });

  final int ayahNumber;
  final Tafsir? tafsir;
  final bool loading;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppLayout.sp4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$ayahNumber — ${S.tafsirHeader}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                tooltip: S.cancel,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ],
          ),
          const SizedBox(height: AppLayout.sp2),
          if (loading)
            const LinearProgressIndicator(minHeight: 2)
          else if (tafsir == null)
            Text(
              'Tafsir tidak tersedia untuk ayat ini.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Text(
              (tafsir!.textLong.isNotEmpty ? tafsir!.textLong : tafsir!.textShort),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
            ),
        ],
      ),
    );
  }
}

/// Ayah card (Stitch §3).
class ReaderAyahTile extends StatefulWidget {
  const ReaderAyahTile({
    super.key,
    required this.ayah,
    required this.surahName,
    required this.quranSize,
    required this.markerSize,
    required this.translationSize,
    required this.showTranslation,
    required this.alignRight,
    required this.tajwidRanges,
    required this.isCurrent,
    required this.isBookmarked,
    required this.isSajdaDone,
    required this.tafsirOpen,
    required this.tafsir,
    required this.tafsirLoading,
    required this.onOpenTafsir,
    required this.onCloseTafsir,
    required this.onToggleBookmark,
    required this.onToggleSajda,
    required this.isPlaying,
    required this.onPlay,
    required this.onPause,
    this.onMounted,
    this.onUnmounted,
  });

  final Ayah ayah;
  final String surahName;
  final double quranSize;
  final double markerSize;
  final double translationSize;
  final bool showTranslation;
  final bool alignRight;
  final List<TajwidRange>? tajwidRanges;
  final bool isCurrent;
  final bool isBookmarked;
  final bool isSajdaDone;
  final bool tafsirOpen;
  final Tafsir? tafsir;
  final bool tafsirLoading;
  final VoidCallback onOpenTafsir;
  final VoidCallback onCloseTafsir;
  final VoidCallback onToggleBookmark;
  final VoidCallback onToggleSajda;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onPause;

  /// Lifecycle hooks so the parent can track which tiles are mounted
  /// (virtualization: only these are scanned for current-ayah tracking).
  final ValueChanged<int>? onMounted;
  final ValueChanged<int>? onUnmounted;

  @override
  State<ReaderAyahTile> createState() => _ReaderAyahTileState();
}

class _ReaderAyahTileState extends State<ReaderAyahTile> {
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    widget.onMounted?.call(widget.ayah.ayahNumber);
  }

  @override
  void dispose() {
    widget.onUnmounted?.call(widget.ayah.ayahNumber);
    super.dispose();
  }

  /// No share_plus dependency yet — the share action copies the ayah and
  /// confirms with a SnackBar (same pattern as the home daily verse).
  Future<void> _share() async {
    await Clipboard.setData(
      ClipboardData(
        text: '${widget.ayah.textUthmani}\n\n"${widget.ayah.translation}"\n'
            '${widget.surahName} : ${widget.ayah.ayahNumber}',
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(S.copyAyahDone),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1800),
        ),
      );
  }

  /// Audio is behind the phase-2 seam: play wiring lives in the parent
  /// (`_onTilePlay`), which keeps the honest "Segera hadir" SnackBar while
  /// NoopAudioService is wired in. This button also acts as pause for the
  /// ayah that is currently playing.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ayah = widget.ayah;
    final tGap = translationGap(widget.quranSize);
    final align = widget.alignRight ? TextAlign.right : TextAlign.center;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppLayout.durBase,
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(AppLayout.sp6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          border: Border.all(
            color: widget.isCurrent
                ? scheme.primary.withValues(alpha: 0.45)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: _hovered ? 0.09 : 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row: number badge left, actions right.
            Row(
              children: [
                _NumberBadge(
                  number: ayah.ayahNumber,
                  isFirst: ayah.ayahNumber == 1,
                ),
                const Spacer(),
                _AyahActionButton(
                  icon: widget.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  tooltip: widget.isPlaying ? S.audioPause : S.playAyah,
                  color: widget.isPlaying
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                  onPressed: widget.isPlaying ? widget.onPause : widget.onPlay,
                ),
                _AyahActionButton(
                  icon: widget.isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  tooltip:
                      widget.isBookmarked ? S.removeBookmark : S.bookmarkAyah,
                  color: widget.isBookmarked
                      ? scheme.tertiaryFixedDim
                      : scheme.onSurfaceVariant,
                  onPressed: widget.onToggleBookmark,
                ),
                _AyahActionButton(
                  icon: Icons.share_rounded,
                  tooltip: S.shareAyah,
                  onPressed: _share,
                ),
                _AyahActionButton(
                  icon: Icons.menu_book_rounded,
                  tooltip: S.tafsirAction,
                  onPressed: widget.onOpenTafsir,
                ),
              ],
            ),
            const SizedBox(height: AppLayout.sp4),
            // Arabic text (RTL, end-of-ayah sajda glyph inline).
            Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: QTextDisplay(
                    text: ayah.textUthmani,
                    step: _stepFor(widget.quranSize),
                    alignment: align,
                    color: scheme.onSurface,
                    tajwidRanges: widget.tajwidRanges,
                  ),
                ),
                if (ayah.sajda == 1) ...[
                  const SizedBox(width: 6),
                  Tooltip(
                    message: widget.isSajdaDone
                        ? S.sujudUnmark
                        : S.sujudMark,
                    child: InkWell(
                      onTap: widget.onToggleSajda,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Text(
                          '\u06E9', // ۩ — place-of-sajdah glyph
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: AppConstants.fontQuran,
                            fontSize: widget.markerSize * 0.6,
                            height: 1.0,
                            color: widget.isSajdaDone
                                ? scheme.tertiary
                                : scheme.onSurfaceVariant
                                    .withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (widget.showTranslation) ...[
              SizedBox(height: tGap),
              Text(
                ayah.translation,
                style: TextStyle(
                  fontFamily: AppConstants.fontUi,
                  fontFamilyFallback: const [AppConstants.fontArabic],
                  fontSize: widget.translationSize,
                  height: 1.7,
                  color: scheme.onSurfaceVariant,
                ),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
              ),
            ],
            if (widget.tafsirOpen) ...[
              const SizedBox(height: AppLayout.sp4),
              _TafsirPanel(
                ayahNumber: ayah.ayahNumber,
                tafsir: widget.tafsir,
                loading: widget.tafsirLoading,
                onClose: widget.onCloseTafsir,
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _stepFor(double size) {
    // Recompute step from the current size for accurate line height.
    return kQuranFontSizes.indexWhere((s) => s == size) + 1;
  }
}
