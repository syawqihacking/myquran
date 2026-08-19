import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../widgets/glass_pill.dart';

/// A scratch instance used only to call the instance method
/// `hijriToGregorian` (pure, stateless) for Gregorian conversions.
final HijriCalendar _converter = HijriCalendar.now();

/// Kalender Hijriah — a monthly Hijri calendar matching the app's calm,
/// card-based visual language. Fully offline (the `hijri` package is pure
/// Dart). Shows a month grid with today highlighted, plus a card with the
/// current date in both Hijri and Gregorian calendars.
class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  // Valid range of the `hijri` package (outside it throws ArgumentError).
  static const int _minYear = 1356;
  static const int _maxYear = 1500;

  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final now = HijriCalendar.now();
    _year = now.hYear;
    _month = now.hMonth;
  }

  bool get _atMin => _year == _minYear && _month == 1;
  bool get _atMax => _year == _maxYear && _month == 12;

  void _previousMonth() {
    if (_atMin) return;
    setState(() {
      if (_month == 1) {
        _month = 12;
        _year--;
      } else {
        _month--;
      }
    });
  }

  void _nextMonth() {
    if (_atMax) return;
    setState(() {
      if (_month == 12) {
        _month = 1;
        _year++;
      } else {
        _month++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Instance for the 1st of the displayed month — carries the correct month
    // name and day count without depending on today.
    final month = HijriCalendar.fromDate(
      _converter.hijriToGregorian(_year, _month, 1),
    );
    final daysInMonth = month.lengthOfMonth;

    // Leading blank cells: Dart weekday of the 1st (1=Senin..7=Ahad).
    final leading = _converter.hijriToGregorian(_year, _month, 1).weekday - 1;

    final today = HijriCalendar.now();
    bool isToday(int day) =>
        today.hYear == _year && today.hMonth == _month && today.hDay == day;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Content fills the screen and scrolls behind the floating glass
            // header pills — exactly like the home header.
            Positioned.fill(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.sp6,
                  AppLayout.sp10 + AppLayout.sp5,
                  AppLayout.sp6,
                  AppLayout.sp8,
                ),
                children: [
                  _MonthNavigator(
                    label:
                        '${month.getLongMonthName()} $_year ${S.hijriYearSuffix}',
                    atMin: _atMin,
                    atMax: _atMax,
                    onPrevious: _previousMonth,
                    onNext: _nextMonth,
                  ),
                  const SizedBox(height: AppLayout.sp5),
                  _CalendarCard(
                    leading: leading,
                    daysInMonth: daysInMonth,
                    isToday: isToday,
                  ),
                  const SizedBox(height: AppLayout.sp5),
                  _TodayCard(today: today),
                ],
              ),
            ),
            // Floating glass header pills, over the scrolling content.
            Positioned(top: 0, left: 0, right: 0, child: _HijriAppBar()),
          ],
        ),
      ),
    );
  }
}

// ── App bar ──────────────────────────────────────────────────────────────

/// Pinned bar mirroring the other screens: centered primary title with a back
/// button, balanced by a spacer on the right.
class _HijriAppBar extends StatelessWidget {
  const _HijriAppBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassHeader(
      title: S.hijriTitle,
      titleStyle: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.primary,
      ),
      leading: GlassPill(
        padding: EdgeInsets.zero,
        child: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: S.back,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
    );
  }
}

// ── Month navigation header ──────────────────────────────────────────────

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({
    required this.label,
    required this.atMin,
    required this.atMax,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final bool atMin;
  final bool atMax;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        _NavButton(
          icon: Icons.chevron_left_rounded,
          tooltip: 'Bulan sebelumnya',
          enabled: !atMin,
          onTap: onPrevious,
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        ),
        _NavButton(
          icon: Icons.chevron_right_rounded,
          tooltip: 'Bulan berikutnya',
          enabled: !atMax,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: enabled ? onTap : null,
      tooltip: tooltip,
      icon: Icon(icon),
      color: enabled ? scheme.primary : scheme.outlineVariant,
      disabledColor: scheme.outlineVariant,
    );
  }
}

// ── Calendar card ────────────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.leading,
    required this.daysInMonth,
    required this.isToday,
  });

  final int leading;
  final int daysInMonth;
  final bool Function(int day) isToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppLayout.sp4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Weekday header.
          Row(
            children: [
              for (final day in S.hijriWeekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppLayout.sp3),
          // Day grid (7 columns; leading blanks then 1..daysInMonth).
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: leading + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leading) return const SizedBox.shrink();
              final day = index - leading + 1;
              return _DayCell(day: day, isToday: isToday(day));
            },
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.isToday});

  final int day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isToday ? scheme.primary : Colors.transparent,
        ),
        child: Text(
          '$day',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            color: isToday ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// ── Today's date card ────────────────────────────────────────────────────

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.today});

  final HijriCalendar today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final gregorian = _converter.hijriToGregorian(
      today.hYear,
      today.hMonth,
      today.hDay,
    );
    final gregorianDayName = _gregorianDayName(gregorian.weekday);

    return Container(
      padding: const EdgeInsets.all(AppLayout.sp5),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today_rounded, size: 18, color: scheme.primary),
              const SizedBox(width: AppLayout.sp1),
              Text(
                S.hijriTodayLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppLayout.sp3),
          Text(
            '${today.getDayName()}, ${today.hDay} ${today.getLongMonthName()} '
            '${today.hYear} ${S.hijriYearSuffix}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppLayout.sp1),
          Text(
            '$gregorianDayName, ${gregorian.day} ${_gregorianMonthName(gregorian.month)} '
            '${gregorian.year} ${S.gregorianYearSuffix}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  static const _gregorianMonths = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  static const _gregorianDays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Ahad',
  ];

  String _gregorianMonthName(int month) => _gregorianMonths[month - 1];
  String _gregorianDayName(int weekday) => _gregorianDays[weekday - 1];
}
