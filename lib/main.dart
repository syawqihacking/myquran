import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'dart:io';

import 'app.dart';
import 'core/app_constants.dart';
import 'data/providers.dart';

/// Registers the Indonesian locale for the `hijri` package (it only ships
/// `en`/`ar`/`tr`). Day keys follow Dart's `DateTime.weekday` (1=Senin..7=Ahad).
void _registerHijriLocale() {
  HijriCalendar.addLocale('id', {
    'long': {
      1: 'Muharram',
      2: 'Safar',
      3: 'Rabiul Awal',
      4: 'Rabiul Akhir',
      5: 'Jumadil Awal',
      6: 'Jumadil Akhir',
      7: 'Rajab',
      8: 'Syaban',
      9: 'Ramadan',
      10: 'Syawal',
      11: 'Zulkaidah',
      12: 'Zulhijah',
    },
    'short': {
      1: 'Muharram',
      2: 'Safar',
      3: 'Rabiul Awal',
      4: 'Rabiul Akhir',
      5: 'Jumadil Awal',
      6: 'Jumadil Akhir',
      7: 'Rajab',
      8: 'Syaban',
      9: 'Ramadan',
      10: 'Syawal',
      11: 'Zulkaidah',
      12: 'Zulhijah',
    },
    'days': {
      1: 'Senin',
      2: 'Selasa',
      3: 'Rabu',
      4: 'Kamis',
      5: 'Jumat',
      6: 'Sabtu',
      7: 'Ahad',
    },
    'short_days': {
      1: 'Sen',
      2: 'Sel',
      3: 'Rab',
      4: 'Kam',
      5: 'Jum',
      6: 'Sab',
      7: 'Ahad',
    },
  });
  HijriCalendar.setLocal('id');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _registerHijriLocale();

  // Audio backend for Linux/Windows: registers media_kit's libmpv before any
  // AudioPlayer is created (defaults: linux/windows on, mobile off). Requires
  // system libmpv on Linux (`sudo apt install libmpv-dev mpv`).
  JustAudioMediaKit.ensureInitialized();

  // Mobile audio focus; a safe no-op on desktop (no platform channel).
  final audioSession = await AudioSession.instance;
  await audioSession.configure(const AudioSessionConfiguration.speech());

  // Foreground service that plays the full adzan at prayer times. Mobile-only:
  // the plugin has no platform channel on desktop, so this must be a no-op
  // there (the app also runs on Linux/Windows).
  if (Platform.isAndroid || Platform.isIOS) {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'prayer_adzan',
        channelName: 'Adzan Waktu Shalat',
        channelDescription: 'Memutar adzan penuh saat waktu shalat tiba',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        playSound: false,
        enableVibration: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(30000),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowAutoRestart: true,
      ),
    );
    FlutterForegroundTask.initCommunicationPort();
  }

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(
      const Size(AppConstants.minWindowWidth, AppConstants.minWindowHeight),
    );
  }

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
  ]);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Restore the previous window geometry (or center on first launch), then
    // persist future resize/move events.
    final windowState = container.read(windowStateServiceProvider);
    await windowState.restore(windowManager);
    windowState.attach(windowManager);
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyQuranApp(),
    ),
  );
}
