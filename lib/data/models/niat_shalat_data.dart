import 'spiritual_content.dart';

/// Niat (intention) for the five daily prayers plus common sunnah prayers.
/// Each item is shown in the SpiritualReaderScreen.
const List<SpiritualItem> niatShalatItems = [
  // ── Shalat wajib ───────────────────────────────────────────────────────
  SpiritualItem(
    id: 1,
    title: 'Niat Shalat Subuh',
    arabic:
        'اُصَلِّيْ فَرْضَ الصُّبْحِ رَكْعَتَيْنِ مُسْتَقْبِلَ الْقِبْلَةِ اَدَاءً مَأْمُوْمًا لِلّٰهِ تَعَالَى',
    transliteration:
        'Ushollii fardlash shubhi rak’ataini mustaqbilal qiblati adaa-an ma’muuman lillaahi ta’aalaa.',
    translation:
        'Aku berniat shalat fardhu Subuh dua rakaat menghadap kiblat, sebagai makmum, karena Allah Ta’ala.',
    note: 'Jika shalat sendirian, ganti "ma\'muuman" dengan "imaaman" atau "lillaahi ta\'aalaa" tanpa keduanya',
  ),
  SpiritualItem(
    id: 2,
    title: 'Niat Shalat Dzuhur',
    arabic:
        'اُصَلِّيْ فَرْضَ الظُّهْرِ اَرْبَعَ رَكَعَاتٍ مُسْتَقْبِلَ الْقِبْلَةِ اَدَاءً مَأْمُوْمًا لِلّٰهِ تَعَالَى',
    transliteration:
        'Ushollii fardhazh zhuhri arba’a raka’aatin mustaqbilal qiblati adaa-an ma’muuman lillaahi ta’aalaa.',
    translation:
        'Aku berniat shalat fardhu Dzuhur empat rakaat menghadap kiblat, sebagai makmum, karena Allah Ta’ala.',
  ),
  SpiritualItem(
    id: 3,
    title: 'Niat Shalat Ashar',
    arabic:
        'اُصَلِّيْ فَرْضَ الْعَصْرِ اَرْبَعَ رَكَعَاتٍ مُسْتَقْبِلَ الْقِبْلَةِ اَدَاءً مَأْمُوْمًا لِلّٰهِ تَعَالَى',
    transliteration:
        'Ushollii fardhal ‘ashri arba’a raka’aatin mustaqbilal qiblati adaa-an ma’muuman lillaahi ta’aalaa.',
    translation:
        'Aku berniat shalat fardhu Ashar empat rakaat menghadap kiblat, sebagai makmum, karena Allah Ta’ala.',
  ),
  SpiritualItem(
    id: 4,
    title: 'Niat Shalat Maghrib',
    arabic:
        'اُصَلِّيْ فَرْضَ الْمَغْرِبِ ثَلَاثَ رَكَعَاتٍ مُسْتَقْبِلَ الْقِبْلَةِ اَدَاءً مَأْمُوْمًا لِلّٰهِ تَعَالَى',
    transliteration:
        'Ushollii fardhal maghribi tsalaatsa raka’aatin mustaqbilal qiblati adaa-an ma’muuman lillaahi ta’aalaa.',
    translation:
        'Aku berniat shalat fardhu Maghrib tiga rakaat menghadap kiblat, sebagai makmum, karena Allah Ta’ala.',
  ),
  SpiritualItem(
    id: 5,
    title: 'Niat Shalat Isya',
    arabic:
        'اُصَلِّيْ فَرْضَ الْعِشَاءِ اَرْبَعَ رَكَعَاتٍ مُسْتَقْبِلَ الْقِبْلَةِ اَدَاءً مَأْمُوْمًا لِلّٰهِ تَعَالَى',
    transliteration:
        'Ushollii fardhal ‘isyaa-i arba’a raka’aatin mustaqbilal qiblati adaa-an ma’muuman lillaahi ta’aalaa.',
    translation:
        'Aku berniat shalat fardhu Isya empat rakaat menghadap kiblat, sebagai makmum, karena Allah Ta’ala.',
  ),

  // ── Shalat sunnah ──────────────────────────────────────────────────────
  SpiritualItem(
    id: 6,
    title: 'Niat Shalat Rawatib Qabliyah Subuh',
    arabic:
        'اُصَلِّيْ سُنَّةَ الصُّبْحِ رَكْعَتَيْنِ قَبْلِيَّةً لِلّٰهِ تَعَالَى',
    transliteration:
        'Ushollii sunnatal shubhi rak’ataini qabliyyatan lillaahi ta’aalaa.',
    translation:
        'Aku berniat shalat sunnah Subuh dua rakaat sebelum (qabliyah), karena Allah Ta’ala.',
  ),
  SpiritualItem(
    id: 7,
    title: 'Niat Shalat Dhuha',
    arabic:
        'اُصَلِّيْ سُنَّةَ الضُّحٰى رَكْعَتَيْنِ لِلّٰهِ تَعَالَى',
    transliteration:
        'Ushollii sunnatadh dhuhaa rak’ataini lillaahi ta’aalaa.',
    translation:
        'Aku berniat shalat sunnah Dhuha dua rakaat, karena Allah Ta’ala.',
  ),
  SpiritualItem(
    id: 8,
    title: 'Niat Shalat Tahajud',
    arabic:
        'اُصَلِّيْ سُنَّةَ التَّهَجُّدِ رَكْعَتَيْنِ لِلّٰهِ تَعَالَى',
    transliteration:
        'Ushollii sunnatat tahajjudi rak’ataini lillaahi ta’aalaa.',
    translation:
        'Aku berniat shalat sunnah Tahajud dua rakaat, karena Allah Ta’ala.',
  ),
  SpiritualItem(
    id: 9,
    title: 'Niat Shalat Witir',
    arabic:
        'اُصَلِّيْ سُنَّةَ الْوِتْرِ ثَلَاثَ رَكَعَاتٍ لِلّٰهِ تَعَالَى',
    transliteration:
        'Ushollii sunnatal witri tsalaatsa raka’aatin lillaahi ta’aalaa.',
    translation:
        'Aku berniat shalat sunnah Witir tiga rakaat, karena Allah Ta’ala.',
  ),
  SpiritualItem(
    id: 10,
    title: 'Niat Shalat Rawatib Ba\'diyah Maghrib',
    arabic:
        'اُصَلِّيْ سُنَّةَ الْمَغْرِبِ رَكْعَتَيْنِ بَعْدِيَّةً لِلّٰهِ تَعَالَى',
    transliteration:
        'Ushollii sunnatal maghribi rak’ataini ba’diyyatan lillaahi ta’aalaa.',
    translation:
        'Aku berniat shalat sunnah Maghrib dua rakaat setelah (ba’diyah), karena Allah Ta’ala.',
  ),
];
