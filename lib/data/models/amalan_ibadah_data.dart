import 'package:flutter/material.dart';

/// Category of a daily deed, used by the filter chips.
enum DeedCategory { wajib, sunnah, dzikir, sosial }

extension DeedCategoryX on DeedCategory {
  /// Indonesian chip/badge label for this category.
  String get label => switch (this) {
        DeedCategory.wajib => 'Wajib',
        DeedCategory.sunnah => 'Sunnah',
        DeedCategory.dzikir => 'Dzikir',
        DeedCategory.sosial => 'Sosial',
      };
}

/// One daily deed (amalan) on the Amalan Ibadah tracker.
class Deed {
  const Deed({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.penjelasan,
    required this.dalil,
  });

  /// Stable id — also the persisted completion key (e.g. `shalat-5-waktu`).
  final String id;
  final String title;
  final DeedCategory category;

  /// One or two grounded sentences shown on the card.
  final String description;
  final IconData icon;

  /// Short grounded explanation shown in the detail sheet.
  final String penjelasan;

  /// Qur'an verse / hadith evidence shown in the detail sheet.
  final String dalil;
}

/// The curated daily-deeds collection (10 items, all four categories).
const List<Deed> amalanDeeds = [
  // --- Wajib ---------------------------------------------------------------
  Deed(
    id: 'shalat-5-waktu',
    title: 'Shalat 5 Waktu',
    category: DeedCategory.wajib,
    description:
        'Menunaikan shalat fardhu lima waktu di awal waktu, berjamaah di masjid bagi laki-laki.',
    icon: Icons.mosque_rounded,
    penjelasan:
        'Shalat lima waktu adalah tiang agama dan kewajiban utama seorang muslim. Menjaganya di awal waktu melatih kedisiplinan dan menghadirkan hati di hadapan Allah.',
    dalil:
        'QS. Al-Ankabut: 45 — "Sungguh, shalat itu mencegah dari perbuatan keji dan mungkar."',
  ),

  // --- Sunnah --------------------------------------------------------------
  Deed(
    id: 'shalat-tahajjud',
    title: 'Shalat Tahajjud',
    category: DeedCategory.sunnah,
    description:
        'Shalat malam setelah bangun tidur, minimal dua rakaat dengan niat ikhlas.',
    icon: Icons.nights_stay_rounded,
    penjelasan:
        'Tahajjud adalah shalat sunnah yang sangat dianjurkan, terutama di sepertiga malam terakhir. Waktu ini adalah saat doa paling mustajab.',
    dalil:
        'QS. Al-Isra: 79 — "Dan pada sebagian malam, lakukanlah shalat tahajud sebagai ibadah tambahan bagimu."',
  ),
  Deed(
    id: 'shalat-dhuha',
    title: 'Shalat Dhuha',
    category: DeedCategory.sunnah,
    description:
        'Shalat sunnah dua rakaat di pagi hari setelah matahari naik setinggi tombak.',
    icon: Icons.wb_sunny_rounded,
    penjelasan:
        'Dhuha adalah shalat sunnah di pagi hari yang disebut sebagai sedekah bagi seluruh persendian tubuh. Banyak yang mengamalkannya untuk kelancaran rezeki.',
    dalil:
        'HR. Muslim — "Dua rakaat dhuha mencukupi semua itu." (tentang sedekah bagi setiap ruas tulang)',
  ),
  Deed(
    id: 'puasa-sunnah',
    title: 'Puasa Sunnah',
    category: DeedCategory.sunnah,
    description:
        'Puasa sunnah seperti Senin-Kamis atau Ayyamul Bidh (tanggal 13, 14, 15 Hijriah).',
    icon: Icons.restaurant_rounded,
    penjelasan:
        'Puasa sunnah melatih pengendalian diri dan mendekatkan diri kepada Allah. Amalan ini ringan namun pahalanya besar.',
    dalil:
        'HR. Tirmidzi — "Amalan-amalan diangkat pada hari Senin dan Kamis, maka aku suka amalanku diangkat saat aku berpuasa."',
  ),

  // --- Dzikir --------------------------------------------------------------
  Deed(
    id: 'tilawah-al-quran',
    title: 'Tilawah Al-Quran',
    category: DeedCategory.dzikir,
    description:
        'Membaca Al-Quran minimal beberapa ayat setiap hari, lebih baik dengan tadabbur.',
    icon: Icons.menu_book_rounded,
    penjelasan:
        'Membaca Al-Quran adalah ibadah yang paling utama bagi lisan. Satu huruf saja mendatangkan sepuluh kebaikan.',
    dalil:
        'HR. Tirmidzi — "Barangsiapa membaca satu huruf dari Kitabullah, maka baginya satu kebaikan, dan satu kebaikan dilipatgandakan sepuluh kali."',
  ),
  Deed(
    id: 'dzikir-pagi-petang',
    title: 'Dzikir Pagi & Petang',
    category: DeedCategory.dzikir,
    description:
        'Membaca wirid dan dzikir yang diajarkan Rasulullah setelah Subuh dan setelah Ashar.',
    icon: Icons.self_improvement_rounded,
    penjelasan:
        'Dzikir pagi dan petang menjaga hati tetap tenang dan mengingat Allah sepanjang hari.',
    dalil:
        'QS. Al-Insan: 25 — "Dan sebutlah nama Tuhanmu pada pagi dan petang."',
  ),
  Deed(
    id: 'doa-sebelum-tidur',
    title: 'Doa Sebelum Tidur',
    category: DeedCategory.dzikir,
    description:
        'Membaca doa dan dzikir sebelum tidur, seperti yang diajarkan Rasulullah.',
    icon: Icons.bedtime_rounded,
    penjelasan:
        'Menutup hari dengan doa menjadikan tidur sebagai ibadah dan memohon perlindungan Allah semalaman.',
    dalil:
        'HR. Bukhari — "Dengan nama-Mu ya Allah, aku mati dan aku hidup."',
  ),

  // --- Sosial --------------------------------------------------------------
  Deed(
    id: 'sedekah',
    title: 'Sedekah',
    category: DeedCategory.sosial,
    description:
        'Memberi sebagian harta, makanan, atau tenaga kepada yang membutuhkan.',
    icon: Icons.volunteer_activism_rounded,
    penjelasan:
        'Sedekah tidak mengurangi harta, justru membersihkan dan melipatgandakannya. Bisa dimulai dari hal yang kecil.',
    dalil: 'HR. Muslim — "Sedekah tidaklah mengurangi harta."',
  ),
  Deed(
    id: 'silaturahmi',
    title: 'Silaturahmi',
    category: DeedCategory.sosial,
    description: 'Menjaga hubungan baik dengan keluarga, kerabat, dan tetangga.',
    icon: Icons.diversity_3_rounded,
    penjelasan:
        'Silaturahmi adalah amalan sosial yang dijanjikan kelapangan rezeki dan panjang umur.',
    dalil:
        'HR. Bukhari — "Barangsiapa ingin dilapangkan rezekinya dan dipanjangkan umurnya, maka sambunglah tali silaturahmi."',
  ),
  Deed(
    id: 'menolong-sesama',
    title: 'Menolong Sesama',
    category: DeedCategory.sosial,
    description: 'Membantu orang lain yang sedang kesulitan, sekecil apa pun.',
    icon: Icons.handshake_rounded,
    penjelasan:
        'Menolong sesama adalah wujud keimanan. Allah menolong hamba-Nya selama hamba itu menolong saudaranya.',
    dalil:
        'HR. Muslim — "Allah akan selalu menolong hamba-Nya selama hamba itu menolong saudaranya."',
  ),
];