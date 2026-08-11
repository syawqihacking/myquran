import 'package:drift/drift.dart';

import '../../core/arabic_normalization.dart';
import '../db/quran_database.dart';

/// Read views over `quran.db` (reference data — no writes).
class SurahRepository {
  SurahRepository(this._db);

  final QuranDatabase _db;

  Stream<List<Surah>> watchSurahs() {
    final q = _db.select(_db.surahs)..orderBy([(t) => OrderingTerm.asc(t.id)]);
    return q.watch();
  }

  Future<Surah?> getSurah(int id) =>
      (_db.select(_db.surahs)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Surah>> getSurahsByIds(List<int> ids) =>
      (_db.select(_db.surahs)..where((t) => t.id.isIn(ids))).get();

  /// Case-insensitive search over Latin/Indonesian surah names (used by the
  /// search overlay's "SURAH" group).
  Future<List<Surah>> searchByName(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final like = '%$q%';
    return (_db.select(_db.surahs)
          ..where((t) =>
              t.nameLatin.lower().like(like) | t.nameIndonesian.lower().like(like))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }
}

/// Range info for one juz (Home → Juz view).
class JuzInfo {
  const JuzInfo({
    required this.juz,
    required this.firstAyahId,
    required this.firstSurahId,
    required this.lastSurahId,
  });

  final int juz;
  final int firstAyahId;
  final int firstSurahId;
  final int lastSurahId;
}

class AyahRepository {
  AyahRepository(this._db);

  final QuranDatabase _db;

  Stream<List<Ayah>> watchAyahs(int surahId) {
    final q = _db.select(_db.ayahs)
      ..where((t) => t.surahId.equals(surahId))
      ..orderBy([(t) => OrderingTerm.asc(t.ayahNumber)]);
    return q.watch();
  }

  Future<Ayah?> getAyah(int id) =>
      (_db.select(_db.ayahs)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Fetches ayahs by id, chunking the IN-clause (500 ids per batch) so a
  /// large id list (e.g. a grown reading_log) never hits SQLite's variable
  /// limit. Order is not preserved.
  Future<List<Ayah>> getAyahsByIds(List<int> ids) async {
    if (ids.isEmpty) return const [];
    const chunkSize = 500;
    final out = <Ayah>[];
    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(
          i, i + chunkSize > ids.length ? ids.length : i + chunkSize);
      out.addAll(
          await (_db.select(_db.ayahs)..where((t) => t.id.isIn(chunk))).get());
    }
    return out;
  }

  Future<Ayah?> getAyahByNumber(int surahId, int ayahNumber) =>
      (_db.select(_db.ayahs)
            ..where((t) =>
                t.surahId.equals(surahId) & t.ayahNumber.equals(ayahNumber)))
          .getSingleOrNull();

  Future<Ayah?> firstAyahOfJuz(int juz) {
    final q = _db.select(_db.ayahs)
      ..where((t) => t.juz.equals(juz))
      ..orderBy([(t) => OrderingTerm.asc(t.id)])
      ..limit(1);
    return q.getSingleOrNull();
  }

  Future<Tafsir?> getTafsir(int ayahId) =>
      (_db.select(_db.tafsirs)..where((t) => t.ayahId.equals(ayahId)))
          .getSingleOrNull();

  /// First ayah id + first/last surah id for each juz, in juz order.
  ///
  /// Uses the first row per juz in ascending ayah-id order; the last surah of
  /// a juz is inferred from the first surah of the following juz.
  Future<List<JuzInfo>> getJuzInfos() async {
    final rows = await _db.customSelect(
      '''
      SELECT juz, id AS first_id, surah_id
      FROM (
        SELECT juz, id, surah_id,
               ROW_NUMBER() OVER (PARTITION BY juz ORDER BY id) AS rn
        FROM ayahs
      )
      WHERE rn = 1
      ORDER BY juz
      ''',
    ).get();

    final list = <JuzInfo>[];
    if (rows.isEmpty) return list;

    final lastIds = <int>[];
    for (var i = 0; i < rows.length; i++) {
      final isLast = i == rows.length - 1;
      final lastId = isLast
          ? await _db.ayahs.count().getSingle()
          : rows[i + 1].read<int>('first_id') - 1;
      lastIds.add(lastId);
    }

    final lastAyahs = await getAyahsByIds(lastIds);
    final lastSurahByAyahId = {for (final a in lastAyahs) a.id: a.surahId};

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final firstAyahId = row.read<int>('first_id');
      final lastSurahId = lastSurahByAyahId[lastIds[i]] ?? row.read<int>('surah_id');
      list.add(JuzInfo(
        juz: row.read<int>('juz'),
        firstAyahId: firstAyahId,
        firstSurahId: row.read<int>('surah_id'),
        lastSurahId: lastSurahId,
      ));
    }
    return list;
  }
}

/// One search hit, ready for navigation and display.
class SearchResult {
  const SearchResult({
    required this.ayahId,
    required this.surahId,
    required this.ayahNumber,
    required this.surahNameLatin,
    required this.surahNameIndonesian,
    required this.juz,
    required this.matchKind,
    required this.arabicSnippet,
    required this.translationSnippet,
  });

  final int ayahId;
  final int surahId;
  final int ayahNumber;
  final String surahNameLatin;
  final String surahNameIndonesian;
  final int juz;

  /// 'arabic' when the normalized query looked Arabic-ish, else 'translation'.
  final String matchKind;
  final String arabicSnippet;
  final String translationSnippet;
}

/// Full-text search over the static FTS5 index (`ayah_fts`).
///
/// The index is contentless and seeded at build time; queries run through
/// `customSelect` because drift cannot model virtual tables.
///
/// NOTE: `snippet()`/`highlight()` return NULL for contentless FTS5 tables
/// (they need the stored content), so snippets are built in Dart from the
/// full text joined from `ayahs`.
class SearchRepository {
  SearchRepository(this._db);

  final QuranDatabase _db;

  Future<List<SearchResult>> search(String query, {int limit = 50}) async {
    final ftsQuery = buildFtsQuery(query);
    if (ftsQuery.isEmpty) return const [];

    final rows = await _db.customSelect(
      '''
      SELECT f.rowid    AS ayah_id,
             a.surah_id AS surah_id,
             a.ayah_number AS ayah_number,
             a.juz      AS juz,
             a.text_uthmani AS full_ar,
             a.translation  AS full_id
      FROM ayah_fts f
      JOIN ayahs a ON a.id = f.rowid
      WHERE ayah_fts MATCH ?
      ORDER BY bm25(ayah_fts)
      LIMIT ?
      ''',
      variables: [Variable.withString(ftsQuery), Variable.withInt(limit)],
    ).get();

    if (rows.isEmpty) return const [];

    final kind = isArabicText(query) ? 'arabic' : 'translation';
    final normQuery = normalizeArabic(query);
    final idQuery = query.trim().toLowerCase();

    final surahIds = rows.map((r) => r.read<int>('surah_id')).toSet().toList();
    final surahs = await (_db.select(_db.surahs)
          ..where((t) => t.id.isIn(surahIds)))
        .get();
    final surahById = {for (final s in surahs) s.id: s};

    return [
      for (final r in rows)
        SearchResult(
          ayahId: r.read<int>('ayah_id'),
          surahId: r.read<int>('surah_id'),
          ayahNumber: r.read<int>('ayah_number'),
          juz: r.read<int>('juz'),
          surahNameLatin: surahById[r.read<int>('surah_id')]!.nameLatin,
          surahNameIndonesian:
              surahById[r.read<int>('surah_id')]!.nameIndonesian,
          matchKind: kind,
          // Arabic snippet runs on the normalized text (no harakat) so the
          // query is found verbatim; translation snippet centers on the
          // keyword for Indonesian queries.
          arabicSnippet: _snippetAround(normalizeArabic(r.read<String>('full_ar')), normQuery),
          translationSnippet: kind == 'arabic'
              ? _snippetAround(r.read<String>('full_id'), '')
              : _snippetAround(r.read<String>('full_id').toLowerCase(), idQuery),
        ),
    ];
  }

  /// A centered window around `needle` in `text`, with ellipses at the cut
  /// edges. Empty `needle` returns a leading window.
  static String _snippetAround(String text, String needle) {
    const win = 55;
    if (needle.isEmpty) {
      return text.length <= 2 * win ? text : '${text.substring(0, 2 * win)}…';
    }
    final idx = text.indexOf(needle);
    if (idx < 0) {
      return text.length <= 2 * win ? text : '${text.substring(0, 2 * win)}…';
    }
    if (text.length <= 2 * win) return text;
    final start = (idx - win).clamp(0, text.length);
    final end = (idx + needle.length + win).clamp(0, text.length);
    final pre = start > 0 ? '…' : '';
    final post = end < text.length ? '…' : '';
    return '$pre${text.substring(start, end)}$post';
  }
}
