/// A single item in a spiritual reading (tahlil, doa, ratib).
class SpiritualItem {
  const SpiritualItem({
    required this.id,
    required this.title,
    required this.arabic,
    this.transliteration = '',
    this.translation = '',
    this.note = '',
    this.repeatCount = 1,
  });

  final int id;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String note;
  final int repeatCount;
}

/// Category of spiritual content.
enum SpiritualCategory {
  tahlil,
  doa,
  ratibAlHaddad,
}
