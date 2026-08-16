import 'package:flutter/material.dart';

import '../../core/app_strings.dart';

/// The three learning categories on Pusat Belajar.
enum LearningCategory { shalat, ngaji, edukasi }

extension LearningCategoryX on LearningCategory {
  /// Indonesian category name (Belajar Shalat / Belajar Ngaji / Edukasi Islam).
  String get label => switch (this) {
        LearningCategory.shalat => S.learningCatShalat,
        LearningCategory.ngaji => S.learningCatNgaji,
        LearningCategory.edukasi => S.learningCatEdukasi,
      };

  /// Short subtitle on the category card.
  String get subtitle => switch (this) {
        LearningCategory.shalat => S.learningCatShalatSub,
        LearningCategory.ngaji => S.learningCatNgajiSub,
        LearningCategory.edukasi => S.learningCatEdukasiSub,
      };

  IconData get icon => switch (this) {
        LearningCategory.shalat => Icons.self_improvement_rounded,
        LearningCategory.ngaji => Icons.menu_book_rounded,
        LearningCategory.edukasi => Icons.lightbulb_rounded,
      };

  /// Circle background color-role on the category card.
  Color color(ColorScheme scheme) => switch (this) {
        LearningCategory.shalat => scheme.secondaryContainer,
        LearningCategory.ngaji => scheme.tertiaryContainer,
        LearningCategory.edukasi => scheme.primaryContainer,
      };

  /// Foreground color for the icon on top of [color].
  Color onColor(ColorScheme scheme) => switch (this) {
        LearningCategory.shalat => scheme.onSecondaryContainer,
        LearningCategory.ngaji => scheme.onTertiaryContainer,
        LearningCategory.edukasi => scheme.onPrimaryContainer,
      };
}

/// One lesson inside a course. [content] is the lesson body; paragraphs are
/// separated by a blank line (`\n\n`).
class Lesson {
  const Lesson({required this.title, required this.content, this.imageAsset});

  final String title;
  final String content;

  /// Optional asset path to an illustration shown at the top of the lesson.
  final String? imageAsset;
}

/// One course: a curated sequence of real lessons.
class Course {
  const Course({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.lessons,
  });

  /// Stable id — also the progress storage key suffix.
  final String id;
  final LearningCategory category;
  final String title;
  final String description;
  final List<Lesson> lessons;
}

/// The full Pusat Belajar curriculum: 3 categories, 12 courses.
/// Content is real and accurate (fiqh, tajwid, adab, sirah); references are
/// only included where confident of authenticity.
const List<Course> learningCourses = [
  // ── Belajar Shalat (3 courses) ──────────────────────────────────────────
  Course(
    id: 'wudhu',
    category: LearningCategory.shalat,
    title: 'Wudhu',
    description:
        'Urutan wudhu sesuai tuntunan: dari niat hingga membasuh kaki.',
    lessons: [
      Lesson(
        title: 'Niat',
        imageAsset: "assets/wudu'/niat.svg",
        content:
            'Niat wudhu dilakukan dalam hati, bersamaan dengan membasuh wajah '
            '(bagian wudhu yang pertama). Niat membedakan wudhu dari sekadar '
            'mencuci biasa.\n\n'
            'Niat tidak perlu dilafalkan; yang penting hati menyengaja wudhu '
            'karena Allah. Sunnahnya, sebelum wudhu dimulai dengan membaca '
            'basmalah (Bismillah).',
      ),
      Lesson(
        title: 'Membasuh Telapak Tangan',
        imageAsset: "assets/wudu'/membasuhtelapaktangan.svg",
        content:
            'Mulailah dengan membasuh kedua telapak tangan tiga kali, termasuk '
            'sela-sela jari. Ini termasuk sunnah wudhu — mencuci tangan sebelum '
            'memulai rangkaian wudhu.\n\n'
            'Pastikan air merata hingga ke sela-sela jari agar tidak ada bagian '
            'yang kering.',
      ),
      Lesson(
        title: 'Berkumur & Membersihkan Hidung',
        imageAsset: "assets/wudu'/berkumurdanmembersihkanhidung.svg",
        content:
            'Berkumur (madhmadhah) dan menghirup air ke dalam hidung '
            '(istinsyaq) lalu mengeluarkannya (istintsar), masing-masing tiga '
            'kali.\n\n'
            'Menurut jumhur ulama, berkumur dan membersihkan hidung hukumnya '
            'sunnah (sebagian mazhab menghitungnya wajib). Keduanya dilakukan '
            'dengan tangan kanan.',
      ),
      Lesson(
        title: 'Membasuh Wajah',
        imageAsset: "assets/wudu'/membasuhwajah.svg",
        content:
            'Basuh seluruh wajah tiga kali. Batas wajah: dari tumbuhnya rambut '
            '(dahi) hingga dagu, dan dari telinga kanan ke telinga kiri.\n\n'
            'Inilah bagian pertama yang disebut langsung dalam QS Al-Ma\'idah '
            '5:6 — "Maka basuhlah wajahmu". Air harus merata ke seluruh wajah.',
      ),
      Lesson(
        title: 'Membasuh Tangan sampai Siku',
        imageAsset: "assets/wudu'/membasuhtangansampaisiku.svg",
        content:
            'Basuh tangan kanan terlebih dahulu sampai siku, lalu tangan kiri. '
            'Siku termasuk bagian yang wajib dibasuh.\n\n'
            'Sela-sela jari disela dengan jari tangan yang lain agar air '
            'menjangkau seluruh bagian, sesuai QS Al-Ma\'idah 5:6 — "dan '
            'tanganmu sampai ke siku".',
      ),
      Lesson(
        title: 'Mengusap Kepala & Telinga',
        imageAsset: "assets/wudu'/mengusapkepaladantelinga.svg",
        content:
            'Usap kepala dengan air: dari depan ke belakang lalu kembali ke '
            'depan. Sebagian ulama membolehkan mengusap sebagian kepala saja.\n\n'
            'Setelah itu usap kedua telinga — bagian dalam dengan telunjuk dan '
            'bagian luar dengan ibu jari — menggunakan sisa air yang sama, '
            'sesuai QS Al-Ma\'idah 5:6 — "dan sapulah kepalamu".',
      ),
      Lesson(
        title: 'Membasuh Kaki sampai Mata Kaki',
        imageAsset: "assets/wudu'/membasuhkakisampaimatakaki.svg",
        content:
            'Basuh kaki kanan terlebih dahulu sampai mata kaki, lalu kaki '
            'kiri. Mata kaki termasuk bagian yang wajib dibasuh.\n\n'
            'Sela-sela jari kaki disela dengan kelingking agar air merata, '
            'sesuai QS Al-Ma\'idah 5:6 — "dan (basuh) kedua kakimu sampai ke '
            'kedua mata kaki".',
      ),
    ],
  ),
  Course(
    id: 'gerakan-shalat',
    category: LearningCategory.shalat,
    title: 'Gerakan Shalat',
    description:
        'Rukun dan gerakan shalat, dari takbiratul ihram hingga salam.',
    lessons: [
      Lesson(
        title: 'Takbiratul Ihram',
        content:
            'Angkat kedua tangan sejajar bahu atau telinga, lalu ucapkan '
            '"Allahu Akbar". Setelah takbir, kedua tangan dilipat di dada '
            '(bagi laki-laki) atau di dada (bagi perempuan).\n\n'
            'Takbiratul ihram adalah rukun shalat — shalat belum dimulai tanpa '
            'takbir ini. Setelahnya, gerakan di luar shalat dilarang.',
      ),
      Lesson(
        title: 'Berdiri & Membaca Al-Fatihah',
        content:
            'Berdiri tegak bagi yang mampu, lalu membaca Al-Fatihah pada '
            'setiap rakaat. Membaca Al-Fatihah adalah rukun shalat.\n\n'
            'Pada dua rakaat pertama, disunnahkan membaca surah atau beberapa '
            'ayat lain setelah Al-Fatihah. Dianjurkan membaca dengan tartil '
            '(perlahan dan benar).',
      ),
      Lesson(
        title: 'Ruku',
        content:
            'Membungkuk dengan punggung lurus, kedua tangan bertumpu di lutut, '
            'sambil membaca "Subhana Rabbiyal \'Azhim" (Maha Suci Tuhanku Yang '
            'Maha Agung) tiga kali.\n\n'
            'Ruku termasuk rukun shalat. Tuma\'ninah — berhenti sejenak dengan '
            'tenang — wajib dilakukan pada setiap gerakan.',
      ),
      Lesson(
        title: 'I\'tidal',
        content:
            'Bangkit dari ruku sambil mengucapkan "Sami\'allahu liman '
            'hamidah" (Semoga Allah mendengar orang yang memuji-Nya), lalu '
            'berdiri tegak dan membaca "Rabbana lakal hamdu" (Wahai Tuhan '
            'kami, bagi-Mu segala puji).\n\n'
            'Berdiri tegak dengan tuma\'ninah setelah ruku adalah rukun shalat.',
      ),
      Lesson(
        title: 'Sujud',
        content:
            'Sujud dengan tujuh anggota badan menyentuh tempat sujud: dahi, '
            'dua telapak tangan, dua lutut, dan dua ujung kaki. Bacaan: '
            '"Subhana Rabbiyal A\'la" (Maha Suci Tuhanku Yang Maha Tinggi) '
            'tiga kali.\n\n'
            'Sujud adalah rukun shalat dan dilakukan dua kali dalam satu '
            'rakaat, dipisahkan oleh duduk antara dua sujud.',
      ),
      Lesson(
        title: 'Duduk antara Dua Sujud',
        content:
            'Duduk iftirasy — duduk di atas kaki kiri dengan kaki kanan tegak — '
            'sambil membaca "Rabbighfirli" (Wahai Tuhanku, ampunilah aku). '
            'Bacaan lengkapnya memohon ampunan, rahmat, dan petunjuk.\n\n'
            'Duduk antara dua sujud termasuk rukun shalat dan wajib '
            'tuma\'ninah.',
      ),
      Lesson(
        title: 'Tasyahud Akhir',
        content:
            'Pada rakaat terakhir, duduk tawarruk — duduk dengan pantat di '
            'lantai dan kaki kiri di bawah kaki kanan — lalu membaca tasyahud '
            '(tahiyat), shalawat kepada Nabi Muhammad, dan doa.\n\n'
            'Tasyahud akhir termasuk rukun shalat. Setelahnya, salam '
            'menandai selesainya shalat.',
      ),
      Lesson(
        title: 'Salam',
        content:
            'Menoleh ke kanan lalu ke kiri sambil mengucapkan "Assalamu\'alaikum '
            'warahmatullah" (Semoga keselamatan dan rahmat Allah atas kalian).\n\n'
            'Salam menandai berakhirnya shalat. Setelah salam, disunnahkan '
            'berdzikir dan berdoa.',
      ),
    ],
  ),
  Course(
    id: 'doa-shalat',
    category: LearningCategory.shalat,
    title: 'Doa-doa Shalat',
    description:
        'Bacaan dan doa dalam shalat: teks Arab, transliterasi, dan arti.',
    lessons: [
      Lesson(
        title: 'Doa Iftitah',
        content:
            'Teks Arab:\n'
            'اَللّٰهُ اَكْبَرُ كَبِيْرًا وَالْحَمْدُ لِلّٰهِ كَثِيْرًا '
            'وَسُبْحَانَ اللّٰهِ بُكْرَةً وَّاَصِيْلًا\n\n'
            'Transliterasi:\n'
            'Allahu akbaru kabiran, walhamdu lillahi katsiran, wa subhanallahi '
            'bukratan wa ashila.\n\n'
            'Artinya:\n'
            '"Allah Maha Besar dengan kebesaran yang sempurna, segala puji bagi '
            'Allah sebanyak-banyaknya, dan Maha Suci Allah pada pagi dan petang '
            'hari."\n\n'
            'Doa ini dibaca setelah takbiratul ihram, sebelum Al-Fatihah.',
      ),
      Lesson(
        title: 'Doa Ruku',
        content:
            'Teks Arab:\n'
            'سُبْحَانَ رَبِّيَ الْعَظِيْمِ\n\n'
            'Transliterasi:\n'
            'Subhana Rabbiyal \'Azhim.\n\n'
            'Artinya:\n'
            '"Maha Suci Tuhanku Yang Maha Agung."\n\n'
            'Dibaca tiga kali saat ruku. Boleh ditambah doa lain, karena ruku '
            'adalah salah satu tempat mustajab untuk berdoa.',
      ),
      Lesson(
        title: 'Doa I\'tidal',
        content:
            'Teks Arab:\n'
            'رَبَّنَا لَكَ الْحَمْدُ مِلْءَ السَّمٰوَاتِ وَمِلْءَ الْاَرْضِ\n\n'
            'Transliterasi:\n'
            'Rabbana lakal hamdu, mil\'us samawati wa mil\'ul ardhi.\n\n'
            'Artinya:\n'
            '"Wahai Tuhan kami, bagi-Mu segala puji sepenuh langit dan sepenuh '
            'bumi."\n\n'
            'Diucapkan setelah bangkit dari ruku, saat berdiri tegak '
            '(i\'tidal).',
      ),
      Lesson(
        title: 'Doa Sujud',
        content:
            'Teks Arab:\n'
            'سُبْحَانَ رَبِّيَ الْاَعْلٰى\n\n'
            'Transliterasi:\n'
            'Subhana Rabbiyal A\'la.\n\n'
            'Artinya:\n'
            '"Maha Suci Tuhanku Yang Maha Tinggi."\n\n'
            'Dibaca tiga kali saat sujud. Rasulullah bersabda bahwa sujud '
            'adalah saat seorang hamba paling dekat dengan Rabb-nya, sehingga '
            'dianjurkan memperbanyak doa di dalamnya.',
      ),
      Lesson(
        title: 'Doa Duduk antara Dua Sujud',
        content:
            'Teks Arab:\n'
            'رَبِّ اغْفِرْلِيْ وَارْحَمْنِيْ وَاجْبُرْنِيْ وَارْفَعْنِيْ '
            'وَارْزُقْنِيْ وَاهْدِنِيْ وَعَافِنِيْ\n\n'
            'Transliterasi:\n'
            'Rabbighfirli, warhamni, wajburni, warfa\'ni, warzuqni, wahdini, '
            'wa \'afini.\n\n'
            'Artinya:\n'
            '"Wahai Tuhanku, ampunilah aku, rahmatilah aku, cukupkanlah '
            'kekuranganku, angkatlah derajatku, berilah aku rezeki, berilah '
            'aku petunjuk, dan sehatkanlah aku."',
      ),
      Lesson(
        title: 'Doa Tasyahud',
        content:
            'Teks Arab:\n'
            'التَّحِيَّاتُ الْمُبَارَكَاتُ الصَّلَوَاتُ الطَّيِّبَاتُ لِلّٰهِ، '
            'السَّلَامُ عَلَيْكَ اَيُّهَا النَّبِيُّ وَرَحْمَةُ اللّٰهِ '
            'وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا وَعَلٰى عِبَادِ اللّٰهِ '
            'الصَّالِحِيْنَ، اَشْهَدُ اَنْ لَّا اِلٰهَ اِلَّا اللّٰهُ '
            'وَاَشْهَدُ اَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُوْلُهُ\n\n'
            'Transliterasi:\n'
            'Attahiyyatul mubarakatus shalawatut thayyibatu lillah. Assalamu '
            '\'alaika ayyuhan nabiyyu wa rahmatullahi wa barakatuh. Assalamu '
            '\'alaina wa \'ala \'ibadillahish shalihin. Asyhadu an la ilaha '
            'illallah wa asyhadu anna Muhammadan \'abduhu wa rasuluh.\n\n'
            'Artinya:\n'
            '"Segala penghormatan, keberkahan, shalawat, dan kebaikan bagi '
            'Allah. Semoga keselamatan atas engkau wahai Nabi, beserta rahmat '
            'Allah dan berkah-Nya. Keselamatan atas kami dan hamba-hamba Allah '
            'yang saleh. Aku bersaksi tiada Tuhan selain Allah, dan aku '
            'bersaksi bahwa Muhammad adalah hamba dan utusan-Nya."',
      ),
      Lesson(
        title: 'Doa Setelah Salam',
        content:
            'Teks Arab:\n'
            'اَسْتَغْفِرُ اللّٰهَ (٣x) — اَللّٰهُمَّ اَنْتَ السَّلَامُ وَمِنْكَ '
            'السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْاِكْرَامِ\n\n'
            'Transliterasi:\n'
            'Astaghfirullah (3x). Allahumma antas salam, wa minkas salam, '
            'tabarakta ya dzal jalali wal ikram.\n\n'
            'Artinya:\n'
            '"Aku memohon ampun kepada Allah (3x). Ya Allah, Engkaulah Yang '
            'Maha Sejahtera dan dari-Mu kesejahteraan. Maha Berkah Engkau, '
            'wahai Pemilik keagungan dan kemuliaan."',
      ),
    ],
  ),

  // ── Belajar Ngaji (7 courses) ───────────────────────────────────────────
  Course(
    id: 'huruf-hijaiyah',
    category: LearningCategory.ngaji,
    title: 'Huruf Hijaiyah',
    description:
        '28 huruf hijaiyah beserta makhraj (tempat keluar huruf).',
    lessons: [
      Lesson(
        title: 'Alif (ا)',
        content:
            'Makhraj: al-jauf (rongga mulut) sebagai huruf mad; huruf hamzah '
            '(ء) keluar dari pangkal tenggorokan.\n\n'
            'Alif adalah huruf pertama hijaiyah. Saat berharakat fathah dibaca '
            '"a"; sebagai huruf mad dibaca panjang dua harakat.',
      ),
      Lesson(
        title: 'Ba (ب)',
        content:
            'Makhraj: syafawi — kedua bibir dirapatkan.\n\n'
            'Dibaca "ba". Termasuk huruf qalqalah: saat sukun, bunyinya '
            'memantul ringan.',
      ),
      Lesson(
        title: 'Ta (ت)',
        content:
            'Makhraj: lisani — ujung lidah menyentuh pangkal gigi seri atas.\n\n'
            'Dibaca "ta" dengan bunyi tipis.',
      ),
      Lesson(
        title: 'Tsa (ث)',
        content:
            'Makhraj: lisani — ujung lidah menyentuh ujung gigi seri atas.\n\n'
            'Dibaca "tsa", mirip bunyi "th" pada kata bahasa Inggris '
            '"three".',
      ),
      Lesson(
        title: 'Jim (ج)',
        content:
            'Makhraj: lisani — tengah lidah menyentuh langit-langit.\n\n'
            'Dibaca "ja". Termasuk huruf qalqalah.',
      ),
      Lesson(
        title: 'Ha (ح)',
        content:
            'Makhraj: halqi — tengah tenggorokan.\n\n'
            'Dibaca "ha" dengan hembusan halus dari tengah tenggorokan, tanpa '
            'bunyi tebal.',
      ),
      Lesson(
        title: 'Kha (خ)',
        content:
            'Makhraj: halqi — pangkal tenggorokan (dekat mulut).\n\n'
            'Dibaca "kha", mirip bunyi "ch" pada kata bahasa Jerman "Bach".',
      ),
      Lesson(
        title: 'Dal (د)',
        content:
            'Makhraj: lisani — ujung lidah menyentuh pangkal gigi seri atas.\n\n'
            'Dibaca "da". Termasuk huruf qalqalah.',
      ),
      Lesson(
        title: 'Dzal (ذ)',
        content:
            'Makhraj: lisani — ujung lidah menyentuh ujung gigi seri atas.\n\n'
            'Dibaca "dzal", mirip bunyi "th" pada kata bahasa Inggris '
            '"this".',
      ),
      Lesson(
        title: 'Ra (ر)',
        content:
            'Makhraj: lisani — ujung lidah mendekati gusi gigi seri atas, '
            'sedikit masuk ke dalam.\n\n'
            'Dibaca "ra". Bisa dibaca tebal (tafkhim) atau tipis (tarqiq) '
            'tergantung harakat dan posisinya.',
      ),
      Lesson(
        title: 'Zai (ز)',
        content:
            'Makhraj: lisani — ujung lidah dekat gusi gigi seri bawah.\n\n'
            'Dibaca "za".',
      ),
      Lesson(
        title: 'Sin (س)',
        content:
            'Makhraj: lisani — ujung lidah dekat gusi gigi seri bawah.\n\n'
            'Dibaca "sa" dengan bunyi desis tipis.',
      ),
      Lesson(
        title: 'Syin (ش)',
        content:
            'Makhraj: lisani — tengah lidah, sedikit di belakang huruf jim.\n\n'
            'Dibaca "sya".',
      ),
      Lesson(
        title: 'Shad (ص)',
        content:
            'Makhraj: lisani — ujung lidah dekat gusi gigi seri bawah, dengan '
            'bibir sedikit maju.\n\n'
            'Dibaca "sha" dengan bunyi tebal (tafkhim).',
      ),
      Lesson(
        title: 'Dad (ض)',
        content:
            'Makhraj: lisani — tepi lidah menyentuh gigi geraham atas.\n\n'
            'Dibaca "dha" dengan bunyi tebal. Termasuk huruf yang paling sulit '
            'bagi sebagian pembelajar.',
      ),
      Lesson(
        title: 'Tha (ط)',
        content:
            'Makhraj: lisani — ujung lidah menyentuh pangkal gigi seri atas, '
            'dengan bunyi tebal.\n\n'
            'Dibaca "tha" (tebal). Termasuk huruf qalqalah.',
      ),
      Lesson(
        title: 'Zha (ظ)',
        content:
            'Makhraj: lisani — ujung lidah menyentuh ujung gigi seri atas, '
            'dengan bunyi tebal.\n\n'
            'Dibaca "zha" (tebal).',
      ),
      Lesson(
        title: '\'Ain (ع)',
        content:
            'Makhraj: halqi — tengah tenggorokan.\n\n'
            'Dibaca "a" yang keluar dari tengah tenggorokan; bunyi khas yang '
            'tidak ada padanannya dalam bahasa Indonesia.',
      ),
      Lesson(
        title: 'Ghain (غ)',
        content:
            'Makhraj: halqi — pangkal tenggorokan (dekat mulut).\n\n'
            'Dibaca "gha" dengan getaran tenggorokan, mirip bunyi "r" dalam '
            'bahasa Perancis.',
      ),
      Lesson(
        title: 'Fa (ف)',
        content:
            'Makhraj: syafawi — bibir bawah menyentuh ujung gigi seri atas.\n\n'
            'Dibaca "fa".',
      ),
      Lesson(
        title: 'Qaf (ق)',
        content:
            'Makhraj: lisani — pangkal lidah (paling belakang).\n\n'
            'Dibaca "qa" dengan bunyi tebal. Termasuk huruf qalqalah.',
      ),
      Lesson(
        title: 'Kaf (ك)',
        content:
            'Makhraj: lisani — pangkal lidah, sedikit di depan huruf qaf.\n\n'
            'Dibaca "ka" dengan bunyi tipis.',
      ),
      Lesson(
        title: 'Lam (ل)',
        content:
            'Makhraj: lisani — tepi lidah menyentuh gusi gigi seri atas.\n\n'
            'Dibaca "la".',
      ),
      Lesson(
        title: 'Mim (م)',
        content:
            'Makhraj: syafawi — kedua bibir dirapatkan.\n\n'
            'Dibaca "ma". Menjadi dasar hukum bacaan mim sukun: ikhfa syafawi, '
            'idgham mimi, dan izhar syafawi.',
      ),
      Lesson(
        title: 'Nun (ن)',
        content:
            'Makhraj: lisani — ujung lidah menyentuh gusi gigi seri atas.\n\n'
            'Dibaca "na". Menjadi dasar hukum bacaan nun sukun dan tanwin.',
      ),
      Lesson(
        title: 'Ha (ه)',
        content:
            'Makhraj: halqi — pangkal tenggorokan (paling dalam).\n\n'
            'Dibaca "ha" dengan hembusan dari pangkal tenggorokan.',
      ),
      Lesson(
        title: 'Wau (و)',
        content:
            'Makhraj: syafawi — kedua bibir dibulatkan.\n\n'
            'Dibaca "wa". Sebagai huruf mad (sukun setelah dhammah) dibaca '
            'panjang dua harakat.',
      ),
      Lesson(
        title: 'Ya (ي)',
        content:
            'Makhraj: lisani — tengah lidah menyentuh langit-langit.\n\n'
            'Dibaca "ya". Sebagai huruf mad (sukun setelah kasrah) dibaca '
            'panjang dua harakat.',
      ),
    ],
  ),
  Course(
    id: 'harakat',
    category: LearningCategory.ngaji,
    title: 'Harakat',
    description: 'Tanda baca dasar: fathah, kasrah, dhammah, sukun, tasydid.',
    lessons: [
      Lesson(
        title: 'Fathah',
        content:
            'Bentuk: garis miring di atas huruf (ﹷ).\n\n'
            'Cara baca: bunyi "a". Contoh: بَ dibaca "ba".\n\n'
            'Fathah adalah harakat paling dasar yang dipelajari pertama kali '
            'dalam membaca Al-Qur\'an.',
      ),
      Lesson(
        title: 'Kasrah',
        content:
            'Bentuk: garis miring di bawah huruf (ﹻ).\n\n'
            'Cara baca: bunyi "i". Contoh: بِ dibaca "bi".',
      ),
      Lesson(
        title: 'Dhammah',
        content:
            'Bentuk: seperti huruf wau kecil di atas huruf (ﹹ).\n\n'
            'Cara baca: bunyi "u". Contoh: بُ dibaca "bu".',
      ),
      Lesson(
        title: 'Sukun',
        content:
            'Bentuk: lingkaran kecil di atas huruf (ْ).\n\n'
            'Cara baca: huruf mati, tanpa harakat. Contoh: بْ dibaca "b" '
            '(huruf mati).\n\n'
            'Sukun menjadi dasar hukum bacaan seperti nun sukun, mim sukun, '
            'dan qalqalah.',
      ),
      Lesson(
        title: 'Tasydid',
        content:
            'Bentuk: seperti huruf wau kecil (atau "w" kecil) di atas huruf '
            '(ّ).\n\n'
            'Cara baca: huruf dibaca dobel (ditekan). Contoh: بّ dibaca "bba" '
            '— seolah-olah ada dua huruf ba.\n\n'
            'Tasydid menandakan huruf itu bertemu dua kali (satu huruf '
            'berharakat sukun dan satu berharakat).',
      ),
    ],
  ),
  Course(
    id: 'tanwin',
    category: LearningCategory.ngaji,
    title: 'Tanwin',
    description: 'Tanda baca ganda: fathatain, kasratain, dhammatain.',
    lessons: [
      Lesson(
        title: 'Fathatain',
        content:
            'Bentuk: dua garis miring di atas huruf (ً).\n\n'
            'Cara baca: bunyi "an". Contoh: بًا dibaca "ban".',
      ),
      Lesson(
        title: 'Kasratain',
        content:
            'Bentuk: dua garis miring di bawah huruf (ٍ).\n\n'
            'Cara baca: bunyi "in". Contoh: بٍِ dibaca "bin".',
      ),
      Lesson(
        title: 'Dhammatain',
        content:
            'Bentuk: dua dhammah di atas huruf (ٌ).\n\n'
            'Cara baca: bunyi "un". Contoh: بٌ dibaca "bun".\n\n'
            'Tanwin secara hukum dibaca seperti nun sukun, sehingga hukum '
            'bacaannya mengikuti hukum nun sukun (izhar, idgham, iqlab, '
            'ikhfa).',
      ),
    ],
  ),
  Course(
    id: 'mad',
    category: LearningCategory.ngaji,
    title: 'Mad',
    description: 'Panjang bacaan: mad thabi\'i, wajib muttasil, jaiz munfasil.',
    lessons: [
      Lesson(
        title: 'Mad Thabi\'i',
        content:
            'Definisi: mad asli, dibaca panjang dua harakat.\n\n'
            'Terjadi ketika:\n'
            '• Fathah diikuti alif (ا)\n'
            '• Kasrah diikuti ya sukun (يْ)\n'
            '• Dhammah diikuti wau sukun (وْ)\n\n'
            'Contoh: قَالَ (qaala), قِيلَ (qiila), يَقُولُ (yaquulu).',
      ),
      Lesson(
        title: 'Mad Wajib Muttasil',
        content:
            'Definisi: mad thabi\'i bertemu hamzah dalam satu kata.\n\n'
            'Panjang bacaan: 4–5 harakat (wajib panjang).\n\n'
            'Contoh: جَاءَ (jaa-a), السَّمَاء (as-samaa-u).\n\n'
            'Dinamakan "muttasil" karena hamzah dan huruf mad berada dalam '
            'satu kata.',
      ),
      Lesson(
        title: 'Mad Jaiz Munfasil',
        content:
            'Definisi: mad thabi\'i di akhir kata bertemu hamzah di awal kata '
            'berikutnya.\n\n'
            'Panjang bacaan: 2, 4, atau 5 harakat (boleh pendek atau '
            'panjang).\n\n'
            'Contoh: إِنَّا أَعْطَيْنَاكَ — mad pada "إِنَّا" bertemu hamzah '
            'pada kata berikutnya.\n\n'
            'Dinamakan "munfasil" karena huruf mad dan hamzah berada dalam '
            'dua kata yang terpisah.',
      ),
    ],
  ),
  Course(
    id: 'nun-sukun-tanwin',
    category: LearningCategory.ngaji,
    title: 'Nun Sukun & Tanwin',
    description: 'Empat hukum bacaan nun sukun dan tanwin.',
    lessons: [
      Lesson(
        title: 'Izhar Halqi',
        content:
            'Definisi: nun sukun/tanwin dibaca jelas (izhar) tanpa dengung.\n\n'
            'Huruf: 6 huruf halqi — ء (hamzah), ه (ha), ع (\'ain), ح (ha), غ '
            '(ghain), خ (kha).\n\n'
            'Contoh: مِنْ أَمْرِهِ — nun sukun bertemu hamzah, dibaca jelas.',
      ),
      Lesson(
        title: 'Idgham',
        content:
            'Definisi: nun sukun/tanwin dimasukkan (dilebur) ke huruf '
            'berikutnya.\n\n'
            'Terbagi dua:\n'
            '• Idgham Bighunnah — bertemu ي ن م و, dibaca dengan dengung. '
            'Contoh: مَنْ يَقُولُ (mayyaquulu).\n'
            '• Idgham Bilaghunnah — bertemu ل ر, dibaca tanpa dengung. '
            'Contoh: مِنْ رَبِّهِمْ (mirrabbihim).',
      ),
      Lesson(
        title: 'Iqlab',
        content:
            'Definisi: nun sukun/tanwin berubah menjadi bunyi "m" dengan '
            'dengung.\n\n'
            'Huruf: ب (ba).\n\n'
            'Contoh: مِنْ بَعْدِ dibaca "mim ba\'di".\n\n'
            'Dalam mushaf, tanda iqlab biasanya ditulis dengan mim kecil di '
            'atas nun sukun.',
      ),
      Lesson(
        title: 'Ikhfa',
        content:
            'Definisi: nun sukun/tanwin dibaca samar — antara izhar dan '
            'idgham — dengan dengung.\n\n'
            'Huruf: 15 huruf selain huruf izhar, idgham, dan iqlab: ت ث ج د '
            'ذ ز س ش ص ض ط ظ ف ق ك.\n\n'
            'Contoh: مِنْ شَرِّ — nun sukun bertemu syin, dibaca samar dengan '
            'dengung.',
      ),
    ],
  ),
  Course(
    id: 'mim-sukun',
    category: LearningCategory.ngaji,
    title: 'Mim Sukun',
    description: 'Tiga hukum bacaan mim sukun.',
    lessons: [
      Lesson(
        title: 'Ikhfa Syafawi',
        content:
            'Definisi: mim sukun dibaca samar dengan dengung.\n\n'
            'Huruf: ب (ba).\n\n'
            'Contoh: تَرْمِيْهِمْ بِحِجَارَةٍ — mim sukun bertemu ba, dibaca '
            'samar dengan dengung.\n\n'
            'Dinamakan "syafawi" karena mim dan ba sama-sama keluar dari '
            'bibir.',
      ),
      Lesson(
        title: 'Idgham Mimi',
        content:
            'Definisi: mim sukun bertemu mim, dilebur dengan dengung.\n\n'
            'Huruf: م (mim).\n\n'
            'Contoh: لَهُمْ مَا dibaca "lahumma".\n\n'
            'Dinamakan juga idgham mutamatsilain (dua huruf yang sama).',
      ),
      Lesson(
        title: 'Izhar Syafawi',
        content:
            'Definisi: mim sukun dibaca jelas tanpa dengung.\n\n'
            'Huruf: semua huruf selain ب dan م.\n\n'
            'Contoh: عَلَيْهِمْ وَلَا — mim sukun bertemu wau, dibaca jelas.',
      ),
    ],
  ),
  Course(
    id: 'qalqalah',
    category: LearningCategory.ngaji,
    title: 'Qalqalah',
    description: 'Bunyi pantul lima huruf qalqalah: sughra dan kubra.',
    lessons: [
      Lesson(
        title: 'Huruf Qalqalah',
        content:
            'Definisi: qalqalah adalah bunyi pantul (memantul) pada huruf '
            'tertentu ketika sukun.\n\n'
            'Huruf qalqalah ada lima: ق (qaf), ط (tha), ب (ba), ج (jim), د '
            '(dal) — sering disingkat "قُطْبُ جَدٍ".\n\n'
            'Qalqalah terbagi dua: sughra (kecil) dan kubra (besar).',
      ),
      Lesson(
        title: 'Qalqalah Sughra',
        content:
            'Definisi: huruf qalqalah sukun di tengah kata, pantulannya '
            'ringan.\n\n'
            'Contoh: يَجْعَلُ — huruf jim sukun di tengah kata, dibaca '
            'dengan pantulan ringan.',
      ),
      Lesson(
        title: 'Qalqalah Kubra',
        content:
            'Definisi: huruf qalqalah sukun di akhir kata (karena berhenti '
            'atau waqaf), pantulannya lebih kuat.\n\n'
            'Contoh: الْحَمْدُ — huruf dal sukun di akhir kata ketika waqaf, '
            'dibaca dengan pantulan kuat.',
      ),
    ],
  ),

  // ── Edukasi Islam (2 courses) ───────────────────────────────────────────
  Course(
    id: 'adab-sehari-hari',
    category: LearningCategory.edukasi,
    title: 'Adab Sehari-hari',
    description:
        'Adab harian seorang muslim: makan, tidur, berbicara, orang tua, '
        'masjid.',
    lessons: [
      Lesson(
        title: 'Adab Makan',
        content:
            '• Membaca basmalah sebelum makan.\n'
            '• Makan dengan tangan kanan.\n'
            '• Mengambil makanan yang terdekat.\n'
            '• Tidak mencela makanan; jika suka dimakan, jika tidak suka '
            'ditinggalkan.\n'
            '• Tidak berlebihan dalam makan dan minum.\n\n'
            'Dalil: hadits dari Umar bin Abi Salamah — "Wahai anakku, sebutlah '
            'nama Allah, makanlah dengan tangan kananmu, dan makanlah dari '
            'bagian yang dekat denganmu." (HR Bukhari & Muslim).',
      ),
      Lesson(
        title: 'Adab Tidur',
        content:
            '• Berwudhu sebelum tidur.\n'
            '• Tidur dengan posisi miring ke kanan.\n'
            '• Membaca doa tidur dan surah perlindungan (Al-Ikhlas, '
            'Al-Falaq, An-Nas).\n'
            '• Membaca doa bangun tidur.\n\n'
            'Dalil: hadits dari Al-Bara\' bin \'Azib tentang tata cara tidur '
            'yang diajarkan Rasulullah (HR Bukhari).',
      ),
      Lesson(
        title: 'Adab Berbicara',
        content:
            '• Berkata baik atau diam.\n'
            '• Tidak berdusta dan tidak menggunjing (ghibah).\n'
            '• Tidak menyela pembicaraan orang lain.\n'
            '• Berbicara dengan suara yang wajar dan sopan.\n\n'
            'Dalil: hadits — "Barang siapa beriman kepada Allah dan hari '
            'akhir, maka berkatalah baik atau diam." (HR Bukhari & Muslim).',
      ),
      Lesson(
        title: 'Adab kepada Orang Tua',
        content:
            '• Berbakti dan taat dalam kebaikan (birrul walidain).\n'
            '• Tidak berkata "ah" atau membentak keduanya.\n'
            '• Berkata dengan perkataan yang mulia.\n'
            '• Mendoakan keduanya, terutama di usia senja.\n'
            '• Membantu dengan ikhlas tanpa mengeluh.\n\n'
            'Dalil: QS Al-Isra 17:23 — "Dan Tuhanmu telah memerintahkan agar '
            'kamu jangan menyembah selain Dia dan hendaklah berbuat baik '
            'kepada ibu bapakmu."',
      ),
      Lesson(
        title: 'Adab di Masjid',
        content:
            '• Masuk dengan kaki kanan dan membaca doa masuk masjid.\n'
            '• Keluar dengan kaki kiri dan membaca doa keluar masjid.\n'
            '• Tidak mengganggu orang yang sedang shalat atau berzikir.\n'
            '• Menjaga kebersihan dan kesucian masjid.\n'
            '• Tidak berjualan atau mengumumkan barang hilang di masjid.',
      ),
    ],
  ),
  Course(
    id: 'sejarah-nabi',
    category: LearningCategory.edukasi,
    title: 'Sejarah Nabi Muhammad',
    description:
        'Sirah ringkas: dari kelahiran hingga wafat Rasulullah.',
    lessons: [
      Lesson(
        title: 'Kelahiran',
        content:
            'Nabi Muhammad lahir pada Tahun Gajah (sekitar 570 M) di kota '
            'Mekkah, dari pasangan Abdullah bin Abdul Muthalib dan Aminah binti '
            'Wahb. Ayahnya wafat sebelum beliau lahir.\n\n'
            'Beliau lahir di rumah kakeknya, Abdul Muthalib, dan kemudian '
            'disusui oleh Halimah Sa\'diyah dari Bani Sa\'d di pedesaan, '
            'sebagaimana kebiasaan masyarakat Mekkah saat itu.',
      ),
      Lesson(
        title: 'Masa Muda',
        content:
            'Ibu beliau, Aminah, wafat saat beliau berusia sekitar enam '
            'tahun. Setelah itu beliau diasuh kakeknya, Abdul Muthalib, dan '
            'setelah kakeknya wafat, diasuh pamannya, Abu Thalib.\n\n'
            'Sejak kecil beliau dikenal jujur dan dapat dipercaya sehingga '
            'dijuluki al-Amin (yang terpercaya). Beliau pernah menggembala '
            'kambing dan ikut berdagang.\n\n'
            'Pada usia sekitar 25 tahun, beliau menikah dengan Khadijah binti '
            'Khuwailid, seorang pedagang terhormat dari Mekkah.',
      ),
      Lesson(
        title: 'Kenabian',
        content:
            'Pada usia sekitar 40 tahun, beliau menerima wahyu pertama di Gua '
            'Hira: QS Al-\'Alaq 96:1–5 yang dimulai dengan "Iqra" (bacalah). '
            'Wahyu disampaikan oleh Malaikat Jibril.\n\n'
            'Khadijah menjadi orang pertama yang beriman. Setelah itu wahyu '
            'turun secara bertahap selama sekitar 23 tahun hingga akhir hayat '
            'beliau.',
      ),
      Lesson(
        title: 'Dakwah di Mekkah',
        content:
            'Dakwah awal dilakukan secara sembunyi-sembunyi kepada orang-orang '
            'terdekat, lalu berlanjut secara terang-terangan. Banyak penduduk '
            'Mekkah, terutama kaum Quraisy, menentang dakwah ini.\n\n'
            'Sebagian sahabat yang lemah mengalami penyiksaan, sehingga '
            'Rasulullah mengizinkan sebagian kaum muslimin hijrah ke Habasyah '
            '(Etiopia).\n\n'
            'Pada tahun duka cita (amul huzn), Abu Thalib dan Khadijah wafat '
            'dalam waktu yang berdekatan.',
      ),
      Lesson(
        title: 'Hijrah ke Madinah',
        content:
            'Setelah Bai\'at Aqabah dari penduduk Yatsrib, Rasulullah hijrah '
            'ke Madinah bersama Abu Bakar. Peristiwa ini kemudian menjadi awal '
            'penanggalan kalender Hijriah.\n\n'
            'Di Madinah, beliau membangun masjid, mempersaudarakan kaum '
            'Muhajirin dan Anshar, serta menyusun piagam Madinah yang mengatur '
            'kehidupan bersama antar kelompok masyarakat.',
      ),
      Lesson(
        title: 'Kehidupan di Madinah',
        content:
            'Di Madinah, Rasulullah memimpin masyarakat yang majemuk. Terjadi '
            'beberapa peperangan besar, di antaranya Perang Badar, Perang '
            'Uhud, dan Perang Khandaq.\n\n'
            'Pada tahun 6 H, Perjanjian Hudaibiyah ditandatangani, dan pada '
            'tahun 7 H dakwah meluas — utusan dikirim kepada berbagai raja dan '
            'pemimpin untuk mengajak masuk Islam.',
      ),
      Lesson(
        title: 'Fathu Mekkah',
        content:
            'Pada tahun 8 H, kaum Quraisy melanggar Perjanjian Hudaibiyah. '
            'Rasulullah kemudian memasuki Mekkah dengan damai dalam peristiwa '
            'Fathu Mekkah (pembebasan Mekkah).\n\n'
            'Beliau membersihkan Ka\'bah dari berhala dan memberikan amnesti '
            '(pengampunan) kepada penduduk Mekkah, termasuk kepada mereka yang '
            'sebelumnya memusuhi dakwah.',
      ),
      Lesson(
        title: 'Wafat',
        content:
            'Pada tahun 10 H, Rasulullah melaksanakan Haji Wada\' (haji '
            'perpisahan) dan menyampaikan khutbah terakhir di Arafah.\n\n'
            'Beliau wafat pada 12 Rabiul Awal tahun 11 H (sekitar 632 M) di '
            'Madinah, di rumah Aisyah, dan dimakamkan di tempat yang sama.\n\n'
            'Sepeninggal beliau, kepemimpinan umat dilanjutkan oleh '
            'para sahabat.',
      ),
    ],
  ),
];