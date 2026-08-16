import 'dart:async';

import 'package:just_audio/just_audio.dart';

import 'audio_service.dart';

/// Primary Ratib Al-Haddad recitation source (streamed, no caching).
const kRatibPrimaryUrl =
    'https://archive.org/download/ratib-alhaddad-by-habib-ahmad-bin-syueb-alhasany-128k/Ratib_Alhaddad_(by_Habib_Ahmad_bin_Syueb_Alhasany)(128k).m4a';

/// Documented fallback Ratib Al-Haddad source, tried when the primary URL
/// fails to load.
const kRatibFallbackUrl =
    'https://archive.org/download/RatibulHaddaadFullVersionByCehuigraphics.com/Ratibul%20Haddaad%20Full%20Version_by%20cehuigraphics.com.mp3';

/// Dedicated Ratib Al-Haddad audio service backed by `just_audio` (+ media_kit
/// on Linux/Windows).
///
/// Plays a single continuous Ratib Al-Haddad audio file by streaming it — no
/// caching, no ayah tagging, no repository/template dependencies. Kept
/// entirely separate from the Quran `JustAudioService` so the two playback
/// paths never interfere.
///
/// URL strategy:
///  1. [kRatibPrimaryUrl];
///  2. [kRatibFallbackUrl], tried (with a timeout) when the primary fails to
///     load — mirroring the Quran service's fallback resilience pattern.
class RatibAudioService {
  RatibAudioService({AudioPlayer? player})
      : _player = player ?? AudioPlayer() {
    // Combine every just_audio signal into the single seam state stream.
    // Streams are re-read synchronously in [_emit] so each event (status,
    // position, duration) produces an up-to-date snapshot promptly.
    _player.playerStateStream.listen((_) => _emit());
    _player.positionStream.listen((_) => _emit());
    _player.durationStream.listen((_) => _emit());
    _emit(status: AudioStatus.idle);
  }

  /// Upper bound for loading one URL before trying the fallback. just_audio's
  /// media_kit backend can hang (instead of throwing) when a URL fails to
  /// open, so the fallback needs a timeout to be reliable.
  static const _sourceLoadTimeout = Duration(seconds: 20);

  final AudioPlayer _player;
  bool _disposed = false;

  final StreamController<AudioPlaybackState> _controller =
      StreamController<AudioPlaybackState>.broadcast(sync: true);

  Stream<AudioPlaybackState> get stateStream => _controller.stream;

  /// Starts (or restarts) the ratib from the beginning, or resumes when it is
  /// currently paused. Tries the primary URL first, falling back to the
  /// fallback URL on load failure.
  Future<void> play() async {
    // Flip off idle immediately so the UI's play button leaves idle right away.
    _emit(status: AudioStatus.buffering);

    for (final url in [kRatibPrimaryUrl, kRatibFallbackUrl]) {
      try {
        await _player
            .setAudioSource(AudioSource.uri(Uri.parse(url)), preload: true)
            .timeout(_sourceLoadTimeout);
        await _player.play();
        _emit();
        return;
      } catch (_) {
        // Try the fallback URL, then give up.
      }
    }
    _emit(status: AudioStatus.idle);
  }

  Future<void> pause() async {
    await _player.pause();
    _emit();
  }

  Future<void> resume() async {
    await _player.play();
    _emit();
  }

  Future<void> stop() async {
    await _player.stop();
    _emit(status: AudioStatus.idle);
  }

  void dispose() {
    _disposed = true;
    unawaited(_player.dispose());
    _controller.close();
  }

  // ---- Internals ----------------------------------------------------------

  AudioStatus _statusFromPlayer() {
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioStatus.idle;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        return AudioStatus.buffering;
      case ProcessingState.ready:
        return _player.playing ? AudioStatus.playing : AudioStatus.paused;
      case ProcessingState.completed:
        // Completed → idle so the play button resets when the ratib finishes.
        return AudioStatus.idle;
    }
  }

  void _emit({AudioStatus? status}) {
    if (_disposed) return;
    _controller.add(AudioPlaybackState(
      status: status ?? _statusFromPlayer(),
      position: _player.position,
      duration: _player.duration ?? Duration.zero,
    ));
  }
}
