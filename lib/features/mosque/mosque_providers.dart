import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../data/providers.dart' show sharedPreferencesProvider;
import 'mosque_models.dart';
import 'mosque_service.dart';

/// Overpass fetch service (with offline cache).
final mosqueServiceProvider = Provider<MosqueService>(
  (ref) => MosqueService(prefs: ref.watch(sharedPreferencesProvider)),
);

/// Resolves the device location (real GPS, reusing the geolocator permission
/// pattern from `prayerScheduleProvider`). On Linux — where geolocator throws
/// MissingPluginException — or when permission is denied, throws
/// [MosqueLocationException]. No fabricated fallback location.
final mosqueLocationProvider = FutureProvider<LatLng>((ref) async {
  if (defaultTargetPlatform == TargetPlatform.linux) {
    throw const MosqueLocationException();
  }

  final perm = await Geolocator.checkPermission();
  LocationPermission effective = perm;
  if (perm == LocationPermission.denied) {
    effective = await Geolocator.requestPermission();
  }
  if (effective == LocationPermission.whileInUse ||
      effective == LocationPermission.always) {
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 5),
      ),
    );
    return LatLng(pos.latitude, pos.longitude);
  }
  throw const MosqueLocationException();
});

/// Nearby mosques, sorted by distance. Depends on [mosqueLocationProvider].
/// Returns [MosqueFetchResult] so the UI can show a stale-data note when the
/// result came from the offline cache.
final mosqueListProvider = FutureProvider<MosqueFetchResult>((ref) async {
  final location = await ref.watch(mosqueLocationProvider.future);
  return ref
      .watch(mosqueServiceProvider)
      .fetchNearby(location.latitude, location.longitude);
});