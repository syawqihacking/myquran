import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../data/providers.dart';
import '../../data/services/prayer_time_service.dart';
import '../widgets/glass_pill.dart';
import '../widgets/liquid_glass.dart';

/// Jadwal Shalat & Kiblat (Stitch design): a pinned app bar, a centered
/// next-prayer header with a live countdown and location row, a qibla compass
/// card, and the prayer list. The qibla needle tracks the device heading via
/// the magnetometer (flutter_compass) and falls back to the computed bearing
/// when no sensor is available (desktop / unsupported platforms).
class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key});

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen> {
  late final Timer _ticker;
  Duration _countdown = Duration.zero;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final schedule = ref.read(prayerScheduleProvider).value;
      if (schedule != null && mounted) {
        final now = DateTime.now();
        final next = schedule.nextPrayer.time;
        final diff = next.isAfter(now)
            ? next.difference(now)
            : next.add(const Duration(days: 1)).difference(now);
        setState(() => _countdown = diff);
      }
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  /// Best-effort re-request: re-runs the provider (GPS permission flow with
  /// the Jakarta fallback) and confirms. No location picker.
  void _changeLocation() {
    final l10n = AppLocalizations.of(context)!;
    ref.invalidate(prayerScheduleProvider);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.locationUpdated),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1800),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(prayerScheduleProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Content fills the screen and scrolls behind the floating glass
            // header pills — exactly like the home header.
            Positioned.fill(
              child: scheduleAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _ErrorState(onRetry: _changeLocation),
                data: (schedule) {
                  if (!_seeded) {
                    _seeded = true;
                    _countdown = schedule.countdown;
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppLayout.sp6,
                      AppLayout.sp10 + AppLayout.sp5,
                      AppLayout.sp6,
                      AppLayout.sp8,
                    ),
                    children: [
                      _HeaderCountdown(
                        schedule: schedule,
                        countdown: _countdown,
                        onChangeLocation: _changeLocation,
                      ),
                      const SizedBox(height: AppLayout.sp6),
                      _CardsGrid(schedule: schedule),
                    ],
                  );
                },
              ),
            ),
            // Floating glass header pills, over the scrolling content.
            Positioned(top: 0, left: 0, right: 0, child: const _PrayerAppBar()),
          ],
        ),
      ),
    );
  }
}

// ── App bar ──────────────────────────────────────────────────────────────

/// Pinned bar with the centered title only — search lives on the Al-Qur'an
/// pages, and there is no drawer, mirroring the home and browse bars.
class _PrayerAppBar extends StatelessWidget {
  const _PrayerAppBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return GlassHeader(
      title: l10n.prayerScreenTitle,
      titleStyle: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.primary,
      ),
      leading: GlassPill(
        padding: EdgeInsets.zero,
        child: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: l10n.back,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
    );
  }
}

// ── Header: next prayer + live countdown + location ──────────────────────

class _HeaderCountdown extends StatelessWidget {
  const _HeaderCountdown({
    required this.schedule,
    required this.countdown,
    required this.onChangeLocation,
  });

  final PrayerSchedule schedule;
  final Duration countdown;
  final VoidCallback onChangeLocation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      children: [
        Text(
          schedule.nextPrayer.label,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 32,
            height: 40 / 32,
            fontWeight: FontWeight.w700,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: AppLayout.sp2),
        Text(
          '${l10n.prayerCountdownPrefix} ${_formatCountdown(countdown)}',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: AppLayout.sp3),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_rounded, size: 18, color: scheme.secondary),
            const SizedBox(width: AppLayout.sp1),
            Flexible(
              child: Text(
                schedule.locationName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: AppLayout.sp2),
            _ChangeLocationButton(onTap: onChangeLocation),
          ],
        ),
      ],
    );
  }
}

/// 3D Liquid Glass "Ubah Lokasi" capsule button.
class _ChangeLocationButton extends StatelessWidget {
  const _ChangeLocationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return LiquidGlassCapsule(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.edit_location_alt_rounded,
            size: 14,
            color: scheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            l10n.changeLocation,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Two-column grid (single column on mobile) ────────────────────────────

class _CardsGrid extends StatelessWidget {
  const _CardsGrid({required this.schedule});

  final PrayerSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    final qibla = _QiblaCard(
      bearing: qiblaBearing(schedule.latitude, schedule.longitude),
    );
    final list = _PrayerListCard(schedule: schedule);

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          qibla,
          const SizedBox(height: AppLayout.sp6),
          list,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: list),
        const SizedBox(width: AppLayout.sp6),
        Expanded(child: qibla),
      ],
    );
  }
}

// ── Qibla card ───────────────────────────────────────────────────────────

class _QiblaCard extends StatefulWidget {
  const _QiblaCard({required this.bearing});

  final double bearing;

  @override
  State<_QiblaCard> createState() => _QiblaCardState();
}

class _QiblaCardState extends State<_QiblaCard> {
  /// True once the compass stream delivers a heading (sensor active). The
  /// caption switches to the device-relative hint only when it is live.
  bool _sensorActive = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 350),
      padding: const EdgeInsets.all(AppLayout.sp5),
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
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle Islamic geometric pattern at ~5% opacity.
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(
                painter: _GeometricPatternPainter(color: scheme.onSurface),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.qiblaTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  height: 28 / 20,
                  fontWeight: FontWeight.w600,
                  color: scheme.primary,
                ),
              ),
              // Stitch mb-xl (64px) → largest sensible house token.
              const SizedBox(height: AppLayout.sp8),
              _Compass(
                bearing: widget.bearing,
                onHeadingChanged: (heading) {
                  final active = heading != null;
                  if (active != _sensorActive) {
                    setState(() => _sensorActive = active);
                  }
                },
              ),
              // Stitch mt-lg (40px) → closest house token.
              const SizedBox(height: AppLayout.sp7),
              Text(
                '${widget.bearing.round()}°',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  height: 28 / 20,
                  fontWeight: FontWeight.w600,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: AppLayout.sp1),
              Text(
                _sensorActive ? l10n.qiblaAlignHint : l10n.qiblaCaption,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Compass extends StatefulWidget {
  const _Compass({required this.bearing, this.onHeadingChanged});

  final double bearing;

  /// Reports every heading update (null = sensor unavailable). Lets the parent
  /// card switch its caption to the device-relative hint while live.
  final ValueChanged<double?>? onHeadingChanged;

  @override
  State<_Compass> createState() => _CompassState();
}

class _CompassState extends State<_Compass> {
  static const double _size = 192;

  StreamSubscription<CompassEvent>? _sub;
  double? _heading;

  /// Needle angle in degrees, unwrapped so the AnimatedRotation glides across
  /// the 0/360° boundary instead of spinning a full turn. Starts at the static
  /// bearing (the pre-sensor behavior) and is adjusted continuously.
  double _angle = 0;

  @override
  void initState() {
    super.initState();
    _angle = widget.bearing;
    // Linux/Windows have no magnetometer backend — listening would throw a
    // MissingPluginException, so bail out and keep the static needle.
    if (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.windows) {
      return;
    }
    final events = FlutterCompass.events;
    if (events == null) return;
    _sub = events.listen(
      (e) => _onHeading(e.heading),
      onError: (_) => _onHeading(null),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onHeading(double? heading) {
    setState(() {
      _heading = heading;
      // Device-relative needle angle: bearing minus the device heading.
      // With no heading this reduces to the static bearing.
      final target = ((widget.bearing - (_heading ?? 0)) % 360 + 360) % 360;
      // Unwrap across the 0/360° boundary so the needle glides, not spins.
      var delta = target - _angle;
      if (delta > 180) delta -= 360;
      if (delta < -180) delta += 360;
      _angle += delta;
    });
    widget.onHeadingChanged?.call(_heading);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Stitch animates the needle over ~0.5s; honor reduced-motion settings.
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 500);
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant, width: 2),
      ),
      child: Stack(
        children: [
          // Inner dashed circle.
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(AppLayout.sp4),
              child: CustomPaint(
                painter: _DashedCirclePainter(color: scheme.outlineVariant),
              ),
            ),
          ),
          // "N" marker at the top.
          Positioned(
            top: 6,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'N',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Needle, pivoting at the compass center. The 96px needle sits in a
          // 192px circle (radius 96), so its tip never exceeds the rim. The
          // rotation animates smoothly toward the live device heading.
          Positioned(
            left: 0,
            right: 0,
            bottom: _size / 2,
            child: Center(
              child: AnimatedRotation(
                turns: _angle / 360,
                duration: duration,
                curve: Curves.easeOut,
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 16,
                  height: 96,
                  child: CustomPaint(
                    painter: _NeedlePainter(
                      primary: scheme.primary,
                      secondary: scheme.secondary,
                      gold: scheme.tertiaryFixedDim,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Center pin.
          Positioned.fill(
            child: Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.surface,
                  border: Border.all(color: scheme.primary, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The needle: a primary triangle pointing up, a small gold pivot dot, and a
/// secondary triangle pointing down at ~60% alpha.
class _NeedlePainter extends CustomPainter {
  const _NeedlePainter({
    required this.primary,
    required this.secondary,
    required this.gold,
  });

  final Color primary;
  final Color secondary;
  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    const topH = 48.0;
    const bottomH = 36.0;

    final top = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, topH)
      ..lineTo(0, topH)
      ..close();
    canvas.drawPath(top, Paint()..color = primary);

    canvas.drawCircle(Offset(w / 2, topH + 5), 4, Paint()..color = gold);

    final bottom = Path()
      ..moveTo(w / 2, size.height)
      ..lineTo(w, size.height - bottomH)
      ..lineTo(0, size.height - bottomH)
      ..close();
    canvas.drawPath(bottom, Paint()..color = secondary.withValues(alpha: 0.6));
  }

  @override
  bool shouldRepaint(_NeedlePainter oldDelegate) =>
      oldDelegate.primary != primary ||
      oldDelegate.secondary != secondary ||
      oldDelegate.gold != gold;
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final radius = size.shortestSide / 2;
    final center = size.center(Offset.zero);
    const dash = 4.0;
    const gap = 4.0;
    final step = (dash + gap) / radius;
    for (var a = -math.pi / 2; a < 3 * math.pi / 2; a += step) {
      final start = center + Offset(math.cos(a), math.sin(a)) * radius;
      final end =
          center +
          Offset(math.cos(a + dash / radius), math.sin(a + dash / radius)) *
              radius;
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// A grid of 8-pointed stars (two squares per cell, one rotated 45°) — the
/// subtle Islamic geometric texture behind the compass. Purely decorative.
class _GeometricPatternPainter extends CustomPainter {
  const _GeometricPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const cell = 56.0;
    for (var y = -cell; y < size.height + cell; y += cell) {
      for (var x = -cell; x < size.width + cell; x += cell) {
        final c = Offset(x + cell / 2, y + cell / 2);
        final r = cell * 0.34;
        _drawSquare(canvas, paint, c, r, 0);
        _drawSquare(canvas, paint, c, r, math.pi / 4);
      }
    }
  }

  void _drawSquare(
    Canvas canvas,
    Paint paint,
    Offset center,
    double r,
    double rotation,
  ) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a = rotation + i * math.pi / 2;
      final p = center + Offset(math.cos(a), math.sin(a)) * r;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GeometricPatternPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ── Prayer list card ─────────────────────────────────────────────────────

class _PrayerListCard extends StatelessWidget {
  const _PrayerListCard({required this.schedule});

  final PrayerSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final activeIdx = schedule.activePrayerIndex;
    final entries = schedule.entries;

    // The five prayers plus Terbit (sunrise). Sunrise is never "active".
    final rows = <({String label, DateTime? time, int? entryIndex})>[
      (label: entries[0].label, time: entries[0].time, entryIndex: 0),
      (label: l10n.sunriseLabel, time: schedule.sunrise, entryIndex: null),
      (label: entries[1].label, time: entries[1].time, entryIndex: 1),
      (label: entries[2].label, time: entries[2].time, entryIndex: 2),
      (label: entries[3].label, time: entries[3].time, entryIndex: 3),
      (label: entries[4].label, time: entries[4].time, entryIndex: 4),
    ];

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
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: AppLayout.sp1),
            _PrayerRow(
              label: rows[i].label,
              time: rows[i].time == null
                  ? '—'
                  : _formatPrayerTime(rows[i].time!),
              active:
                  rows[i].entryIndex != null && rows[i].entryIndex == activeIdx,
            ),
          ],
        ],
      ),
    );
  }
}

class _PrayerRow extends StatefulWidget {
  const _PrayerRow({
    required this.label,
    required this.time,
    required this.active,
  });

  final String label;
  final String time;
  final bool active;

  @override
  State<_PrayerRow> createState() => _PrayerRowState();
}

class _PrayerRowState extends State<_PrayerRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final active = widget.active;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppLayout.durBase,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.sp4,
          vertical: AppLayout.sp3,
        ),
        decoration: BoxDecoration(
          color: active
              ? scheme.primaryContainer.withValues(alpha: 0.10)
              : _hovered
              ? scheme.surfaceContainerLow
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppLayout.radiusSm),
          border: Border(
            left: BorderSide(
              color: active ? scheme.primary : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: active ? scheme.primary : scheme.onSurfaceVariant,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            Text(
              widget.time,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
                height: 28 / 20,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: active ? scheme.primary : scheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error state ──────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.sp9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppLayout.sp3),
            Text(l10n.prayerError, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppLayout.sp4),
            LiquidGlassButton.tonal(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: l10n.retry,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────

/// Great-circle bearing from (lat, lng) to the Kaaba (Mecca), in degrees
/// clockwise from true north. Pure math — no sensor or package needed.
double qiblaBearing(double lat, double lng) {
  const kaabaLat = 21.4225, kaabaLng = 39.8262;
  final dLng = (kaabaLng - lng) * math.pi / 180;
  final lat1 = lat * math.pi / 180;
  final lat2 = kaabaLat * math.pi / 180;
  final y = math.sin(dLng);
  final x = math.cos(lat1) * math.tan(lat2) - math.sin(lat1) * math.cos(dLng);
  final bearing = math.atan2(y, x) * 180 / math.pi;
  return (bearing + 360) % 360;
}

String _formatCountdown(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

String _formatPrayerTime(DateTime time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
