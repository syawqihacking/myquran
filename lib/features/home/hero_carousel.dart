import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/asmaul_husna_data.dart';
import '../../data/models/doa_harian_data.dart';
import '../../data/providers.dart';
import '../browse/browse_screen.dart';
import '../spiritual/tasbih_digital_screen.dart';
import '../widgets/ayah_number_badge.dart';
import '../widgets/liquid_glass.dart';

/// A sliding carousel that displays the last-read hero and other features.
class HeroCarousel extends ConsumerStatefulWidget {
  const HeroCarousel({super.key});

  @override
  ConsumerState<HeroCarousel> createState() => HeroCarouselState();
}

class HeroCarouselState extends ConsumerState<HeroCarousel> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  final int _pageCount = 4;

  @override
  void initState() {
    super.initState();
    _currentPage = 3000;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(_currentPage);
    });

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 6), (Timer timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1000),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 180,
          child: OverflowBox(
            maxWidth: width + gap,
            alignment: Alignment.centerLeft,
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              onPageChanged: (int page) {
                setState(() => _currentPage = page);
              },
              itemBuilder: (context, index) {
                final realIndex = index % _pageCount;

                Widget child;
                if (realIndex == 0) {
                  child = const LastReadHero();
                } else if (realIndex == 1) {
                  child = const RandomDoaHeroSlide();
                } else if (realIndex == 2) {
                  child = const RandomAsmaulHusnaHeroSlide();
                } else {
                  child = const TasbihHeroSlide();
                }

                return Padding(
                  padding: const EdgeInsets.only(right: gap),
                  child: child,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pageCount, (index) {
            final active = (_currentPage % _pageCount) == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? scheme.primary
                    : scheme.outlineVariant.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Deep-emerald gradient hero for the most recent reading: history label,
/// surah name, ayah/juz position, a "Lanjutkan" pill, and a watermark open
/// book at 10% opacity (Stitch Beranda §3).
class LastReadHero extends ConsumerWidget {
  const LastReadHero({super.key});

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
            error: (_, __) => HeroHint(onStart: () => openSurah(context, 1)),
            data: (d) {
              if (d == null) {
                return HeroHint(onStart: () => openSurah(context, 1));
              }
              final surah = d.surah;
              final ayah = d.ayah;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeroTopInfo(),
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
                      ContinuePill(
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

class RandomDoaHeroSlide extends ConsumerStatefulWidget {
  const RandomDoaHeroSlide({super.key});

  @override
  ConsumerState<RandomDoaHeroSlide> createState() =>
      RandomDoaHeroSlideState();
}

class RandomDoaHeroSlideState extends ConsumerState<RandomDoaHeroSlide> {
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

class RandomAsmaulHusnaHeroSlide extends ConsumerStatefulWidget {
  const RandomAsmaulHusnaHeroSlide({super.key});

  @override
  ConsumerState<RandomAsmaulHusnaHeroSlide> createState() =>
      RandomAsmaulHusnaHeroSlideState();
}

class RandomAsmaulHusnaHeroSlideState
    extends ConsumerState<RandomAsmaulHusnaHeroSlide> {
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

class TasbihHeroSlide extends StatelessWidget {
  const TasbihHeroSlide({super.key});

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
class HeroHint extends StatelessWidget {
  const HeroHint({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text(
          l10n.noHistoryTitle,
          style: theme.textTheme.titleMedium?.copyWith(color: scheme.onPrimary),
        ),
        const SizedBox(height: AppLayout.sp3),
        LiquidGlassButton.filled(
          onPressed: onStart,
          icon: const Icon(Icons.menu_book_rounded, size: 18),
          label: l10n.startFromFatihah,
        ),
      ],
    );
  }
}

/// The "Lanjutkan" pill on the hero — 3D liquid glass capsule.
class ContinuePill extends StatelessWidget {
  const ContinuePill({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            l10n.continueButton,
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

class HeroTopInfo extends ConsumerStatefulWidget {
  const HeroTopInfo({super.key});

  @override
  ConsumerState<HeroTopInfo> createState() => HeroTopInfoState();
}

class HeroTopInfoState extends ConsumerState<HeroTopInfo> {
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
    final l10n = AppLocalizations.of(context)!;
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
              l10n.lastReadLabel.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onPrimary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(width: AppLayout.sp2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hijriText,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
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
                      Flexible(
                        child: Text(
                          '${next.label} ${_formatCountdown(_countdown)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onPrimary.withValues(alpha: 0.9),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
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
