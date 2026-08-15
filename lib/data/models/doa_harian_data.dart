/// One daily prayer (doa harian) entry, ready for the Doa Harian screen.
class DoaHarian {
  const DoaHarian({
    required this.id,
    required this.title,
    required this.arabic,
    required this.translation,
    required this.category,
  });

  /// Unique latin slug, also the bookmark key (e.g. `doa-sebelum-tidur`).
  final String id;
  final String title;
  final String arabic;
  final String translation;

  /// One of [doaCategories] (also the chip label).
  final String category;
}

/// Category chips, in the Stitch design's order.
const List<String> doaCategories = [
  'Populer',
  'Shalat',
  'Pagi & Petang',
  'Rumah Tangga',
  'Bepergian',
];

/// The daily-prayer collection (doa harian).
const List<DoaHarian> doaHarianItems = [
  // --- Populer -------------------------------------------------------------
  DoaHarian(
    id: 'doa-sebelum-tidur',
    title: 'Doa Sebelum Tidur',
    arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
    translation:
        'Dengan nama-Mu ya Allah, aku mati dan aku hidup. (HR. Bukhari)',
    category: 'Populer',
  ),
  DoaHarian(
    id: 'doa-bangun-tidur',
    title: 'Doa Bangun Tidur',
    arabic:
        'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
    translation:
        'Segala puji bagi Allah yang menghidupkan kami setelah mematikan kami, dan hanya kepada-Nya kami dibangkitkan. (HR. Bukhari)',
    category: 'Populer',
  ),
  DoaHarian(
    id: 'doa-sebelum-makan',
    title: 'Doa Sebelum Makan',
    arabic: 'اللَّهُمَّ بَارِكْ لَنَا فِيمَا رَزَقْتَنَا وَقِنَا عَذَابَ النَّارِ',
    translation:
        'Ya Allah, berkahilah kami dalam rezeki yang Engkau berikan dan peliharalah kami dari siksa api neraka. (HR. Ibnu Sunni)',
    category: 'Populer',
  ),

  // --- Shalat --------------------------------------------------------------
  DoaHarian(
    id: 'doa-masuk-masjid',
    title: 'Doa Masuk Masjid',
    arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
    translation:
        'Ya Allah, bukalah untukku pintu-pintu rahmat-Mu. (HR. Muslim)',
    category: 'Shalat',
  ),
  DoaHarian(
    id: 'doa-keluar-masjid',
    title: 'Doa Keluar Masjid',
    arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
    translation:
        'Ya Allah, sesungguhnya aku memohon karunia-Mu. (HR. Muslim)',
    category: 'Shalat',
  ),
  DoaHarian(
    id: 'doa-setelah-wudhu',
    title: 'Doa Setelah Wudhu',
    arabic:
        'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
    translation:
        'Aku bersaksi bahwa tiada tuhan selain Allah Yang Maha Esa, tiada sekutu bagi-Nya, dan aku bersaksi bahwa Muhammad adalah hamba dan utusan-Nya. (HR. Muslim)',
    category: 'Shalat',
  ),

  // --- Pagi & Petang -------------------------------------------------------
  DoaHarian(
    id: 'doa-pagi-hari',
    title: 'Doa Pagi Hari',
    arabic:
        'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
    translation:
        'Kami memasuki waktu pagi dan kerajaan hanya milik Allah. Segala puji bagi Allah, tiada tuhan selain Allah Yang Maha Esa, tiada sekutu bagi-Nya. (HR. Muslim)',
    category: 'Pagi & Petang',
  ),
  DoaHarian(
    id: 'doa-petang-hari',
    title: 'Doa Petang Hari',
    arabic:
        'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
    translation:
        'Kami memasuki waktu petang dan kerajaan hanya milik Allah. Segala puji bagi Allah, tiada tuhan selain Allah Yang Maha Esa, tiada sekutu bagi-Nya. (HR. Muslim)',
    category: 'Pagi & Petang',
  ),
  DoaHarian(
    id: 'sayyidul-istighfar',
    title: 'Sayyidul Istighfar',
    arabic:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    translation:
        'Ya Allah, Engkau Tuhanku, tiada tuhan selain Engkau. Engkau menciptakanku dan aku hamba-Mu, aku menepati janji-Mu semampuku. Aku berlindung kepada-Mu dari keburukan perbuatanku. Aku mengakui nikmat-Mu atasku dan aku mengakui dosaku, maka ampunilah aku. Sesungguhnya tiada yang mengampuni dosa selain Engkau. (HR. Bukhari)',
    category: 'Pagi & Petang',
  ),

  // --- Rumah Tangga --------------------------------------------------------
  DoaHarian(
    id: 'doa-masuk-rumah',
    title: 'Doa Masuk Rumah',
    arabic:
        'بِسْمِ اللهِ وَلَجْنَا وَبِسْمِ اللهِ خَرَجْنَا وَعَلَى اللهِ رَبِّنَا تَوَكَّلْنَا',
    translation:
        'Dengan nama Allah kami masuk, dengan nama Allah kami keluar, dan kepada Allah Tuhan kami kami bertawakal. (HR. Abu Dawud)',
    category: 'Rumah Tangga',
  ),
  DoaHarian(
    id: 'doa-keluar-rumah',
    title: 'Doa Keluar Rumah',
    arabic:
        'بِسْمِ اللهِ تَوَكَّلْتُ عَلَى اللهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
    translation:
        'Dengan nama Allah aku bertawakal kepada Allah, tiada daya dan upaya kecuali dengan pertolongan Allah. (HR. Tirmidzi)',
    category: 'Rumah Tangga',
  ),
  DoaHarian(
    id: 'doa-untuk-orang-tua',
    title: 'Doa untuk Orang Tua',
    arabic: 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
    translation:
        'Ya Tuhanku, sayangilah keduanya sebagaimana mereka menyayangiku di waktu kecil. (QS. Al-Isra: 24)',
    category: 'Rumah Tangga',
  ),

  // --- Bepergian -----------------------------------------------------------
  DoaHarian(
    id: 'doa-naik-kendaraan',
    title: 'Doa Naik Kendaraan',
    arabic:
        'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
    translation:
        'Maha Suci Allah yang menundukkan kendaraan ini bagi kami, padahal kami sebelumnya tidak mampu menguasainya, dan sesungguhnya kami akan kembali kepada Tuhan kami. (QS. Az-Zukhruf: 13-14)',
    category: 'Bepergian',
  ),
  DoaHarian(
    id: 'doa-sampai-tujuan',
    title: 'Doa Sampai Tujuan',
    arabic:
        'أَسْأَلُكَ خَيْرَهَا وَخَيْرَ أَهْلِهَا وَخَيْرَ مَا فِيهَا وَأَعُوذُ بِكَ مِنْ شَرِّهَا وَشَرِّ أَهْلِهَا وَشَرِّ مَا فِيهَا',
    translation:
        'Ya Allah, aku memohon kebaikan tempat ini, kebaikan penduduknya, dan kebaikan yang ada di dalamnya; dan aku berlindung kepada-Mu dari keburukan tempat ini, keburukan penduduknya, dan keburukan yang ada di dalamnya. (HR. Ibnu Sunni)',
    category: 'Bepergian',
  ),
];