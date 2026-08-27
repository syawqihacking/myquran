import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'core/app_constants.dart';
import 'core/app_layout.dart';
import 'l10n/app_localizations.dart';
import 'core/error_boundary.dart';
import 'core/quran_theme.dart';
import 'data/providers.dart';
import 'features/bookmarks/bookmarks_screen.dart';
import 'features/browse/browse_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/prayer/prayer_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/widgets/liquid_glass.dart';

/// Provides ultra-smooth scrolling physics, overscroll bouncing, and mouse/touch drag support.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.unknown,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}

/// App root: watches the theme setting and applies the MyQuran theme.
class MyQuranApp extends ConsumerWidget {
  const MyQuranApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    // Keep prayer notifications in sync with the toggle + schedule for the
    // whole session (the service skips redundant rescheduling).
    ref.watch(prayerNotificationSyncProvider);
    // Keep the dzikir reminders in sync with their toggle for the whole session.
    ref.watch(dzikirReminderSyncProvider);
    // Keep the hijri event reminders in sync for the whole session.
    ref.watch(hijriEventReminderSyncProvider);
    return ErrorBoundary(
      child: MaterialApp(
        title: 'MyQuran',
        debugShowCheckedModeBanner: false,
        scrollBehavior: const AppScrollBehavior(),
        theme: buildAppTheme(Brightness.light, paper: settings.paperTheme),
        darkTheme: buildAppTheme(Brightness.dark, paper: settings.paperTheme),
        themeMode: settings.themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: settings.locale.toLocale(),
        // First launch shows onboarding; completing/skipping it flips
        // [onboardingDoneProvider] and this swaps to the app shell. On every
        // later launch the flag is already set, so onboarding never reappears.
        home: ref.watch(onboardingDoneProvider)
            ? const AppShell()
            : const OnboardingScreen(),
      ),
    );
  }
}

/// Desktop shell: sidebar navigation + content stack (design §4, §13).
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

enum _View { home, browse, bookmarks, stats, profile }

class _AppShellState extends ConsumerState<AppShell> {
  _View _view = _View.home;

  /// State of the unified Al-Qur'an page (list tab + search panel open state).
  /// Owned here so it survives IndexedStack switches and can be driven from
  /// outside (Ctrl+K, Beranda quick access).
  final ValueNotifier<BrowseState> _browseState = ValueNotifier(
    const BrowseState(),
  );

  /// Bumped on every Ctrl+K so the search field re-focuses even when the
  /// search panel is already open (focus may have been lost in between).
  int _searchFocusTick = 0;

  @override
  void dispose() {
    _browseState.dispose();
    super.dispose();
  }

  void _openBrowse(BrowseSegment segment) {
    _browseState.value = BrowseState(segment: segment, searchOpen: false);
    setState(() => _view = _View.browse);
  }

  void _openSearch() {
    _searchFocusTick++;
    _browseState.value = _browseState.value.copyWith(searchOpen: true);
    setState(() => _view = _View.browse);
  }

  @override
  Widget build(BuildContext context) {
    final body = IndexedStack(
      index: switch (_view) {
        _View.home => 0,
        _View.browse => 1,
        _View.bookmarks => 2,
        _View.stats => 3,
        _View.profile => 4,
      },
      children: [
        HomeScreen(
          onOpenSurahs: () => _openBrowse(BrowseSegment.surah),
          onOpenJuzs: () => _openBrowse(BrowseSegment.juz),
          onOpenSearch: _openSearch,
          onOpenPrayer: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PrayerScreen())),
        ),
        BrowseScreen(state: _browseState, focusTick: _searchFocusTick),
        const BookmarksScreen(),
        const StatsScreen(),
        const ProfileScreen(),
      ],
    );

    final isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _openSearch,
      },
      child: Scaffold(
        body: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isMobile)
                  _Sidebar(
                    view: _view,
                    onSelect: (v) => setState(() => _view = v),
                  ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppConstants.contentColumnMaxWidth,
                      ),
                      child: body,
                    ),
                  ),
                ),
              ],
            ),
            // Floating liquid-glass bottom nav on mobile: the content row
            // stays full-height behind it so scrolling content refracts
            // through the glass. Each screen's scrollable carries bottom
            // padding so its last item clears the nav at the scroll extreme.
            if (isMobile)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _BottomNav(
                  view: _view,
                  onSelect: (v) => setState(() => _view = v),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.view, required this.onSelect});

  final _View view;
  final ValueChanged<_View> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    int selectedIndex = switch (view) {
      _View.home => 0,
      _View.browse => 1,
      _View.bookmarks => 2,
      _View.stats => 3,
      _View.profile => 4,
    };

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeGreen = isDark
        ? const Color(0xFF67E8B5)
        : const Color(0xFF064E3B);
    final inactiveColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return GlassTabBar.bottom(
      horizontalPadding: 16,
      verticalPadding: 6,
      barHeight: 64,
      selectedIndex: selectedIndex,
      selectedIconColor: activeGreen,
      selectedLabelColor: activeGreen,
      unselectedIconColor: inactiveColor,
      unselectedLabelColor: inactiveColor,
      onTabSelected: (idx) {
        final v = switch (idx) {
          0 => _View.home,
          1 => _View.browse,
          2 => _View.bookmarks,
          3 => _View.stats,
          4 => _View.profile,
          _ => _View.home,
        };
        onSelect(v);
      },
      tabs: [
        const GlassTab(
          label: 'Beranda',
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
        ),
        GlassTab(
          label: l10n.browseTitle,
          icon: const Icon(Icons.menu_book_outlined),
          activeIcon: const Icon(Icons.menu_book_rounded),
        ),
        const GlassTab(
          label: 'Penanda',
          icon: Icon(Icons.bookmark_border_rounded),
          activeIcon: Icon(Icons.bookmark_rounded),
        ),
        const GlassTab(
          label: 'Statistik',
          icon: Icon(Icons.insights_outlined),
          activeIcon: Icon(Icons.insights_rounded),
        ),
        GlassTab(
          label: l10n.profileTitle,
          icon: const Icon(Icons.person_outline_rounded),
          activeIcon: const Icon(Icons.person_rounded),
        ),
      ],
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.view, required this.onSelect});

  final _View view;
  final ValueChanged<_View> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final rail =
        MediaQuery.sizeOf(context).width < AppConstants.sidebarBreakpoint;
    final width = rail
        ? AppConstants.sidebarRailWidth
        : AppConstants.sidebarFullWidth;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BrandTile(rail: rail),
          const SizedBox(height: AppLayout.sp2),
          if (rail)
            const Divider(height: 1)
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp6),
              child: Text(
                'BACA',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: AppLayout.sp1),
          _NavItem(
            rail: rail,
            icon: Icons.home_rounded,
            label: 'Beranda',
            selected: view == _View.home,
            onTap: () => onSelect(_View.home),
          ),
          _NavItem(
            rail: rail,
            icon: Icons.menu_book_rounded,
            label: l10n.browseTitle,
            selected: view == _View.browse,
            onTap: () => onSelect(_View.browse),
          ),
          const SizedBox(height: AppLayout.sp2),
          if (rail)
            const Divider(height: 1)
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp6),
              child: Text(
                'LAINNYA',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: AppLayout.sp1),
          _NavItem(
            rail: rail,
            icon: Icons.bookmark_rounded,
            label: 'Penanda',
            selected: view == _View.bookmarks,
            onTap: () => onSelect(_View.bookmarks),
          ),
          _NavItem(
            rail: rail,
            icon: Icons.insights_rounded,
            label: 'Statistik',
            selected: view == _View.stats,
            onTap: () => onSelect(_View.stats),
          ),
          _NavItem(
            rail: rail,
            icon: Icons.person_rounded,
            label: l10n.profileTitle,
            selected: view == _View.profile,
            onTap: () => onSelect(_View.profile),
          ),

          const Spacer(),
          _SidebarFooter(rail: rail),
        ],
      ),
    );
  }
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({required this.rail});

  final bool rail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppLayout.sp4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppLayout.radiusMd),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          if (!rail) ...[
            const SizedBox(width: AppLayout.sp3),
            Text(l10n.appName, style: theme.textTheme.titleLarge),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.rail,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final bool rail;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = widget.selected;
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp3,
        vertical: 2,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: selected
              ? theme.colorScheme.secondaryContainer
              : _hovered
              ? theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppLayout.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.sp3,
                vertical: AppLayout.sp2 + 2,
              ),
              child: widget.rail
                  ? Tooltip(
                      message: widget.label,
                      child: Icon(widget.icon, color: color, size: 22),
                    )
                  : Row(
                      children: [
                        Icon(widget.icon, color: color, size: 22),
                        const SizedBox(width: AppLayout.sp3),
                        Expanded(
                          child: Text(
                            widget.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: color,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends ConsumerWidget {
  const _SidebarFooter({required this.rail});

  final bool rail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final mode = ref.watch(settingsProvider).themeMode;

    void cycle() {
      final next = switch (mode) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      };
      ref.read(settingsProvider.notifier).setThemeMode(next);
    }

    return Padding(
      padding: const EdgeInsets.all(AppLayout.sp3),
      child: Column(
        children: [
          IconButton(
            onPressed: cycle,
            tooltip: l10n.changeTheme,
            icon: Icon(switch (mode) {
              ThemeMode.light => Icons.light_mode_rounded,
              ThemeMode.dark => Icons.dark_mode_rounded,
              ThemeMode.system => Icons.brightness_auto_rounded,
            }),
          ),
          if (!rail)
            Text(
              'MyQuran v1.0',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
