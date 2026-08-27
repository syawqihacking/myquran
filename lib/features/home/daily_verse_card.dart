import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/db/quran_database.dart';
import '../../data/providers.dart';
import '../widgets/quran_text_view.dart';

/// The daily-verse card: Amiri Arabic verse (right-aligned), italic
/// translation, and a primary reference — with a share action and a faint
/// rotated mosque watermark (Stitch Beranda §6). Wired to the offline DB via
/// [dailyAyahProvider] (a day-of-year rotation over beloved ayahs).
class DailyVerseCard extends ConsumerWidget {
  const DailyVerseCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final verseAsync = ref.watch(dailyAyahProvider);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative mosque watermark, rotated 12°, ~3-4% opacity.
          Positioned(
            right: -32,
            top: -36,
            child: Transform.rotate(
              angle: 12 * math.pi / 180,
              child: Icon(
                Icons.mosque_rounded,
                size: 150,
                color: scheme.primary.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppLayout.sp5),
            child: verseAsync.when(
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, __) => SizedBox(
                height: 120,
                child: Center(child: Text(S.dailyVerseError)),
              ),
              data: (d) => VerseContent(ayah: d.ayah, surah: d.surah),
            ),
          ),
        ],
      ),
    );
  }
}

class VerseContent extends StatelessWidget {
  const VerseContent({required this.ayah, required this.surah});

  final Ayah ayah;
  final Surah surah;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.auto_stories_rounded, size: 20, color: scheme.primary),
            const SizedBox(width: AppLayout.sp2),
            Text(
              S.dailyVerseLabel.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => _share(context),
              tooltip: S.shareVerse,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.share_outlined,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppLayout.sp4),
        QTextDisplay(
          text: ayah.textUthmani,
          step: 4, // ≈34px — the card's "quran-text" display size
          color: scheme.onSurface,
        ),
        const SizedBox(height: AppLayout.sp3),
        Text(
          '"${ayah.translation}"',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: AppLayout.sp3),
        Text(
          '${surah.nameLatin} : ${ayah.ayahNumber}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// No share_plus dependency yet — the share action copies the verse and
  /// confirms with a SnackBar.
  Future<void> _share(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(
        text:
            '${ayah.textUthmani}\n\n"${ayah.translation}"\n'
            '${surah.nameLatin} : ${ayah.ayahNumber}',
      ),
    );
    if (!context.mounted) return;
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
}
