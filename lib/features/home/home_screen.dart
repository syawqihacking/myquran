import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../widgets/liquid_glass.dart';
import 'daily_verse_card.dart';
import 'fasting_reminder_card.dart';
import 'feature_cards_row.dart';
import 'hero_carousel.dart';
import 'home_app_bar.dart';
import 'home_greeting.dart';
import 'prayer_times_card.dart';
import 'quick_actions_bento.dart';
import 'reading_history.dart';

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
              const Greeting(),
              const SizedBox(height: AppLayout.sp6),
              const HeroCarousel(),
              const SizedBox(height: AppLayout.sp6),
              QuickActionsBento(onOpenPrayer: onOpenPrayer),
              const SizedBox(height: AppLayout.sp3),
              const FeatureCardsRow(),
              const SizedBox(height: AppLayout.sp7),
              const PrayerTimesCard(),
              const SizedBox(height: AppLayout.sp7),
              const FastingReminderCard(),
              const SizedBox(height: AppLayout.sp7),
              const DailyVerseCard(),
              const SizedBox(height: AppLayout.sp7),
              const ReadingHistory(),
              const SizedBox(height: AppLayout.sp7),
              // QuickAccess(onOpenSurahs: onOpenSurahs, onOpenJuzs: onOpenJuzs),
            ],
          ),
          // Floating glass header pill (title + search), inset from the
          // screen edges and pinned over the scrolling content.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HomeAppBar(onOpenSearch: onOpenSearch),
          ),
        ],
      ),
    );
  }
}
