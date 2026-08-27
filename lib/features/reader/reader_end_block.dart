import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppLayout.sp8),
      child: Column(
        children: [
          const OrnamentDivider(),
          const SizedBox(height: AppLayout.sp6),
          Text('${S.endOfSurah} — ${surah.nameLatin}',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: AppLayout.sp2),
          Text(
            S.nextSurah,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppLayout.sp5),
          if (onNext != null)
            FilledButton.tonal(
              onPressed: onNext,
              child: const Text(S.nextSurah),
            ),
          const SizedBox(height: AppLayout.sp3),
          TextButton.icon(
            onPressed: onHome,
            icon: const Icon(Icons.home_rounded, size: 18),
            label: const Text(S.backToHome),
          ),
        ],
      ),
    );
  }
}
