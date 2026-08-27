import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:hijri/hijri_calendar.dart';

import '../../features/hijri/hijri_event.dart';
import '../models/adzan_voice.dart';
import 'adzan_foreground_handler.dart';
import 'prayer_time_service.dart';

/// Schedules daily prayer-time (adzan) notifications via
/// flutter_local_notifications.
///
/// Mobile-only by design: Android and iOS have real alarm scheduling; on
/// desktop (Linux/Windows/macOS) every method is a safe no-op so the app never
/// crashes in the dev environment. Exact alarms are used when the user granted
/// the permission, otherwise scheduling falls back to inexact (may fire a few
/// minutes late) rather than throwing.
///
/// Scheduled prayer notifications are deliberately SILENT: the full adzan is
/// played by the foreground service (see [startAdzanService]) on the media
/// stream, which is not interrupted by the volume buttons. The notification
/// itself only shows the reminder text. Each voice gets its own silent channel
/// (`prayer_silent_<id>`); the sounding channel (`prayer_times_<id>`) is used
/// only by [showTestNotification] so the user can preview a voice.
class NotificationService {
  NotificationService();

  static const String _channelName = 'Waktu Shalat';
  static const String _channelDesc = 'Pengingat waktu shalat harian';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Whether exact alarms were granted at enable time. Used to pick the
  /// Android schedule mode; exact mode throws if the permission is missing.
  bool _exactAllowed = false;

  /// The last scheduled prayer times (hour/minute), used to skip redundant
  /// rescheduling when the 30 s schedule refresh emits the same times.
  List<DateTime>? _scheduledTimes;

  /// The voice id the last schedule was created with; a voice change forces a
  /// reschedule even when the times are unchanged.
  String? _scheduledVoiceId;

  /// The fajr voice id the last schedule was created with; a fajr voice change
  /// forces a reschedule even when the times are unchanged.
  String? _scheduledFajrVoiceId;

  static bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _ensureInitialized() async {
    if (_initialized || !_isMobile) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('NotificationService._ensureInitialized: timezone lookup failed — $e');
      // Fall back to WIB if the timezone lookup fails.
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  /// Requests the runtime permissions (Android 13+ notifications, exact
  /// alarms, iOS alert/badge/sound) and returns whether notifications are
  /// allowed. False on desktop (feature not available there).
  Future<bool> requestPermissions() async {
    await _ensureInitialized();
    if (!_isMobile) return false;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final notificationsOk =
        await android?.requestNotificationsPermission() ?? true;
    _exactAllowed = await android?.requestExactAlarmsPermission() ?? false;
    final ios = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return notificationsOk == true;
  }

  /// Downloads the voice's mp3 into app storage if not cached yet and returns
  /// its absolute path. Throws on network/HTTP failure so callers can surface
  /// an honest error.
  Future<String> ensureVoiceDownloaded(AdzanVoice voice) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/adzan/${voice.id}.mp3');
    if (await file.exists()) return file.path;
    await file.parent.create(recursive: true);
    final res = await http
        .get(Uri.parse(voice.url))
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) {
      throw HttpException('adzan download failed: ${res.statusCode}');
    }
    await file.writeAsBytes(res.bodyBytes, flush: true);
    return file.path;
  }

  /// Converts an absolute file path into a `content://` URI via the Android
  /// FileProvider (see MainActivity.kt + res/xml/file_paths.xml). SystemUI
  /// cannot read a `file://` URI into app-private storage, so the content URI
  /// is required for the adzan sound to actually play.
  ///
  /// Returns null on any failure (missing platform channel, unmapped path,
  /// etc.) so callers can fall back to the default sound instead of failing to
  /// show the notification at all.
  Future<String?> _contentUriForFile(String path) async {
    try {
      const channel = MethodChannel('app/file_provider');
      final uri = await channel
          .invokeMethod<String>('getUriForFile', {'path': path});
      return uri;
    } catch (e) {
      debugPrint('NotificationService._contentUriForFile: failed to resolve URI for $path — $e');
      return null;
    }
  }

  /// Creates (or updates) the sounding notification channel used by
  /// [showTestNotification] so the user can preview a voice. The channel sound
  /// is fixed at creation, so each voice keeps its own channel id. Never
  /// throws: a sound failure must not prevent the notification from being
  /// shown.
  Future<void> _createChannel(String voiceId, String soundPath) async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final soundUri = await _contentUriForFile(soundPath);
      await android?.createNotificationChannel(
        AndroidNotificationChannel(
          'prayer_times_$voiceId',
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
          sound: soundUri == null
              ? null
              : UriAndroidNotificationSound(soundUri),
        ),
      );
    } catch (e) {
      debugPrint('NotificationService._createChannel: failed to create channel for voice $voiceId — $e');
      // Ignore: the notification still shows with the default sound.
    }
  }

  /// Creates (or updates) the SILENT channel used by scheduled prayer
  /// notifications. The adzan itself is played by the foreground service on
  /// the media stream, so the notification must not add a second sound (and
  /// must not be killed by the volume buttons). Never throws.
  Future<void> _createSilentChannel(String voiceId) async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        AndroidNotificationChannel(
          'prayer_silent_$voiceId',
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
          playSound: false,
        ),
      );
    } catch (e) {
      debugPrint('NotificationService._createSilentChannel: failed to create silent channel for voice $voiceId — $e');
      // Ignore: the notification still shows.
    }
  }

  /// Schedules the five daily prayer notifications on the given voice's SILENT
  /// channel. The adzan audio is played by the foreground service (media
  /// stream, unaffected by the volume buttons); the notification only shows
  /// the reminder text so the two never double-play. Skips when both the times
  /// and the voices are unchanged since the last call (the schedule refreshes
  /// every 30 s).
  ///
  /// The Subuh (fajr) prayer uses its own voice ([fajrVoiceId]) and its own
  /// silent channel (`prayer_silent_<fajrVoiceId>`); the other four prayers use
  /// [voiceId] on `prayer_silent_<voiceId>`.
  Future<void> schedulePrayers(
    PrayerSchedule schedule, {
    required String voiceId,
    required String fajrVoiceId,
  }) async {
    await _ensureInitialized();
    if (!_isMobile) return;
    final times = schedule.entries.map((e) => e.time).toList();
    if (_sameTimes(times) &&
        _scheduledVoiceId == voiceId &&
        _scheduledFajrVoiceId == fajrVoiceId) {
      return;
    }
    _scheduledTimes = times;
    _scheduledVoiceId = voiceId;
    _scheduledFajrVoiceId = fajrVoiceId;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    // Refresh the exact-alarm state: USE_EXACT_ALARM (Android 13+) is
    // auto-granted, and the user may have granted SCHEDULE_EXACT_ALARM since
    // enabling — so re-check instead of trusting the toggle-time value.
    _exactAllowed = await android?.requestExactAlarmsPermission() ?? false;

    await _createSilentChannel(voiceId);
    await _createSilentChannel(fajrVoiceId);

    await _plugin.cancelAllPendingNotifications();
    final now = tz.TZDateTime.now(tz.local);
    for (final entry in schedule.entries) {
      final id = entry.prayer.index + 1;
      final isFajr = entry.prayer == Prayer.subuh;
      final channelId = isFajr
          ? 'prayer_silent_$fajrVoiceId'
          : 'prayer_silent_$voiceId';
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        entry.time.hour,
        entry.time.minute,
      );
      // The first occurrence must be in the future; the daily repeat is
      // handled by matchDateTimeComponents.time.
      if (!scheduled.isAfter(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        id: id,
        title: 'Waktu ${entry.label}',
        body: 'Sudah masuk waktu ${entry.label}.',
        scheduledDate: scheduled,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            // Silent on purpose: the adzan is played by the foreground
            // service, so the notification must not add a second sound.
            silent: true,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: _exactAllowed
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// Shows an immediate test notification on the given voice's channel so the
  /// user can hear the adzan without waiting for a prayer time.
  Future<void> showTestNotification({required String voiceId}) async {
    await _ensureInitialized();
    if (!_isMobile) return;
    final voice = adzanVoiceById(voiceId);
    final soundPath = await ensureVoiceDownloaded(voice);
    final soundUri = await _contentUriForFile(soundPath);
    await _createChannel(voiceId, soundPath);
    await _plugin.show(
      id: 999,
      title: 'Waktu Shalat',
      body: 'Ini notifikasi uji coba. Notifikasi waktu shalat aktif.',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_times_$voiceId',
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          // Notification-level sound must be set explicitly (see schedulePrayers).
          sound: soundUri == null
              ? null
              : UriAndroidNotificationSound(soundUri),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Shows an immediate test notification for Hijri events.
  Future<void> showHijriTestNotification() async {
    await _ensureInitialized();
    if (!_isMobile) return;

    final hijriNow = HijriCalendar.now();
    HijriEvent? todayEvent;
    for (final event in kIslamicEvents) {
      if (event.month == hijriNow.hMonth && event.day == hijriNow.hDay) {
        todayEvent = event;
        break;
      }
    }

    final body = todayEvent != null
        ? 'Hari ini: ${todayEvent.title}'
        : 'Ini adalah uji coba pengingat peristiwa penting Hijriah. Hari ini tidak ada peristiwa khusus.';

    await _plugin.show(
      id: 998,
      title: 'Peringatan Kalender Hijriah',
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'hijri_events',
          'Peristiwa Penting Hijriah',
          channelDescription: 'Pengingat peristiwa penting di kalender Islam',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Cancels all pending prayer notifications. Skips when nothing was
  /// scheduled (the sync provider re-runs on every schedule refresh).
  Future<void> cancelAll() async {
    await _ensureInitialized();
    if (!_isMobile) return;
    if (_scheduledTimes == null) return;
    await _plugin.cancelAllPendingNotifications();
    _scheduledTimes = null;
    _scheduledVoiceId = null;
    _scheduledFajrVoiceId = null;
  }

  /// Schedules the two daily Dzikir Pagi & Petang reminder notifications
  /// (morning ~06:00, evening ~18:00) on their own channel. Uses distinct ids
  /// (1001/1002) so they never collide with prayer notifications (1-5) or the
  /// test notification (999). Mobile-only: a safe no-op on desktop.
  Future<void> scheduleDzikirReminders() async {
    await _ensureInitialized();
    if (!_isMobile) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    // Refresh the exact-alarm state (see schedulePrayers).
    _exactAllowed = await android?.requestExactAlarmsPermission() ?? false;

    final now = tz.TZDateTime.now(tz.local);
    final reminders = <({int id, int hour, int minute, String title, String body})>[
      (id: 1001, hour: 6, minute: 0, title: 'Dzikir Pagi', body: 'Waktunya membaca dzikir pagi.'),
      (id: 1002, hour: 18, minute: 0, title: 'Dzikir Petang', body: 'Waktunya membaca dzikir petang.'),
    ];
    for (final r in reminders) {
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        r.hour,
        r.minute,
      );
      // The first occurrence must be in the future; the daily repeat is
      // handled by matchDateTimeComponents.time.
      if (!scheduled.isAfter(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        id: r.id,
        title: r.title,
        body: r.body,
        scheduledDate: scheduled,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'dzikir_reminder',
            'Dzikir Pagi & Petang',
            channelDescription: 'Pengingat harian dzikir pagi dan petang',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: _exactAllowed
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// Cancels only the two dzikir reminder notifications (ids 1001/1002).
  /// Deliberately does NOT call cancelAllPendingNotifications, which would also
  /// wipe the prayer notifications. Mobile-only: a safe no-op on desktop.
  Future<void> cancelDzikirReminders() async {
    await _ensureInitialized();
    if (!_isMobile) return;
    await _plugin.cancel(id: 1001);
    await _plugin.cancel(id: 1002);
  }

  /// Schedules local notifications for Hijri calendar events for the current
  /// and next Hijri year at 07:00 AM on the day of the event. Uses distinct ids
  /// starting from 2000.
  Future<void> scheduleHijriEvents() async {
    await _ensureInitialized();
    if (!_isMobile) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    _exactAllowed = await android?.requestExactAlarmsPermission() ?? false;

    final now = tz.TZDateTime.now(tz.local);
    final hijriNow = HijriCalendar.now();
    final currentYear = hijriNow.hYear;
    
    // Schedule for the current Hijri year and the next one
    final years = [currentYear, currentYear + 1];
    int notificationId = 2000;
    
    for (final year in years) {
      for (final event in kIslamicEvents) {
        final date = hijriNow.hijriToGregorian(year, event.month, event.day);
        
        final scheduled = tz.TZDateTime(
          tz.local,
          date.year,
          date.month,
          date.day,
          7, // 07:00 AM
          0,
        );
        
        if (scheduled.isAfter(now)) {
          await _plugin.zonedSchedule(
            id: notificationId,
            title: 'Peringatan Kalender Hijriah',
            body: 'Hari ini: ${event.title}',
            scheduledDate: scheduled,
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'hijri_events',
                'Peristiwa Penting Hijriah',
                channelDescription: 'Pengingat peristiwa penting di kalender Islam',
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: _exactAllowed
                ? AndroidScheduleMode.exactAllowWhileIdle
                : AndroidScheduleMode.inexactAllowWhileIdle,
          );
        }
        notificationId++;
      }
    }
  }

  /// Cancels all scheduled Hijri event notifications (IDs 2000 to ~2200).
  Future<void> cancelHijriEvents() async {
    await _ensureInitialized();
    if (!_isMobile) return;
    
    for (int i = 2000; i < 2200; i++) {
      await _plugin.cancel(id: i);
    }
  }

  /// Starts (or updates) the foreground service that plays the full adzan at
  /// prayer times. Mobile-only: a safe no-op on desktop.
  ///
  /// Both voice mp3 paths (regular + fajr) and the daily schedule (as a JSON
  /// string) are stored via [FlutterForegroundTask.saveData] so the background
  /// isolate's handler can read them. Each schedule entry carries a `fajr`
  /// flag so the handler can pick the fajr voice for Subuh and the regular
  /// voice for the other four prayers. If the service is already running it is
  /// updated (to refresh the notification text) rather than restarted.
  Future<void> startAdzanService(
    PrayerSchedule schedule, {
    required String voiceId,
    required String fajrVoiceId,
  }) async {
    if (!_isMobile) return;

    final voice = adzanVoiceById(voiceId);
    final path = await ensureVoiceDownloaded(voice);

    final fajrVoice = adzanVoiceById(fajrVoiceId);
    final fajrPath = await ensureVoiceDownloaded(fajrVoice);

    final scheduleJson = jsonEncode([
      for (final e in schedule.entries)
        {
          'label': e.label,
          'hh': e.time.hour,
          'mm': e.time.minute,
          'fajr': e.prayer == Prayer.subuh,
        },
    ]);

    await FlutterForegroundTask.saveData(
      key: 'adzan_voice_path',
      value: path,
    );
    await FlutterForegroundTask.saveData(
      key: 'adzan_fajr_voice_path',
      value: fajrPath,
    );
    await FlutterForegroundTask.saveData(
      key: 'adzan_schedule',
      value: scheduleJson,
    );

    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Adzan Waktu Shalat',
        notificationText: 'Menunggu waktu shalat...',
        notificationButtons: [
          NotificationButton(id: 'stop', text: 'Berhenti'),
        ],
        callback: adzanTaskCallback,
      );
    } else {
      await FlutterForegroundTask.startService(
        serviceTypes: [ForegroundServiceTypes.mediaPlayback],
        notificationTitle: 'Adzan Waktu Shalat',
        notificationText: 'Menunggu waktu shalat...',
        notificationButtons: [
          NotificationButton(id: 'stop', text: 'Berhenti'),
        ],
        callback: adzanTaskCallback,
      );
    }
  }

  /// Stops the adzan foreground service. Mobile-only: a safe no-op on desktop.
  Future<void> stopAdzanService() async {
    if (!_isMobile) return;
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }

  bool _sameTimes(List<DateTime> times) {
    final prev = _scheduledTimes;
    if (prev == null || prev.length != times.length) return false;
    for (var i = 0; i < times.length; i++) {
      if (prev[i].hour != times[i].hour || prev[i].minute != times[i].minute) {
        return false;
      }
    }
    return true;
  }
}