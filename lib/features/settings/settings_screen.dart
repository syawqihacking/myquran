import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/db/user_database.dart';
import '../../data/models/adzan_voice.dart';
import '../../data/providers.dart';
import '../widgets/liquid_glass.dart';

/// Settings (design §21).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    final isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

    final isDark = theme.brightness == Brightness.dark;
    final activeGreen = isDark ? const Color(0xFF67E8B5) : const Color(0xFF064E3B);
    final inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _SettingsAppBar(),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? AppLayout.sp4 : AppLayout.sp6,
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
          const SizedBox(height: AppLayout.sp2),
          Text(
            S.settingsCaption,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppLayout.sp6),
          _Section(
            title: S.appearanceSection,
            children: [
              _SettingRow(
                icon: Icons.brightness_6_rounded,
                title: S.themeModeLabel,
                subtitle: S.themeModeSublabel,
                bottom: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: GlassSegmentedControl(
                    useOwnLayer: true,
                    selectedIndex: switch (settings.themeMode) {
                      ThemeMode.system => 0,
                      ThemeMode.light => 1,
                      ThemeMode.dark => 2,
                    },
                    onSegmentSelected: (index) {
                      final mode = switch (index) {
                        0 => ThemeMode.system,
                        1 => ThemeMode.light,
                        2 => ThemeMode.dark,
                        _ => ThemeMode.system,
                      };
                      controller.setThemeMode(mode);
                    },
                    selectedIconColor: activeGreen,
                    selectedTextStyle: TextStyle(
                      color: activeGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    unselectedTextStyle: TextStyle(
                      color: inactiveColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    segments: const [
                      GlassSegment(
                        label: S.themeSystem,
                        icon: Icon(Icons.brightness_auto_rounded, size: 18),
                      ),
                      GlassSegment(
                        label: S.themeLight,
                        icon: Icon(Icons.light_mode_rounded, size: 18),
                      ),
                      GlassSegment(
                        label: S.themeDark,
                        icon: Icon(Icons.dark_mode_rounded, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const _DividerRow(),
              _SettingRow(
                icon: Icons.format_size_rounded,
                title: S.quranFontSizeLabel,
                subtitle: S.quranFontSizeSublabel,
                trailing: GlassChip(
                  useOwnLayer: true,
                  label: S.reset,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: activeGreen,
                    fontSize: 12,
                  ),
                  onTap: controller.resetFontStep,
                ),
                bottom: Slider(
                  value: settings.quranFontStep.toDouble(),
                  min: AppConstants.minQuranFontStep.toDouble(),
                  max: AppConstants.maxQuranFontStep.toDouble(),
                  divisions:
                      AppConstants.maxQuranFontStep -
                      AppConstants.minQuranFontStep,
                  label: '${settings.quranFontStep}',
                  onChanged: (v) => controller.setFontStep(v.round()),
                ),
              ),
              const _DividerRow(),
              _SettingRow(
                icon: Icons.translate_rounded,
                title: S.showTranslationLabel,
                trailing: GlassSwitch(
                  value: settings.showTranslation,
                  onChanged: controller.setShowTranslation,
                  useOwnLayer: true,
                ),
              ),
              const _DividerRow(),
              _SettingRow(
                icon: Icons.format_align_right_rounded,
                title: S.alignLabel,
                subtitle: S.alignNote,
                bottom: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: GlassSegmentedControl(
                    useOwnLayer: true,
                    selectedIndex: settings.alignArabicRight ? 0 : 1,
                    onSegmentSelected: (index) {
                      controller.setAlignArabicRight(index == 0);
                    },
                    selectedIconColor: activeGreen,
                    selectedTextStyle: TextStyle(
                      color: activeGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    unselectedTextStyle: TextStyle(
                      color: inactiveColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    segments: const [
                      GlassSegment(label: S.alignRight),
                      GlassSegment(label: S.alignCenter),
                    ],
                  ),
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
                trailing: GlassSwitch(
                  value: settings.tafsirOpenByDefault,
                  onChanged: controller.setTafsirOpenByDefault,
                  useOwnLayer: true,
                ),
              ),
              const _DividerRow(),
              _SettingRow(
                icon: Icons.palette_rounded,
                title: S.tajwidColorLabel,
                subtitle: S.tajwidColorSublabel,
                trailing: GlassSwitch(
                  value: settings.tajwidColor,
                  onChanged: controller.setTajwidColor,
                  useOwnLayer: true,
                ),
              ),
              const _DividerRow(),
              _SettingRow(
                icon: Icons.history_rounded,
                title: S.restoreLastReadLabel,
                trailing: GlassSwitch(
                  value: settings.restoreLastRead,
                  onChanged: controller.setRestoreLastRead,
                  useOwnLayer: true,
                ),
              ),
              const _DividerRow(),
              _SettingRow(
                icon: Icons.record_voice_over_rounded,
                title: S.reciterLabel,
                subtitle: _reciterName(ref),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onTap: () => _pickReciter(context, ref),
              ),
            ],
          ),
          // Prayer notifications are a mobile feature (Android/iOS alarms);
          // hidden on desktop where scheduling is not supported.
          if (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS) ...[
            _Section(
              title: S.notificationsSection,
              children: [
                _SettingRow(
                  icon: Icons.notifications_active_rounded,
                  title: S.prayerNotificationsLabel,
                  subtitle: S.prayerNotificationsSublabel,
                  trailing: GlassSwitch(
                    value: ref.watch(prayerNotificationsEnabledProvider),
                    useOwnLayer: true,
                    onChanged: (v) async {
                      final ok = await ref
                          .read(prayerNotificationsEnabledProvider.notifier)
                          .setEnabled(v);
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(S.prayerNotificationsDenied)),
                        );
                      }
                    },
                  ),
                ),
                const _DividerRow(),
                _SettingRow(
                  icon: Icons.self_improvement_rounded,
                  title: S.dzikirReminderLabel,
                  subtitle: S.dzikirReminderSublabel,
                  trailing: GlassSwitch(
                    value: ref.watch(dzikirReminderEnabledProvider),
                    useOwnLayer: true,
                    onChanged: (v) async {
                      final ok = await ref
                          .read(dzikirReminderEnabledProvider.notifier)
                          .setEnabled(v);
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(S.dzikirReminderDenied)),
                        );
                      }
                    },
                  ),
                ),
                const _DividerRow(),
                _SettingRow(
                  icon: Icons.notifications_rounded,
                  title: S.prayerNotificationsTest,
                  subtitle: S.prayerNotificationsTestSublabel,
                  bottom: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: AppLayout.sp2,
                      runSpacing: AppLayout.sp2,
                      children: [
                        GlassChip(
                          useOwnLayer: true,
                          icon: Icon(
                            Icons.volume_up_rounded,
                            size: 18,
                            color: activeGreen,
                          ),
                          label: S.adzanTestSholat,
                          labelStyle: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          onTap: () => _sendTestNotification(
                            context,
                            ref,
                            ref.read(selectedAdzanVoiceProvider),
                          ),
                        ),
                        GlassChip(
                          useOwnLayer: true,
                          icon: Icon(
                            Icons.wb_twilight_rounded,
                            size: 18,
                            color: activeGreen,
                          ),
                          label: S.adzanTestFajr,
                          labelStyle: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          onTap: () => _sendTestNotification(
                            context,
                            ref,
                            ref.read(selectedFajrAdzanVoiceProvider),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // The voice picker is a self-contained card, so it sits on its own
            // outside the section container instead of nesting two rounded boxes.
            Padding(
              padding: const EdgeInsets.only(bottom: AppLayout.sp6),
              child: _buildAdzanVoiceCard(context, ref),
            ),
          ],
          _Section(
            title: S.dataSection,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.sp4,
                  vertical: AppLayout.sp3,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppLayout.sp3),
                    Expanded(
                      child: Text(
                        S.dataSourceLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const _DividerRow(),
              _SettingRow(
                icon: Icons.storage_rounded,
                title: S.dataVersionLabel,
                trailing: _ValueChip(
                  text: 'v${AppConstants.quranDbSchemaVersion}',
                ),
              ),
              const _DividerRow(),
              const _SettingRow(
                icon: Icons.balance_rounded,
                title: S.licenseLabel,
                trailing: _ValueChip(text: 'CC BY-SA 4.0'),
              ),
            ],
          ),
          _Section(
            title: S.shortcutsSection,
            children: const [
              _ShortcutRow(
                icon: Icons.search_rounded,
                label: S.shortcutSearch,
                keys: ['Ctrl', 'K'],
              ),
              _ShortcutRow(
                icon: Icons.zoom_in_rounded,
                label: S.shortcutZoomIn,
                keys: ['Ctrl', '+'],
              ),
              _ShortcutRow(
                icon: Icons.zoom_out_rounded,
                label: S.shortcutZoomOut,
                keys: ['Ctrl', '−'],
              ),
              _ShortcutRow(
                icon: Icons.close_rounded,
                label: S.shortcutClose,
                keys: ['Esc'],
              ),
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
                trailing: GlassTouchButton(
                  onTap: () => _confirmReset(context, ref),
                  radius: AppLayout.radiusFull,
                  style: glassChromeStyle(
                    context,
                    cornerRadius: AppLayout.radiusFull,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: Text(
                      S.resetDataConfirm,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(S.resetDataDone)));
  }

  /// Lets the user pick an adzan voice for one category: shows the voices of
  /// that category, downloads the chosen mp3 (blocking progress dialog), then
  /// switches the selection — the sync provider reschedules the prayers on the
  /// new voice's channel.
  Future<void> _pickAdzanVoice(
    BuildContext context,
    WidgetRef ref,
    AdzanCategory category,
  ) async {
    final isFajr = category == AdzanCategory.fajr;
    final current = isFajr
        ? ref.read(selectedFajrAdzanVoiceProvider)
        : ref.read(selectedAdzanVoiceProvider);
    final voices = adzanVoicesByCategory(category);
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        final textTheme = Theme.of(ctx).textTheme;
        return SimpleDialog(
          titlePadding: const EdgeInsets.fromLTRB(
            AppLayout.sp4,
            AppLayout.sp4,
            AppLayout.sp4,
            AppLayout.sp2,
          ),
          title: Row(
            children: [
              Icon(
                isFajr ? Icons.wb_twilight_rounded : Icons.volume_up_rounded,
                size: 22,
                color: scheme.primary,
              ),
              const SizedBox(width: AppLayout.sp3),
              Expanded(
                child: Text(
                  isFajr ? S.adzanVoiceFajrLabel : S.adzanVoiceSholatLabel,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppLayout.sp4,
                0,
                AppLayout.sp4,
                AppLayout.sp2,
              ),
              child: Text(
                isFajr ? S.adzanVoiceFajrHint : S.adzanVoiceSholatHint,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            RadioGroup<String>(
              groupValue: current,
              onChanged: (id) {
                if (id != null) Navigator.of(ctx).pop(id);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final v in voices)
                    RadioListTile<String>(
                      value: v.id,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppLayout.sp4,
                      ),
                      title: Text(
                        v.name,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: v.id == current ? FontWeight.w600 : null,
                          color: v.id == current ? scheme.primary : null,
                        ),
                      ),
                      subtitle: Text(v.license),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppLayout.sp2),
          ],
        );
      },
    );
    if (selected == null || selected == current) return;
    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: AppLayout.sp4),
            Expanded(child: Text(S.adzanVoiceDownloading)),
          ],
        ),
      ),
    );
    try {
      await ref
          .read(prayerNotificationsProvider)
          .ensureVoiceDownloaded(adzanVoiceById(selected));
      if (!context.mounted) return;
      Navigator.of(context).pop(); // close the progress dialog
      if (isFajr) {
        await ref
            .read(selectedFajrAdzanVoiceProvider.notifier)
            .select(selected);
      } else {
        await ref.read(selectedAdzanVoiceProvider.notifier).select(selected);
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.adzanVoiceChanged)));
    } catch (_) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // close the progress dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.adzanVoiceDownloadFailed)));
    }
  }

  /// Sends a test notification with the given voice id, then confirms.
  Future<void> _sendTestNotification(
    BuildContext context,
    WidgetRef ref,
    String voiceId,
  ) async {
    await ref
        .read(prayerNotificationsProvider)
        .showTestNotification(voiceId: voiceId);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.prayerNotificationsTestSent)));
    }
  }

  /// The grouped adzan voice picker: one tappable row per category (regular
  /// prayers vs fajr), each showing the currently selected voice.
  Widget _buildAdzanVoiceCard(BuildContext context, WidgetRef ref) {
    final regularVoice = adzanVoiceById(ref.watch(selectedAdzanVoiceProvider));
    final fajrVoice = adzanVoiceById(ref.watch(selectedFajrAdzanVoiceProvider));
    return _AdzanVoiceCard(
      regularVoiceName: regularVoice.name,
      fajrVoiceName: fajrVoice.name,
      onRegularTap: () => _pickAdzanVoice(context, ref, AdzanCategory.regular),
      onFajrTap: () => _pickAdzanVoice(context, ref, AdzanCategory.fajr),
    );
  }

  /// The selected reciter's display name, falling back to the default while
  /// the reciter list is still loading or unavailable.
  String _reciterName(WidgetRef ref) {
    final reciters = ref.watch(recitersProvider).value;
    final selectedId = ref.watch(selectedReciterProvider);
    if (reciters != null) {
      for (final r in reciters) {
        if (r.id == selectedId) return r.name;
      }
    }
    return S.reciterDefault;
  }

  /// Lets the user pick a qari: shows the reciter list from the DB and
  /// switches the selection immediately — no download, murottal files are
  /// resolved at playback time via the reciter's URL template.
  Future<void> _pickReciter(BuildContext context, WidgetRef ref) async {
    final current = ref.read(selectedReciterProvider);
    final List<Reciter> reciters;
    try {
      reciters = await ref.read(recitersProvider.future);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.reciterLoadFailed)));
      return;
    }
    if (!context.mounted || reciters.isEmpty) return;

    final selected = await showDialog<int>(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        final textTheme = Theme.of(ctx).textTheme;
        return SimpleDialog(
          titlePadding: const EdgeInsets.fromLTRB(
            AppLayout.sp4,
            AppLayout.sp4,
            AppLayout.sp4,
            AppLayout.sp2,
          ),
          title: Row(
            children: [
              Icon(
                Icons.record_voice_over_rounded,
                size: 22,
                color: scheme.primary,
              ),
              const SizedBox(width: AppLayout.sp3),
              Expanded(child: Text(S.reciterDialogTitle)),
            ],
          ),
          children: [
            RadioGroup<int>(
              groupValue: current,
              onChanged: (id) {
                if (id != null) Navigator.of(ctx).pop(id);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final r in reciters)
                    RadioListTile<int>(
                      value: r.id,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppLayout.sp4,
                      ),
                      title: Text(
                        r.name,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: r.id == current ? FontWeight.w600 : null,
                          color: r.id == current ? scheme.primary : null,
                        ),
                      ),
                      subtitle: Text(r.style),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppLayout.sp2),
          ],
        );
      },
    );
    if (selected == null || selected == current) return;
    if (!context.mounted) return;

    await ref.read(selectedReciterProvider.notifier).select(selected);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(S.reciterChanged)));
  }
}

/// App bar for the pushed Settings route: a quiet bar with just the back
/// button. The page title lives in the body header (eyebrow + display title
/// + caption), so it is not repeated here.
class _SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SettingsAppBar();

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
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingRow extends StatefulWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
    this.destructive = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? bottom;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  State<_SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<_SettingRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final isDestructive = widget.destructive;
    final iconBg = isDestructive
        ? scheme.errorContainer.withValues(alpha: 0.5)
        : scheme.primaryContainer.withValues(alpha: 0.3);
    final iconColor = isDestructive ? scheme.error : scheme.primary;

    final content = AnimatedContainer(
      duration: AppLayout.durBase,
      color: _hovered && widget.onTap != null
          ? scheme.surfaceContainerHigh.withValues(alpha: 0.5)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp4,
        vertical: AppLayout.sp4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppLayout.radiusMd),
            ),
            child: Icon(widget.icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: AppLayout.sp4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? scheme.error : null,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (widget.bottom != null) ...[
                  const SizedBox(height: AppLayout.sp3),
                  widget.bottom!,
                ],
              ],
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: AppLayout.sp3),
            widget.trailing!,
          ],
        ],
      ),
    );

    if (widget.onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (v) => setState(() => _hovered = v),
        child: content,
      ),
    );
  }
}

/// A grouped card for choosing the adzan voices: a small header plus one
/// tappable row per category (regular prayers vs fajr), each showing the
/// currently selected voice.
class _AdzanVoiceCard extends StatelessWidget {
  const _AdzanVoiceCard({
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
                    S.adzanVoiceLabel,
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
            _AdzanVoiceOption(
              icon: Icons.volume_up_rounded,
              iconBackground: scheme.secondaryContainer,
              iconColor: scheme.onSecondaryContainer,
              title: S.adzanVoiceSholatLabel,
              voiceName: regularVoiceName,
              onTap: onRegularTap,
            ),
            Divider(
              height: 1,
              indent: AppLayout.sp4 + 40 + AppLayout.sp3,
              endIndent: AppLayout.sp4,
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
            _AdzanVoiceOption(
              icon: Icons.wb_twilight_rounded,
              iconBackground: scheme.tertiaryContainer,
              iconColor: scheme.onTertiaryContainer,
              title: S.adzanVoiceFajrLabel,
              voiceName: fajrVoiceName,
              onTap: onFajrTap,
            ),
          ],
        ),
      ),
    );
  }
}

/// A tappable row inside [_AdzanVoiceCard]: a tinted category icon, the
/// category title, the current voice name, and a chevron.
class _AdzanVoiceOption extends StatelessWidget {
  const _AdzanVoiceOption({
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

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({
    required this.icon,
    required this.label,
    required this.keys,
  });

  final IconData icon;
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
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: AppLayout.sp3),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
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

/// A small pill showing a status value (e.g. data version, license) on the
/// trailing side of a [_SettingRow].
class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp2,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppLayout.radiusFull),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
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
      endIndent: AppLayout.sp4,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
