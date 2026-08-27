import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../widgets/ayah_number_badge.dart';

/// Jump pill — a floating button at the bottom-left that opens the jump dialog.
class ReaderJumpPill extends StatelessWidget {
  const ReaderJumpPill({
    super.key,
    required this.currentAyahNumber,
    required this.onTap,
  });

  final int? currentAyahNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 3,
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppLayout.radiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppLayout.radiusFull),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.sp4,
            vertical: AppLayout.sp2 + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${S.jumpLabel} ${toArabicIndic(currentAyahNumber ?? 1)}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: AppLayout.sp1),
              Icon(
                Icons.unfold_more_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
