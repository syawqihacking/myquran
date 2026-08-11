import 'dart:async';

import 'package:flutter/foundation.dart' show immutable;

/// Phase-2 audio seam. The reader only ever talks to this interface — phase 2
/// swaps `NoopAudioService` for a real implementation (download/caching stays
/// inside the service) without any reader refactor.
enum AudioStatus { idle, buffering, playing, paused }

@immutable
class AudioPlaybackState {
  const AudioPlaybackState({
    this.status = AudioStatus.idle,
    this.ayahId,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  const AudioPlaybackState.idle()
      : this(status: AudioStatus.idle, ayahId: null);

  final AudioStatus status;
  final int? ayahId;
  final Duration position;
  final Duration duration;

  bool get isIdle => status == AudioStatus.idle || status == AudioStatus.paused;
}

abstract class AudioService {
  Stream<AudioPlaybackState> get stateStream;

  Future<void> playAyah(int ayahId);

  Future<void> playSurahFrom(int surahId, int ayahId);

  Future<void> pause();

  Future<void> resume();

  Future<void> stop();

  void dispose();
}

/// MVP implementation: emits `idle` forever.
class NoopAudioService implements AudioService {
  NoopAudioService() {
    _controller.add(const AudioPlaybackState.idle());
  }

  final StreamController<AudioPlaybackState> _controller =
      StreamController<AudioPlaybackState>.broadcast();

  @override
  Stream<AudioPlaybackState> get stateStream => _controller.stream;

  @override
  Future<void> playAyah(int ayahId) async {}

  @override
  Future<void> playSurahFrom(int surahId, int ayahId) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> stop() async {}

  @override
  void dispose() => _controller.close();
}
