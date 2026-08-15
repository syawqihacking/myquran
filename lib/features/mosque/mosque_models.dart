import 'package:flutter/material.dart';

/// Amenities that OpenStreetMap actually tags on mosques (verified live).
/// There is no "wudu" tag in OSM, so toilets map to `toilets=yes`.
enum MosqueAmenity { parking, toilets, ac, wheelchair }

extension MosqueAmenityX on MosqueAmenity {
  /// Chip label shown on cards and in the detail sheet.
  String get label => switch (this) {
        MosqueAmenity.parking => 'Parkir',
        MosqueAmenity.toilets => 'Toilet',
        MosqueAmenity.ac => 'AC',
        MosqueAmenity.wheelchair => 'Ramah Disabilitas',
      };

  IconData get icon => switch (this) {
        MosqueAmenity.parking => Icons.local_parking_rounded,
        MosqueAmenity.toilets => Icons.wc_rounded,
        MosqueAmenity.ac => Icons.ac_unit_rounded,
        MosqueAmenity.wheelchair => Icons.accessible_rounded,
      };
}

/// A nearby mosque parsed from the Overpass response.
class Mosque {
  const Mosque({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.address,
    required this.distanceMeters,
    required this.amenities,
    this.openingHours,
  });

  /// OSM element id, e.g. `node/12345`.
  final String id;
  final String name;
  final double lat;
  final double lon;
  final String address;
  final double distanceMeters;
  final Set<MosqueAmenity> amenities;

  /// OSM `opening_hours` tag, if present.
  final String? openingHours;

  bool get hasAmenity => amenities.isNotEmpty;

  /// JSON shape for the offline cache (see `mosque_service.dart`).
  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'name': name,
        'lat': lat,
        'lon': lon,
        'address': address,
        'distanceMeters': distanceMeters,
        'amenities': [for (final a in amenities) a.name],
        if (openingHours != null) 'openingHours': openingHours,
      };

  factory Mosque.fromCacheJson(Map<String, dynamic> json) {
    final amenities = <MosqueAmenity>{};
    for (final a in (json['amenities'] as List<dynamic>? ?? const [])) {
      final amenity =
          a is String ? MosqueAmenity.values.asNameMap()[a] : null;
      if (amenity != null) amenities.add(amenity);
    }
    return Mosque(
      id: json['id'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      address: json['address'] as String? ?? '',
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      amenities: amenities,
      openingHours: json['openingHours'] as String?,
    );
  }
}

/// Result of a fetch — the mosques plus whether they came from the offline
/// cache (all live endpoints failed, so the data may be stale).
class MosqueFetchResult {
  const MosqueFetchResult({required this.mosques, required this.fromCache});

  final List<Mosque> mosques;
  final bool fromCache;
}

/// Thrown when the device location cannot be obtained (Linux desktop, denied
/// permission, timeout). Never fabricated — the UI shows an explicit state.
class MosqueLocationException implements Exception {
  const MosqueLocationException();
}

/// Thrown when the Overpass request fails (network, HTTP, or parse).
class MosqueFetchException implements Exception {
  const MosqueFetchException(this.message);

  final String message;

  @override
  String toString() => 'MosqueFetchException: $message';
}