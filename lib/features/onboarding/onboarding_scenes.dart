import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Hand-drawn vector hero scenes for the onboarding slides.
///
/// Each scene is one [CustomPainter] painting geometric shapes and gradients
/// from the app scheme onto a rounded "night card" — no external assets.
/// A shared stage ([OnboardingScene]) owns exactly ONE looping
/// [AnimationController] per scene and feeds its 0..1 value (`t`) to the
/// painter, so each scene carries a single main motion effect:
///
///  * Slide 1 — night sky, crescent, twinkling stars, mosque silhouette.
///  * Slide 2 — open mushaf with a soft light sweeping across the pages.
///  * Slide 3 — large hijri crescent, twinkling stars, calendar card.
///  * Slide 4 — mosque silhouette with an expanding-fading radar pulse and
///    a location pin.
///
/// The loop only runs while the slide is active, renders one static frame
/// under prefers-reduced-motion, and everything disposes cleanly. Painting is
/// isolated behind a [RepaintBoundary]; swipe parallax moves the whole card.

/// Stage for one onboarding illustration: owns the scene's single loop,
/// gates it on [active] and reduced-motion, applies swipe parallax and keeps
/// repaints inside a boundary.
class OnboardingScene extends StatefulWidget {
  const OnboardingScene({
    super.key,
    required this.active,
    required this.drift,
    required this.painter,
    this.maxWidth = 360,
    this.aspectRatio = 3 / 2,
  });

  /// Whether the owning slide is the current PageView page — the loop runs
  /// only while true.
  final bool active;

  /// Live swipe distance −1..1; the card drifts against the swipe direction.
  final double drift;

  /// Builds the painter for loop value `t` (0..1; constant when reduced
  /// motion is on or the slide rests).
  final CustomPainter Function(double t) painter;

  final double maxWidth;
  final double aspectRatio;

  @override
  State<OnboardingScene> createState() => _OnboardingSceneState();
}

class _OnboardingSceneState extends State<OnboardingScene>
    with SingleTickerProviderStateMixin {
  /// Frame shown when motion is off (mid-twinkle, mid-glow — pleasant stills).
  static const _restT = 0.35;

  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
    value: _restT,
  );

  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    // Start/stop decisions live in didChangeDependencies — they depend on
    // MediaQuery (reduced motion), which cannot be read in initState.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    _sync();
  }

  @override
  void didUpdateWidget(OnboardingScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _sync();
  }

  void _sync() {
    if (widget.active && !_reducedMotion) {
      _loop.repeat();
    } else {
      _loop.stop(); // resting slides freeze on their last frame
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Transform.translate(
            // Parallax: slide against the swipe at a gentle fraction.
            offset: Offset(widget.drift * -26, 0),
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _loop,
                builder: (context, _) => CustomPaint(
                  size: Size.infinite,
                  painter: widget.painter(_loop.value),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mode-independent art palette pinned to the theme's fixed roles, so every
/// scene reads identically in light and dark mode: deep emerald skies, warm
/// gold light, cream paper, mint accents.
@immutable
class ScenePalette {
  const ScenePalette({
    required this.skyTop,
    required this.skyMid,
    required this.horizonGlow,
    required this.deep,
    required this.deeper,
    required this.gold,
    required this.goldSoft,
    required this.cream,
    required this.mint,
  });

  factory ScenePalette.of(ColorScheme scheme) {
    const black = Color(0xFF000000);
    final emerald = scheme.primaryContainer; // #064E3B light / #0F5744 dark
    final gold = scheme.tertiaryFixedDim; // E9C349
    final goldSoft = scheme.tertiaryFixed; // FFE088
    return ScenePalette(
      skyTop: Color.lerp(emerald, black, 0.55)!,
      skyMid: emerald,
      horizonGlow: Color.lerp(emerald, gold, 0.28)!,
      deep: Color.lerp(emerald, black, 0.62)!,
      deeper: Color.lerp(emerald, black, 0.74)!,
      gold: gold,
      goldSoft: goldSoft,
      cream: Color.lerp(const Color(0xFFFFFBF0), goldSoft, 0.38)!,
      mint: scheme.primaryFixedDim, // 95D3BA
    );
  }

  final Color skyTop;
  final Color skyMid;
  final Color horizonGlow;
  final Color deep;
  final Color deeper;
  final Color gold;
  final Color goldSoft;
  final Color cream;
  final Color mint;

  @override
  bool operator ==(Object other) =>
      other is ScenePalette &&
      other.skyTop == skyTop &&
      other.skyMid == skyMid &&
      other.horizonGlow == horizonGlow &&
      other.deep == deep &&
      other.deeper == deeper &&
      other.gold == gold &&
      other.goldSoft == goldSoft &&
      other.cream == cream &&
      other.mint == mint;

  @override
  int get hashCode => Object.hash(
        skyTop, skyMid, horizonGlow, deep, deeper, gold, goldSoft, cream, mint,
      );
}

/// Base for the four scenes: carries palette + loop time and repaints only
/// when either changes.
abstract class ScenePainter extends CustomPainter {
  ScenePainter(this.pal, this.t);

  final ScenePalette pal;
  final double t;

  @override
  bool shouldRepaint(covariant ScenePainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.pal != pal;
}

// ---------------------------------------------------------------------------
// Shared drawing helpers.
// ---------------------------------------------------------------------------

/// Rounded card covering the whole canvas.
RRect _panel(Size size) =>
    RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(28));

/// Vertical night-sky wash shared by every scene.
void _sky(Canvas canvas, Size size, ScenePalette c) {
  canvas.drawRRect(
    _panel(size),
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [c.skyTop, c.skyMid, c.horizonGlow],
        stops: const [0.0, 0.62, 1.0],
      ).createShader(Offset.zero & size),
  );
}

/// Soft radial glow (moon halo, lamp light…).
void _glow(Canvas canvas, Offset center, double radius, Color color) {
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.20), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius)),
  );
}

/// Four-point star sparkle whose brightness pulses with the loop.
void _star(Canvas canvas, Offset p, double r, double intensity, Color color) {
  if (intensity <= 0.02) return;
  _glow(canvas, p, r * 3.0, color.withValues(alpha: intensity * 0.5));
  final path = Path()
    ..moveTo(p.dx, p.dy - r)
    ..quadraticBezierTo(p.dx, p.dy, p.dx + r, p.dy)
    ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + r)
    ..quadraticBezierTo(p.dx, p.dy, p.dx - r, p.dy)
    ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - r)
    ..close();
  canvas.drawPath(path, Paint()..color = color.withValues(alpha: intensity));
  canvas.drawCircle(
    p,
    r * 0.30,
    Paint()..color = Colors.white.withValues(alpha: intensity * 0.9),
  );
}

/// Dashed guide ring drawn as arc segments (no PathEffect needed).
void _dashedCircle(Canvas canvas, Offset c, double radius, Paint paint) {
  const segments = 28;
  final sweep = 2 * math.pi / segments;
  for (var i = 0; i < segments; i += 2) {
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius),
      i * sweep,
      sweep * 0.62,
      false,
      paint,
    );
  }
}

/// Crescent = full disc minus an offset "bite" disc.
Path _crescent(Offset center, double r, Offset bite) => Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: center, radius: r)),
      Path()..addOval(Rect.fromCircle(center: bite, radius: r * 0.84)),
    );

/// Onion-dome silhouette rising from [baseY].
Path _dome(double cx, double baseY, double halfWidth, double height) {
  return Path()
    ..moveTo(cx - halfWidth, baseY)
    ..cubicTo(
      cx - halfWidth * 1.06, baseY - height * 0.50,
      cx - halfWidth * 0.52, baseY - height * 0.88,
      cx, baseY - height,
    )
    ..cubicTo(
      cx + halfWidth * 0.52, baseY - height * 0.88,
      cx + halfWidth * 1.06, baseY - height * 0.50,
      cx + halfWidth, baseY,
    )
    ..close();
}

/// Pointed-arch niche (doorway / window).
Path _arch(double cx, double baseY, double halfWidth, double height) {
  return Path()
    ..moveTo(cx - halfWidth, baseY)
    ..lineTo(cx - halfWidth, baseY - height + halfWidth)
    ..quadraticBezierTo(cx - halfWidth, baseY - height, cx, baseY - height)
    ..quadraticBezierTo(cx + halfWidth, baseY - height, cx + halfWidth,
        baseY - height + halfWidth)
    ..lineTo(cx + halfWidth, baseY)
    ..close();
}

/// Map-pin teardrop with its tip at [tip].
Path _pin(Offset tip, double r) {
  final head = Rect.fromCircle(center: Offset(tip.dx, tip.dy - r * 1.55), radius: r);
  return Path()
    ..addOval(head)
    ..moveTo(tip.dx, tip.dy)
    ..lineTo(tip.dx - r * 0.60, tip.dy - r * 1.02)
    ..lineTo(tip.dx + r * 0.60, tip.dy - r * 1.02)
    ..close();
}

/// Twinkle brightness 0..1 for a star with its own phase.
double _twinkle(double t, double phase) =>
    0.30 + 0.70 * (0.5 + 0.5 * math.sin(2 * math.pi * (t + phase)));

// ---------------------------------------------------------------------------
// Slide 1 — Selamat datang: night sky, crescent, twinkling stars and a
// mosque-dome skyline on the horizon. Main effect: twinkling stars.
// ---------------------------------------------------------------------------

class WelcomeSkyPainter extends ScenePainter {
  WelcomeSkyPainter(super.pal, super.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.clipRRect(_panel(size));

    _sky(canvas, size, pal);

    // Crescent moon, upper right, with a quiet halo.
    const moonCenter = Offset(0.76, 0.27);
    final mr = h * 0.115;
    _glow(canvas, Offset(w * moonCenter.dx, h * moonCenter.dy), mr * 2.6,
        pal.gold.withValues(alpha: 0.55));
    canvas.drawPath(
      _crescent(
        Offset(w * moonCenter.dx, h * moonCenter.dy),
        mr,
        Offset(w * moonCenter.dx - mr * 0.42, h * moonCenter.dy - mr * 0.34),
      ),
      Paint()..color = pal.gold,
    );

    // Seven stars, each on its own twinkle phase.
    const stars = [
      (0.12, 0.24, 4.6, 0.00),
      (0.28, 0.36, 3.2, 0.50),
      (0.47, 0.16, 3.8, 1.00),
      (0.60, 0.44, 2.7, 1.50),
      (0.87, 0.55, 4.2, 0.80),
      (0.33, 0.60, 2.4, 2.20),
      (0.05, 0.48, 2.6, 2.80),
    ];
    for (final (fx, fy, r, phase) in stars) {
      _star(
        canvas,
        Offset(w * fx, h * fy),
        r,
        _twinkle(t, phase),
        fx > 0.6 ? pal.goldSoft : Colors.white,
      );
    }

    // Mosque-dome skyline resting on the horizon.
    final hy = h * 0.79;
    final cx = w * 0.5;
    final ink = Paint()..color = pal.deep;

    // Side structures.
    canvas.drawPath(_dome(cx - w * 0.215, hy, w * 0.055, h * 0.11), ink);
    canvas.drawPath(_dome(cx + w * 0.215, hy, w * 0.055, h * 0.11), ink);
    canvas.drawRect(
      Rect.fromLTRB(cx - w * 0.30, hy - h * 0.035, cx + w * 0.30, hy),
      ink,
    );

    // Central dome + drum + finial.
    canvas.drawRect(
      Rect.fromLTRB(cx - w * 0.075, hy - h * 0.045, cx + w * 0.075, hy),
      ink,
    );
    canvas.drawPath(_dome(cx, hy - h * 0.04, w * 0.115, h * 0.235), ink);
    canvas.drawRect(
      Rect.fromLTWH(cx - 1.4, hy - h * 0.315, 2.8, h * 0.045),
      ink,
    );
    canvas.drawCircle(Offset(cx, hy - h * 0.325), 3.0, ink);

    // Warm doorway + windows glowing in the silhouette.
    final lit = Paint()..color = pal.gold.withValues(alpha: 0.85);
    canvas.drawPath(_arch(cx, hy, w * 0.022, h * 0.075), lit);
    canvas.drawPath(_arch(cx - w * 0.145, hy, w * 0.013, h * 0.045), lit);
    canvas.drawPath(_arch(cx + w * 0.145, hy, w * 0.013, h * 0.045), lit);

    // Ground band closes the scene.
    canvas.drawRect(Rect.fromLTRB(0, hy, w, h), Paint()..color = pal.deeper);
  }
}

// ---------------------------------------------------------------------------
// Slide 2 — Al-Qur'an: open mushaf with layered pages, arched text lines and
// a soft light sweeping across the paper. Main effect: glow sweep.
// ---------------------------------------------------------------------------

class MushafGlowPainter extends ScenePainter {
  MushafGlowPainter(super.pal, super.t);

  /// One curved page of the open book. [dir] −1 = left, +1 = right.
  Path _page(
    double spineX,
    double dir,
    double topY,
    double botY,
    double halfW,
    double dip,
  ) {
    final ox = spineX + dir * halfW;
    return Path()
      ..moveTo(spineX, topY + dip)
      ..quadraticBezierTo(
          spineX + dir * halfW * 0.48, topY - dip * 0.18, ox, topY)
      ..lineTo(ox, botY)
      ..quadraticBezierTo(
          spineX + dir * halfW * 0.44, botY + dip * 0.72, spineX, botY + dip)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.clipRRect(_panel(size));

    _sky(canvas, size, pal);

    final cx = w * 0.5;
    final halfW = w * 0.335;
    final topY = h * 0.42;
    final botY = h * 0.76;
    final dip = h * 0.045;

    // Ambient lamp-light pooling above the book (static part of the glow).
    _glow(canvas, Offset(cx, topY - h * 0.10), halfW * 1.25, pal.gold);

    // Book shadow on the "table".
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, botY + dip + h * 0.045),
        width: halfW * 1.7,
        height: h * 0.05,
      ),
      Paint()..color = pal.deeper.withValues(alpha: 0.55),
    );

    final left = _page(cx, -1, topY, botY, halfW, dip);
    final right = _page(cx, 1, topY, botY, halfW, dip);

    // Stacked under-pages give the mushaf some depth.
    for (final (lift, tone) in [(9.0, 0.22), (4.5, 0.11)]) {
      final shade = Paint()
        ..color = Color.lerp(pal.cream, pal.deeper, tone)!;
      canvas.drawPath(left.shift(const Offset(0, 1) * lift), shade);
      canvas.drawPath(right.shift(const Offset(0, 1) * lift), shade);
    }

    // The two open pages.
    final pageFill = Paint()..color = pal.cream;
    canvas.drawPath(left, pageFill);
    canvas.drawPath(right, pageFill);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Color.lerp(pal.gold, pal.deeper, 0.45)!.withValues(alpha: 0.8);
    canvas.drawPath(left, edge);
    canvas.drawPath(right, edge);

    // Gutter shadow down the spine.
    canvas.drawRect(
      Rect.fromLTRB(cx - 7, topY - 6, cx + 7, botY + dip * 2 + 6),
      Paint()
        ..shader = LinearGradient(
          colors: [
            pal.deeper.withValues(alpha: 0.0),
            pal.deeper.withValues(alpha: 0.28),
            pal.deeper.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTRB(cx - 7, topY, cx + 7, botY)),
    );

    // Arched text lines following the page curvature.
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2
      ..color = pal.skyMid.withValues(alpha: 0.42);
    final pad = (botY - topY) * 0.17;
    final markY = botY - pad + 6;
    for (final dir in [-1.0, 1.0]) {
      final step = (botY - topY - pad * 2) / 3;
      for (var i = 0; i < 3; i++) {
        final y = topY + pad + step * i;
        final path = Path()
          ..moveTo(cx + dir * halfW * 0.82, y)
          ..quadraticBezierTo(cx + dir * halfW * 0.48, y - dip * 0.55,
              cx + dir * halfW * 0.16, y - dip * 0.18);
        canvas.drawPath(path, line);
      }
    }
    // Small gold ayah-mark diamonds closing each page's last line.
    final mark = Paint()..color = pal.gold;
    for (final dir in [-1.0, 1.0]) {
      final mx = cx + dir * halfW * 0.30;
      canvas.drawPath(
        Path()
          ..moveTo(mx, markY - 4)
          ..lineTo(mx - 4, markY)
          ..lineTo(mx, markY + 4)
          ..lineTo(mx + 4, markY)
          ..close(),
        mark,
      );
    }

    // MAIN EFFECT — a soft band of light sweeping back and forth across the
    // open pages (clipped to the paper so it never spills).
    final k = t < 0.5 ? t * 2 : (1 - t) * 2; // ping-pong 0..1..0
    final eased = Curves.easeInOut.transform(k);
    final sweepX = cx + (eased * 2 - 1) * halfW * 1.15;
    canvas.save();
    canvas.clipPath(Path.combine(PathOperation.union, left, right));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(sweepX - 26, topY - 30, 52, botY - topY + 60),
        const Radius.circular(26),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [
            pal.goldSoft.withValues(alpha: 0.0),
            pal.goldSoft.withValues(alpha: 0.32),
            pal.goldSoft.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(sweepX - 26, topY - 30, 52, botY - topY + 60)),
    );
    canvas.restore();
  }
}

// ---------------------------------------------------------------------------
// Slide 3 — Kalender Hijriah: a large golden crescent, twinkling stars and a
// tilted calendar card. Main effect: twinkling stars.
// ---------------------------------------------------------------------------

class HijriCalendarPainter extends ScenePainter {
  HijriCalendarPainter(super.pal, super.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.clipRRect(_panel(size));

    _sky(canvas, size, pal);

    // Large crescent opening to the upper right.
    final cc = Offset(w * 0.32, h * 0.42);
    final cr = h * 0.27;
    _glow(canvas, cc, cr * 2.1, pal.gold.withValues(alpha: 0.5));
    canvas.drawPath(
      _crescent(cc, cr, Offset(cc.dx + cr * 0.46, cc.dy - cr * 0.30)),
      Paint()..color = pal.gold,
    );

    // Five companion stars.
    const stars = [
      (0.56, 0.15, 3.4, 0.20),
      (0.70, 0.24, 2.7, 0.90),
      (0.85, 0.17, 4.4, 0.50),
      (0.91, 0.42, 3.0, 1.40),
      (0.49, 0.30, 2.4, 1.90),
    ];
    for (final (fx, fy, r, phase) in stars) {
      _star(canvas, Offset(w * fx, h * fy), r, _twinkle(t, phase),
          Colors.white);
    }

    // Calendar card, gently tilted, overlapping the crescent.
    final center = Offset(w * 0.67, h * 0.57);
    final cw = w * 0.34;
    final ch = h * 0.54;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.087);

    // Drop shadow.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: const Offset(3, 6),
          width: cw,
          height: ch,
        ),
        const Radius.circular(12),
      ),
      Paint()
        ..color = pal.deeper.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Body + header.
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: cw, height: ch),
      const Radius.circular(12),
    );
    canvas.drawRRect(body, Paint()..color = pal.cream);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(-cw / 2, -ch / 2, cw, ch * 0.24),
        topLeft: const Radius.circular(12),
        topRight: const Radius.circular(12),
      ),
      Paint()..color = pal.skyMid,
    );
    canvas.drawLine(
      Offset(-cw / 2, -ch / 2 + ch * 0.24),
      Offset(cw / 2, -ch / 2 + ch * 0.24),
      Paint()
        ..color = pal.gold
        ..strokeWidth = 1.6,
    );

    // Mini crescent + date bars in the header.
    final hc = Offset(-cw / 2 + 14, -ch / 2 + ch * 0.12);
    canvas.drawPath(
      _crescent(hc, 6.5, Offset(hc.dx + 3.4, hc.dy - 2.2)),
      Paint()..color = pal.goldSoft,
    );
    final bar = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(hc.dx + 14, hc.dy - 5, cw * 0.30, 4),
        const Radius.circular(2),
      ),
      bar,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(hc.dx + 14, hc.dy + 1, cw * 0.18, 4),
        const Radius.circular(2),
      ),
      Paint()..color = pal.goldSoft.withValues(alpha: 0.9),
    );

    // Day-dot grid; one highlighted "today".
    final gridTop = -ch / 2 + ch * 0.34;
    final cols = 4;
    final rows = 3;
    final cellW = (cw - 24) / cols;
    final cellH = (ch * 0.56) / rows;
    for (var rI = 0; rI < rows; rI++) {
      for (var cI = 0; cI < cols; cI++) {
        final p = Offset(
          -cw / 2 + 12 + cellW * (cI + 0.5),
          gridTop + cellH * (rI + 0.5),
        );
        final isToday = rI == 0 && cI == 2;
        if (isToday) {
          canvas.drawCircle(
            p,
            6.5,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = pal.gold,
          );
          canvas.drawCircle(p, 3, Paint()..color = pal.gold);
        } else {
          canvas.drawCircle(
            p,
            2.8,
            Paint()..color = pal.skyMid.withValues(alpha: 0.38),
          );
        }
      }
    }
    canvas.restore();
  }
}

// ---------------------------------------------------------------------------
// Slide 4 — Temukan Masjid: mosque silhouette (dome + two minarets) under an
// expanding-fading radar pulse and a location pin. Main effect: radar pulse.
// ---------------------------------------------------------------------------

class MosqueRadarPainter extends ScenePainter {
  MosqueRadarPainter(super.pal, super.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.clipRRect(_panel(size));

    _sky(canvas, size, pal);

    final cx = w * 0.5;
    final gy = h * 0.80; // ground line

    // Radar origin floats above the dome apex.
    final radarCenter = Offset(cx, h * 0.30);

    // Static dashed guide ring gives the radar its instrument feel.
    _dashedCircle(
      canvas,
      radarCenter,
      h * 0.24,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.14),
    );

    // MAIN EFFECT — one pulse ring expanding and fading, looping forever.
    final pr = h * 0.07 + (h * 0.37) * t;
    canvas.drawCircle(
      radarCenter,
      pr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = pal.mint.withValues(alpha: (1 - t) * 0.55),
    );
    canvas.drawCircle(
      radarCenter,
      pr,
      Paint()..color = pal.mint.withValues(alpha: (1 - t) * 0.05),
    );

    // Location pin hovering at the radar origin.
    final tip = radarCenter + const Offset(0, 14);
    canvas.drawPath(_pin(tip, h * 0.052), Paint()..color = pal.gold);
    canvas.drawCircle(
      Offset(tip.dx, tip.dy - h * 0.052 * 1.55),
      h * 0.052 * 0.38,
      Paint()..color = pal.deeper,
    );

    // Ground band.
    canvas.drawRect(Rect.fromLTRB(0, gy, w, h), Paint()..color = pal.deeper);

    final ink = Paint()..color = pal.deep;

    // Base wall.
    canvas.drawRect(
      Rect.fromLTRB(cx - w * 0.29, gy - h * 0.085, cx + w * 0.29, gy + h * 0.02),
      ink,
    );

    // Central dome on its drum, with finial.
    canvas.drawRect(
      Rect.fromLTRB(cx - w * 0.085, gy - h * 0.105, cx + w * 0.085, gy - h * 0.06),
      ink,
    );
    canvas.drawPath(_dome(cx, gy - h * 0.095, w * 0.125, h * 0.225), ink);
    canvas.drawRect(
      Rect.fromLTWH(cx - 1.4, gy - h * 0.355, 2.8, h * 0.04),
      ink,
    );
    canvas.drawCircle(Offset(cx, gy - h * 0.365), 3.0, ink);

    // Two minarets: shafts, balconies, caps, finials.
    for (final dir in [-1.0, 1.0]) {
      final mx = cx + dir * w * 0.245;
      final mw = w * 0.020;
      canvas.drawRect(
        Rect.fromLTRB(mx - mw, gy - h * 0.30, mx + mw, gy + h * 0.02),
        ink,
      );
      canvas.drawRect(
        Rect.fromLTRB(mx - mw * 1.7, gy - h * 0.185, mx + mw * 1.7, gy - h * 0.165),
        ink,
      );
      canvas.drawPath(_dome(mx, gy - h * 0.30, mw * 1.5, h * 0.055), ink);
      canvas.drawRect(
        Rect.fromLTWH(mx - 1, gy - h * 0.375, 2, h * 0.025),
        ink,
      );
      canvas.drawCircle(Offset(mx, gy - h * 0.382), 2.2, ink);
    }

    // Lit openings: doorway, wall windows, minaret slits.
    final lit = Paint()..color = pal.gold.withValues(alpha: 0.85);
    canvas.drawPath(_arch(cx, gy + h * 0.01, w * 0.022, h * 0.065), lit);
    canvas.drawPath(_arch(cx - w * 0.19, gy, w * 0.013, h * 0.04), lit);
    canvas.drawPath(_arch(cx + w * 0.19, gy, w * 0.013, h * 0.04), lit);
    for (final dir in [-1.0, 1.0]) {
      final mx = cx + dir * w * 0.245;
      canvas.drawRect(
        Rect.fromLTWH(mx - 1.6, gy - h * 0.255, 3.2, h * 0.045),
        lit,
      );
    }
  }
}
