import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../data/db/user_database.dart';
import '../../data/models/adzan_voice.dart';
import '../../data/providers.dart';
import '../widgets/liquid_glass.dart';
import 'adzan_voice_widgets.dart';
import 'settings_app_bar.dart';
import 'settings_widgets.dart';

/// Settings (design §21).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
      appBar: const SettingsAppBar(),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? AppLayout.sp4 : AppLayout.sp6,
          vertical: AppLayout.sp8,
        ),
        children: [
          Text(
            l10n.settingsEyebrow,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: AppLayout.sp2),
          Text(l10n.settingsTitle, style: theme.textTheme.displaySmall),
          const SizedBox(height: AppLayout.sp2),
          Text(
            l10n.settingsCaption,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppLayout.sp6),
          Section(
            title: l10n.appearanceSection,
            children: [
              SettingRow(
                icon: Icons.brightness_6_rounded,
                title: l10n.themeModeLabel,
                subtitle: l10n.themeModeSublabel,
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
                        // label: l10n.themeSystem,
                        icon: Icon(Icons.brightness_auto_rounded, size: 18),
                      ),
                      GlassSegment(
                        // label: l10n.themeLight,
                        icon: Icon(Icons.light_mode_rounded, size: 18),
                      ),
                      GlassSegment(
                        // label: l10n.themeDark,
                        icon: Icon(Icons.dark_mode_rounded, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const DividerRow(),
              SettingRow(
                icon: Icons.format_size_rounded,
                title: l10n.quranFontSizeLabel,
                subtitle: l10n.quranFontSizeSublabel,
                trailing: GlassChip(
                  useOwnLayer: true,
                  label: l10n.reset,
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
              const DividerRow(),
              SettingRow(
                icon: Icons.translate_rounded,
                title: l10n.showTranslationLabel,
                trailing: GlassSwitch(
                  value: settings.showTranslation,
                  onChanged: controller.setShowTranslation,
                  useOwnLayer: true,
                ),
              ),
              const DividerRow(),
              SettingRow(
                icon: Icons.format_align_right_rounded,
                title: l10n.alignLabel,
                subtitle: l10n.alignNote,
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
                    segments: [
                      GlassSegment(label: l10n.alignRight),
                      GlassSegment(label: l10n.alignCenter),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Section(
            title: l10n.readingSection,
            children: [
              SettingRow(
                icon: Icons.menu_book_rounded,
                title: l10n.tafsirDefaultLabel,
                trailing: GlassSwitch(
                  value: settings.tafsirOpenByDefault,
                  onChanged: controller.setTafsirOpenByDefault,
                  useOwnLayer: true,
                ),
              ),
              const DividerRow(),
              SettingRow(
                icon: Icons.palette_rounded,
                title: l10n.tajwidColorLabel,
                subtitle: l10n.tajwidColorSublabel,
                trailing: GlassSwitch(
                  value: settings.tajwidColor,
                  onChanged: controller.setTajwidColor,
                  useOwnLayer: true,
                ),
              ),
              const DividerRow(),
              SettingRow(
                icon: Icons.history_rounded,
                title: l10n.restoreLastReadLabel,
                trailing: GlassSwitch(
                  value: settings.restoreLastRead,
                  onChanged: controller.setRestoreLastRead,
                  useOwnLayer: true,
                ),
              ),
              const DividerRow(),
              SettingRow(
                icon: Icons.record_voice_over_rounded,
                title: l10n.reciterLabel,
                subtitle: _reciterName(context, ref),
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
            Section(
              title: l10n.notificationsSection,
              children: [
                SettingRow(
                  icon: Icons.notifications_active_rounded,
                  title: l10n.prayerNotificationsLabel,
                  subtitle: l10n.prayerNotificationsSublabel,
                  trailing: GlassSwitch(
                    value: ref.watch(prayerNotificationsEnabledProvider),
                    useOwnLayer: true,
                    onChanged: (v) async {
                      final ok = await ref
                          .read(prayerNotificationsEnabledProvider.notifier)
                          .setEnabled(v);
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.prayerNotificationsDenied)),
                        );
                      }
                    },
                  ),
                ),
                const DividerRow(),
                SettingRow(
                  icon: Icons.self_improvement_rounded,
                  title: l10n.dzikirReminderLabel,
                  subtitle: l10n.dzikirReminderSublabel,
                  trailing: GlassSwitch(
                    value: ref.watch(dzikirReminderEnabledProvider),
                    useOwnLayer: true,
                    onChanged: (v) async {
                      final ok = await ref
                          .read(dzikirReminderEnabledProvider.notifier)
                          .setEnabled(v);
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.dzikirReminderDenied)),
                        );
                      }
                    },
                  ),
                ),
                const DividerRow(),
                SettingRow(
                  icon: Icons.event_rounded,
                  title: l10n.hijriEventReminderLabel,
                  subtitle: l10n.hijriEventReminderSublabel,
                  trailing: GlassSwitch(
                    value: ref.watch(hijriEventReminderEnabledProvider),
                    useOwnLayer: true,
                    onChanged: (v) async {
                      final ok = await ref
                          .read(hijriEventReminderEnabledProvider.notifier)
                          .setEnabled(v);
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.hijriEventReminderDenied)),
                        );
                      }
                    },
                  ),
                ),
                const DividerRow(),
                SettingRow(
                  icon: Icons.notifications_rounded,
                  title: l10n.prayerNotificationsTest,
                  subtitle: l10n.prayerNotificationsTestSublabel,
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
                          label: l10n.adzanTestSholat,
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
                          label: l10n.adzanTestFajr,
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
                        GlassChip(
                          useOwnLayer: true,
                          icon: Icon(
                            Icons.event_rounded,
                            size: 18,
                            color: activeGreen,
                          ),
                          label: l10n.testHijriEvent,
                          labelStyle: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          onTap: () => _sendHijriTestNotification(
                            context,
                            ref,
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
          Section(
            title: l10n.dataSection,
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
                        l10n.dataSourceLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const DividerRow(),
              SettingRow(
                icon: Icons.storage_rounded,
                title: l10n.dataVersionLabel,
                trailing: ValueChip(
                  text: 'v${AppConstants.quranDbSchemaVersion}',
                ),
              ),
              const DividerRow(),
              SettingRow(
                icon: Icons.balance_rounded,
                title: l10n.licenseLabel,
                trailing: ValueChip(text: 'CC BY-SA 4.0'),
              ),
            ],
          ),
          Section(
            title: l10n.shortcutsSection,
            children: [
              ShortcutRow(
                icon: Icons.search_rounded,
                label: l10n.shortcutSearch,
                keys: ['Ctrl', 'K'],
              ),
              ShortcutRow(
                icon: Icons.zoom_in_rounded,
                label: l10n.shortcutZoomIn,
                keys: ['Ctrl', '+'],
              ),
              ShortcutRow(
                icon: Icons.zoom_out_rounded,
                label: l10n.shortcutZoomOut,
                keys: ['Ctrl', '−'],
              ),
              ShortcutRow(
                icon: Icons.close_rounded,
                label: l10n.shortcutClose,
                keys: ['Esc'],
              ),
            ],
          ),
          Section(
            title: l10n.resetDataSection,
            children: [
              SettingRow(
                icon: Icons.delete_forever_rounded,
                title: l10n.resetDataLabel,
                subtitle: l10n.resetDataSublabel,
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
                      l10n.resetDataConfirm,
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
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.resetDataConfirmTitle),
        content: Text(l10n.resetDataConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: Text(l10n.resetDataConfirm),
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
    ).showSnackBar(SnackBar(content: Text(l10n.resetDataDone)));
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
    final l10n = AppLocalizations.of(context)!;
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
                  isFajr ? l10n.adzanVoiceFajrLabel : l10n.adzanVoiceSholatLabel,
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
                isFajr ? l10n.adzanVoiceFajrHint : l10n.adzanVoiceSholatHint,
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
      builder: (ctx) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: AppLayout.sp4),
            Expanded(child: Text(l10n.adzanVoiceDownloading)),
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
      ).showSnackBar(SnackBar(content: Text(l10n.adzanVoiceChanged)));
    } catch (e) {
      debugPrint('SettingsScreen._selectAdzanVoice: voice download/selection failed — $e');
      if (!context.mounted) return;
      Navigator.of(context).pop(); // close the progress dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.adzanVoiceDownloadFailed)));
    }
  }

  /// Sends a test notification with the given voice id, then confirms.
  Future<void> _sendTestNotification(
    BuildContext context,
    WidgetRef ref,
    String voiceId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    await ref
        .read(prayerNotificationsProvider)
        .showTestNotification(voiceId: voiceId);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.prayerNotificationsTestSent)));
    }
  }

  /// Sends a test notification for Hijri events, then confirms.
  Future<void> _sendHijriTestNotification(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await ref.read(prayerNotificationsProvider).requestPermissions();
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.hijriEventReminderDenied)),
      );
      return;
    }

    await ref.read(prayerNotificationsProvider).showHijriTestNotification();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.prayerNotificationsTestSent)));
    }
  }

  /// The grouped adzan voice picker: one tappable row per category (regular
  /// prayers vs fajr), each showing the currently selected voice.
  Widget _buildAdzanVoiceCard(BuildContext context, WidgetRef ref) {
    final regularVoice = adzanVoiceById(ref.watch(selectedAdzanVoiceProvider));
    final fajrVoice = adzanVoiceById(ref.watch(selectedFajrAdzanVoiceProvider));
    return AdzanVoiceCard(
      regularVoiceName: regularVoice.name,
      fajrVoiceName: fajrVoice.name,
      onRegularTap: () => _pickAdzanVoice(context, ref, AdzanCategory.regular),
      onFajrTap: () => _pickAdzanVoice(context, ref, AdzanCategory.fajr),
    );
  }

  /// The selected reciter's display name, falling back to the default while
  /// the reciter list is still loading or unavailable.
  String _reciterName(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final reciters = ref.watch(recitersProvider).value;
    final selectedId = ref.watch(selectedReciterProvider);
    if (reciters != null) {
      for (final r in reciters) {
        if (r.id == selectedId) return r.name;
      }
    }
    return l10n.reciterDefault;
  }

  /// Lets the user pick a qari: shows the reciter list from the DB and
  /// switches the selection immediately — no download, murottal files are
  /// resolved at playback time via the reciter's URL template.
  Future<void> _pickReciter(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.read(selectedReciterProvider);
    final List<Reciter> reciters;
    try {
      reciters = await ref.read(recitersProvider.future);
    } catch (e) {
      debugPrint('SettingsScreen._pickReciter: failed to load reciters — $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.reciterLoadFailed)));
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
              Expanded(child: Text(l10n.reciterDialogTitle)),
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
    ).showSnackBar(SnackBar(content: Text(l10n.reciterChanged)));
  }
}
