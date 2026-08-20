import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/db/quran_database.dart';
import '../../data/providers.dart';
import '../../data/models/doa_harian_data.dart';
import '../../data/models/asmaul_husna_data.dart';
import '../../data/models/tahlil_doa_data.dart';
import '../spiritual/doa_setelah_sholat_screen.dart';
import '../../data/repositories/reading_history_repository.dart';
import '../browse/browse_screen.dart';
import '../hijri/hijri_calendar_screen.dart';
import '../learning/learning_screen.dart';
import '../mosque/mosque_screen.dart';
import '../personality/personality_screen.dart';
import '../spiritual/amalan_ibadah_screen.dart';
import '../spiritual/asmaul_husna_screen.dart';
import '../spiritual/doa_harian_screen.dart';
import '../spiritual/zakat_calculator_screen.dart';
import '../spiritual/ratibul_haddad_screen.dart';
import '../spiritual/spiritual_reader_screen.dart';
import '../spiritual/tasbih_digital_screen.dart';
import '../thematic/thematic_verse_screen.dart';
import '../widgets/ayah_number_badge.dart';
import '../widgets/glass_pill.dart';
import '../widgets/liquid_glass.dart';
import '../widgets/quran_text_view.dart';
import 'prayer_times_card.dart';

/// Beranda — the Stitch remodel: a pinned app bar (Al-Qur'an + search), a
/// greeting, the last-read hero, a quick-actions bento, the Jadwal Sholat
/// strip, and Ayat Hari Ini. The reading history and the full surah/juz links
/// from the previous design stay on below, so nothing useful is lost.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    required this.onOpenSurahs,
    required this.onOpenJuzs,
    required this.onOpenSearch,
    required this.onOpenPrayer,
  });

  final VoidCallback onOpenSurahs;
  final VoidCallback onOpenJuzs;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenPrayer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          ListView(
            // The list fills the viewport so content scrolls behind the
            // pinned glass app bar and the floating glass nav. The top inset
            // clears the first item from the app bar (its height is sp10)
            // plus a small margin; the bottom inset clears the last item
            // from the nav (80px + margin + system inset) on mobile.
            padding: EdgeInsets.fromLTRB(
              AppLayout.sp6,
              AppLayout.sp10 + AppLayout.sp5,
              AppLayout.sp6,
              isMobile
                  ? glassNavClearance + MediaQuery.paddingOf(context).bottom
                  : AppLayout.sp8,
            ),
            children: [
              const _Greeting(),
              const SizedBox(height: AppLayout.sp6),
              const _HeroCarousel(),
              const SizedBox(height: AppLayout.sp6),
              _QuickActionsBento(onOpenPrayer: onOpenPrayer),
              const SizedBox(height: AppLayout.sp3),
              const _FeatureCardsRow(),
              const SizedBox(height: AppLayout.sp7),
              const PrayerTimesCard(),
              const SizedBox(height: AppLayout.sp7),
              const _DailyVerseCard(),
              const SizedBox(height: AppLayout.sp7),
              const _ReadingHistory(),
              const SizedBox(height: AppLayout.sp7),
              // _QuickAccess(onOpenSurahs: onOpenSurahs, onOpenJuzs: onOpenJuzs),
            ],
          ),
          // Floating glass header pill (title + search), inset from the
          // screen edges and pinned over the scrolling content.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _HomeAppBar(onOpenSearch: onOpenSearch),
          ),
        ],
      ),
    );
  }
}

// ── Pinned app bar ───────────────────────────────────────────────────────

/// Floating glass header: the centered "Al-Qur'an" title and the search
/// action live in TWO separate compact liquid-glass pills — a title pill
/// and a search pill — NOT one full-width bar and not one shared lens.
/// Both are inset from the screen edges (sp4) and pinned at the top, so
/// scrolling content refracts through the glass behind them while the
/// title stays centered and the search button keeps working as before.
class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({required this.onOpenSearch});

  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      // Inset from the screen edges so the pills float, not span edge-to-edge.
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp4,
        vertical: AppLayout.sp2,
      ),
      child: SizedBox(
        // Pins the header row to the search button's height (48px) so the
        // centered title pill and the right-edge search pill share one line.
        height: AppLayout.sp10 + AppLayout.sp2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Title pill — compact, wraps only the text + its own padding.
            GlassPill(
              child: Text(
                S.browseTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ),
            // Search pill — compact, sized to the button.
            Positioned(
              right: 0,
              child: GlassPill(
                padding: EdgeInsets.zero,
                child: GlassTouchButton(
                  radius: AppLayout.radiusFull,
                  child: IconButton(
                    onPressed: onOpenSearch,
                    tooltip: S.openSearch,
                    icon: Icon(
                      Icons.search_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Greeting ─────────────────────────────────────────────────────────────

class _Greeting extends ConsumerWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final name = ref.watch(profileNameProvider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.homeGreeting,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  height: 32 / 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Last-read hero card ──────────────────────────────────────────────────

/// A sliding carousel that displays the last-read hero and other features.
class _HeroCarousel extends ConsumerStatefulWidget {
  const _HeroCarousel();

  @override
  ConsumerState<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends ConsumerState<_HeroCarousel> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  final int _pageCount = 4;

  @override
  void initState() {
    super.initState();
    // Start at a large number to allow swiping backwards initially if we wanted to,
    // but 0 is fine if we only auto-scroll forward.
    // Let's start at an index that is a multiple of 3, e.g., 3000.
    _currentPage = 3000;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(_currentPage);
    });

    _timer = Timer.periodic(const Duration(seconds: 6), (Timer timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1400),
          curve: Curves.fastLinearToSlowEaseIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - (AppLayout.sp6 * 2);
    const gap = 12.0;

    return SizedBox(
      height: 180,
      child: OverflowBox(
        maxWidth: width + gap,
        alignment: Alignment.centerLeft,
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (int page) {
            _currentPage = page;
          },
          itemBuilder: (context, index) {
            final realIndex = index % _pageCount;

            Widget child;
            if (realIndex == 0) {
              child = const _LastReadHero();
            } else if (realIndex == 1) {
              child = const _RandomDoaHeroSlide();
            } else if (realIndex == 2) {
              child = const _RandomAsmaulHusnaHeroSlide();
            } else {
              child = const _TasbihHeroSlide();
            }

            return Padding(
              padding: const EdgeInsets.only(right: gap),
              child: child,
            );
          },
        ),
      ),
    );
  }
}

/// Deep-emerald gradient hero for the most recent reading: history label,
/// surah name, ayah/juz position, a "Lanjutkan" pill, and a watermark open
/// book at 10% opacity (Stitch Beranda §3).
class _LastReadHero extends ConsumerWidget {
  const _LastReadHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final detail = ref.watch(lastReadDetailProvider);

    return Container(
      padding: const EdgeInsets.all(AppLayout.sp5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.surfaceTint],
        ),
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Watermark — open book in the bottom-right corner.
          Positioned(
            right: -36,
            bottom: -40,
            child: Icon(
              Icons.menu_book_rounded,
              size: 150,
              color: scheme.onPrimary.withValues(alpha: 0.10),
            ),
          ),
          detail.when(
            loading: () => const SizedBox(
              height: 128,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, __) => _HeroHint(onStart: () => openSurah(context, 1)),
            data: (d) {
              if (d == null) {
                return _HeroHint(onStart: () => openSurah(context, 1));
              }
              final surah = d.surah;
              final ayah = d.ayah;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HeroTopInfo(),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              surah.nameArabic,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppConstants.fontQuran,
                                fontSize: 22,
                                height: 1.25,
                                color: scheme.onPrimary.withValues(alpha: 0.95),
                                letterSpacing: 0, // never letter-space Arabic
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              surah.nameLatin,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 24,
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                color: scheme.onPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ayat ${toArabicIndic(ayah.ayahNumber)} • '
                              'Juz ${toArabicIndic(ayah.juz)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.primaryFixedDim,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppLayout.sp4),
                      _ContinuePill(
                        onTap: () => openSurah(
                          context,
                          surah.id,
                          initialAyahId: ayah.id,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RandomDoaHeroSlide extends ConsumerStatefulWidget {
  const _RandomDoaHeroSlide();

  @override
  ConsumerState<_RandomDoaHeroSlide> createState() =>
      _RandomDoaHeroSlideState();
}

class _RandomDoaHeroSlideState extends ConsumerState<_RandomDoaHeroSlide> {
  late final DoaHarian _doa;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _doa = doaHarianItems[random.nextInt(doaHarianItems.length)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppLayout.sp5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.secondary, scheme.primary],
        ),
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        boxShadow: [
          BoxShadow(
            color: scheme.secondary.withValues(alpha: 0.1),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -32,
            child: Icon(
              Icons.volunteer_activism_rounded,
              size: 150,
              color: scheme.onPrimary.withValues(alpha: 0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.stars_rounded, size: 20, color: scheme.onPrimary),
                  const SizedBox(width: AppLayout.sp2),
                  Text(
                    'DOA HARI INI',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      _doa.arabic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: AppConstants.fontQuran,
                        fontSize: 22,
                        height: 1.5,
                        color: scheme.onPrimary.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _doa.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _doa.translation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RandomAsmaulHusnaHeroSlide extends ConsumerStatefulWidget {
  const _RandomAsmaulHusnaHeroSlide();

  @override
  ConsumerState<_RandomAsmaulHusnaHeroSlide> createState() =>
      _RandomAsmaulHusnaHeroSlideState();
}

class _RandomAsmaulHusnaHeroSlideState
    extends ConsumerState<_RandomAsmaulHusnaHeroSlide> {
  late final AsmaulHusna _asma;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _asma = asmaulHusnaItems[random.nextInt(asmaulHusnaItems.length)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppLayout.sp5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00695C), Color(0xFF004D40)],
        ),
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        boxShadow: [
          BoxShadow(
            color: scheme.tertiary.withValues(alpha: 0.1),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -32,
            child: Icon(
              Icons.stars_rounded,
              size: 150,
              color: scheme.onPrimary.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 20,
                    color: scheme.onPrimary,
                  ),
                  const SizedBox(width: AppLayout.sp2),
                  Text(
                    'ASMAUL HUSNA',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      _asma.arabic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: AppConstants.fontQuran,
                        fontSize: 28,
                        height: 1.5,
                        color: scheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _asma.transliteration,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _asma.translation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TasbihHeroSlide extends StatelessWidget {
  const _TasbihHeroSlide();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const TasbihDigitalScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppLayout.sp5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: 0.9),
              scheme.secondary.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.1),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -24,
              bottom: -32,
              child: Icon(
                Icons.fingerprint_rounded,
                size: 150,
                color: scheme.onPrimary.withValues(alpha: 0.08),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.fingerprint_rounded,
                      size: 20,
                      color: scheme.onPrimary,
                    ),
                    const SizedBox(width: AppLayout.sp2),
                    Text(
                      'TASBIH DIGITAL',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'Hitung Dzikir',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Berdzikir mengingat Allah dengan mudah',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Friendly empty state shown inside the hero before the first reading.
class _HeroHint extends StatelessWidget {
  const _HeroHint({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text(
          S.noHistoryTitle,
          style: theme.textTheme.titleMedium?.copyWith(color: scheme.onPrimary),
        ),
        const SizedBox(height: AppLayout.sp3),
        LiquidGlassButton.filled(
          onPressed: onStart,
          icon: const Icon(Icons.menu_book_rounded, size: 18),
          label: S.startFromFatihah,
        ),
      ],
    );
  }
}

/// The "Lanjutkan" pill on the hero — 3D liquid glass capsule.
class _ContinuePill extends StatelessWidget {
  const _ContinuePill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return LiquidGlassCapsule(
      onTap: onTap,
      backgroundColor: scheme.primaryContainer.withValues(alpha: 0.88),
      borderColor: Colors.white.withValues(alpha: 0.55),
      glowColor: const Color(0xFF67E8B5),
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp4,
        vertical: AppLayout.sp2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            S.continueButton,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppLayout.sp1),
          Icon(
            Icons.arrow_forward_rounded,
            size: 16,
            color: scheme.onPrimaryContainer,
          ),
        ],
      ),
    );
  }
}

class _HeroTopInfo extends ConsumerStatefulWidget {
  const _HeroTopInfo();

  @override
  ConsumerState<_HeroTopInfo> createState() => _HeroTopInfoState();
}

class _HeroTopInfoState extends ConsumerState<_HeroTopInfo> {
  late Timer _ticker;
  Duration _countdown = Duration.zero;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final schedule = ref.read(prayerScheduleProvider).value;
      if (schedule != null && mounted) {
        final now = DateTime.now();
        final next = schedule.nextPrayer;
        final diff = next.time.isAfter(now)
            ? next.time.difference(now)
            : next.time.add(const Duration(days: 1)).difference(now);
        setState(() => _countdown = diff);
      }
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  String _formatCountdown(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '-$h j ${m.toString().padLeft(2, '0')} m';
    }
    return '-${m.toString().padLeft(2, '0')} m ${s.toString().padLeft(2, '0')} d';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final scheduleAsync = ref.watch(prayerScheduleProvider);

    final today = HijriCalendar.now();
    final hijriText =
        '${today.getDayName()}, ${today.hDay} ${today.getLongMonthName()} ${today.hYear} H';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 20, color: scheme.onPrimary),
            const SizedBox(width: AppLayout.sp2),
            Text(
              S.lastReadLabel.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onPrimary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hijriText,
                textAlign: TextAlign.right,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              scheduleAsync.when(
                data: (schedule) {
                  if (!_seeded) {
                    _seeded = true;
                    _countdown = schedule.countdown;
                  }
                  final next = schedule.nextPrayer;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: scheme.onPrimary.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${next.label} ${_formatCountdown(_countdown)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onPrimary.withValues(alpha: 0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Quick actions bento ──────────────────────────────────────────────────

/// Four equal quick-action tiles (Kiblat, Doa Harian, Zakat, Masjid Terdekat).
/// "Kiblat" opens the prayer screen; "Doa Harian" opens the spiritual view;
/// the rest are not built yet and show a "Segera hadir" SnackBar rather than
/// a placeholder screen.
class _QuickActionsBento extends StatelessWidget {
  const _QuickActionsBento({required this.onOpenPrayer});

  final VoidCallback onOpenPrayer;

  void _showMoreFeatures(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppLayout.radiusLg),
        ),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final scheme = theme.colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppLayout.sp4,
              AppLayout.sp3,
              AppLayout.sp4,
              AppLayout.sp6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                    ),
                  ),
                ),
                const SizedBox(height: AppLayout.sp4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp2),
                  child: Row(
                    children: [
                      Text(
                        'Fitur Lainnya',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppLayout.sp3),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppLayout.sp3,
                  crossAxisSpacing: AppLayout.sp2,
                  childAspectRatio: 0.82,
                  children: [
                    _QuickActionTile(
                      icon: Icons.category_rounded,
                      label: 'Ayat Tematik',
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ThematicVerseScreen(),
                          ),
                        );
                      },
                    ),
                    _QuickActionTile(
                      icon: Icons.monetization_on_rounded,
                      label: S.qaZakat,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ZakatCalculatorScreen(),
                          ),
                        );
                      },
                    ),
                    _QuickActionTile(
                      icon: Icons.mosque_rounded,
                      label: S.qaMasjidTerdekat,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const MosqueScreen(),
                          ),
                        );
                      },
                    ),
                    _QuickActionTile(
                      icon: Icons.psychology_rounded,
                      label: 'Kepribadian',
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const PersonalityScreen(),
                          ),
                        );
                      },
                    ),
                    _QuickActionTile(
                      icon: Icons.calendar_month_rounded,
                      label: S.qaKalenderHijriah,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const HijriCalendarScreen(),
                          ),
                        );
                      },
                    ),
                    _QuickActionTile(
                      icon: Icons.auto_stories_rounded,
                      label: S.tahlilTitle,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => SpiritualReaderScreen(
                              title: S.tahlilTitle,
                              subtitle: S.tahlilCaption,
                              items: tahlilDoaItems,
                              icon: Icons.auto_stories_rounded,
                            ),
                          ),
                        );
                      },
                    ),
                    _QuickActionTile(
                      icon: Icons.brightness_5_rounded,
                      label: S.ratibTitle,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const RatibulHaddadScreen(),
                          ),
                        );
                      },
                    ),
                    _QuickActionTile(
                      icon: Icons.checklist_rounded,
                      label: S.amalanIbadahTitle,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AmalanIbadahScreen(),
                          ),
                        );
                      },
                    ),
                    _QuickActionTile(
                      icon: Icons.stars_rounded,
                      label: S.asmaulHusnaTitle,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AsmaulHusnaScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _QuickActionTile(
            icon: Icons.explore_rounded,
            label: S.qaKiblat,
            onTap: onOpenPrayer,
          ),
        ),
        const SizedBox(width: AppLayout.sp2),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.volunteer_activism_rounded,
            label: S.qaDoaHarian,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const DoaHarianScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppLayout.sp2),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.fingerprint_rounded,
            label: 'Tasbih Digital',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const TasbihDigitalScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppLayout.sp2),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.grid_view_rounded,
            label: 'Lainnya',
            onTap: () => _showMoreFeatures(context),
          ),
        ),
      ],
    );
  }
}

// ── Feature cards row (Pusat Belajar + Doa Setelah Sholat) ──────────────

/// One bento tile: a sage 48px circle with a filled icon and a label below,
/// on a `surfaceContainerLowest` card with a soft shadow. The circle gently
/// scales up on hover (desktop delight).
class _QuickActionTile extends StatefulWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppLayout.durBase,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _hovered
              ? scheme.surfaceContainerLow
              : scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppLayout.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppLayout.sp3,
                horizontal: AppLayout.sp1,
              ),
              child: Column(
                children: [
                  AnimatedScale(
                    duration: AppLayout.durBase,
                    scale: _hovered ? 1.06 : 1.0,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: scheme.onSecondaryContainer,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppLayout.sp2),
                  Text(
                    widget.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
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

/// Two side-by-side feature cards: Pusat Belajar (left) and Doa Setelah
/// Sholat (right). Both use the app's primary/theme-consistent green palette.
class _FeatureCardsRow extends StatelessWidget {
  const _FeatureCardsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _LearningTile()),
        SizedBox(width: AppLayout.sp3),
        Expanded(child: _DoaSetelahSholatTile()),
      ],
    );
  }
}

/// Compact vertical tile for Pusat Belajar.
class _LearningTile extends StatelessWidget {
  const _LearningTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppLayout.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const LearningScreen())),
        child: Container(
          padding: const EdgeInsets.all(AppLayout.sp4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                ),
                child: Icon(
                  Icons.school_rounded,
                  size: 24,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: AppLayout.sp3),
              Text(
                S.learningHomeEntryTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                S.learningHomeEntrySubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact vertical tile for Doa Setelah Sholat.
class _DoaSetelahSholatTile extends StatelessWidget {
  const _DoaSetelahSholatTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppLayout.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const DoaSetelahSholatScreen(),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppLayout.sp4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                ),
                child: Icon(
                  Icons.back_hand_rounded,
                  size: 24,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: AppLayout.sp3),
              Text(
                S.doaSetelahSholatHomeTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                S.doaSetelahSholatHomeSubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Ayat Hari Ini ────────────────────────────────────────────────────────

/// The daily-verse card: Amiri Arabic verse (right-aligned), italic
/// translation, and a primary reference — with a share action and a faint
/// rotated mosque watermark (Stitch Beranda §6). Wired to the offline DB via
/// [dailyAyahProvider] (a day-of-year rotation over beloved ayahs).
class _DailyVerseCard extends ConsumerWidget {
  const _DailyVerseCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final verseAsync = ref.watch(dailyAyahProvider);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative mosque watermark, rotated 12°, ~3-4% opacity.
          Positioned(
            right: -32,
            top: -36,
            child: Transform.rotate(
              angle: 12 * math.pi / 180,
              child: Icon(
                Icons.mosque_rounded,
                size: 150,
                color: scheme.primary.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppLayout.sp5),
            child: verseAsync.when(
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, __) => SizedBox(
                height: 120,
                child: Center(child: Text(S.dailyVerseError)),
              ),
              data: (d) => _VerseContent(ayah: d.ayah, surah: d.surah),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerseContent extends StatelessWidget {
  const _VerseContent({required this.ayah, required this.surah});

  final Ayah ayah;
  final Surah surah;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.auto_stories_rounded, size: 20, color: scheme.primary),
            const SizedBox(width: AppLayout.sp2),
            Text(
              S.dailyVerseLabel.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => _share(context),
              tooltip: S.shareVerse,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.share_outlined,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppLayout.sp4),
        QTextDisplay(
          text: ayah.textUthmani,
          step: 4, // ≈34px — the card's "quran-text" display size
          color: scheme.onSurface,
        ),
        const SizedBox(height: AppLayout.sp3),
        Text(
          '"${ayah.translation}"',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: AppLayout.sp3),
        Text(
          '${surah.nameLatin} : ${ayah.ayahNumber}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// No share_plus dependency yet — the share action copies the verse and
  /// confirms with a SnackBar.
  Future<void> _share(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(
        text:
            '${ayah.textUthmani}\n\n"${ayah.translation}"\n'
            '${surah.nameLatin} : ${ayah.ayahNumber}',
      ),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(S.copyAyahDone),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1800),
        ),
      );
  }
}

// ── Surah / juz quick links ──────────────────────────────────────────────

// class _QuickAccess extends StatelessWidget {
//   const _QuickAccess({required this.onOpenSurahs, required this.onOpenJuzs});

//   final VoidCallback onOpenSurahs;
//   final VoidCallback onOpenJuzs;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           S.quickAccessEyebrow,
//           style: theme.textTheme.labelSmall?.copyWith(
//             color: theme.colorScheme.onSurfaceVariant,
//           ),
//         ),
//         const SizedBox(height: AppLayout.sp2),
//         _QuickLink(
//           icon: Icons.menu_book_rounded,
//           title: S.surahListTitle,
//           caption: S.quickSurahCaption,
//           onTap: onOpenSurahs,
//         ),
//         const SizedBox(height: AppLayout.sp2),
//         _QuickLink(
//           icon: Icons.auto_stories_rounded,
//           title: S.juzListTitle,
//           caption: S.quickJuzCaption,
//           onTap: onOpenJuzs,
//         ),
//       ],
//     );
//   }
// }

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.title,
    required this.caption,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HoverTile(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppLayout.radiusMd),
            ),
            child: Icon(icon, color: theme.colorScheme.tertiary, size: 24),
          ),
          const SizedBox(width: AppLayout.sp4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  caption,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

// ── Reading history ──────────────────────────────────────────────────────

/// Riwayat baca: the 4 most recent surahs (the newest one already sits in the
/// hero above), each with a thin progress bar and a jump back to the last read
/// ayah. Renders nothing when there is no history beyond the hero.
class _ReadingHistory extends ConsumerWidget {
  const _ReadingHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recent = ref.watch(recentSurahsProvider);
    final hero = ref.watch(lastReadDetailProvider).value;

    final items = recent.value ?? const [];
    // The hero already surfaces the newest surah — skip it to avoid doubling.
    final rest = hero == null
        ? items
        : items.where((r) => r.surah.id != hero.surah.id).toList();
    if (rest.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.historyEyebrow,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppLayout.sp3),
        for (final item in rest) ...[
          _HistoryRow(item: item),
          const SizedBox(height: AppLayout.sp2),
        ],
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item});

  final RecentSurahRead item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surah = item.surah;
    return HoverTile(
      onTap: () => openSurah(context, surah.id, initialAyahId: item.lastAyahId),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: QTextDisplay(
              text: surah.nameArabic,
              step: 2,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              alignment: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppLayout.sp4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${surah.nameLatin} · ${surah.nameIndonesian}',
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppLayout.sp2),
                _ThinProgress(progress: item.progress),
              ],
            ),
          ),
          const SizedBox(width: AppLayout.sp4),
          Text(
            '${item.readAyahCount}/${item.totalAyahCount}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: AppLayout.sp1),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

/// 3px reading progress bar (echoes the reader's progress strip).
class _ThinProgress extends StatelessWidget {
  const _ThinProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(1.5),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ),
    );
  }
}
