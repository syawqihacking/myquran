import 'dart:convert' show jsonDecode;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/adzan_voice.dart';
import '../services/notification_service.dart';
import '../services/prayer_time_service.dart';
import 'database_providers.dart';

final prayerTimeServiceProvider = Provider<PrayerTimeService>(
  (ref) => PrayerTimeService(),
);

/// Streams prayer schedule, refreshing every 30 seconds for live countdown.
/// Uses GPS location with Jakarta fallback if permission is denied.
final prayerScheduleProvider = StreamProvider<PrayerSchedule>((ref) async* {
  final service = ref.watch(prayerTimeServiceProvider);

  // Try to get the device location; fall back to Jakarta.
  double lat = -6.2088;
  double lng = 106.8456;
  String locName = 'Jakarta';

  try {
    final perm = await Geolocator.checkPermission();
    LocationPermission effectivePerm = perm;
    if (perm == LocationPermission.denied) {
      effectivePerm = await Geolocator.requestPermission();
    }
    if (effectivePerm == LocationPermission.whileInUse ||
        effectivePerm == LocationPermission.always) {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
      lat = pos.latitude;
      lng = pos.longitude;
      // Resolve the coordinates to a real place name; keep the generic label
      // when the lookup fails (offline / rate-limited).
      locName = await _reverseGeocode(lat, lng) ?? 'Lokasi Anda';
    }
  } catch (e) {
    debugPrint('prayerTimesStreamProvider: location/geocoding failed — $e');
    // Keep Jakarta defaults.
  }

  // Emit immediately, then every 30 s so the countdown stays fresh.
  while (true) {
    yield service.calculate(
      latitude: lat,
      longitude: lng,
      now: DateTime.now(),
      locationName: locName,
    );
    await Future<void>.delayed(const Duration(seconds: 30));
  }
});

/// Reverse-geocodes coordinates to a short place name ("Bandung, Indonesia")
/// via the free Nominatim (OpenStreetMap) endpoint. Returns null when the
/// lookup fails (offline, rate-limited, or no address) so callers can fall
/// back to a generic label. Results are cached per rounded coordinate to stay
/// well within Nominatim's 1 req/s policy.
final Map<String, String> _geocodeCache = {};

Future<String?> _reverseGeocode(double lat, double lng) async {
  final key = '${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)}';
  final cached = _geocodeCache[key];
  if (cached != null) return cached;

  try {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?format=jsonv2&lat=$lat&lon=$lng&zoom=10&accept-language=id',
    );
    final res = await http
        .get(uri, headers: const {'User-Agent': 'MyQuran/1.0 (prayer times)'})
        .timeout(const Duration(seconds: 5));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final address = data['address'] as Map<String, dynamic>?;
    if (address == null) return null;
    final city =
        (address['city'] ??
                address['town'] ??
                address['village'] ??
                address['county'] ??
                address['state'])
            as String?;
    final country = address['country'] as String?;
    if (city == null) return null;
    final name = country == null ? city : '$city, $country';
    _geocodeCache[key] = name;
    return name;
  } catch (e) {
    debugPrint('prayerTimesStreamProvider._reverseGeocode: lookup failed for ($lat, $lng) — $e');
    return null;
  }
}

// ---- Prayer notifications --------------------------------------------------

/// The notification service singleton.
final prayerNotificationsProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

/// The selected adzan voice id (persisted; defaults to the first voice).
final selectedAdzanVoiceProvider =
    NotifierProvider<AdzanVoiceController, String>(AdzanVoiceController.new);

class AdzanVoiceController extends Notifier<String> {
  static const _key = 'adzan_voice_id';

  @override
  String build() {
    return ref.watch(sharedPreferencesProvider).getString(_key) ??
        adzanVoices.first.id;
  }

  Future<void> select(String id) async {
    state = id;
    await ref.read(sharedPreferencesProvider).setString(_key, id);
  }
}

/// The selected fajr (subuh) adzan voice id (persisted; defaults to the first
/// fajr voice). Used for the Subuh prayer while [selectedAdzanVoiceProvider]
/// covers the other four prayers.
final selectedFajrAdzanVoiceProvider =
    NotifierProvider<FajrAdzanVoiceController, String>(
      FajrAdzanVoiceController.new,
    );

class FajrAdzanVoiceController extends Notifier<String> {
  static const _key = 'adzan_voice_fajr_id';

  @override
  String build() {
    return ref.watch(sharedPreferencesProvider).getString(_key) ??
        defaultVoiceForCategory(AdzanCategory.fajr).id;
  }

  Future<void> select(String id) async {
    state = id;
    await ref.read(sharedPreferencesProvider).setString(_key, id);
  }
}

/// Whether daily prayer-time notifications are enabled (persisted).
final prayerNotificationsEnabledProvider =
    NotifierProvider<PrayerNotificationsController, bool>(
      PrayerNotificationsController.new,
    );

class PrayerNotificationsController extends Notifier<bool> {
  static const _key = 'prayer_notifications_enabled';

  @override
  bool build() {
    return ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;
  }

  /// Enables/disables notifications. Enabling first requests the runtime
  /// permissions; returns false (and stays off) when the user denies them.
  Future<bool> setEnabled(bool enabled) async {
    if (enabled) {
      final ok = await ref
          .read(prayerNotificationsProvider)
          .requestPermissions();
      if (!ok) return false;
    }
    state = enabled;
    await ref.read(sharedPreferencesProvider).setBool(_key, enabled);
    return true;
  }
}

/// Keeps the scheduled notifications in sync with the toggle and the current
/// prayer schedule. Watched at the app root so it stays alive for the whole
/// session; the service itself skips redundant rescheduling.
final prayerNotificationSyncProvider = Provider<void>((ref) {
  final enabled = ref.watch(prayerNotificationsEnabledProvider);
  final voiceId = ref.watch(selectedAdzanVoiceProvider);
  final fajrVoiceId = ref.watch(selectedFajrAdzanVoiceProvider);
  final schedule = ref.watch(prayerScheduleProvider).value;
  final service = ref.watch(prayerNotificationsProvider);
  if (!enabled) {
    service.cancelAll();
    service.stopAdzanService();
    return;
  }
  if (schedule != null) {
    service.schedulePrayers(
      schedule,
      voiceId: voiceId,
      fajrVoiceId: fajrVoiceId,
    );
    service.startAdzanService(
      schedule,
      voiceId: voiceId,
      fajrVoiceId: fajrVoiceId,
    );
  }
});

/// Whether the daily Dzikir Pagi & Petang reminder notifications are enabled
/// (persisted).
final dzikirReminderEnabledProvider =
    NotifierProvider<DzikirReminderController, bool>(
      DzikirReminderController.new,
    );

class DzikirReminderController extends Notifier<bool> {
  static const _key = 'dzikir_reminder_enabled';

  @override
  bool build() {
    return ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;
  }

  /// Enables/disables the dzikir reminders. Enabling first requests the runtime
  /// permissions; returns false (and stays off) when the user denies them.
  Future<bool> setEnabled(bool enabled) async {
    if (enabled) {
      final ok = await ref
          .read(prayerNotificationsProvider)
          .requestPermissions();
      if (!ok) return false;
    }
    state = enabled;
    await ref.read(sharedPreferencesProvider).setBool(_key, enabled);
    return true;
  }
}

/// Keeps the dzikir reminder notifications in sync with the toggle. Watched at
/// the app root so it stays alive for the whole session.
final dzikirReminderSyncProvider = Provider<void>((ref) {
  final enabled = ref.watch(dzikirReminderEnabledProvider);
  final service = ref.watch(prayerNotificationsProvider);
  if (enabled) {
    service.scheduleDzikirReminders();
  } else {
    service.cancelDzikirReminders();
  }
});

/// Whether the Hijri event reminder notifications are enabled (persisted).
final hijriEventReminderEnabledProvider =
    NotifierProvider<HijriEventReminderController, bool>(
        HijriEventReminderController.new);

class HijriEventReminderController extends Notifier<bool> {
  static const _key = 'hijri_event_reminder_enabled';

  @override
  bool build() {
    return ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;
  }

  /// Enables/disables the Hijri event reminders.
  Future<bool> setEnabled(bool enabled) async {
    if (enabled) {
      final ok =
          await ref.read(prayerNotificationsProvider).requestPermissions();
      if (!ok) return false;
    }
    state = enabled;
    await ref.read(sharedPreferencesProvider).setBool(_key, enabled);
    return true;
  }
}

/// Keeps the Hijri event reminder notifications in sync with the toggle.
final hijriEventReminderSyncProvider = Provider<void>((ref) {
  final enabled = ref.watch(hijriEventReminderEnabledProvider);
  final service = ref.watch(prayerNotificationsProvider);
  if (enabled) {
    service.scheduleHijriEvents();
  } else {
    service.cancelHijriEvents();
  }
});

/// Whether the Fasting reminder notifications are enabled (persisted).
final fastingReminderEnabledProvider =
    NotifierProvider<FastingReminderController, bool>(
        FastingReminderController.new);

class FastingReminderController extends Notifier<bool> {
  static const _key = 'fasting_reminder_enabled';

  @override
  bool build() {
    return ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;
  }

  /// Enables/disables the Fasting reminders.
  Future<bool> setEnabled(bool enabled) async {
    if (enabled) {
      final ok =
          await ref.read(prayerNotificationsProvider).requestPermissions();
      if (!ok) return false;
    }
    state = enabled;
    await ref.read(sharedPreferencesProvider).setBool(_key, enabled);
    return true;
  }
}

/// Keeps the Fasting reminder notifications in sync with the toggle.
final fastingReminderSyncProvider = Provider<void>((ref) {
  final enabled = ref.watch(fastingReminderEnabledProvider);
  final service = ref.watch(prayerNotificationsProvider);
  if (enabled) {
    service.scheduleFastingReminders();
  } else {
    service.cancelFastingReminders();
  }
});
