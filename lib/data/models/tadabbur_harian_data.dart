import 'spiritual_content.dart';

/// Tadabbur Harian — a short daily reflection. `arabic` is the ayah,
/// `translation` is the ayah's Indonesian translation, and `note` is the
/// reflection (renungan). One entry per day of the week as a starting set.
const List<SpiritualItem> tadabburHarianItems = [
  SpiritualItem(
    id: 1,
    title: 'Hari Senin — Ikhlas',
    arabic:
        'وَمَآ اُمِرُوْٓا اِلَّا لِيَعْبُدُوا اللّٰهَ مُخْلِصِيْنَ لَهُ الدِّيْنَ ەۙ حُنَفَاۤءَ وَيُقِيْمُوا الصَّلٰوةَ وَيُؤْتُوا الزَّكٰوةَ وَذٰلِكَ دِيْنُ الْقَيِّمَةِ',
    transliteration:
        'Wa maa umiruu illaa liya’budullaaha mukhlishiina lahud diina hunafaa-a wa yuqiimush shalaata wa yu’tuz zakaata wa dzaalika diinul qayyimah.',
    translation:
        'Padahal mereka hanya diperintahkan menyembah Allah dengan ikhlas menaati-Nya semata-mata karena (menjalankan) agama, dan juga agar melaksanakan shalat dan menunaikan zakat; dan yang demikian itulah agama yang lurus (benar). (QS. Al-Bayyinah 98:5)',
    note: 'Renungan: Ikhlas adalah inti dari setiap amal. Ketika niat kita hanya untuk Allah, amal sekecil apa pun menjadi bernilai besar di sisi-Nya.',
  ),
  SpiritualItem(
    id: 2,
    title: 'Hari Selasa — Sabar',
    arabic:
        'يٰٓاَيُّهَا الَّذِيْنَ اٰمَنُوا اسْتَعِيْنُوْا بِالصَّبْرِ وَالصَّلٰوةِ ۗ اِنَّ اللّٰهَ مَعَ الصّٰبِرِيْنَ',
    transliteration:
        'Yaa ayyuhalladziina aamanus ta’iinuu bish shabri wash shalaah, innallaaha ma’ash shaabiriin.',
    translation:
        'Wahai orang-orang yang beriman! Mohonlah pertolongan (kepada Allah) dengan sabar dan shalat. Sungguh, Allah beserta orang-orang yang sabar. (QS. Al-Baqarah 2:153)',
    note: 'Renungan: Kesabaran bukan berarti pasrah tanpa usaha. Sabar adalah tetap teguh dan berdoa di tengah ujian, karena Allah selalu bersama orang-orang yang sabar.',
  ),
  SpiritualItem(
    id: 3,
    title: 'Hari Rabu — Syukur',
    arabic:
        'لَىِٕنْ شَكَرْتُمْ لَاَزِيْدَنَّكُمْ وَلَىِٕنْ كَفَرْتُمْ اِنَّ عَذَابِيْ لَشَدِيْدٌ',
    transliteration:
        'La-in syakartum la-aziidannakum wa la-in kafartum inna ‘adzaabii lasyadiid.',
    translation:
        'Sesungguhnya jika kamu bersyukur, niscaya Aku akan menambah (nikmat) kepadamu, tetapi jika kamu mengingkari (nikmat-Ku), maka pasti azab-Ku sangat berat. (QS. Ibrahim 14:7)',
    note: 'Renungan: Bersyukur bukan sekadar mengucapkan alhamdulillah, tetapi juga menggunakan nikmat di jalan kebaikan. Syukur yang tulus akan mendatangkan tambahan nikmat.',
  ),
  SpiritualItem(
    id: 4,
    title: 'Hari Kamis — Tawakal',
    arabic:
        'وَمَنْ يَّتَوَكَّلْ عَلَى اللّٰهِ فَهُوَ حَسْبُهٗ ۗ اِنَّ اللّٰهَ بَالِغُ اَمْرِهٖ ۗ قَدْ جَعَلَ اللّٰهُ لِكُلِّ شَيْءٍ قَدْرًا',
    transliteration:
        'Wa man yatawakkal ‘alallaahi fahuwa hasbuh. Innallaaha baalighu amrih. Qad ja’alallaahu likulli syai-in qadraa.',
    translation:
        'Dan barang siapa bertawakal kepada Allah, niscaya Allah akan mencukupkan (keperluan)nya. Sesungguhnya Allah melaksanakan urusan-Nya. Sungguh, Allah telah mengadakan ketentuan bagi setiap sesuatu. (QS. At-Talaq 65:3)',
    note: 'Renungan: Tawakal adalah menyerahkan hasil kepada Allah setelah berusaha sebaik mungkin. Allah tidak akan pernah menelantarkan hamba yang berserah diri kepada-Nya.',
  ),
  SpiritualItem(
    id: 5,
    title: 'Hari Jumat — Taubat',
    arabic:
        'قُلْ يٰعِبَادِيَ الَّذِيْنَ اَسْرَفُوْا عَلٰى اَنْفُسِهِمْ لَا تَقْنَطُوْا مِنْ رَّحْمَةِ اللّٰهِ ۗ اِنَّ اللّٰهَ يَغْفِرُ الذُّنُوْبَ جَمِيْعًا ۗ اِنَّهٗ هُوَ الْغَفُوْرُ الرَّحِيْمُ',
    transliteration:
        'Qul yaa ‘ibaadiyalladziina asrafuu ‘alaa anfusihim laa taqnathuu mir rahmatillaah. Innallaaha yaghfirudz dzunuuba jamii’aa. Innahuu huwal ghafuurur rahiim.',
    translation:
        'Katakanlah, "Wahai hamba-hamba-Ku yang melampaui batas terhadap diri mereka sendiri! Janganlah kamu berputus asa dari rahmat Allah. Sesungguhnya Allah mengampuni dosa-dosa semuanya. Sungguh, Dialah Yang Maha Pengampun lagi Maha Penyayang." (QS. Az-Zumar 39:53)',
    note: 'Renungan: Sebesar apa pun kesalahan, rahmat Allah lebih luas. Pintu taubat selalu terbuka, selama kita belum sampai pada ajal dan mau kembali kepada-Nya.',
  ),
  SpiritualItem(
    id: 6,
    title: 'Hari Sabtu — Ukhuwah',
    arabic:
        'اِنَّمَا الْمُؤْمِنُوْنَ اِخْوَةٌ فَاَصْلِحُوْا بَيْنَ اَخَوَيْكُمْ وَاتَّقُوا اللّٰهَ لَعَلَّكُمْ تُرْحَمُوْنَ',
    transliteration:
        'Innamal mu’minuuna ikhwatun fa ashlihuu baina akhawaykum wattaqullaaha la’allakum turhamuun.',
    translation:
        'Sesungguhnya orang-orang mukmin itu bersaudara, karena itu damaikanlah antara kedua saudaramu (yang berselisih) dan bertakwalah kepada Allah agar kamu mendapat rahmat. (QS. Al-Hujurat 49:10)',
    note: 'Renungan: Persaudaraan sesama mukmin adalah ikatan yang kuat. Menjaga kerukunan dan mendamaikan yang berselisih adalah bagian dari ketakwaan.',
  ),
  SpiritualItem(
    id: 7,
    title: 'Hari Ahad — Kehidupan Dunia',
    arabic:
        'اِنَّمَا الْحَيٰوةُ الدُّنْيَا لَعِبٌ وَّلَهْوٌ ۗ وَاِنْ تُؤْمِنُوْا وَتَتَّقُوْا يُؤْتِكُمْ اُجُوْرَكُمْ وَلَا يَسْـَٔلْكُمْ اَمْوَالَكُمْ',
    transliteration:
        'Innamal hayaatud dunyaa la’ibun wa lahw. Wa in tu’minuu wa tattaquu yu’tikum ujuurakum wa laa yas’alkum amwaalakum.',
    translation:
        'Sesungguhnya kehidupan dunia itu hanyalah permainan dan senda gurau. Jika kamu beriman serta bertakwa, Allah akan memberikan pahala kepadamu dan Dia tidak akan meminta harta-hartamu. (QS. Muhammad 47:36)',
    note: 'Renungan: Dunia hanyalah persinggahan sementara. Yang kekal adalah akhirat, karena itu jadikan dunia sebagai ladang amal, bukan tujuan utama.',
  ),
];
