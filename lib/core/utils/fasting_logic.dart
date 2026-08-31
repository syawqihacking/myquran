import 'package:hijri/hijri_calendar.dart';

enum FastingType {
  senin,
  kamis,
  ayyamulBidh,
  arafah,
  asyura,
  none,
}

class FastingInfo {
  final FastingType type;
  final String title;
  final String arabic;
  final String latin;
  final String meaning;

  const FastingInfo({
    required this.type,
    required this.title,
    required this.arabic,
    required this.latin,
    required this.meaning,
  });
}

class FastingLogic {
  /// Returns the fasting information if tomorrow is a Sunnah fasting day.
  /// Returns null if it is not.
  static FastingInfo? getTomorrowFasting() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return getFastingFor(tomorrow);
  }

  /// Returns the fasting information if the given [date] is a Sunnah fasting day.
  static FastingInfo? getFastingFor(DateTime date) {
    final dateHijri = HijriCalendar.fromDate(date);
    
    // Check Arafah (9 Dzulhijjah)
    if (dateHijri.hMonth == 12 && dateHijri.hDay == 9) {
      return const FastingInfo(
        type: FastingType.arafah,
        title: 'Puasa Arafah',
        arabic: 'نَوَيْتُ صَوْمَ عَرَفَةَ سُنَّةً لِلّٰهِ تَعَالَى',
        latin: 'Nawaitu shauma arafata sunnatan lillaahi ta\'aalaa',
        meaning: 'Saya niat puasa sunnah Arafah karena Allah Ta\'ala.',
      );
    }

    // Check Asyura (10 Muharram)
    if (dateHijri.hMonth == 1 && dateHijri.hDay == 10) {
      return const FastingInfo(
        type: FastingType.asyura,
        title: 'Puasa Asyura',
        arabic: 'نَوَيْتُ صَوْمَ عَاشُورَاءَ سُنَّةً لِلّٰهِ تَعَالَى',
        latin: 'Nawaitu shauma aasyuuraa-a sunnatan lillaahi ta\'aalaa',
        meaning: 'Saya niat puasa sunnah Asyura karena Allah Ta\'ala.',
      );
    }

    // Check Ayyamul Bidh (13, 14, 15 of any Hijri month)
    if (dateHijri.hDay == 13 || dateHijri.hDay == 14 || dateHijri.hDay == 15) {
      return const FastingInfo(
        type: FastingType.ayyamulBidh,
        title: 'Puasa Ayyamul Bidh',
        arabic: 'نَوَيْتُ صَوْمَ غَدٍ اَيَّامَ اْلبِيْضِ سُنَّةً لِلَّهِ تَعَالَى',
        latin: 'Nawaitu shauma ghadin ayyaamal biidhi sunnatan lillaahi ta\'aalaa',
        meaning: 'Saya niat puasa sunnah ayyamul bidh besok hari karena Allah Ta\'ala.',
      );
    }

    // Check Senin-Kamis
    if (date.weekday == DateTime.monday) {
      return const FastingInfo(
        type: FastingType.senin,
        title: 'Puasa Senin',
        arabic: 'نَوَيْتُ صَوْمَ يَوْمَ اْلاِثْنَيْنِ سُنَّةً ِللهِ تَعَالَى',
        latin: 'Nawaitu shauma yaumal itsnaini sunnatan lillaahi ta\'aalaa',
        meaning: 'Saya niat puasa sunnah hari Senin karena Allah Ta\'ala.',
      );
    } else if (date.weekday == DateTime.thursday) {
      return const FastingInfo(
        type: FastingType.kamis,
        title: 'Puasa Kamis',
        arabic: 'نَوَيْتُ صَوْمَ يَوْمَ الْخَمِيْسِ سُنَّةً ِللهِ تَعَالَى',
        latin: 'Nawaitu shauma yaumal khamiisi sunnatan lillaahi ta\'aalaa',
        meaning: 'Saya niat puasa sunnah hari Kamis karena Allah Ta\'ala.',
      );
    }

    return null; // Not a fasting day
  }
}
