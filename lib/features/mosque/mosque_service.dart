import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'mosque_models.dart';

/// Fetches nearby mosques from the Overpass API (live OpenStreetMap data).
///
/// Query (verified live, ~20 mosques for Jakarta within 5 km):
/// `[out:json][timeout:25];(nwr["amenity"="place_of_worship"]
/// ["religion"="muslim"](around:5000,LAT,LNG););out center 20;`
/// `out center` puts coordinates in `center` for ways/relations, so the parser
/// reads `center` first and falls back to `lat`/`lon` for nodes.
///
/// Reliability: tries each endpoint in order with one retry per endpoint
/// (flaky 504/empty responses get a second chance), then falls back to the
/// last successful cached result for the rounded location. If every endpoint
/// fails and no cache exists, throws [MosqueFetchException] carrying a summary
/// of what failed.
class MosqueService {
  MosqueService({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  /// Ordered Overpass mirrors. `overpass-api.de` is primary; the others are
  /// fallbacks (verified: kumi.systems works but is flaky, private.coffee and
  /// mail.ru are mirrors).
  static const List<String> _endpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.private.coffee/api/interpreter',
    'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
  ];

  /// Per-attempt timeout (seconds).
  static const Duration _attemptTimeout = Duration(seconds: 15);

  /// Radius used by the Overpass query (meters).
  static const double defaultRadiusMeters = 5000;

  Future<MosqueFetchResult> fetchNearby(
    double lat,
    double lng, {
    double radiusMeters = defaultRadiusMeters,
  }) async {
    final query = '[out:json][timeout:25];'
        '(nwr["amenity"="place_of_worship"]["religion"="muslim"]'
        '(around:${radiusMeters.round()},$lat,$lng););'
        'out center 20;';

    final failures = <String>[];

    for (final endpoint in _endpoints) {
      // One retry per endpoint — a flaky 504/empty response gets a second
      // chance before we move to the next mirror.
      for (var attempt = 0; attempt < 2; attempt++) {
        try {
          final res = await http
              .post(Uri.parse(endpoint), body: {'data': query})
              .timeout(_attemptTimeout);

          if (res.statusCode != 200) {
            failures.add('$endpoint: HTTP ${res.statusCode}');
            continue;
          }
          if (res.body.trim().isEmpty) {
            failures.add('$endpoint: respons kosong');
            continue;
          }

          final mosques = _parseBody(res.body, lat, lng);
          await _writeCache(lat, lng, mosques);
          return MosqueFetchResult(mosques: mosques, fromCache: false);
        } catch (e) {
          failures.add('$endpoint: $e');
        }
      }
    }

    // Every endpoint failed — fall back to the offline cache for this
    // rounded location, if any.
    final cached = await _readCache(lat, lng);
    if (cached != null) {
      return MosqueFetchResult(mosques: cached, fromCache: true);
    }

    throw MosqueFetchException(
      'Semua server Overpass gagal: ${failures.join('; ')}',
    );
  }

  List<Mosque> _parseBody(String body, double lat, double lng) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final elements = (decoded['elements'] as List<dynamic>?) ?? const [];
    final mosques = <Mosque>[];
    for (final e in elements) {
      if (e is! Map<String, dynamic>) continue;
      final m = _parseElement(e, lat, lng);
      if (m != null) mosques.add(m);
    }
    mosques.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return mosques;
  }

  Mosque? _parseElement(Map<String, dynamic> element, double lat, double lng) {
    final tags = (element['tags'] as Map<String, dynamic>?) ?? const {};
    final name = (tags['name'] as String?)?.trim();
    if (name == null || name.isEmpty) return null;

    // `out center` puts coordinates in `center` for ways/relations.
    final center = element['center'];
    final mLat =
        (center is Map<String, dynamic> ? center['lat'] : element['lat']) as num?;
    final mLon =
        (center is Map<String, dynamic> ? center['lon'] : element['lon']) as num?;
    if (mLat == null || mLon == null) return null;

    final type = element['type'] as String? ?? 'node';
    final id = element['id'];

    return Mosque(
      id: '$type/$id',
      name: name,
      lat: mLat.toDouble(),
      lon: mLon.toDouble(),
      address: _buildAddress(tags),
      distanceMeters: _haversine(lat, lng, mLat.toDouble(), mLon.toDouble()),
      amenities: _parseAmenities(tags),
      openingHours: tags['opening_hours'] as String?,
    );
  }

  String _buildAddress(Map<String, dynamic> tags) {
    final street = (tags['addr:street'] as String?)?.trim();
    final city = (tags['addr:city'] as String?)?.trim();
    if ((street?.isNotEmpty ?? false) && (city?.isNotEmpty ?? false)) {
      return '$street, $city';
    }
    if (street?.isNotEmpty ?? false) return street!;
    if (city?.isNotEmpty ?? false) return city!;
    return '';
  }

  Set<MosqueAmenity> _parseAmenities(Map<String, dynamic> tags) {
    final set = <MosqueAmenity>{};
    if (_tagYes(tags, 'parking')) set.add(MosqueAmenity.parking);
    if (_tagYes(tags, 'toilets')) set.add(MosqueAmenity.toilets);
    if (_tagYes(tags, 'air_conditioning')) set.add(MosqueAmenity.ac);
    if (_tagYes(tags, 'wheelchair')) set.add(MosqueAmenity.wheelchair);
    return set;
  }

  bool _tagYes(Map<String, dynamic> tags, String key) {
    final v = tags[key] as String?;
    return v != null && v.toLowerCase() == 'yes';
  }

  /// Great-circle distance in meters.
  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _rad(double deg) => deg * math.pi / 180;

  // -------------------------------------------------------------------------
  // Offline cache (shared_preferences).
  // -------------------------------------------------------------------------

  /// Cache key for the rounded location, e.g. `masjid_cache_-6.20_106.84`
  /// (2-decimal truncation ≈ 1 km grid).
  String _cacheKey(double lat, double lng) =>
      'masjid_cache_${_cacheCoord(lat)}_${_cacheCoord(lng)}';

  String _cacheCoord(double v) {
    final truncated = (v * 100).truncate() / 100;
    return truncated.toStringAsFixed(2);
  }

  Future<void> _writeCache(double lat, double lng, List<Mosque> mosques) async {
    await _prefs.setString(
      _cacheKey(lat, lng),
      jsonEncode({
        'mosques': [for (final m in mosques) m.toCacheJson()],
      }),
    );
  }

  Future<List<Mosque>?> _readCache(double lat, double lng) async {
    final raw = _prefs.getString(_cacheKey(lat, lng));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final list = (decoded['mosques'] as List<dynamic>?) ?? const [];
      return [
        for (final e in list)
          if (e is Map<String, dynamic>) Mosque.fromCacheJson(e),
      ];
    } catch (e) {
      debugPrint('MosqueService._fromCache: failed to decode cached mosques JSON — $e');
      return null;
    }
  }
}