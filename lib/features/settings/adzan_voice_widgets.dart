import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/liquid_glass.dart';

/// A grouped card for choosing the adzan voices: a small header plus one
/// tappable row per category (regular prayers vs fajr), each showing the
/// currently selected voice.
class AdzanVoiceCard extends StatelessWidget {
  const AdzanVoiceCard({
    super.key,
    required this.regularVoiceName,
    required this.fajrVoiceName,
    required this.onRegularTap,
    required this.onFajrTap,
  });

  final String regularVoiceName;
  final String fajrVoiceName;
  final VoidCallback onRegularTap;
  final VoidCallback onFajrTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return GlassTouchButton(
      radius: AppLayout.radiusLg,
      style: glassChromeStyle(context, cornerRadius: AppLayout.radiusLg),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppLayout.sp4,
                AppLayout.sp3,
                AppLayout.sp4,
                AppLayout.sp2,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.campaign_rounded,
                    size: 18,
                    color: scheme.tertiary,
                  ),
                  const SizedBox(width: AppLayout.sp2),
                  Text(
                    l10n.adzanVoiceLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              indent: AppLayout.sp4,
              endIndent: AppLayout.sp4,
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
            AdzanVoiceOption(
              icon: Icons.volume_up_rounded,
              iconBackground: scheme.secondaryContainer,
              iconColor: scheme.onSecondaryContainer,
              title: l10n.adzanVoiceSholatLabel,
              voiceName: regularVoiceName,
              onTap: onRegularTap,
            ),
            Divider(
              height: 1,
              indent: AppLayout.sp4 + 40 + AppLayout.sp3,
              endIndent: AppLayout.sp4,
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
            AdzanVoiceOption(
              icon: Icons.wb_twilight_rounded,
              iconBackground: scheme.tertiaryContainer,
              iconColor: scheme.onTertiaryContainer,
              title: l10n.adzanVoiceFajrLabel,
              voiceName: fajrVoiceName,
              onTap: onFajrTap,
            ),
          ],
        ),
      ),
    );
  }
}

/// A tappable row inside [AdzanVoiceCard]: a tinted category icon, the
/// category title, the current voice name, and a chevron.
class AdzanVoiceOption extends StatelessWidget {
  const AdzanVoiceOption({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.voiceName,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String voiceName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.sp4,
          vertical: AppLayout.sp3,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(AppLayout.radiusMd),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: AppLayout.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    voiceName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppLayout.sp3),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
