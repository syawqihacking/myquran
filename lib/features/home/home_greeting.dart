import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../l10n/app_localizations.dart';
import '../../data/providers.dart';

/// Time-of-day video background greeting.
///
/// Shows a muted looping video that matches the current time of day (pagi /
/// siang / sore / malam) behind the "Assalamu'alaikum," + name text. The
/// video plays at near-full visibility (0.9) so the animation is clearly
/// seen, with a multi-stop gradient overlay and text shadows ensuring the
/// greeting text stays readable over any scene.
///
/// A single-shot [Timer] is scheduled for each time boundary (05, 12, 17, 19)
/// so the video switches automatically when the hour window changes — no
/// restart needed.
///
/// Falls back to a silent gradient when the video player is not supported
/// (e.g. Linux desktop) or the asset fails to load — the greeting never
/// breaks.
class Greeting extends ConsumerStatefulWidget {
  const Greeting({super.key});

  @override
  ConsumerState<Greeting> createState() => _GreetingState();
}

class _GreetingState extends ConsumerState<Greeting> {
  VideoPlayerController? _controller;
  Future<void>? _initialized;
  bool _videoError = false;
  String? _currentAsset;
  Timer? _timer;

  /// Time-of-day boundaries that trigger a video switch.
  static const _boundaries = [5, 12, 17, 19];

  @override
  void initState() {
    super.initState();
    _currentAsset = _assetForTimeOfDay();
    _initVideo();
  }

  // ── Video lifecycle ──────────────────────────────────────────────────────

  /// Creates a new [VideoPlayerController] for [_currentAsset], initialises it
  /// muted + looping, starts playback, and schedules the next boundary check.
  /// Any error silently sets [_videoError] so the UI falls back to a gradient.
  void _initVideo() {
    try {
      _controller = VideoPlayerController.asset(_currentAsset!);
      _initialized = _controller!.initialize().then((_) {
        if (!mounted) return;
        _controller!.setLooping(true);
        _controller!.setVolume(0);
        _controller!.play();
        _scheduleNextCheck();
      }).catchError((_) {
        if (mounted) {
          setState(() => _videoError = true);
          _scheduleNextCheck();
        }
      });
    } catch (_) {
      _videoError = true;
      _scheduleNextCheck();
    }
  }

  /// Returns the asset path for the current hour window.
  String _assetForTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'assets/animasi/Islamic_morning_animation_loopin…_202609021746.mp4';
    }
    if (hour >= 12 && hour < 17) {
      return 'assets/animasi/Edit_video_time_of_day_202609021752.mp4';
    }
    if (hour >= 17 && hour < 19) {
      return 'assets/animasi/Editing_video_sunset_atmosphere_202609021756.mp4';
    }
    return 'assets/animasi/Transform_video_into_night_scene_202609021758.mp4';
  }

  // ── Boundary scheduling ──────────────────────────────────────────────────

  /// Calculates the [Duration] until the next time boundary (5, 12, 17, or 19).
  /// If all boundaries have passed today, returns the duration until 05:00
  /// tomorrow.
  Duration _untilNextBoundary() {
    final now = DateTime.now();
    for (final h in _boundaries) {
      if (now.hour < h) {
        return DateTime(now.year, now.month, now.day, h).difference(now);
      }
    }
    // Past midnight → next boundary is 05:00 tomorrow.
    return DateTime(now.year, now.month, now.day + 1, 5).difference(now);
  }

  /// Schedules a single-shot [Timer] that fires at the next time boundary.
  /// Cancels any previously scheduled timer first.
  void _scheduleNextCheck() {
    _timer?.cancel();
    _timer = Timer(_untilNextBoundary(), _onTimeBoundaryReached);
  }

  /// Called when the scheduled timer fires at a time boundary.
  ///
  /// If the video asset for the current hour differs from the one playing, it
  /// swaps the player. Otherwise it simply re-schedules for the next boundary.
  void _onTimeBoundaryReached() {
    if (!mounted) return;
    if (_videoError) {
      _scheduleNextCheck();
      return;
    }
    final next = _assetForTimeOfDay();
    if (next != _currentAsset) {
      _currentAsset = next;
      _controller?.dispose();
      _controller = null;
      // Show the fallback gradient briefly while the new video loads.
      setState(() {});
      _initVideo();
    } else {
      _scheduleNextCheck();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final name = ref.watch(profileNameProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            // Video background — or fallback gradient when unsupported.
            if (_videoError || _controller == null)
              Container(color: scheme.surfaceContainerLow)
            else
              FutureBuilder<void>(
                future: _initialized,
                builder: (context, snapshot) {
                  final ready =
                      snapshot.connectionState == ConnectionState.done;
                  if (!ready) {
                    return Container(
                      color: scheme.surfaceContainerLow,
                    );
                  }
                  return Opacity(
                    opacity: 0.9,
                    child: VideoPlayer(_controller!),
                  );
                },
              ),
            // Gradient overlay — darkens the bottom so the text lifts off
            // the video cleanly, with a mid-stop to ease the transition.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      scheme.surface.withValues(alpha: 0.85),
                      scheme.surface.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            // Greeting text, anchored to the bottom-left of the card.
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeGreeting,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                      shadows: const [
                        Shadow(color: Colors.black45, blurRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 24,
                      height: 32 / 24,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                      shadows: const [
                        Shadow(color: Colors.black45, blurRadius: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}