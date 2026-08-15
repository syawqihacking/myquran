import 'dzikir_content.dart';

/// Dzikir pagi & petang — the well-known adhkar from the Quran and Sunnah.
/// Each item is marked with [DzikirTime.pagi] or [DzikirTime.petang]; most are
/// read in both, so the same text appears in both sections.
const List<DzikirItem> dzikirPagiPetangItems = [
  // ── Ayat Kursi ─────────────────────────────────────────────────────────
  DzikirItem(
    id: 1,
    title: 'Ayat Kursi (Al-Baqarah 255)',
    arabic:
        'اَللّٰهُ لَآ اِلٰهَ اِلَّا هُوَ الْحَيُّ الْقَيُّوْمُۚ لَا تَأْخُذُهٗ سِنَةٌ وَّلَا نَوْمٌۗ لَهٗ مَا فِى السَّمٰوٰتِ وَمَا فِى الْاَرْضِۗ مَنْ ذَا الَّذِيْ يَشْفَعُ عِنْدَهٗٓ اِلَّا بِاِذْنِهٖۗ يَعْلَمُ مَا بَيْنَ اَيْدِيْهِمْ وَمَا خَلْفَهُمْۖ وَلَا يُحِيْطُوْنَ بِشَيْءٍ مِّنْ عِلْمِهٖٓ اِلَّا بِمَا شَاۤءَۚ وَسِعَ كُرْسِيُّهُ السَّمٰوٰتِ وَالْاَرْضَۚ وَلَا يَـُٔوْدُهٗ حِفْظُهُمَاۚ وَهُوَ الْعَلِيُّ الْعَظِيْمُ',
    transliteration:
        'Allaahu laa ilaaha illaa huwal hayyul qayyuum. Laa ta’khudzuhuu sinatun wa laa naum. Lahuu maa fis samaawaati wa maa fil ardh. Man dzalladzii yasyfa’u ‘indahuu illaa bi-idznih. Ya’lamu maa baina aidiihim wa maa khalfahum wa laa yuhiithuuna bisyai-in min ‘ilmihii illaa bimaa syaa-a. Wasi’a kursiyyuhus samaawaati wal ardh. Wa laa ya-uuduhuu hifzhuhumaa wa huwal ‘aliyyul ‘azhiim.',
    translation:
        'Allah, tidak ada Tuhan selain Dia, Yang Maha Hidup lagi terus-menerus mengurus makhluk-Nya. Tidak mengantuk dan tidak tidur. Milik-Nya apa yang ada di langit dan di bumi. Tidak ada yang dapat memberi syafaat di sisi-Nya tanpa izin-Nya. Dia mengetahui apa yang di hadapan dan di belakang mereka, dan mereka tidak mengetahui sesuatu pun dari ilmu-Nya melainkan apa yang Dia kehendaki. Kursi-Nya meliputi langit dan bumi, dan Dia tidak merasa berat memelihara keduanya. Dan Dia Maha Tinggi lagi Maha Besar.',
    note: 'Dibaca 1 kali setiap pagi dan petang',
    repeatCount: 1,
    time: DzikirTime.pagi,
  ),
  DzikirItem(
    id: 2,
    title: 'Ayat Kursi (Al-Baqarah 255)',
    arabic:
        'اَللّٰهُ لَآ اِلٰهَ اِلَّا هُوَ الْحَيُّ الْقَيُّوْمُۚ لَا تَأْخُذُهٗ سِنَةٌ وَّلَا نَوْمٌۗ لَهٗ مَا فِى السَّمٰوٰتِ وَمَا فِى الْاَرْضِۗ مَنْ ذَا الَّذِيْ يَشْفَعُ عِنْدَهٗٓ اِلَّا بِاِذْنِهٖۗ يَعْلَمُ مَا بَيْنَ اَيْدِيْهِمْ وَمَا خَلْفَهُمْۖ وَلَا يُحِيْطُوْنَ بِشَيْءٍ مِّنْ عِلْمِهٖٓ اِلَّا بِمَا شَاۤءَۚ وَسِعَ كُرْسِيُّهُ السَّمٰوٰتِ وَالْاَرْضَۚ وَلَا يَـُٔوْدُهٗ حِفْظُهُمَاۚ وَهُوَ الْعَلِيُّ الْعَظِيْمُ',
    transliteration:
        'Allaahu laa ilaaha illaa huwal hayyul qayyuum. Laa ta’khudzuhuu sinatun wa laa naum. Lahuu maa fis samaawaati wa maa fil ardh. Man dzalladzii yasyfa’u ‘indahuu illaa bi-idznih. Ya’lamu maa baina aidiihim wa maa khalfahum wa laa yuhiithuuna bisyai-in min ‘ilmihii illaa bimaa syaa-a. Wasi’a kursiyyuhus samaawaati wal ardh. Wa laa ya-uuduhuu hifzhuhumaa wa huwal ‘aliyyul ‘azhiim.',
    translation:
        'Allah, tidak ada Tuhan selain Dia, Yang Maha Hidup lagi terus-menerus mengurus makhluk-Nya. Tidak mengantuk dan tidak tidur. Milik-Nya apa yang ada di langit dan di bumi. Tidak ada yang dapat memberi syafaat di sisi-Nya tanpa izin-Nya. Dia mengetahui apa yang di hadapan dan di belakang mereka, dan mereka tidak mengetahui sesuatu pun dari ilmu-Nya melainkan apa yang Dia kehendaki. Kursi-Nya meliputi langit dan bumi, dan Dia tidak merasa berat memelihara keduanya. Dan Dia Maha Tinggi lagi Maha Besar.',
    note: 'Dibaca 1 kali setiap pagi dan petang',
    repeatCount: 1,
    time: DzikirTime.petang,
  ),

  // ── Al-Ikhlas, Al-Falaq, An-Nas (x3) ───────────────────────────────────
  DzikirItem(
    id: 3,
    title: 'Surat Al-Ikhlas',
    arabic:
        'قُلْ هُوَ اللّٰهُ اَحَدٌۚ اَللّٰهُ الصَّمَدُۚ لَمْ يَلِدْ وَلَمْ يُوْلَدْۙ وَلَمْ يَكُنْ لَّهٗ كُفُوًا اَحَدٌ',
    transliteration:
        'Qul huwallaahu ahad. Allaahush shamad. Lam yalid wa lam yuulad. Wa lam yakul lahuu kufuwan ahad.',
    translation:
        'Katakanlah: Dialah Allah Yang Maha Esa. Allah tempat bergantung segala sesuatu. Dia tidak beranak dan tidak diperanakkan. Dan tidak ada sesuatu pun yang setara dengan-Nya.',
    repeatCount: 3,
    time: DzikirTime.pagi,
  ),
  DzikirItem(
    id: 4,
    title: 'Surat Al-Falaq',
    arabic:
        'قُلْ اَعُوْذُ بِرَبِّ الْفَلَقِۙ مِنْ شَرِّ مَا خَلَقَۙ وَمِنْ شَرِّ غَاسِقٍ اِذَا وَقَبَۙ وَمِنْ شَرِّ النَّفّٰثٰتِ فِى الْعُقَدِۙ وَمِنْ شَرِّ حَاسِدٍ اِذَا حَسَدَ',
    transliteration:
        'Qul a’uudzu birabbil falaq. Min syarri maa khalaq. Wa min syarri ghaasiqin idzaa waqab. Wa min syarrin naffaatsaati fil ‘uqad. Wa min syarri haasidin idzaa hasad.',
    translation:
        'Katakanlah: Aku berlindung kepada Tuhan yang menguasai waktu subuh. Dari kejahatan makhluk-Nya. Dan dari kejahatan malam apabila telah gelap gulita. Dan dari kejahatan para wanita yang meniup pada buhul-buhul (sihir). Dan dari kejahatan orang yang dengki apabila ia dengki.',
    repeatCount: 3,
    time: DzikirTime.pagi,
  ),
  DzikirItem(
    id: 5,
    title: 'Surat An-Nas',
    arabic:
        'قُلْ اَعُوْذُ بِرَبِّ النَّاسِۙ مَلِكِ النَّاسِۙ اِلٰهِ النَّاسِۙ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِۖ الَّذِيْ يُوَسْوِسُ فِيْ صُدُوْرِ النَّاسِۙ مِنَ الْجِنَّةِ وَالنَّاسِ',
    transliteration:
        'Qul a’uudzu birabbinnaas. Malikinnaas. Ilaahinnaas. Min syarril waswaasil khannaas. Alladzii yuwaswisu fii shuduurinnaas. Minal jinnati wannaas.',
    translation:
        'Katakanlah: Aku berlindung kepada Tuhan manusia. Raja manusia. Sembahan manusia. Dari kejahatan (bisikan) setan yang bersembunyi. Yang membisikkan (kejahatan) ke dalam dada manusia. Dari (golongan) jin dan manusia.',
    repeatCount: 3,
    time: DzikirTime.pagi,
  ),
  DzikirItem(
    id: 6,
    title: 'Surat Al-Ikhlas',
    arabic:
        'قُلْ هُوَ اللّٰهُ اَحَدٌۚ اَللّٰهُ الصَّمَدُۚ لَمْ يَلِدْ وَلَمْ يُوْلَدْۙ وَلَمْ يَكُنْ لَّهٗ كُفُوًا اَحَدٌ',
    transliteration:
        'Qul huwallaahu ahad. Allaahush shamad. Lam yalid wa lam yuulad. Wa lam yakul lahuu kufuwan ahad.',
    translation:
        'Katakanlah: Dialah Allah Yang Maha Esa. Allah tempat bergantung segala sesuatu. Dia tidak beranak dan tidak diperanakkan. Dan tidak ada sesuatu pun yang setara dengan-Nya.',
    repeatCount: 3,
    time: DzikirTime.petang,
  ),
  DzikirItem(
    id: 7,
    title: 'Surat Al-Falaq',
    arabic:
        'قُلْ اَعُوْذُ بِرَبِّ الْفَلَقِۙ مِنْ شَرِّ مَا خَلَقَۙ وَمِنْ شَرِّ غَاسِقٍ اِذَا وَقَبَۙ وَمِنْ شَرِّ النَّفّٰثٰتِ فِى الْعُقَدِۙ وَمِنْ شَرِّ حَاسِدٍ اِذَا حَسَدَ',
    transliteration:
        'Qul a’uudzu birabbil falaq. Min syarri maa khalaq. Wa min syarri ghaasiqin idzaa waqab. Wa min syarrin naffaatsaati fil ‘uqad. Wa min syarri haasidin idzaa hasad.',
    translation:
        'Katakanlah: Aku berlindung kepada Tuhan yang menguasai waktu subuh. Dari kejahatan makhluk-Nya. Dan dari kejahatan malam apabila telah gelap gulita. Dan dari kejahatan para wanita yang meniup pada buhul-buhul (sihir). Dan dari kejahatan orang yang dengki apabila ia dengki.',
    repeatCount: 3,
    time: DzikirTime.petang,
  ),
  DzikirItem(
    id: 8,
    title: 'Surat An-Nas',
    arabic:
        'قُلْ اَعُوْذُ بِرَبِّ النَّاسِۙ مَلِكِ النَّاسِۙ اِلٰهِ النَّاسِۙ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِۖ الَّذِيْ يُوَسْوِسُ فِيْ صُدُوْرِ النَّاسِۙ مِنَ الْجِنَّةِ وَالنَّاسِ',
    transliteration:
        'Qul a’uudzu birabbinnaas. Malikinnaas. Ilaahinnaas. Min syarril waswaasil khannaas. Alladzii yuwaswisu fii shuduurinnaas. Minal jinnati wannaas.',
    translation:
        'Katakanlah: Aku berlindung kepada Tuhan manusia. Raja manusia. Sembahan manusia. Dari kejahatan (bisikan) setan yang bersembunyi. Yang membisikkan (kejahatan) ke dalam dada manusia. Dari (golongan) jin dan manusia.',
    repeatCount: 3,
    time: DzikirTime.petang,
  ),

  // ── Sayyidul Istighfar ─────────────────────────────────────────────────
  DzikirItem(
    id: 9,
    title: 'Sayyidul Istighfar',
    arabic:
        'اَللّٰهُمَّ اَنْتَ رَبِّيْ لَا اِلٰهَ اِلَّا اَنْتَ، خَلَقْتَنِيْ وَاَنَا عَبْدُكَ، وَاَنَا عَلٰى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، اَعُوْذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، اَبُوْءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَاَبُوْءُ بِذَنْبِيْ فَاغْفِرْ لِيْ فَاِنَّهُ لَا يَغْفِرُ الذُّنُوْبَ اِلَّا اَنْتَ',
    transliteration:
        'Allaahumma anta rabbii laa ilaaha illaa anta, khalaqtanii wa ana ‘abduka, wa ana ‘alaa ‘ahdika wa wa’dika mastatha’tu, a’uudzu bika min syarri maa shana’tu, abuu-u laka bini’matika ‘alayya, wa abuu-u bidzanbii, faghfir lii fa-innahuu laa yaghfirudz dzunuuba illaa anta.',
    translation:
        'Ya Allah, Engkau adalah Tuhanku, tidak ada Tuhan selain Engkau. Engkau menciptakanku dan aku adalah hamba-Mu. Aku menepati janji-Mu semampuku. Aku berlindung kepada-Mu dari kejahatan yang kuperbuat. Aku mengakui nikmat-Mu kepadaku, dan aku mengakui dosaku. Maka ampunilah aku, sesungguhnya tidak ada yang mengampuni dosa kecuali Engkau.',
    note: 'Barang siapa membacanya di pagi hari dengan yakin, lalu wafat sebelum petang, ia termasuk penghuni surga',
    repeatCount: 1,
    time: DzikirTime.pagi,
  ),
  DzikirItem(
    id: 10,
    title: 'Sayyidul Istighfar',
    arabic:
        'اَللّٰهُمَّ اَنْتَ رَبِّيْ لَا اِلٰهَ اِلَّا اَنْتَ، خَلَقْتَنِيْ وَاَنَا عَبْدُكَ، وَاَنَا عَلٰى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، اَعُوْذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، اَبُوْءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَاَبُوْءُ بِذَنْبِيْ فَاغْفِرْ لِيْ فَاِنَّهُ لَا يَغْفِرُ الذُّنُوْبَ اِلَّا اَنْتَ',
    transliteration:
        'Allaahumma anta rabbii laa ilaaha illaa anta, khalaqtanii wa ana ‘abduka, wa ana ‘alaa ‘ahdika wa wa’dika mastatha’tu, a’uudzu bika min syarri maa shana’tu, abuu-u laka bini’matika ‘alayya, wa abuu-u bidzanbii, faghfir lii fa-innahuu laa yaghfirudz dzunuuba illaa anta.',
    translation:
        'Ya Allah, Engkau adalah Tuhanku, tidak ada Tuhan selain Engkau. Engkau menciptakanku dan aku adalah hamba-Mu. Aku menepati janji-Mu semampuku. Aku berlindung kepada-Mu dari kejahatan yang kuperbuat. Aku mengakui nikmat-Mu kepadaku, dan aku mengakui dosaku. Maka ampunilah aku, sesungguhnya tidak ada yang mengampuni dosa kecuali Engkau.',
    note: 'Barang siapa membacanya di petang hari dengan yakin, lalu wafat sebelum pagi, ia termasuk penghuni surga',
    repeatCount: 1,
    time: DzikirTime.petang,
  ),

  // ── Tasbih / Tahmid / Takbir / Tahlil ──────────────────────────────────
  DzikirItem(
    id: 11,
    title: 'Tasbih',
    arabic: 'سُبْحَانَ اللهِ',
    transliteration: 'Subhaanallaah.',
    translation: 'Maha Suci Allah.',
    repeatCount: 33,
    time: DzikirTime.pagi,
  ),
  DzikirItem(
    id: 12,
    title: 'Tahmid',
    arabic: 'اَلْحَمْدُ لِلّٰهِ',
    transliteration: 'Alhamdulillaah.',
    translation: 'Segala puji bagi Allah.',
    repeatCount: 33,
    time: DzikirTime.pagi,
  ),
  DzikirItem(
    id: 13,
    title: 'Takbir',
    arabic: 'اَللّٰهُ اَكْبَرُ',
    transliteration: 'Allaahu akbar.',
    translation: 'Allah Maha Besar.',
    repeatCount: 33,
    time: DzikirTime.pagi,
  ),
  DzikirItem(
    id: 14,
    title: 'Tahlil',
    arabic: 'لَا اِلٰهَ اِلَّا اللهُ وَحْدَهُ لَا شَرِيْكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلٰى كُلِّ شَيْءٍ قَدِيْرٌ',
    transliteration:
        'Laa ilaaha illallaahu wahdahuu laa syariika lah, lahul mulku wa lahul hamdu wa huwa ‘alaa kulli syai-in qadiir.',
    translation:
        'Tidak ada Tuhan selain Allah semata, tidak ada sekutu bagi-Nya. Milik-Nya kerajaan dan bagi-Nya segala puji, dan Dia Maha Kuasa atas segala sesuatu.',
    note: 'Penutup dzikir pagi, dibaca 1 kali',
    repeatCount: 1,
    time: DzikirTime.pagi,
  ),
  DzikirItem(
    id: 15,
    title: 'Tasbih',
    arabic: 'سُبْحَانَ اللهِ',
    transliteration: 'Subhaanallaah.',
    translation: 'Maha Suci Allah.',
    repeatCount: 33,
    time: DzikirTime.petang,
  ),
  DzikirItem(
    id: 16,
    title: 'Tahmid',
    arabic: 'اَلْحَمْدُ لِلّٰهِ',
    transliteration: 'Alhamdulillaah.',
    translation: 'Segala puji bagi Allah.',
    repeatCount: 33,
    time: DzikirTime.petang,
  ),
  DzikirItem(
    id: 17,
    title: 'Takbir',
    arabic: 'اَللّٰهُ اَكْبَرُ',
    transliteration: 'Allaahu akbar.',
    translation: 'Allah Maha Besar.',
    repeatCount: 33,
    time: DzikirTime.petang,
  ),
  DzikirItem(
    id: 18,
    title: 'Tahlil',
    arabic: 'لَا اِلٰهَ اِلَّا اللهُ وَحْدَهُ لَا شَرِيْكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلٰى كُلِّ شَيْءٍ قَدِيْرٌ',
    transliteration:
        'Laa ilaaha illallaahu wahdahuu laa syariika lah, lahul mulku wa lahul hamdu wa huwa ‘alaa kulli syai-in qadiir.',
    translation:
        'Tidak ada Tuhan selain Allah semata, tidak ada sekutu bagi-Nya. Milik-Nya kerajaan dan bagi-Nya segala puji, dan Dia Maha Kuasa atas segala sesuatu.',
    note: 'Penutup dzikir petang, dibaca 1 kali',
    repeatCount: 1,
    time: DzikirTime.petang,
  ),

  // ── Doa pagi ───────────────────────────────────────────────────────────
  DzikirItem(
    id: 19,
    title: 'Doa Pagi',
    arabic:
        'اَللّٰهُمَّ بِكَ اَصْبَحْنَا، وَبِكَ اَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوْتُ، وَاِلَيْكَ النُّشُوْرُ',
    transliteration:
        'Allaahumma bika ashbahnaa, wa bika amsainaa, wa bika nahyaa, wa bika namuutu, wa ilaikan nusyuur.',
    translation:
        'Ya Allah, dengan-Mu kami memasuki waktu pagi, dengan-Mu kami memasuki waktu petang, dengan-Mu kami hidup, dengan-Mu kami mati, dan hanya kepada-Mu kebangkitan (kami kembali).',
    repeatCount: 1,
    time: DzikirTime.pagi,
  ),
  DzikirItem(
    id: 20,
    title: 'Doa Perlindungan Pagi',
    arabic:
        'بِسْمِ اللهِ الَّذِيْ لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْاَرْضِ وَلَا فِي السَّمَاۤءِ وَهُوَ السَّمِيْعُ الْعَلِيْمُ',
    transliteration:
        'Bismillaahilladzii laa yadhurru ma’asmihii syai-un fil ardhi wa laa fis samaa-i wa huwas samii’ul ‘aliim.',
    translation:
        'Dengan nama Allah yang dengan nama-Nya tidak ada sesuatu pun yang membahayakan, baik di bumi maupun di langit. Dan Dia Maha Mendengar lagi Maha Mengetahui.',
    note: 'Dibaca 3 kali di pagi hari',
    repeatCount: 3,
    time: DzikirTime.pagi,
  ),

  // ── Doa petang ─────────────────────────────────────────────────────────
  DzikirItem(
    id: 21,
    title: 'Doa Petang',
    arabic:
        'اَللّٰهُمَّ بِكَ اَمْسَيْنَا، وَبِكَ اَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوْتُ، وَاِلَيْكَ الْمَصِيْرُ',
    transliteration:
        'Allaahumma bika amsainaa, wa bika ashbahnaa, wa bika nahyaa, wa bika namuutu, wa ilaikal mashiir.',
    translation:
        'Ya Allah, dengan-Mu kami memasuki waktu petang, dengan-Mu kami memasuki waktu pagi, dengan-Mu kami hidup, dengan-Mu kami mati, dan hanya kepada-Mu tempat kembali.',
    repeatCount: 1,
    time: DzikirTime.petang,
  ),
  DzikirItem(
    id: 22,
    title: 'Doa Perlindungan Petang',
    arabic:
        'بِسْمِ اللهِ الَّذِيْ لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْاَرْضِ وَلَا فِي السَّمَاۤءِ وَهُوَ السَّمِيْعُ الْعَلِيْمُ',
    transliteration:
        'Bismillaahilladzii laa yadhurru ma’asmihii syai-un fil ardhi wa laa fis samaa-i wa huwas samii’ul ‘aliim.',
    translation:
        'Dengan nama Allah yang dengan nama-Nya tidak ada sesuatu pun yang membahayakan, baik di bumi maupun di langit. Dan Dia Maha Mendengar lagi Maha Mengetahui.',
    note: 'Dibaca 3 kali di petang hari',
    repeatCount: 3,
    time: DzikirTime.petang,
  ),
];
