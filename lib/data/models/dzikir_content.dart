/// Time of day for a morning/evening dhikr item.
enum DzikirTime { pagi, petang }

/// One morning/evening dhikr (dzikir pagi & petang) entry.
class DzikirItem {
  const DzikirItem({
    required this.id,
    required this.title,
    required this.arabic,
    this.transliteration = '',
    required this.translation,
    this.note = '',
    this.repeatCount = 1,
    required this.time,
  });

  final int id;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String note;
  final int repeatCount;
  final DzikirTime time;
}
