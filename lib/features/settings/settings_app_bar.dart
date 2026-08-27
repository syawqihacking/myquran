import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../widgets/liquid_glass.dart';

/// App bar for the pushed Settings route: a quiet bar with just the back
/// button. The page title lives in the body header (eyebrow + display title
/// + caption), so it is not repeated here.
class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(AppLayout.sp10);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PreferredSize(
      preferredSize: const Size.fromHeight(AppLayout.sp10),
      child: Container(
        height: AppLayout.sp10,
        padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp2),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.9),
          border: Border(
            bottom: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
        ),
        child: Row(
          children: [
            GlassTouchButton(
              radius: AppLayout.radiusFull,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: S.back,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
