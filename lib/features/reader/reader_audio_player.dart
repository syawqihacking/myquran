import 'package:flutter/material.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/services/audio_service.dart';
import '../widgets/liquid_glass.dart';

/// 4px progress line with a 12px thumb at the fill edge (Stitch §6). Read-only
/// for now: the thumb just tracks position (Noop stays at 0, so it sits at
/// the start).
class _PlayerProgressBar extends StatelessWidget {
  const _PlayerProgressBar({
    required this.progress,
    required this.fill,
    required this.track,
    required this.thumb,
  });

  final double progress;
  final Color fill;
  final Color track;
  final Color thumb;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final fillWidth = width * progress;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: Container(color: track)),
              AnimatedContainer(
                duration: AppLayout.durBase,
                curve: Curves.easeOut,
                width: fillWidth,
                height: 4,
                color: fill,
              ),
              AnimatedPositioned(
                duration: AppLayout.durBase,
                curve: Curves.easeOut,
                left: (fillWidth - 6).clamp(0.0, width - 6),
                top: -4,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: thumb,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The 56px primary play/pause circle (Stitch §6), with a buffering spinner.
class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.status, required this.onPressed});

  final AudioStatus status;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final buffering = status == AudioStatus.buffering;
    final playing = status == AudioStatus.playing;
    return Tooltip(
      message: playing || buffering ? S.audioPause : S.audioPlay,
      child: Material(
        color: scheme.primary,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Center(
              child: buffering
                  ? SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: scheme.onPrimary,
                      ),
                    )
                  : Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 32,
                      color: scheme.onPrimary,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small circular icon button for the player's transport/option rows.
class _PlayerIconButton extends StatelessWidget {
  const _PlayerIconButton({
    required this.icon,
    required this.size,
    required this.tooltip,
    required this.onPressed,
    this.boxSize = 40,
  });

  final IconData icon;
  final double size;
  final String tooltip;
  final VoidCallback onPressed;
  final double boxSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        foregroundColor: scheme.onSurfaceVariant,
        hoverColor: scheme.surfaceContainerHighest,
        fixedSize: Size.square(boxSize),
        padding: EdgeInsets.zero,
      ),
      icon: Icon(icon, size: size),
    );
  }
}

/// Sticky audio player (Stitch §6): 1px progress line + reciter / transport /
/// options row. Read-only progress — AudioService has no seek API yet.
class ReaderAudioPlayer extends StatelessWidget {
  const ReaderAudioPlayer({
    super.key,
    required this.state,
    required this.surahName,
    required this.ayahNumber,
    required this.speed,
    required this.reciterName,
    required this.onTogglePlayPause,
    required this.onPrev,
    required this.onNext,
    required this.onCycleSpeed,
    required this.onVolume,
    required this.onQueue,
    required this.onClose,
  });

  final AudioPlaybackState state;
  final String surahName;
  final int ayahNumber;
  final double speed;
  final String reciterName;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onCycleSpeed;
  final VoidCallback onVolume;
  final VoidCallback onQueue;
  final VoidCallback onClose;

  String get _speedLabel =>
      speed == 1.25 ? '1.25x' : '${speed.toStringAsFixed(1)}x';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    final durationMs = state.duration.inMilliseconds;
    final progress = durationMs > 0
        ? (state.position.inMilliseconds / durationMs).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: LiquidGlassLens(
        style: glassChromeStyle(context),
        useImpellerBackdrop: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              _PlayerProgressBar(
                progress: progress,
                fill: scheme.primary,
                track: scheme.surfaceContainerHighest,
                thumb: scheme.tertiaryFixedDim,
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.contentColumnMaxWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppLayout.sp5,
                      vertical: AppLayout.sp4,
                    ),
                    child: Row(
                      children: [
                        // Reciter info — text collapses to the avatar on mobile.
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(
                                    AppLayout.radiusMd,
                                  ),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 24,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              if (!isMobile) ...[
                                const SizedBox(width: AppLayout.sp3),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reciterName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        S.audioCaption(
                                          surahName,
                                          ayahNumber,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          height: 14 / 10,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Transport controls.
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GlassTouchButton(
                              radius: AppLayout.radiusFull,
                              child: _PlayerIconButton(
                                icon: Icons.skip_previous_rounded,
                                size: 28,
                                boxSize: isMobile ? 36 : 40,
                                tooltip: S.audioPrev,
                                onPressed: onPrev,
                              ),
                            ),
                            const SizedBox(width: AppLayout.sp1),
                            GlassTouchButton(
                              radius: AppLayout.radiusFull,
                              child: _PlayPauseButton(
                                status: state.status,
                                onPressed: onTogglePlayPause,
                              ),
                            ),
                            const SizedBox(width: AppLayout.sp1),
                            GlassTouchButton(
                              radius: AppLayout.radiusFull,
                              child: _PlayerIconButton(
                                icon: Icons.skip_next_rounded,
                                size: 28,
                                boxSize: isMobile ? 36 : 40,
                                tooltip: S.audioNext,
                                onPressed: onNext,
                              ),
                            ),
                          ],
                        ),
                        // Options — speed label is desktop-only per the design,
                        // and the volume placeholder is omitted on mobile to
                        // keep the row from overflowing narrow screens.
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isMobile) ...[
                              LiquidGlassCapsule(
                                onTap: onCycleSpeed,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppLayout.sp3,
                                  vertical: AppLayout.sp1 + 2,
                                ),
                                child: Text(
                                  _speedLabel,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppLayout.sp1),
                              GlassTouchButton(
                                radius: AppLayout.radiusFull,
                                child: _PlayerIconButton(
                                  icon: Icons.volume_up_rounded,
                                  size: 24,
                                  tooltip: S.audioVolume,
                                  onPressed: onVolume,
                                ),
                              ),
                            ],
                            GlassTouchButton(
                              radius: AppLayout.radiusFull,
                              child: _PlayerIconButton(
                                icon: Icons.queue_music_rounded,
                                size: 24,
                                boxSize: isMobile ? 36 : 40,
                                tooltip: S.audioQueue,
                                onPressed: onQueue,
                              ),
                            ),
                            GlassTouchButton(
                              radius: AppLayout.radiusFull,
                              child: _PlayerIconButton(
                                icon: Icons.close_rounded,
                                size: 20,
                                boxSize: isMobile ? 36 : 40,
                                tooltip: S.audioClose,
                                onPressed: onClose,
                              ),
                            ),
                          ],
                        ),
                      ],
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
