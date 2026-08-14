import 'package:adhan/adhan.dart';

/// Which of the five daily prayers.
enum Prayer { subuh, dzuhur, ashar, maghrib, isya }

/// A single prayer entry: name + computed time.
class PrayerEntry {
  const PrayerEntry({required this.prayer, required this.time});

  final Prayer prayer;
  final DateTime time;

  String get label => switch (prayer) {
        Prayer.subuh => 'Subuh',
        Prayer.dzuhur => 'Dzuhur',
        Prayer.ashar => 'Ashar',
        Prayer.maghrib => 'Maghrib',
        Prayer.isya => 'Isya',
      };

  String get icon => switch (prayer) {
        Prayer.subuh => '🌅',
        Prayer.dzuhur => '☀️',
        Prayer.ashar => '🌤️',
        Prayer.maghrib => '🌇',
        Prayer.isya => '🌙',
      };
}

/// All five prayer times for a given day, plus helpers for "next prayer" and
/// the currently active prayer.
class PrayerSchedule {
  PrayerSchedule({
    required this.entries,
    required this.now,
    required this.locationName,
  });

  final List<PrayerEntry> entries;
  final DateTime now;
  final String locationName;

  /// The next upcoming prayer (or Subuh of the following day if Isya has
  /// already passed).
  PrayerEntry get nextPrayer {
    for (final e in entries) {
      if (e.time.isAfter(now)) return e;
    }
    // All prayers passed — next is Subuh tomorrow (approximate +24h).
    return entries.first;
  }

  /// Duration remaining until the next prayer.
  Duration get countdown {
    final next = nextPrayer;
    if (next.time.isAfter(now)) {
      return next.time.difference(now);
    }
    // Wrap around to next day's Subuh.
    return next.time.add(const Duration(days: 1)).difference(now);
  }

  /// Index of the currently active prayer (the last prayer whose time <= now),
  /// or -1 if none has started yet today.
  int get activePrayerIndex {
    int active = -1;
    for (int i = 0; i < entries.length; i++) {
      if (!entries[i].time.isAfter(now)) active = i;
    }
    return active;
  }

  /// Index of the next upcoming prayer in [entries], or 0 if all passed.
  int get nextPrayerIndex {
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].time.isAfter(now)) return i;
    }
    return 0;
  }
}

/// Computes Islamic prayer times offline using astronomical formulas via the
/// `adhan` package. Uses **Kemenag RI** parameters by default (Fajr 20deg,
/// Isha 18deg).
class PrayerTimeService {
  /// Calculate today's five prayer times for the given coordinates.
  PrayerSchedule calculate({
    required double latitude,
    required double longitude,
    required DateTime now,
    String locationName = 'Lokasi Anda',
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final dateComponents = DateComponents.from(now);

    // Kemenag RI: Fajr 20deg, Isha 18deg.
    final params = CalculationMethod.singapore.getParameters();
    params.fajrAngle = 20.0;
    params.ishaAngle = 18.0;
    params.madhab = Madhab.shafi;

    final times = PrayerTimes(coordinates, dateComponents, params);

    final entries = [
      PrayerEntry(prayer: Prayer.subuh, time: times.fajr),
      PrayerEntry(prayer: Prayer.dzuhur, time: times.dhuhr),
      PrayerEntry(prayer: Prayer.ashar, time: times.asr),
      PrayerEntry(prayer: Prayer.maghrib, time: times.maghrib),
      PrayerEntry(prayer: Prayer.isya, time: times.isha),
    ];

    return PrayerSchedule(
      entries: entries,
      now: now,
      locationName: locationName,
    );
  }
}
