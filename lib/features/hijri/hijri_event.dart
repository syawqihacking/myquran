class HijriEvent {
  const HijriEvent({
    required this.day,
    required this.month,
    required this.title,
    this.description,
  });

  /// 1-30
  final int day;

  /// 1-12
  final int month;

  /// The title of the event (e.g. "Tahun Baru Islam")
  final String title;

  /// Optional description (e.g. "1 Muharram")
  final String? description;
}

const List<HijriEvent> kIslamicEvents = [
  // Muharram
  HijriEvent(day: 1, month: 1, title: 'Tahun Baru Islam (1 Muharram)'),
  HijriEvent(day: 9, month: 1, title: 'Puasa Tasu\'a (9 Muharram)'),
  HijriEvent(day: 10, month: 1, title: 'Puasa \'Asyura (10 Muharram)'),
  HijriEvent(day: 13, month: 1, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 14, month: 1, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 15, month: 1, title: 'Puasa Ayyamul Bidh'),
  // Safar
  HijriEvent(day: 13, month: 2, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 14, month: 2, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 15, month: 2, title: 'Puasa Ayyamul Bidh'),
  // Rabiul Awwal
  HijriEvent(day: 12, month: 3, title: 'Maulid Nabi Muhammad SAW (12 Rabiul Awwal)'),
  HijriEvent(day: 13, month: 3, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 14, month: 3, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 15, month: 3, title: 'Puasa Ayyamul Bidh'),
  // Rabiul Akhir
  HijriEvent(day: 13, month: 4, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 14, month: 4, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 15, month: 4, title: 'Puasa Ayyamul Bidh'),
  // Jumadil Awwal
  HijriEvent(day: 13, month: 5, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 14, month: 5, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 15, month: 5, title: 'Puasa Ayyamul Bidh'),
  // Jumadil Akhir
  HijriEvent(day: 13, month: 6, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 14, month: 6, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 15, month: 6, title: 'Puasa Ayyamul Bidh'),
  // Rajab
  HijriEvent(day: 13, month: 7, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 14, month: 7, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 15, month: 7, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 27, month: 7, title: 'Isra\' Mi\'raj (27 Rajab)'),
  // Sya'ban
  HijriEvent(day: 13, month: 8, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 14, month: 8, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 15, month: 8, title: 'Nisfu Sya\'ban (15 Sya\'ban)'),
  // Ramadan
  HijriEvent(day: 1, month: 9, title: 'Awal Puasa Ramadan (1 Ramadan)'),
  HijriEvent(day: 17, month: 9, title: 'Nuzulul Quran (17 Ramadan)'),
  // Syawal
  HijriEvent(day: 1, month: 10, title: 'Hari Raya Idul Fitri (1 Syawal)'),
  HijriEvent(day: 13, month: 10, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 14, month: 10, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 15, month: 10, title: 'Puasa Ayyamul Bidh'),
  // Dzulqa'dah
  HijriEvent(day: 13, month: 11, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 14, month: 11, title: 'Puasa Ayyamul Bidh'),
  HijriEvent(day: 15, month: 11, title: 'Puasa Ayyamul Bidh'),
  // Dzulhijjah
  HijriEvent(day: 1, month: 12, title: 'Awal Dzulhijjah (1 Dzulhijjah)'),
  HijriEvent(day: 8, month: 12, title: 'Puasa Tarwiyah (8 Dzulhijjah)'),
  HijriEvent(day: 9, month: 12, title: 'Puasa Arafah (9 Dzulhijjah)'),
  HijriEvent(day: 10, month: 12, title: 'Hari Raya Idul Adha (10 Dzulhijjah)'),
  HijriEvent(day: 11, month: 12, title: 'Hari Tasyrik'),
  HijriEvent(day: 12, month: 12, title: 'Hari Tasyrik'),
  HijriEvent(day: 13, month: 12, title: 'Hari Tasyrik'),
];
