import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../data/db/quran_database.dart';
import '../widgets/ornament.dart';

/// End block shown at the bottom of each surah.
class ReaderEndBlock extends StatelessWidget {
  const ReaderEndBlock({
    super.key,
    required this.surah,
    required this.hasNext,
    required this.onNext,
    required this.onHome,
  });

  final Surah surah;
  final bool hasNext;
  final VoidCallback? onNext;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppLayout.sp8),
      child: Column(
        children: [
          const OrnamentDivider(),
          const SizedBox(height: AppLayout.sp6),
          Text('${l10n.endOfSurah} — ${surah.nameLatin}',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: AppLayout.sp2),
          Text(
            l10n.nextSurah,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppLayout.sp5),
          if (onNext != null)
            FilledButton.tonal(
              onPressed: onNext,
              child: Text(l10n.nextSurah),
            ),
          const SizedBox(height: AppLayout.sp3),
          TextButton.icon(
            onPressed: onHome,
            icon: const Icon(Icons.home_rounded, size: 18),
            label: Text(l10n.backToHome),
          ),
        ],
      ),
    );
  }
}
