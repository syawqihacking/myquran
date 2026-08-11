import 'package:drift/drift.dart';

import '../db/user_database.dart';

/// Sujud tilawah tracking — one row per ayah the user has already performed
/// sujud on. The `(ayahId)` unique key dedupes repeated marks.
class SajdaRepository {
  SajdaRepository(this._db);

  final UserDatabase _db;

  Stream<List<SajdaLogEntry>> watchSajdaLog() =>
      _db.select(_db.sajdaLog).watch();

  Future<bool> isSajdaDone(int ayahId) async {
    final row = await (_db.select(_db.sajdaLog)
          ..where((t) => t.ayahId.equals(ayahId)))
        .getSingleOrNull();
    return row != null;
  }

  /// Records a sujud for [ayahId]; a no-op if already marked (unique ayahId).
  Future<void> markSajda(int ayahId) async {
    await _db.into(_db.sajdaLog).insert(
          SajdaLogCompanion.insert(
            ayahId: ayahId,
            createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> unmarkSajda(int ayahId) async {
    await (_db.delete(_db.sajdaLog)..where((t) => t.ayahId.equals(ayahId)))
        .go();
  }

  Future<int> countSajdaDone() => _db.sajdaLog.count().getSingle();
}

/// The single active khatam target (single-row table, id pinned to 0).
class KhatamRepository {
  KhatamRepository(this._db);

  final UserDatabase _db;

  Future<KhatamTarget?> getTarget() =>
      _db.select(_db.khatamTargets).getSingleOrNull();

  Stream<KhatamTarget?> watchTarget() =>
      _db.select(_db.khatamTargets).watchSingleOrNull();

  /// Replaces the active target (upsert on the pinned id=0 row).
  ///
  /// A null [targetDate] expresses a 30-day plan (startDate + 30 days); the
  /// `target_date` column stays NULL in that case. Pass a concrete date to
  /// target a specific khatam day instead.
  Future<void> setTarget({
    DateTime? targetDate,
    required DateTime startDate,
  }) async {
    await _db.into(_db.khatamTargets).insertOnConflictUpdate(
          KhatamTarget(
            id: 0,
            targetDate: targetDate == null ? null : _epochDay(targetDate),
            startDate: _epochDay(startDate),
            createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          ),
        );
  }

  Future<void> clearTarget() => _db.delete(_db.khatamTargets).go();

  static int _epochDay(DateTime d) =>
      DateTime(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 86400000;
}

/// Per-surah reading position, used to restore where the user left off when
/// reopening a surah.
class SurahPositionRepository {
  SurahPositionRepository(this._db);

  final UserDatabase _db;

  Future<SurahPosition?> getPosition(int surahId) =>
      (_db.select(_db.surahPositions)..where((t) => t.surahId.equals(surahId)))
          .getSingleOrNull();

  Future<void> setPosition(int surahId, int ayahId) async {
    await _db.into(_db.surahPositions).insertOnConflictUpdate(
          SurahPosition(
            surahId: surahId,
            ayahId: ayahId,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  Stream<SurahPosition?> watchPosition(int surahId) =>
      (_db.select(_db.surahPositions)..where((t) => t.surahId.equals(surahId)))
          .watchSingleOrNull();
}