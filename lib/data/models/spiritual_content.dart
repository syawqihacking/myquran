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
    this.label = '',
  });

  final int id;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String note;
  final int repeatCount;

  /// Optional short type label (e.g. "AL-FATIHAH", "AYAT KURSI") shown as the
  /// type chip on the Ratibul Haddad item cards. Empty means no chip.
  final String label;
}

/// Category of spiritual content.
enum SpiritualCategory {
  tahlil,
  doa,
  ratibAlHaddad,
}
