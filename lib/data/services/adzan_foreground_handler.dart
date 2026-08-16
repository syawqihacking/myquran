import 'dart:convert';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:just_audio/just_audio.dart';

/// Entry point for the foreground task's background isolate. Must be a
/// top-level `@pragma('vm:entry-point')` function so the isolate can invoke it
/// without the main isolate's Dart code being tree-shaken away.
@pragma('vm:entry-point')
void adzanTaskCallback() {
  FlutterForegroundTask.setTaskHandler(AdzanTaskHandler());
}

/// Plays the full adzan at prayer times from the foreground service's
/// background isolate.
///
/// The handler reads the voice paths (regular + fajr) and the daily schedule
/// (stored as a JSON string) via [FlutterForegroundTask.getData], which is
/// backed by shared_preferences and works in the background isolate. On every
/// [onRepeatEvent] it re-reads the data so daily schedule changes are picked
/// up, and plays the adzan when the current time matches a prayer's
/// hour:minute (guarded against double-play per day). Entries flagged `fajr`
/// play the fajr voice; all others play the regular voice.
class AdzanTaskHandler extends TaskHandler {
  AudioPlayer? _player;

  /// Key of the last prayer played today, e.g. "2026-08-16:2". Guards against
  /// playing the same prayer twice on the same day.
  String _lastPlayedKey = '';

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _player = AudioPlayer();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _checkAndPlay();
  }

  @override
  void onReceiveData(Object data) {
    _checkAndPlay();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _player?.dispose();
    _player = null;
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'stop') {
      FlutterForegroundTask.stopService();
    }
  }

  /// Re-reads the schedule + voice paths and plays the adzan if a prayer time
  /// has just arrived. Never throws: a failure must not crash the isolate.
  Future<void> _checkAndPlay() async {
    try {
      final path = await FlutterForegroundTask.getData<String>(
        key: 'adzan_voice_path',
      );
      final fajrPath = await FlutterForegroundTask.getData<String>(
        key: 'adzan_fajr_voice_path',
      );
      final scheduleJson = await FlutterForegroundTask.getData<String>(
        key: 'adzan_schedule',
      );
      if (path == null || scheduleJson == null) return;

      final decoded = jsonDecode(scheduleJson);
      if (decoded is! List) return;

      final now = DateTime.now();
      final todayKey = '${now.year}-${now.month}-${now.day}';

      for (var i = 0; i < decoded.length; i++) {
        final entry = decoded[i];
        if (entry is! Map) continue;
        final hh = entry['hh'];
        final mm = entry['mm'];
        if (hh is! int || mm is! int) continue;

        // Play when the current time is within the same minute as the prayer.
        if (now.hour == hh && now.minute == mm) {
          final key = '$todayKey:$i';
          if (_lastPlayedKey == key) return; // already played today
          _lastPlayedKey = key;
          // Fajr entries use the fajr voice; fall back to the regular voice
          // when the fajr path is missing.
          final isFajr = entry['fajr'] == true;
          final playPath = isFajr && fajrPath != null ? fajrPath : path;
          _playAdzan(playPath);
          return;
        }
      }
    } catch (_) {
      // Ignore: never crash the isolate on bad data or playback failure.
    }
  }

  Future<void> _playAdzan(String path) async {
    try {
      final player = _player ??= AudioPlayer();
      await player.setFilePath(path);
      await player.play();
    } catch (_) {
      // Ignore: a playback failure must not crash the isolate.
    }
  }
}
