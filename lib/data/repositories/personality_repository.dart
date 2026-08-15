import 'package:drift/drift.dart';

import '../db/quran_database.dart';
import '../db/user_database.dart';
import '../models/personality_data.dart';
import 'quran_repositories.dart';

/// Percentage share of one reading theme in the user's DNA Bacaan.
class ThemeShare {
  const ThemeShare({required this.theme, required this.percent});

  final PersonalityTheme theme;

  /// 0..100 — the three shares always sum to exactly 100.
  final int percent;
}

/// The full personality analysis — computed entirely from real `reading_log`
/// rows (user.db) joined to ayah/surah details from `quran.db`. No fabricated
/// numbers: if there is no reading data, [PersonalityRepository.analyze]
/// returns null and the screen shows the honest empty state.
class PersonalityAnalysis {
  const PersonalityAnalysis({
    required this.archetype,
    required this.dnaShares,
    required this.activeSlot,
    required this.favoriteSurahName,
    required this.recommendation,
    required this.recommendationReason,
  });

  /// Character archetype derived from the dominant theme.
  final PersonalityArchetype archetype;

  /// Three theme shares, oldest-first in enum order, summing to 100.
  final List<ThemeShare> dnaShares;

  /// Dominant reading time slot.
  final ReadingTimeSlot activeSlot;

  /// Name of the surah with the most distinct ayahs read.
  final String favoriteSurahName;

  /// Suggestion from the weakest theme (its [ThemeRecommendation.surahId] is
  /// what "Mulai Membaca" navigates to).
  final ThemeRecommendation recommendation;

  /// [ThemeRecommendation.reason] with the surah name already filled in.
  final String recommendationReason;
}

/// Computes the personality analysis from `reading_log` (user.db), joined to
/// ayah/surah details from `quran.db` — the same cross-DB pattern as
/// `ReadingHistoryRepository`. The query is bounded to the 200 most recent log
/// rows before the join, so a large log never floods the lookup.
class PersonalityRepository {
  PersonalityRepository(UserDatabase user, QuranDatabase quran)
      : _user = user,
        _ayahs = AyahRepository(quran),
        _surahs = SurahRepository(quran);

  final UserDatabase _user;
  final AyahRepository _ayahs;
  final SurahRepository _surahs;

  /// Computes the analysis. Returns null when there is no usable reading data
  /// (empty log, or every row references an unknown ayah).
  Future<PersonalityAnalysis?> analyze() async {
    final entries = await (_user.select(_user.readingLog)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(200))
        .get();
    if (entries.isEmpty) return null;

    final ayahs = await _ayahs.getAyahsByIds(
        entries.map((e) => e.ayahId).toSet().toList());
    final ayahById = {for (final a in ayahs) a.id: a};

    // Pass 1 — aggregate theme counts, hour counts, and per-surah distinct
    // ayah sets. Rows whose ayah is unknown (e.g. deleted reference data) are
    // skipped entirely.
    final themeCounts = <PersonalityTheme, int>{};
    final hourCounts = <int, int>{};
    final surahReads = <int, Set<int>>{};
    for (final e in entries) {
      final ayah = ayahById[e.ayahId];
      if (ayah == null) continue;
      final theme = surahTheme[ayah.surahId] ?? PersonalityTheme.tauhidAkidah;
      themeCounts[theme] = (themeCounts[theme] ?? 0) + 1;
      final hour =
          DateTime.fromMillisecondsSinceEpoch(e.createdAt * 1000).hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      surahReads.putIfAbsent(ayah.surahId, () => <int>{}).add(ayah.id);
    }
    if (themeCounts.isEmpty) return null;

    final total = themeCounts.values.fold<int>(0, (a, b) => a + b);

    // DNA Bacaan — percentages rounded per theme; the rounding drift is
    // absorbed by the dominant theme so the three always sum to 100.
    final rounded = <ThemeShare>[
      for (final t in PersonalityTheme.values)
        ThemeShare(
          theme: t,
          percent: ((themeCounts[t] ?? 0) * 100 / total).round(),
        ),
    ];
    final drift = 100 - rounded.fold<int>(0, (s, x) => s + x.percent);
    final dominant = themeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    final dnaShares = <ThemeShare>[
      for (final s in rounded)
        s.theme == dominant
            ? ThemeShare(theme: s.theme, percent: s.percent + drift)
            : s,
    ];

    // Waktu Aktif — the hour slot with the most reads.
    final dominantHour = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    final activeSlot = readingSlotForHour(dominantHour);

    // Surah Favorit — surah with the most distinct ayahs read; ties go to the
    // surah read most recently (first in log order).
    final surahs = await _surahs.getSurahsByIds(surahReads.keys.toList());
    final surahById = {for (final s in surahs) s.id: s};
    int? bestSurahId;
    var bestDistinct = -1;
    surahReads.forEach((id, ayahsRead) {
      if (ayahsRead.length > bestDistinct) {
        bestDistinct = ayahsRead.length;
        bestSurahId = id;
      }
    });
    final favorite = bestSurahId == null ? null : surahById[bestSurahId];
    if (favorite == null) return null;

    // Langkah Selanjutnya — recommendation from the weakest theme (fewest
    // reads) to balance the reading.
    final weakest = PersonalityTheme.values.reduce((a, b) =>
        (themeCounts[a] ?? 0) <= (themeCounts[b] ?? 0) ? a : b);
    final recommendation =
        themeRecommendations.firstWhere((r) => r.theme == weakest);
    final recSurah = await _surahs.getSurah(recommendation.surahId);
    if (recSurah == null) return null;

    return PersonalityAnalysis(
      archetype: personalityArchetypes.firstWhere((a) => a.theme == dominant),
      dnaShares: dnaShares,
      activeSlot: activeSlot,
      favoriteSurahName: favorite.nameLatin,
      recommendation: recommendation,
      recommendationReason: recommendation.reason(recSurah.nameLatin),
    );
  }

  /// Emits the analysis immediately, then re-emits whenever `reading_log`
  /// changes — mirrors `ReadingStatsRepository.watchStats`.
  Stream<PersonalityAnalysis?> watchAnalysis() async* {
    yield await analyze();
    yield* _user
        .tableUpdates(TableUpdateQuery.onTable(_user.readingLog))
        .asyncMap((_) => analyze());
  }
}