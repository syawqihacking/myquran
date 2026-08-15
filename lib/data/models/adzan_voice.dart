/// A downloadable adzan (call to prayer) voice used as the prayer-notification
/// sound. Audio files are fetched from archive.org (license-clear recordings)
/// and cached in app storage; each voice gets its own notification channel so
/// the sound can be switched without recreating channels.
class AdzanVoice {
  const AdzanVoice({
    required this.id,
    required this.name,
    required this.url,
    required this.license,
  });

  final String id;
  final String name;

  /// Direct mp3 download URL (verified live).
  final String url;

  /// License label shown in the picker (CC0 / CC-BY / Public Domain).
  final String license;
}

/// Curated, license-clear adzan recordings (verified live on archive.org).
/// CC0/CC-BY items are the cleanest; the Public Domain Mark items are field
/// recordings uploaded by their recorders. Famous muadzin performances are
/// deliberately excluded (copyrighted).
const List<AdzanVoice> adzanVoices = [
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
  ),
  AdzanVoice(
    id: 'imadi',
    name: 'Adzan Ahmed al-Imadi',
    url: 'https://archive.org/download/adhan.notifications/'
        'Ahmed_al_Imadi_Adhan.mp3',
    license: 'Public Domain',
  ),
];

/// Looks up a voice by id; falls back to the first (default) voice.
AdzanVoice adzanVoiceById(String id) =>
    adzanVoices.firstWhere((v) => v.id == id, orElse: () => adzanVoices.first);