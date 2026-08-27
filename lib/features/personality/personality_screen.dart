import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/personality_data.dart';
import '../../data/providers.dart';
import '../../data/repositories/personality_repository.dart';
import '../browse/browse_screen.dart' show openSurah;
import '../widgets/glass_pill.dart';
import '../widgets/liquid_glass.dart';

/// Analisis Kepribadian (Stitch "Personality Analysis", Sacred Path).
///
/// Every value is computed from real `reading_log` data via
/// [personalityProvider] — no fabricated numbers. When the user has no reading
/// data the provider emits null and an honest empty state (with a CTA into the
/// reader) is shown instead.
class PersonalityScreen extends ConsumerWidget {
  const PersonalityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final analysis = ref.watch(personalityProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Content fills the screen and scrolls behind the floating glass
            // header pills — exactly like the home header.
            Positioned.fill(
              child: analysis.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppLayout.sp6),
                    child: Text(
                      l10n.personalityError,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
                data: (a) => a == null ? const _EmptyState() : _AnalysisView(a),
              ),
            ),
            // Floating glass header pills, over the content.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _PersonalityAppBar(
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// App bar.
// ---------------------------------------------------------------------------

class _PersonalityAppBar extends StatelessWidget {
  const _PersonalityAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return GlassHeader(
      title: l10n.personalityTitle,
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
// Analysis view (data present).
// ---------------------------------------------------------------------------

class _AnalysisView extends StatelessWidget {
  const _AnalysisView(this.analysis);

  final PersonalityAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.sp6,
        AppLayout.sp10 + AppLayout.sp5,
        AppLayout.sp6,
        AppLayout.sp6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header.
          Text(
            l10n.personalityHeaderTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 24,
              height: 32 / 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppLayout.sp2),
          Text(
            l10n.personalitySubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppLayout.sp6),
          _CharacterCard(archetype: analysis.archetype),
          const SizedBox(height: AppLayout.sp4),
          // Bento grid: DNA spans full width, the two insight cards sit side
          // by side on wide screens, Langkah Selanjutnya spans full width.
          LayoutBuilder(
            builder: (context, constraints) {
              final twoCol = constraints.maxWidth >= 520;
              final half = (constraints.maxWidth - AppLayout.sp3) / 2;
              return Wrap(
                spacing: AppLayout.sp3,
                runSpacing: AppLayout.sp3,
                children: [
                  SizedBox(
                    width: constraints.maxWidth,
                    child: _DnaCard(shares: analysis.dnaShares),
                  ),
                  SizedBox(
                    width: twoCol ? half : constraints.maxWidth,
                    child: _SlotCard(slot: analysis.activeSlot),
                  ),
                  SizedBox(
                    width: twoCol ? half : constraints.maxWidth,
                    child: _FavoriteCard(surahName: analysis.favoriteSurahName),
                  ),
                  SizedBox(
                    width: constraints.maxWidth,
                    child: _NextStepCard(
                      reason: analysis.recommendationReason,
                      surahId: analysis.recommendation.surahId,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Character card: primary background with a faint radial-dot pattern, the
/// 64px avatar circle, archetype name and grounded description.
class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.archetype});

  final PersonalityArchetype archetype;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppLayout.sp6),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _DotPatternPainter(scheme.onPrimary)),
          ),
          Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: scheme.onPrimary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  size: 32,
                  color: scheme.tertiaryFixedDim,
                ),
              ),
              const SizedBox(height: AppLayout.sp4),
              Text(
                archetype.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.tertiaryFixedDim,
                ),
              ),
              const SizedBox(height: AppLayout.sp2),
              Text(
                archetype.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 1px dots on a 16px grid at 5% opacity — the design's `islamic-pattern`.
class _DotPatternPainter extends CustomPainter {
  const _DotPatternPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.05);
    const step = 16.0;
    for (var x = step / 2; x < size.width; x += step) {
      for (var y = step / 2; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// DNA Bacaan: fingerprint header + three theme progress bars.
class _DnaCard extends StatelessWidget {
  const _DnaCard({required this.shares});

  final List<ThemeShare> shares;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppLayout.sp6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fingerprint, size: 20, color: scheme.primary),
              const SizedBox(width: AppLayout.sp2),
              Text(l10n.personalityDnaTitle, style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppLayout.sp4),
          for (var i = 0; i < shares.length; i++) ...[
            _DnaBar(share: shares[i]),
            if (i != shares.length - 1) const SizedBox(height: AppLayout.sp3),
          ],
        ],
      ),
    );
  }
}

class _DnaBar extends StatelessWidget {
  const _DnaBar({required this.share});

  final ThemeShare share;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = share.theme.color(scheme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              share.theme.label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            Text(
              '${share.percent}%',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppLayout.sp1),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppLayout.radiusFull),
          child: LinearProgressIndicator(
            value: share.percent / 100,
            minHeight: 6,
            backgroundColor: scheme.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

/// Waktu Aktif: dominant reading slot.
class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.slot});

  final ReadingTimeSlot slot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppLayout.sp4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.schedule_rounded,
              size: 18,
              color: scheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: AppLayout.sp2),
          Text(
            l10n.personalityActiveSlotLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            slot.label,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Surah Favorit: surah with the most distinct ayahs read.
class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.surahName});

  final String surahName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppLayout.sp4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: scheme.tertiaryFixed,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite,
              size: 18,
              color: scheme.onTertiaryFixedVariant,
            ),
          ),
          const SizedBox(height: AppLayout.sp2),
          Text(
            l10n.personalityFavoriteLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            surahName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Langkah Selanjutnya: recommendation from the weakest theme with a working
/// "Mulai Membaca" button into the reader at the recommended surah.
class _NextStepCard extends StatelessWidget {
  const _NextStepCard({required this.reason, required this.surahId});

  final String reason;
  final int surahId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppLayout.sp6),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        border: Border.all(color: scheme.secondaryContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 20, color: scheme.secondary),
              const SizedBox(width: AppLayout.sp2),
              Text(l10n.personalityNextTitle, style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppLayout.sp3),
          Text(
            reason,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppLayout.sp4),
          LiquidGlassButton.filled(
            onPressed: () => openSurah(context, surahId),
            label: l10n.personalityNextButton,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state (no reading data yet).
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.sp6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology_rounded,
              size: 48,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppLayout.sp3),
            Text(l10n.personalityEmptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppLayout.sp1),
            Text(
              l10n.personalityEmptyMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppLayout.sp4),
            LiquidGlassButton.tonal(
              onPressed: () => openSurah(context, 1),
              label: l10n.personalityEmptyCta,
            ),
          ],
        ),
      ),
    );
  }
}
