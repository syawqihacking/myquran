/// Which kind of prayer a voice is meant for. Fajr (subuh) adzans are
/// traditionally shorter and use a different melody, so they are selectable
/// separately from the regular voices.
enum AdzanCategory { regular, fajr }

/// A downloadable adzan (call to prayer) voice used as the prayer-notification
/// sound. Audio files are fetched from a remote URL (archive.org or GitHub
/// Releases) and cached in app storage; each voice gets its own notification
/// channel so the sound can be switched without recreating channels.
class AdzanVoice {
  const AdzanVoice({
    required this.id,
    required this.name,
    required this.url,
    required this.license,
    this.category = AdzanCategory.regular,
  });

  final String id;
  final String name;

  /// Direct mp3 download URL (verified live).
  final String url;

  /// License label shown in the picker (CC0 / CC-BY / Public Domain /
  /// Koleksi pribadi).
  final String license;

  /// Which prayer kind this voice is meant for (defaults to [AdzanCategory.regular]).
  final AdzanCategory category;
}

/// Curated adzan recordings. The first group is license-clear archive.org
/// recordings (CC0/CC-BY items are the cleanest; the Public Domain Mark items
/// are field recordings uploaded by their recorders). The second group is the
/// user's personal collection hosted on GitHub Releases (tag v.1.1.0).
const List<AdzanVoice> adzanVoices = [
  // --- archive.org (license-clear) ---
  AdzanVoice(
    id: 'klcc',
    name: 'Adzan Masjid KLCC (Kuala Lumpur)',
    url: 'https://archive.org/download/AzanZhurMasjidKlcc/CallToPrayer.mp3',
    license: 'CC0',
  ),
  AdzanVoice(
    id: 'madinah',
    name: 'Adzan Madinah',
    url: 'https://archive.org/download/AdzanKotaMadinah/AdzanKotaMadinah2.mp3',
    license: 'CC-BY 4.0',
  ),
  AdzanVoice(
    id: 'bosnia',
    name: 'Adzan Bosnia',
    url: 'https://archive.org/download/AdzanKotaBosnia_201808/'
        'Adzan%20Kota%20Bosnia.mp3',
    license: 'CC-BY 4.0',
  ),
  AdzanVoice(
    id: 'doha',
    name: 'Adzan Doha (Fajr)',
    url: 'https://archive.org/download/adhan.recordings.from.doha.qatar/'
        'Adhan_Doha_Qatar_01_Fajr_Adhan.mp3',
    license: 'Public Domain',
    category: AdzanCategory.fajr,
  ),
  AdzanVoice(
    id: 'imadi',
    name: 'Adzan Ahmed al-Imadi',
    url: 'https://archive.org/download/adhan.notifications/'
        'Ahmed_al_Imadi_Adhan.mp3',
    license: 'Public Domain',
  ),

  // --- GitHub Releases v.1.1.0 (koleksi pribadi) ---
  AdzanVoice(
    id: 'adhan_by_muhammad_al_luhaidan',
    name: 'Adzan Muhammad al-Luhaidan',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/adhan_by_muhammad_al-luhaidan.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adhan_from_hawai_by_abderrahim_ed',
    name: 'Adzan Abderrahim (Hawai)',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/adhan_from_hawai_by_abderrahim_ed.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_bosnia',
    name: 'Adzan Bosnia',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/Adzan-Bosnia.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_imam_malaysia',
    name: 'Adzan Imam Malaysia',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/Adzan-imam-Malaysia.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_mesir_1',
    name: 'Adzan Mesir 1',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/adzan-mesir-1.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_mesir_3',
    name: 'Adzan Mesir 3',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/adzan-mesir-3.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_misyari_rasyid',
    name: 'Adzan Misyari Rasyid',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/Adzan-Misyari-Rasyid.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_muhammad_taha_bajunaid',
    name: 'Adzan Muhammad Taha Bajunaid',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/Adzan-Muhammad-Taha-Bajunaid.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_subuh_abu_hazim',
    name: 'Adzan Subuh Abu Hazim',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/Adzan-Shubuh-Abu-Hazim.mp3',
    license: 'Koleksi pribadi',
    category: AdzanCategory.fajr,
  ),
  AdzanVoice(
    id: 'adzan_yusuf_islam_cat_steven',
    name: 'Adzan Yusuf Islam (Cat Stevens)',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/Adzan-Yusuf-Islam-cat-steven.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_abdel_baset',
    name: 'Adzan Abdel Baset',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/adzan_abdel_baset.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_mishari_rashid_al_afasy_2',
    name: 'Adzan Mishari Rashid al-Afasy 2',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/adzan_by_mishari_rashid_al-afasy-2.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_magrib_trans_tv',
    name: 'Adzan Magrib Trans TV',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/adzan_magrib_di_trans_tv.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_turki_1',
    name: 'Adzan Turki 1',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/adzan_turkey-1.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_turki_2',
    name: 'Adzan Turki 2',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/adzan_turkey-2.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_uea',
    name: 'Adzan UEA',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/adzan_uea.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_ahmad_nafees',
    name: 'Adzan Ahmad Nafees',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/Ahmad-Nafees-Adzan.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_alaqsa_1',
    name: 'Adzan Al-Aqsa 1',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/alaqsa1_64_22.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_alaqsa_2',
    name: 'Adzan Al-Aqsa 2',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/alaqsa2_64_22.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_anak_ahmet',
    name: 'Adzan Anak (Ahmet)',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/athan_by_child_ahmet.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_mesir_athan',
    name: 'Adzan Mesir (Athan)',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/athan_egypt.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_tv9_malaysia',
    name: 'Adzan TV9 Malaysia',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/azan_di_tv9_malaysia.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'doa_mendengar_adzan_saad_al_ghamidi',
    name: 'Doa Mendengar Adzan (Saad al-Ghamidi)',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/doa_ketika_mendengarkan_adzan_by_saad_al-ghamidi.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'doa_sesudah_adzan',
    name: 'Doa Sesudah Adzan',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/doa_sesudah_adzan.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'ezan_eropa',
    name: 'Ezan Eropa',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/ezan_from_europe.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_fajr',
    name: 'Adzan Fajr',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/fajr_128_44.mp3',
    license: 'Koleksi pribadi',
    category: AdzanCategory.fajr,
  ),
  AdzanVoice(
    id: 'adzan_hussein_rajab',
    name: 'Adzan Hussein Rajab',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/Hussein-Rajab-Adzan.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_ibrahim_as_sadee',
    name: 'Adzan Ibrahim as-Sadee',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/Ibrahim-As-Sadee-Adzan.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'iqamah',
    name: 'Iqamah',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/iqama.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_fajr_madinah',
    name: 'Adzan Fajr Madinah',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/Madina-Adzan-Fajr.mp3',
    license: 'Koleksi pribadi',
    category: AdzanCategory.fajr,
  ),
  AdzanVoice(
    id: 'adzan_mekkah_2',
    name: 'Adzan Mekkah 2',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/Mecca-Adzan-2.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_mekkah',
    name: 'Adzan Mekkah',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/mecca_56_22.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_pakistan',
    name: 'Adzan Pakistan',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/Pakistan-Adzan.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_suriah',
    name: 'Adzan Suriah',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/Syria-Adzan.mp3',
    license: 'Koleksi pribadi',
  ),
  AdzanVoice(
    id: 'adzan_yusuf_maati',
    name: 'Adzan Yusuf Maati',
    url: 'https://github.com/syawqihacking/myquran/releases/download/'
        'v.1.1.0/Yusuf-Maati-Adzan.mp3',
    license: 'Koleksi pribadi',
  ),
];

/// Looks up a voice by id; falls back to the first (default) voice.
AdzanVoice adzanVoiceById(String id) =>
    adzanVoices.firstWhere((v) => v.id == id, orElse: () => adzanVoices.first);

/// All voices belonging to the given [category].
List<AdzanVoice> adzanVoicesByCategory(AdzanCategory c) =>
    adzanVoices.where((v) => v.category == c).toList();

/// The default (first) voice for the given [category].
AdzanVoice defaultVoiceForCategory(AdzanCategory c) =>
    adzanVoicesByCategory(c).first;