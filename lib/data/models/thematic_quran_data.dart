import 'package:flutter/material.dart';

/// Represents a specific verse reference within a theme.
class ThematicVerseRef {
  const ThematicVerseRef({
    required this.surahNumber,
    required this.ayahNumber,
    this.note,
  });

  final int surahNumber;
  final int ayahNumber;
  final String? note;
}

/// Category grouping for quick filtering
enum ThemeGroup {
  semua,
  ketenangan,
  sabarUjian,
  rezekiIbadah,
  keluargaSosial,
}

/// Represents a curated topic / theme for Quranic exploration.
class QuranThemeCategory {
  const QuranThemeCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.group,
    required this.keywords,
    required this.verses,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final ThemeGroup group;
  final List<String> keywords;
  final List<ThematicVerseRef> verses;
}

/// Curated comprehensive collection of Quranic themes and corresponding verses.
const List<QuranThemeCategory> kQuranThemeCategories = [
  QuranThemeCategory(
    id: 'ketenangan_hati',
    title: 'Ketenangan Hati',
    description: 'Menemukan kedamaian batin dan ketenteraman bersama Allah.',
    icon: Icons.spa_outlined,
    group: ThemeGroup.ketenangan,
    keywords: ['tenang', 'hati', 'tentram', 'damai', 'dzikir', 'mengingat allah', 'jiwa'],
    verses: [
      ThematicVerseRef(surahNumber: 13, ayahNumber: 28, note: 'Hanya dengan mengingat Allah hati menjadi tenteram'),
      ThematicVerseRef(surahNumber: 48, ayahNumber: 4, note: 'Dialah yang menurunkan ketenangan ke dalam hati orang beriman'),
      ThematicVerseRef(surahNumber: 89, ayahNumber: 27, note: 'Wahai jiwa yang tenang, kembalilah kepada Tuhanmu'),
      ThematicVerseRef(surahNumber: 2, ayahNumber: 260, note: 'Agar hatiku bertambah mantap dan tenteram'),
      ThematicVerseRef(surahNumber: 15, ayahNumber: 97, note: 'Kami tahu dadamu menjadi sempit karena perkataan mereka'),
      ThematicVerseRef(surahNumber: 39, ayahNumber: 23, note: 'Kulit dan hati mereka menjadi tenang karena mengingat Allah'),
    ],
  ),
  QuranThemeCategory(
    id: 'kesabaran',
    title: 'Kesabaran',
    description: 'Keteguhan dan keutamaan bersabar dalam menghadapi ujian.',
    icon: Icons.shield_outlined,
    group: ThemeGroup.sabarUjian,
    keywords: ['sabar', 'kesabaran', 'tabah', 'tahan', 'teguh', 'kuat'],
    verses: [
      ThematicVerseRef(surahNumber: 2, ayahNumber: 153, note: 'Jadikanlah sabar dan sholat sebagai penolongmu'),
      ThematicVerseRef(surahNumber: 2, ayahNumber: 155, note: 'Dan sampaikanlah kabar gembira kepada orang-orang yang sabar'),
      ThematicVerseRef(surahNumber: 3, ayahNumber: 200, note: 'Bersabarlah kamu dan kuatkanlah kesabaranmu'),
      ThematicVerseRef(surahNumber: 39, ayahNumber: 10, note: 'Pahala orang yang sabar dicukupkan tanpa batas'),
      ThematicVerseRef(surahNumber: 31, ayahNumber: 17, note: 'Dan bersabarlah terhadap apa yang menimpamu'),
      ThematicVerseRef(surahNumber: 103, ayahNumber: 3, note: 'Nasihat-menasihati dalam kebenaran dan kesabaran'),
    ],
  ),
  QuranThemeCategory(
    id: 'kesedihan',
    title: 'Kesedihan & Duka',
    description: 'Penghiburan di kala hati merasa sedih dan terluka.',
    icon: Icons.favorite_border_rounded,
    group: ThemeGroup.ketenangan,
    keywords: ['sedih', 'duka', 'menangis', 'pilu', 'keluh', 'lara', 'kecewa'],
    verses: [
      ThematicVerseRef(surahNumber: 12, ayahNumber: 86, note: 'Hanya kepada Allah aku mengadukan kesusahan dan kesedihanku'),
      ThematicVerseRef(surahNumber: 9, ayahNumber: 40, note: 'Janganlah engkau bersedih, sesungguhnya Allah bersama kita'),
      ThematicVerseRef(surahNumber: 3, ayahNumber: 139, note: 'Janganlah kamu merasa lemah dan janganlah bersedih hati'),
      ThematicVerseRef(surahNumber: 57, ayahNumber: 23, note: 'Agar kamu tidak bersedih hati terhadap apa yang luput dari kamu'),
      ThematicVerseRef(surahNumber: 2, ayahNumber: 214, note: 'Ingatlah, sesungguhnya pertolongan Allah itu amat dekat'),
    ],
  ),
  QuranThemeCategory(
    id: 'rezeki',
    title: 'Rezeki & Berkah',
    description: 'Jaminan rezeki, pintu kemudahan, dan rezeki tak terduga.',
    icon: Icons.account_balance_wallet_outlined,
    group: ThemeGroup.rezekiIbadah,
    keywords: ['rezeki', 'harta', 'berkah', 'kaya', 'kecukupan', 'pemberian', 'nafkah'],
    verses: [
      ThematicVerseRef(surahNumber: 65, ayahNumber: 2, note: 'Allah akan membukakan jalan keluar baginya'),
      ThematicVerseRef(surahNumber: 65, ayahNumber: 3, note: 'Dan memberinya rezeki dari arah yang tiada disangka-sangka'),
      ThematicVerseRef(surahNumber: 11, ayahNumber: 6, note: 'Tidak ada suatu makhluk pun di bumi melainkan Allah yang menjamin rezekinya'),
      ThematicVerseRef(surahNumber: 34, ayahNumber: 39, note: 'Allah melapangkan dan menyempitkan rezeki bagi siapa yang Dia kehendaki'),
      ThematicVerseRef(surahNumber: 62, ayahNumber: 11, note: 'Dan Allah adalah sebaik-baik pemberi rezeki'),
      ThematicVerseRef(surahNumber: 71, ayahNumber: 10, note: 'Mohonlah ampun, niscaya Dia mengirimkan hujan dan melimpahkan harta'),
    ],
  ),
  QuranThemeCategory(
    id: 'doa',
    title: 'Doa & Munajat',
    description: 'Kedekatan Allah kepada hamba yang memohon dan berharap.',
    icon: Icons.front_hand_outlined,
    group: ThemeGroup.rezekiIbadah,
    keywords: ['doa', 'memohon', 'meminta', 'munajat', 'berharap', 'kabulkan'],
    verses: [
      ThematicVerseRef(surahNumber: 2, ayahNumber: 186, note: 'Aku dekat. Aku mengabulkan permohonan orang yang berdoa'),
      ThematicVerseRef(surahNumber: 40, ayahNumber: 60, note: 'Berdoalah kepada-Ku, niscaya akan Kuperkenankan bagimu'),
      ThematicVerseRef(surahNumber: 21, ayahNumber: 87, note: 'Doa Nabi Yunus di dalam kegelapan: Tiada Tuhan selain Engkau'),
      ThematicVerseRef(surahNumber: 25, ayahNumber: 74, note: 'Doa memohon pasangan dan keturunan penyejuk hati'),
      ThematicVerseRef(surahNumber: 7, ayahNumber: 55, note: 'Berdoalah kepada Tuhanmu dengan rendah hati dan suara lembut'),
    ],
  ),
  QuranThemeCategory(
    id: 'taubat',
    title: 'Taubat & Ampunan',
    description: 'Pintu ampunan dan rahmat Allah yang senantiasa terbuka.',
    icon: Icons.restart_alt_rounded,
    group: ThemeGroup.ketenangan,
    keywords: ['taubat', 'ampun', 'istighfar', 'dosa', 'maaf', 'kembali', 'bersih'],
    verses: [
      ThematicVerseRef(surahNumber: 39, ayahNumber: 53, note: 'Janganlah berputus asa dari rahmat Allah. Allah mengampuni semua dosa'),
      ThematicVerseRef(surahNumber: 4, ayahNumber: 110, note: 'Barangsiapa memohon ampun, Allah Maha Pengampun'),
      ThematicVerseRef(surahNumber: 66, ayahNumber: 8, note: 'Bertaubatlah kepada Allah dengan taubat yang semurni-murninya'),
      ThematicVerseRef(surahNumber: 25, ayahNumber: 70, note: 'Allah mengganti kejahatan mereka dengan kebaikan bagi yang bertaubat'),
      ThematicVerseRef(surahNumber: 3, ayahNumber: 135, note: 'Dan siapa lagi yang dapat mengampuni dosa selain Allah?'),
    ],
  ),
  QuranThemeCategory(
    id: 'motivasi',
    title: 'Motivasi & Harapan',
    description: 'Optimisme dan kemudahan di balik setiap kesulitan hidup.',
    icon: Icons.lightbulb_outline_rounded,
    group: ThemeGroup.ketenangan,
    keywords: ['motivasi', 'semangat', 'harapan', 'mudah', 'sukses', 'optimis', 'kemudahan'],
    verses: [
      ThematicVerseRef(surahNumber: 94, ayahNumber: 5, note: 'Maka sesungguhnya bersama kesulitan ada kemudahan'),
      ThematicVerseRef(surahNumber: 94, ayahNumber: 6, note: 'Sesungguhnya bersama kesulitan ada kemudahan'),
      ThematicVerseRef(surahNumber: 93, ayahNumber: 3, note: 'Tuhanmu tidak meninggalkan engkau dan tidak membencimu'),
      ThematicVerseRef(surahNumber: 93, ayahNumber: 5, note: 'Kelak Tuhanmu pasti memberikan karunia-Nya kepadamu hingga puas'),
      ThematicVerseRef(surahNumber: 2, ayahNumber: 286, note: 'Allah tidak membebani seseorang melainkan sesuai kesanggupannya'),
    ],
  ),
  QuranThemeCategory(
    id: 'bersyukur',
    title: 'Rasa Syukur',
    description: 'Menghargai nikmat Allah dan janji bertambahnya karunia.',
    icon: Icons.sentiment_satisfied_alt_rounded,
    group: ThemeGroup.ketenangan,
    keywords: ['syukur', 'nikmat', 'terima kasih', 'puji', 'alhamdulillah'],
    verses: [
      ThematicVerseRef(surahNumber: 14, ayahNumber: 7, note: 'Jika kamu bersyukur, niscaya Aku akan menambah nikmat kepadamu'),
      ThematicVerseRef(surahNumber: 27, ayahNumber: 40, note: 'Ini karunia Tuhanku untuk mengujiku apakah aku bersyukur atau kufur'),
      ThematicVerseRef(surahNumber: 31, ayahNumber: 12, note: 'Barangsiapa bersyukur, sesungguhnya dia bersyukur untuk dirinya sendiri'),
      ThematicVerseRef(surahNumber: 2, ayahNumber: 152, note: 'Ingatlah kepada-Ku, Aku pun akan ingat kepadamu, dan bersyukurlah'),
      ThematicVerseRef(surahNumber: 55, ayahNumber: 13, note: 'Maka nikmat Tuhanmu yang manakah yang kamu dustakan?'),
    ],
  ),
  QuranThemeCategory(
    id: 'tawakal',
    title: 'Tawakal & Pasrah',
    description: 'Menyerahkan urusan dan bersandar sepenuhnya kepada Allah.',
    icon: Icons.verified_user_outlined,
    group: ThemeGroup.sabarUjian,
    keywords: ['tawakal', 'pasrah', 'berserah', 'percaya', 'yakin', 'sandaran'],
    verses: [
      ThematicVerseRef(surahNumber: 3, ayahNumber: 159, note: 'Apabila engkau telah membulatkan tekad, bertawakallah kepada Allah'),
      ThematicVerseRef(surahNumber: 8, ayahNumber: 2, note: 'Dan hanya kepada Tuhanlah mereka bertawakal'),
      ThematicVerseRef(surahNumber: 65, ayahNumber: 3, note: 'Barangsiapa bertawakal kepada Allah, Dia akan mencukupkannya'),
      ThematicVerseRef(surahNumber: 9, ayahNumber: 129, note: 'Cukuplah Allah bagiku; tidak ada tuhan selain Dia. Kepada-Nya aku bertawakal'),
      ThematicVerseRef(surahNumber: 14, ayahNumber: 12, note: 'Mengapa kami tidak bertawakal padahal Dia telah menunjukkan jalan'),
    ],
  ),
  QuranThemeCategory(
    id: 'orang_tua',
    title: 'Orang Tua & Adab',
    description: 'Berbakti, memuliakan kedua orang tua, dan mendoakan mereka.',
    icon: Icons.people_outline_rounded,
    group: ThemeGroup.keluargaSosial,
    keywords: ['orang tua', 'ibu', 'bapak', 'ayah', 'keluarga', 'anak', 'birrul walidain'],
    verses: [
      ThematicVerseRef(surahNumber: 17, ayahNumber: 23, note: 'Hendaklah berbuat baik kepada ibu bapak dan jangan berkata "ah"'),
      ThematicVerseRef(surahNumber: 17, ayahNumber: 24, note: 'Wahai Tuhanku! Sayangilah keduanya sebagaimana mereka mendidikku waktu kecil'),
      ThematicVerseRef(surahNumber: 31, ayahNumber: 14, note: 'Ibunya telah mengandungnya dalam keadaan lemah yang bertambah-tambah'),
      ThematicVerseRef(surahNumber: 46, ayahNumber: 15, note: 'Doa mensyukuri nikmat dan berbakti kepada orang tua'),
      ThematicVerseRef(surahNumber: 29, ayahNumber: 8, note: 'Kami wajibkan kepada manusia berbuat baik kepada kedua orang tuanya'),
    ],
  ),
  QuranThemeCategory(
    id: 'ujian_cobaan',
    title: 'Ujian & Cobaan',
    description: 'Hikmah di balik cobaan hidup sebagai sarana pemurnian iman.',
    icon: Icons.psychology_outlined,
    group: ThemeGroup.sabarUjian,
    keywords: ['ujian', 'cobaan', 'musibah', 'fitnah', 'bala', 'rintangan'],
    verses: [
      ThematicVerseRef(surahNumber: 29, ayahNumber: 2, note: 'Apakah manusia mengira akan dibiarkan berkata beriman tanpa diuji?'),
      ThematicVerseRef(surahNumber: 2, ayahNumber: 155, note: 'Kami pasti menguji kamu dengan sedikit ketakutan, lapar, dan kekurangan harta'),
      ThematicVerseRef(surahNumber: 67, ayahNumber: 2, note: 'Menciptakan mati dan hidup untuk menguji siapa yang paling baik amalnya'),
      ThematicVerseRef(surahNumber: 76, ayahNumber: 2, note: 'Kami telah menciptakan manusia untuk Kami uji'),
      ThematicVerseRef(surahNumber: 21, ayahNumber: 35, note: 'Kami menguji kamu dengan keburukan dan kebaikan sebagai cobaan'),
    ],
  ),
  QuranThemeCategory(
    id: 'kasih_sayang',
    title: 'Kasih Sayang & Rahmat',
    description: 'Rahmat Allah yang luas dan anjuran saling berkasih sayang.',
    icon: Icons.favorite_outline_rounded,
    group: ThemeGroup.keluargaSosial,
    keywords: ['kasih', 'sayang', 'rahmat', 'cinta', 'lemah lembut', 'peduli'],
    verses: [
      ThematicVerseRef(surahNumber: 7, ayahNumber: 156, note: 'Dan rahmat-Ku meliputi segala sesuatu'),
      ThematicVerseRef(surahNumber: 49, ayahNumber: 10, note: 'Sesungguhnya orang-orang mukmin itu bersaudara, maka damaikanlah'),
      ThematicVerseRef(surahNumber: 90, ayahNumber: 17, note: 'Saling berpesan untuk bersabar dan saling berkasih sayang'),
      ThematicVerseRef(surahNumber: 41, ayahNumber: 34, note: 'Tolaklah kejahatan dengan cara yang baik, musuhmu akan menjadi sahabat'),
      ThematicVerseRef(surahNumber: 16, ayahNumber: 90, note: 'Allah menyuruh berlaku adil dan berbuat kebajikan'),
    ],
  ),
  QuranThemeCategory(
    id: 'keadilan_kejujuran',
    title: 'Keadilan & Kejujuran',
    description: 'Menegakkan integritas, amanah, dan kebenaran tanpa kompromi.',
    icon: Icons.balance_rounded,
    group: ThemeGroup.keluargaSosial,
    keywords: ['adil', 'jujur', 'amanah', 'benar', 'timbangan', 'kesaksian'],
    verses: [
      ThematicVerseRef(surahNumber: 4, ayahNumber: 135, note: 'Jadilah penegak keadilan menjadi saksi karena Allah sekalipun atas diri sendiri'),
      ThematicVerseRef(surahNumber: 5, ayahNumber: 8, note: 'Jangan kebencianmu pada suatu kaum mendorongmu berlaku tidak adil'),
      ThematicVerseRef(surahNumber: 33, ayahNumber: 70, note: 'Bertakwalah kepada Allah dan ucapkanlah perkataan yang benar'),
      ThematicVerseRef(surahNumber: 83, ayahNumber: 1, note: 'Celakalah bagi orang-orang yang curang dalam menakar dan menimbang'),
      ThematicVerseRef(surahNumber: 4, ayahNumber: 58, note: 'Allah menyuruhmu menyampaikan amanat kepada yang berhak menerimanya'),
    ],
  ),
  QuranThemeCategory(
    id: 'ibadah_taqwa',
    title: 'Ibadah & Ketakwaan',
    description: 'Tujuan mulia penciptaan manusia dan keutamaan hamba bertakwa.',
    icon: Icons.mosque_outlined,
    group: ThemeGroup.rezekiIbadah,
    keywords: ['ibadah', 'taqwa', 'shalat', 'sujud', 'takwa', 'taat'],
    verses: [
      ThematicVerseRef(surahNumber: 51, ayahNumber: 56, note: 'Tidaklah Aku menciptakan jin dan manusia melainkan untuk beribadah'),
      ThematicVerseRef(surahNumber: 29, ayahNumber: 45, note: 'Sesungguhnya shalat itu mencegah dari perbuatan keji dan mungkar'),
      ThematicVerseRef(surahNumber: 3, ayahNumber: 102, note: 'Bertakwalah kepada Allah dengan sebenar-benar takwa kepada-Nya'),
      ThematicVerseRef(surahNumber: 49, ayahNumber: 13, note: 'Yang paling mulia di antara kamu di sisi Allah ialah yang paling bertakwa'),
      ThematicVerseRef(surahNumber: 22, ayahNumber: 77, note: 'Rukuklah, sujudlah, dan berbuatlah kebaikan agar kamu beruntung'),
    ],
  ),
  QuranThemeCategory(
    id: 'kematian_akhirat',
    title: 'Kematian & Akhirat',
    description: 'Pengingat akan kepastian ajal dan balasan hari kebangkitan.',
    icon: Icons.hourglass_empty_rounded,
    group: ThemeGroup.ketenangan,
    keywords: ['mati', 'kematian', 'akhirat', 'surga', 'neraka', 'kiamat', 'hisab', 'ajal'],
    verses: [
      ThematicVerseRef(surahNumber: 3, ayahNumber: 185, note: 'Tiap-tiap yang bernyawa akan merasakan mati'),
      ThematicVerseRef(surahNumber: 62, ayahNumber: 8, note: 'Kematian yang kamu lari daripadanya pasti akan menemui kamu'),
      ThematicVerseRef(surahNumber: 50, ayahNumber: 19, note: 'Dan datanglah sakaratul maut dengan sebenar-benarnya'),
      ThematicVerseRef(surahNumber: 56, ayahNumber: 88, note: 'Orang yang didekatkan kepada Allah beroleh ketenteraman dan surga'),
      ThematicVerseRef(surahNumber: 21, ayahNumber: 47, note: 'Kami akan memasang timbangan yang adil pada hari Kiamat'),
    ],
  ),
  QuranThemeCategory(
    id: 'pernikahan_keluarga',
    title: 'Pernikahan & Sakinah',
    description: 'Ikatan suci rumah tangga, cinta, dan ketenteraman bersama.',
    icon: Icons.diversity_1_outlined,
    group: ThemeGroup.keluargaSosial,
    keywords: ['nikah', 'jodoh', 'suami', 'istri', 'pasangan', 'sakinah', 'mahabbah'],
    verses: [
      ThematicVerseRef(surahNumber: 30, ayahNumber: 21, note: 'Menciptakan pasangan agar tenteram, dan dijadikan kasih sayang'),
      ThematicVerseRef(surahNumber: 24, ayahNumber: 32, note: 'Nikahkanlah yang masih sendiri; jika miskin, Allah akan memampukan'),
      ThematicVerseRef(surahNumber: 25, ayahNumber: 74, note: 'Anugerahkan pasangan dan keturunan sebagai penyejuk hati'),
      ThematicVerseRef(surahNumber: 78, ayahNumber: 8, note: 'Dan Kami menciptakan kamu berpasang-pasangan'),
      ThematicVerseRef(surahNumber: 2, ayahNumber: 187, note: 'Mereka adalah pakaian bagimu, dan kamu adalah pakaian bagi mereka'),
    ],
  ),
  QuranThemeCategory(
    id: 'menuntut_ilmu',
    title: 'Menuntut Ilmu',
    description: 'Ketinggian derajat orang yang berilmu dan anjuran belajar.',
    icon: Icons.menu_book_outlined,
    group: ThemeGroup.rezekiIbadah,
    keywords: ['ilmu', 'belajar', 'hikmah', 'paham', 'akal', 'membaca', 'tahu'],
    verses: [
      ThematicVerseRef(surahNumber: 96, ayahNumber: 1, note: 'Bacalah dengan menyebut nama Tuhanmu yang menciptakan'),
      ThematicVerseRef(surahNumber: 20, ayahNumber: 114, note: 'Katakanlah: Ya Tuhanku, tambahkanlah kepadaku ilmu pengetahuan'),
      ThematicVerseRef(surahNumber: 58, ayahNumber: 11, note: 'Allah meninggikan derajat orang beriman dan berilmu beberapa derajat'),
      ThematicVerseRef(surahNumber: 39, ayahNumber: 9, note: 'Adakah sama orang yang mengetahui dengan orang yang tidak mengetahui?'),
      ThematicVerseRef(surahNumber: 2, ayahNumber: 269, note: 'Barangsiapa diberi hikmah, sungguh telah diberi kebaikan yang banyak'),
    ],
  ),
  QuranThemeCategory(
    id: 'memaafkan',
    title: 'Memaafkan & Ikhlas',
    description: 'Kelapangan hati untuk menahan amarah dan memaafkan sesama.',
    icon: Icons.volunteer_activism_outlined,
    group: ThemeGroup.keluargaSosial,
    keywords: ['maaf', 'memaafkan', 'marah', 'lapang dada', 'sabar', 'ikhlas'],
    verses: [
      ThematicVerseRef(surahNumber: 3, ayahNumber: 134, note: 'Orang yang menahan amarah dan memaafkan kesalahan orang lain'),
      ThematicVerseRef(surahNumber: 42, ayahNumber: 40, note: 'Barangsiapa memaafkan dan berbuat baik, pahalanya dijamin Allah'),
      ThematicVerseRef(surahNumber: 24, ayahNumber: 22, note: 'Hendaklah mereka memaafkan dan berlapang dada'),
      ThematicVerseRef(surahNumber: 7, ayahNumber: 199, note: 'Jadilah pemaaf dan suruhlah orang mengerjakan yang makruf'),
    ],
  ),
];
