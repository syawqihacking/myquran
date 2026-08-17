import 'spiritual_content.dart';

/// Doa-doa setelah sholat, dikelompokkan per waktu sholat fardhu.
/// Teks placeholder — akan diganti pengguna dengan versi final.

// ── Dzikir umum (dibaca setelah setiap sholat) ──────────────────────────

const List<SpiritualItem> _dzikirUmum = [
  SpiritualItem(
    id: 1,
    title: 'Istighfar',
    arabic: 'أَسْتَغْفِرُ اللهَ الْعَظِيْمَ',
    transliteration: 'Astaghfirullaahal \'azhiim.',
    translation: 'Aku memohon ampun kepada Allah Yang Maha Agung.',
    repeatCount: 3,
  ),
  SpiritualItem(
    id: 2,
    title: 'Doa Setelah Salam',
    arabic:
        'اَللّٰهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
    transliteration:
        'Allaahumma antas-salaamu wa minkas-salaamu tabaarakta yaa dzal-jalaali wal-ikraam.',
    translation:
        'Ya Allah, Engkaulah As-Salaam (sumber keselamatan) dan dari-Mu-lah keselamatan. Mahasuci Engkau, wahai Dzat yang memiliki Keagungan dan Kemuliaan.',
  ),
  SpiritualItem(
    id: 3,
    title: 'Laa Ilaaha Illallah',
    arabic:
        'لَا إِلٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيْكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيْرٌ',
    transliteration:
        'Laa ilaaha illallaahu wahdahuu laa syariika lah, lahul-mulku wa lahul-hamdu wa huwa \'alaa kulli syai-in qadiir.',
    translation:
        'Tidak ada Tuhan selain Allah semata, tidak ada sekutu bagi-Nya. Bagi-Nya segala kerajaan dan segala pujian, dan Dia Mahakuasa atas segala sesuatu.',
  ),
  SpiritualItem(
    id: 4,
    title: 'Tasbih',
    arabic: 'سُبْحَانَ اللهِ',
    transliteration: 'Subhaanallaah.',
    translation: 'Mahasuci Allah.',
    repeatCount: 33,
  ),
  SpiritualItem(
    id: 5,
    title: 'Tahmid',
    arabic: 'اَلْحَمْدُ لِلّٰهِ',
    transliteration: 'Alhamdulillaah.',
    translation: 'Segala puji bagi Allah.',
    repeatCount: 33,
  ),
  SpiritualItem(
    id: 6,
    title: 'Takbir',
    arabic: 'اَللهُ أَكْبَرُ',
    transliteration: 'Allaahu akbar.',
    translation: 'Allah Maha Besar.',
    repeatCount: 33,
  ),
  SpiritualItem(
    id: 7,
    title: 'Tahlil Penutup',
    arabic:
        'لَا إِلٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيْكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيْرٌ',
    transliteration:
        'Laa ilaaha illallaahu wahdahuu laa syariika lah, lahul-mulku wa lahul-hamdu wa huwa \'alaa kulli syai-in qadiir.',
    translation:
        'Tidak ada Tuhan selain Allah semata, tidak ada sekutu bagi-Nya. Bagi-Nya segala kerajaan dan segala pujian, dan Dia Mahakuasa atas segala sesuatu.',
  ),
  SpiritualItem(
    id: 8,
    title: 'Ayat Kursi',
    arabic:
        'اَللهُ لَآ اِلٰهَ اِلَّا هُوَۚ اَلْحَيُّ الْقَيُّوْمُۚ لَا تَأْخُذُهٗ سِنَةٌ وَّلَا نَوْمٌۗ لَهٗ مَا فِى السَّمٰوٰتِ وَمَا فِى الْاَرْضِۗ مَنْ ذَا الَّذِيْ يَشْفَعُ عِنْدَهٗٓ اِلَّا بِاِذْنِهٖۗ يَعْلَمُ مَا بَيْنَ اَيْدِيْهِمْ وَمَا خَلْفَهُمْۗ وَلَا يُحِيْطُوْنَ بِشَيْءٍ مِّنْ عِلْمِهٖٓ اِلَّا بِمَا شَاۤءَۚ وَسِعَ كُرْسِيُّهُ السَّمٰوٰتِ وَالْاَرْضَۚ وَلَا يَـُٔوْدُهٗ حِفْظُهُمَاۚ وَهُوَ الْعَلِيُّ الْعَظِيْمُ',
    transliteration:
        'Allaahu laa ilaaha illaa huwal-hayyul-qayyuum. Laa ta\'khudzuhuu sinatuw wa laa naum. Lahuu maa fis-samaawaati wa maa fil-ardh. Man dzal-ladzii yasyfa\'u \'indahuu illaa bi-idznih. Ya\'lamu maa baina aidiihim wa maa khalfahum. Wa laa yuhiithuuna bisyai-im min \'ilmihii illaa bimaa syaa\'. Wasi\'a kursiyyuhus-samaawaati wal-ardh. Wa laa ya-uuduhuu hifzhuhumaa wa huwal-\'aliyyul-\'azhiim.',
    translation:
        'Allah, tidak ada Tuhan selain Dia, Yang Mahahidup lagi terus-menerus mengurus (makhluk-Nya). Dia tidak dilanda oleh kantuk dan tidak (pula) oleh tidur. Milik-Nya apa yang ada di langit dan apa yang ada di bumi. Tidak ada yang dapat memberi syafaat di sisi-Nya tanpa izin-Nya. Dia mengetahui apa yang ada di hadapan mereka dan apa yang ada di belakang mereka. Mereka tidak mengetahui sesuatu pun dari ilmu-Nya, kecuali apa yang Dia kehendaki. Kursi-Nya meliputi langit dan bumi. Dia tidak merasa berat memelihara keduanya. Dan Dia Mahatinggi lagi Mahaagung.',
  ),
  SpiritualItem(
    id: 9,
    title: 'Doa Kebaikan Dunia & Akhirat',
    arabic:
        'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    transliteration:
        'Rabbanaa aatinaa fid-dunyaa hasanatan wa fil-aakhirati hasanatan wa qinaa \'adzaaban-naar.',
    translation:
        'Ya Tuhan kami, berilah kami kebaikan di dunia dan kebaikan di akhirat, dan peliharalah kami dari siksa api neraka.',
  ),
];

// ── Doa khusus per waktu sholat ─────────────────────────────────────────

const SpiritualItem _doaSubuhKhusus = SpiritualItem(
  id: 100,
  title: 'Doa Khusus Setelah Subuh',
  arabic:
      'اَللّٰهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا طَيِّبًا وَعَمَلًا مُتَقَبَّلًا',
  transliteration:
      'Allaahumma innii as-aluka \'ilman naafi\'an wa rizqan thayyiban wa \'amalan mutaqabbalan.',
  translation:
      'Ya Allah, sesungguhnya aku memohon kepada-Mu ilmu yang bermanfaat, rezeki yang baik, dan amal yang diterima.',
  note: 'Dibaca khusus setelah sholat Subuh (HR. Ibnu Majah)',
);

const SpiritualItem _doaDhuhurKhusus = SpiritualItem(
  id: 101,
  title: 'Doa Khusus Setelah Dhuhur',
  arabic:
      'اَللّٰهُمَّ اجْعَلْ فِي قَلْبِي نُوْرًا وَفِي بَصَرِي نُوْرًا وَفِي سَمْعِي نُوْرًا وَعَنْ يَمِيْنِي نُوْرًا وَعَنْ يَسَارِي نُوْرًا',
  transliteration:
      'Allaahummaj\'al fii qalbii nuuran wa fii bashorii nuuran wa fii sam\'ii nuuran wa \'an yamiinii nuuran wa \'an yasaarii nuuran.',
  translation:
      'Ya Allah, jadikanlah cahaya di hatiku, cahaya di penglihatanku, cahaya di pendengaranku, cahaya di kananku, dan cahaya di kiriku.',
  note: 'Doa memohon cahaya (nur) di waktu pertengahan hari',
);

const SpiritualItem _doaAsarKhusus = SpiritualItem(
  id: 102,
  title: 'Doa Khusus Setelah Asar',
  arabic:
      'اَللّٰهُمَّ إِنِّي أَعُوْذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ وَأَعُوْذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ وَأَعُوْذُ بِكَ مِنَ الْجُبْنِ وَالْبُخْلِ وَأَعُوْذُ بِكَ مِنْ غَلَبَةِ الدَّيْنِ وَقَهْرِ الرِّجَالِ',
  transliteration:
      'Allaahumma innii a\'uudzu bika minal-hammi wal-hazani wa a\'uudzu bika minal-\'ajzi wal-kasali wa a\'uudzu bika minal-jubni wal-bukhli wa a\'uudzu bika min ghalabatid-daini wa qahrir-rijaal.',
  translation:
      'Ya Allah, aku berlindung kepada-Mu dari rasa gundah dan sedih, aku berlindung kepada-Mu dari kelemahan dan kemalasan, aku berlindung kepada-Mu dari sifat pengecut dan kikir, dan aku berlindung kepada-Mu dari lilitan hutang dan penindasan manusia.',
  note: 'Doa perlindungan menjelang petang (HR. Abu Dawud)',
);

const SpiritualItem _doaMaghribKhusus = SpiritualItem(
  id: 103,
  title: 'Doa Khusus Setelah Maghrib',
  arabic:
      'يَا مُقَلِّبَ الْقُلُوْبِ ثَبِّتْ قَلْبِي عَلَى دِيْنِكَ',
  transliteration:
      'Yaa muqallibal-quluubi tsabbit qalbii \'alaa diinik.',
  translation:
      'Wahai Dzat yang membolak-balikkan hati, tetapkanlah hatiku pada agama-Mu.',
  note: 'Doa keteguhan iman di waktu malam (HR. Tirmidzi)',
  repeatCount: 3,
);

const SpiritualItem _doaIsyaKhusus = SpiritualItem(
  id: 104,
  title: 'Doa Khusus Setelah Isya',
  arabic:
      'اَللّٰهُمَّ إِنِّي أَعُوْذُ بِكَ مِنْ عَذَابِ الْقَبْرِ وَمِنْ عَذَابِ النَّارِ وَمِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ وَمِنْ فِتْنَةِ الْمَسِيْحِ الدَّجَّالِ',
  transliteration:
      'Allaahumma innii a\'uudzu bika min \'adzaabil-qabri wa min \'adzaabin-naari wa min fitnatil-mahyaa wal-mamaati wa min fitnatil-masiihid-dajjaal.',
  translation:
      'Ya Allah, aku berlindung kepada-Mu dari azab kubur, dari azab api neraka, dari fitnah kehidupan dan kematian, dan dari fitnah Dajjal.',
  note: 'Doa perlindungan sebelum tidur (HR. Bukhari & Muslim)',
);

// ── Daftar per waktu sholat ─────────────────────────────────────────────

List<SpiritualItem> _withExtra(SpiritualItem extra) {
  return [
    ..._dzikirUmum,
    extra,
  ];
}

final List<SpiritualItem> doaSetelahSubuh = _withExtra(_doaSubuhKhusus);
final List<SpiritualItem> doaSetelahDhuhur = _withExtra(_doaDhuhurKhusus);
final List<SpiritualItem> doaSetelahAsar = _withExtra(_doaAsarKhusus);
final List<SpiritualItem> doaSetelahMaghrib = _withExtra(_doaMaghribKhusus);
final List<SpiritualItem> doaSetelahIsya = _withExtra(_doaIsyaKhusus);

/// Metadata for each prayer time card on the picker screen.
class DoaSholatInfo {
  const DoaSholatInfo({
    required this.name,
    required this.arabicName,
    required this.timeHint,
    required this.items,
  });

  final String name;
  final String arabicName;
  final String timeHint;
  final List<SpiritualItem> items;
}

final List<DoaSholatInfo> doaSholatList = [
  DoaSholatInfo(
    name: 'Subuh',
    arabicName: 'الصُّبْحِ',
    timeHint: 'Fajar — sebelum matahari terbit',
    items: doaSetelahSubuh,
  ),
  DoaSholatInfo(
    name: 'Dhuhur',
    arabicName: 'الظُّهْرِ',
    timeHint: 'Tengah hari — saat matahari condong',
    items: doaSetelahDhuhur,
  ),
  DoaSholatInfo(
    name: 'Asar',
    arabicName: 'الْعَصْرِ',
    timeHint: 'Sore hari — sebelum matahari tenggelam',
    items: doaSetelahAsar,
  ),
  DoaSholatInfo(
    name: 'Maghrib',
    arabicName: 'الْمَغْرِبِ',
    timeHint: 'Petang — setelah matahari tenggelam',
    items: doaSetelahMaghrib,
  ),
  DoaSholatInfo(
    name: 'Isya',
    arabicName: 'الْعِشَاءِ',
    timeHint: 'Malam — saat gelap telah tiba',
    items: doaSetelahIsya,
  ),
];
