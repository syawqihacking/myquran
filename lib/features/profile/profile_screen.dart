import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/providers.dart';
import '../../data/repositories/reading_history_repository.dart';
import '../../data/repositories/reading_stats_repository.dart';
import '../browse/browse_screen.dart';
import '../settings/settings_screen.dart';
import '../widgets/liquid_glass.dart';
import '../widgets/quran_text_view.dart';

/// Profil Pengguna — honest profile screen: an editable display name, real
/// reading stats (distinct surahs, total ayahs, streak), real reading history,
/// real settings shortcuts, and a destructive "Hapus Data Bacaan" action.
/// No fabricated identity, no premium badge, no dead buttons.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final stats = ref.watch(readingStatsProvider).value;
    final surahCount = ref.watch(surahsReadCountProvider).value;
    final recent = ref.watch(profileRecentSurahsProvider);
    final isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const _ProfileAppBar(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppLayout.sp5,
                  AppLayout.sp2,
                  AppLayout.sp5,
                  isMobile
                      ? glassNavClearance + MediaQuery.paddingOf(context).bottom
                      : AppLayout.sp8,
                ),
                children: [
                  const _ProfileHeader(),
                  const SizedBox(height: AppLayout.sp6),
                  _StatsGrid(surahCount: surahCount, stats: stats),
                  const SizedBox(height: AppLayout.sp7),
                  Text(
                    S.profileHistoryTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppLayout.sp3),
                  _HistorySection(recent: recent),
                  const SizedBox(height: AppLayout.sp7),
                  Text(
                    S.profileSettingsTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppLayout.sp3),
                  const _SettingsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App bar ────────────────────────────────────────────────────────────────

class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // As a top-level shell view there is nothing to pop, so the back button
    // is hidden and the title is centered; when pushed as a route the back
    // button appears (and the title shifts to stay visually centered).
    final canPop = Navigator.of(context).canPop();
    return Container(
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
          if (canPop)
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: S.back,
              icon: const Icon(Icons.arrow_back_rounded),
            )
          else
            const SizedBox(width: 48), // balances the title when centered
          Expanded(
            child: Text(
              S.profileTitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
                height: 28 / 20,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 48), // balances the back button
        ],
      ),
    );
  }
}

// ── Profile header ─────────────────────────────────────────────────────────

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final name = ref.watch(profileNameProvider);

    return Column(
      children: [
        // Avatar (icon-based — no fabricated photo) with a live edit badge.
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                size: 48,
                color: scheme.onPrimaryContainer,
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: GlassTouchButton(
                radius: AppLayout.radiusFull,
                child: Material(
                  color: scheme.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _editName(context, ref),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: scheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppLayout.sp3),
        Text(
          name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.primary,
          ),
        ),
      ],
    );
  }

  /// Rename dialog — the edit badge is a real control, not decoration.
  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final controller =
        TextEditingController(text: ref.read(profileNameProvider));
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.profileNameDialogTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: S.profileNameHint,
            counterText: '',
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text(S.profileSave),
          ),
        ],
      ),
    );
    if (newName != null) {
      ref.read(profileNameProvider.notifier).setName(newName);
    }
  }
}

// ── Stats grid ─────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.surahCount, required this.stats});

  final int? surahCount;
  final ReadingStats? stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCell(value: _formatCount(surahCount), label: S.profileSurahRead),
        const SizedBox(width: AppLayout.sp2),
        _StatCell(
          value: _formatCount(stats?.totalAyahs),
          label: S.profileAyahRead,
        ),
        const SizedBox(width: AppLayout.sp2),
        _StatCell(
          value: _formatCount(stats?.streakDays),
          label: S.profileStreakDays,
          icon: Icons.local_fire_department_rounded,
        ),
      ],
    );
  }

  /// Indonesian thousands separator (12345 → "12.345"); '—' while loading.
  static String _formatCount(int? value) {
    if (value == null) return '—';
    final digits = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    return buf.toString();
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label, this.icon});

  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.sp2,
          vertical: AppLayout.sp4,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: scheme.tertiary),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reading history ────────────────────────────────────────────────────────

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.recent});

  final AsyncValue<List<RecentSurahRead>> recent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return recent.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) {
          // Honest empty state — no fabricated history.
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppLayout.sp6),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppLayout.radiusLg),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              children: [
                Icon(Icons.history_rounded, size: 32, color: scheme.outline),
                const SizedBox(height: AppLayout.sp3),
                Text(
                  S.profileHistoryEmpty,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  S.profileHistoryEmptyHint,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.outline,
                  ),
                ),
              ],
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const _DividerRow(),
                _HistoryRow(item: items[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item});

  final RecentSurahRead item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surah = item.surah;

    return InkWell(
      onTap: () => openSurah(context, surah.id, initialAyahId: item.lastAyahId),
      borderRadius: BorderRadius.circular(AppLayout.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.sp4,
          vertical: AppLayout.sp3,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.nameLatin,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.readAyahCount}/${item.totalAyahCount} ${S.ayatCount}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppLayout.sp3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                QTextDisplay(
                  text: surah.nameArabic,
                  step: 2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  alignment: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  _relativeTime(item.lastReadAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// "Baru saja" / "X menit lalu" / "X jam lalu" / "Kemarin" / "X hari lalu".
  static String _relativeTime(int epochSeconds) {
    final now = DateTime.now();
    final then = DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
    final diff = now.difference(then);
    if (diff.inMinutes < 1) return S.profileTimeJustNow;
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} ${S.profileTimeMinutesAgo}';
    }
    if (diff.inHours < 24) return '${diff.inHours} ${S.profileTimeHoursAgo}';
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(then.year, then.month, then.day);
    final days = today.difference(day).inDays;
    if (days == 1) return S.profileTimeYesterday;
    return '$days ${S.profileTimeDaysAgo}';
  }
}

// ── Settings shortcuts ─────────────────────────────────────────────────────

class _SettingsSection extends ConsumerWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final settings = ref.watch(settingsProvider);
    final themeLabel = switch (settings.themeMode) {
      ThemeMode.system => S.themeSystem,
      ThemeMode.light => S.themeLight,
      ThemeMode.dark => S.themeDark,
    };

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          _SettingRow(
            icon: Icons.settings_rounded,
            title: S.profileThemeLabel,
            subtitle: themeLabel,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
          const _DividerRow(),
          const _SettingRow(
            icon: Icons.language_rounded,
            title: S.profileLanguageLabel,
            subtitle: S.profileLanguageValue,
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// When null the row is informational (no chevron, not tappable).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppLayout.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.sp4,
          vertical: AppLayout.sp3,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppLayout.radiusMd),
              ),
              child: Icon(
                icon,
                size: 20,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: AppLayout.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
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

class _DividerRow extends StatelessWidget {
  const _DividerRow();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: AppLayout.sp4 + 36 + AppLayout.sp3,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
