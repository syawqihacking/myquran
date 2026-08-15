import 'package:flutter/material.dart';

import '../../core/app_strings.dart';

/// The three reading-theme buckets used by the personality analysis. Every
/// surah (1..114) is mapped to exactly one theme in [surahTheme].
enum PersonalityTheme { sabarSyukur, kisahNabi, tauhidAkidah }

extension PersonalityThemeX on PersonalityTheme {
  /// Indonesian label for the DNA Bacaan rows.
  String get label => switch (this) {
        PersonalityTheme.sabarSyukur => S.personalityThemeSabar,
        PersonalityTheme.kisahNabi => S.personalityThemeKisah,
        PersonalityTheme.tauhidAkidah => S.personalityThemeTauhid,
      };

  /// Material color-role mapping for the DNA progress bars (Sacred Path):
  /// Sabar & Syukur → primary, Kisah Para Nabi → tertiaryContainer,
  /// Tauhid & Akidah → secondary.
  Color color(ColorScheme scheme) => switch (this) {
        PersonalityTheme.sabarSyukur => scheme.primary,
        PersonalityTheme.kisahNabi => scheme.tertiaryContainer,
        PersonalityTheme.tauhidAkidah => scheme.secondary,
      };
}

/// Curated mapping of every surah (1..114) to its dominant reading theme.
///
/// Categorization follows dominant content:
///  - Sabar & Syukur — patience, gratitude, trials, forgiveness, consolation.
///  - Kisah Para Nabi — prophet / past-nation narratives.
///  - Tauhid & Akidah — oneness of Allah, faith, and the akhirah.
const List<int> _tauhidSurahIds = [
  1, 4, 5, 6, 8, 9, 13, 16, 17, 22, 24, 25, 30, 31, 32, 34, 35, 36, 40, 41,
  42, 43, 44, 45, 47, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62,
  63, 64, 65, 66, 67, 68, 69, 70, 72, 73, 74, 75, 77, 78, 79, 80, 81, 82, 83,
  84, 85, 86, 87, 88, 89, 95, 96, 97, 98, 99, 100, 101, 102, 104, 106, 107,
  109, 110, 111, 112, 113, 114,
];

const List<int> _kisahSurahIds = [
  7, 10, 11, 12, 15, 19, 20, 21, 23, 26, 27, 28, 29, 33, 37, 38, 46, 48, 71,
  105,
];

const List<int> _sabarSurahIds = [
  2, 3, 14, 18, 39, 76, 90, 91, 92, 93, 94, 103, 108,
];

/// All 114 surahs → one theme each. Built once at first access with
/// collection-for so the three id lists above stay the single source of truth
/// (no accidental gaps). 81 tauhid / 20 kisah / 13 sabar = 114.
final Map<int, PersonalityTheme> surahTheme = Map.unmodifiable({
  for (final id in _tauhidSurahIds) id: PersonalityTheme.tauhidAkidah,
  for (final id in _kisahSurahIds) id: PersonalityTheme.kisahNabi,
  for (final id in _sabarSurahIds) id: PersonalityTheme.sabarSyukur,
});

/// One character archetype — derived from the dominant reading theme.
/// Names and descriptions are modest and grounded; they describe the reading
/// pattern, never the person's worth.
class PersonalityArchetype {
  const PersonalityArchetype({
    required this.theme,
    required this.name,
    required this.description,
  });

  final PersonalityTheme theme;
  final String name;
  final String description;
}

/// The three archetypes, one per theme.
const List<PersonalityArchetype> personalityArchetypes = [
  PersonalityArchetype(
    theme: PersonalityTheme.sabarSyukur,
    name: 'Pencari Kedamaian',
    description:
        'Bacaanmu paling banyak berputar pada ayat-ayat tentang kesabaran, '
        'rasa syukur, dan ketenangan hati. Semoga ketenangan itu terus '
        'menemanimu.',
  ),
  PersonalityArchetype(
    theme: PersonalityTheme.kisahNabi,
    name: 'Penikmat Kisah',
    description:
        'Bacaanmu paling banyak berputar pada kisah para nabi dan umat '
        'terdahulu. Setiap kisah menyimpan pelajaran yang bisa direnungkan.',
  ),
  PersonalityArchetype(
    theme: PersonalityTheme.tauhidAkidah,
    name: 'Peneguh Iman',
    description:
        'Bacaanmu paling banyak berputar pada ayat-ayat tentang keesaan '
        'Allah dan hari akhir. Kamu gemar memperkuat keyakinan lewat '
        'Al-Qur\'an.',
  ),
];

/// A "Langkah Selanjutnya" suggestion for one theme: a surah to read next
/// plus a reason template. The weakest theme is recommended to balance the
/// reading.
class ThemeRecommendation {
  const ThemeRecommendation({
    required this.theme,
    required this.surahId,
    required this.reasonTemplate,
  });

  final PersonalityTheme theme;
  final int surahId;

  /// Template with a `{surah}` placeholder replaced by the surah's name.
  final String reasonTemplate;

  String reason(String surahName) =>
      reasonTemplate.replaceAll('{surah}', surahName);
}

/// One recommendation per theme.
const List<ThemeRecommendation> themeRecommendations = [
  ThemeRecommendation(
    theme: PersonalityTheme.sabarSyukur,
    surahId: 94, // Al-Insyirah
    reasonTemplate:
        'Untuk menyeimbangkan bacaanmu, cobalah membaca Surah {surah} — '
        'ayat-ayatnya menguatkan kesabaran dan rasa syukur.',
  ),
  ThemeRecommendation(
    theme: PersonalityTheme.kisahNabi,
    surahId: 12, // Yusuf
    reasonTemplate:
        'Untuk menyeimbangkan bacaanmu, cobalah membaca Surah {surah} — '
        'kisahnya penuh pelajaran tentang keteguhan hati.',
  ),
  ThemeRecommendation(
    theme: PersonalityTheme.tauhidAkidah,
    surahId: 67, // Al-Mulk
    reasonTemplate:
        'Untuk menyeimbangkan bacaanmu, cobalah membaca Surah {surah} — '
        'ayat-ayatnya memperkuat keyakinan pada keesaan Allah.',
  ),
];

/// When the user is most active, from the hour of their logged reads.
enum ReadingTimeSlot { subuh, pagi, siang, sore, malam }

extension ReadingTimeSlotX on ReadingTimeSlot {
  String get label => switch (this) {
        ReadingTimeSlot.subuh => S.personalitySlotSubuh,
        ReadingTimeSlot.pagi => S.personalitySlotPagi,
        ReadingTimeSlot.siang => S.personalitySlotSiang,
        ReadingTimeSlot.sore => S.personalitySlotSore,
        ReadingTimeSlot.malam => S.personalitySlotMalam,
      };
}

/// Hour → slot. Subuh 03:00–06:00, Pagi 06:00–11:00, Siang 11:00–15:00,
/// Sore 15:00–18:00, Malam 18:00–03:00 (wraps past midnight).
ReadingTimeSlot readingSlotForHour(int hour) {
  if (hour >= 3 && hour < 6) return ReadingTimeSlot.subuh;
  if (hour >= 6 && hour < 11) return ReadingTimeSlot.pagi;
  if (hour >= 11 && hour < 15) return ReadingTimeSlot.siang;
  if (hour >= 15 && hour < 18) return ReadingTimeSlot.sore;
  return ReadingTimeSlot.malam;
}