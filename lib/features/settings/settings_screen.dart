import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/providers.dart';

/// Settings (design §21).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp6,
        vertical: AppLayout.sp8,
      ),
      children: [
        Text(
          S.settingsEyebrow,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: AppLayout.sp2),
        Text(S.settingsTitle, style: theme.textTheme.displaySmall),
        const SizedBox(height: AppLayout.sp6),
        _Section(
          title: S.appearanceSection,
          children: [
            _SettingRow(
              icon: Icons.brightness_6_rounded,
              title: S.themeModeLabel,
              subtitle: S.themeModeSublabel,
              trailing: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(S.themeSystem),
                    icon: Icon(Icons.brightness_auto_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(S.themeLight),
                    icon: Icon(Icons.light_mode_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(S.themeDark),
                    icon: Icon(Icons.dark_mode_rounded, size: 16),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (s) => controller.setThemeMode(s.first),
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
            const _DividerRow(),
            _SettingRow(
              icon: Icons.format_size_rounded,
              title: S.quranFontSizeLabel,
              subtitle: S.quranFontSizeSublabel,
              trailing: TextButton(
                onPressed: controller.resetFontStep,
                child: const Text(S.reset),
              ),
            ),
            Slider(
              value: settings.quranFontStep.toDouble(),
              min: AppConstants.minQuranFontStep.toDouble(),
              max: AppConstants.maxQuranFontStep.toDouble(),
              divisions: AppConstants.maxQuranFontStep - AppConstants.minQuranFontStep,
              label: '${settings.quranFontStep}',
              onChanged: (v) => controller.setFontStep(v.round()),
            ),
            const _DividerRow(),
            _SettingRow(
              icon: Icons.translate_rounded,
              title: S.showTranslationLabel,
              trailing: Switch(
                value: settings.showTranslation,
                onChanged: controller.setShowTranslation,
              ),
            ),
            const _DividerRow(),
            _SettingRow(
              icon: Icons.format_align_right_rounded,
              title: S.alignLabel,
              subtitle: S.alignNote,
              trailing: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text(S.alignRight)),
                  ButtonSegment(value: false, label: Text(S.alignCenter)),
                ],
                selected: {settings.alignArabicRight},
                onSelectionChanged: (s) =>
                    controller.setAlignArabicRight(s.first),
                showSelectedIcon: false,
                style: ButtonStyle(visualDensity: VisualDensity.compact),
              ),
            ),
          ],
        ),
        _Section(
          title: S.readingSection,
          children: [
            _SettingRow(
              icon: Icons.menu_book_rounded,
              title: S.tafsirDefaultLabel,
              trailing: Switch(
                value: settings.tafsirOpenByDefault,
                onChanged: controller.setTafsirOpenByDefault,
              ),
            ),
            const _DividerRow(),
            _SettingRow(
              icon: Icons.history_rounded,
              title: S.restoreLastReadLabel,
              trailing: Switch(
                value: settings.restoreLastRead,
                onChanged: controller.setRestoreLastRead,
              ),
            ),
          ],
        ),
        _Section(
          title: S.dataSection,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppLayout.sp3),
              child: Text(
                S.dataSourceLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const _DividerRow(),
            _SettingRow(
              icon: Icons.storage_rounded,
              title: S.dataVersionLabel,
              trailing: Text(
                '${AppConstants.quranDbSchemaVersion}',
                style: theme.textTheme.labelLarge,
              ),
            ),
            const _DividerRow(),
            const _SettingRow(
              icon: Icons.balance_rounded,
              title: S.licenseLabel,
              trailing: Text('CC BY-SA 4.0'),
            ),
          ],
        ),
        _Section(
          title: S.shortcutsSection,
          children: const [
            _ShortcutRow(label: S.shortcutSearch, keys: ['Ctrl', 'K']),
            _ShortcutRow(label: S.shortcutZoomIn, keys: ['Ctrl', '+']),
            _ShortcutRow(label: S.shortcutZoomOut, keys: ['Ctrl', '−']),
            _ShortcutRow(label: S.shortcutClose, keys: ['Esc']),
          ],
        ),
        _Section(
          title: S.resetDataSection,
          children: [
            _SettingRow(
              icon: Icons.delete_forever_rounded,
              title: S.resetDataLabel,
              subtitle: S.resetDataSublabel,
              destructive: true,
              trailing: TextButton(
                onPressed: () => _confirmReset(context, ref),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                child: const Text(S.resetDataConfirm),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppLayout.sp6),
      ],
    );
  }

  /// Destructive action: asks for confirmation, then wipes all user data
  /// (user.db only — never quran.db) and refreshes the one-shot providers
  /// that do not auto-update via drift table streams.
  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.resetDataConfirmTitle),
        content: const Text(S.resetDataConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text(S.resetDataConfirm),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await ref.read(userDatabaseProvider).resetAll();
    // Stream providers (bookmarks, last-read, sajda log, khatam target,
    // reading stats, recent surahs) re-emit automatically on table changes;
    // only the one-shot futures need an explicit refresh.
    ref.invalidate(sajdaCountProvider);
    ref.invalidate(dailyActivityProvider);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.resetDataDone)),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: AppLayout.sp2),
        Container(
          margin: const EdgeInsets.only(bottom: AppLayout.sp6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  /// When true, the row is rendered in the error color (destructive action).
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent =
        destructive ? theme.colorScheme.error : theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp4,
        vertical: AppLayout.sp3,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: accent),
          const SizedBox(width: AppLayout.sp3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: destructive ? theme.colorScheme.error : null,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppLayout.sp3),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({required this.label, required this.keys});

  final String label;
  final List<String> keys;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp4,
        vertical: AppLayout.sp3,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          for (final k in keys) ...[
            Container(
              margin: const EdgeInsets.only(left: AppLayout.sp1),
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.sp2,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Text(
                k,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DividerRow extends StatelessWidget {
  const _DividerRow();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: AppLayout.sp4 + 20 + AppLayout.sp3,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
