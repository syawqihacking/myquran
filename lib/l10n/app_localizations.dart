import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('id'),
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In id, this message translates to:
  /// **'MyQuran'**
  String get appName;

  /// No description provided for @homeEyebrow.
  ///
  /// In id, this message translates to:
  /// **'AL-QUR\'AN'**
  String get homeEyebrow;

  /// No description provided for @homeTitle.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get homeTitle;

  /// No description provided for @homeCaption.
  ///
  /// In id, this message translates to:
  /// **'Baca Al-Qur\'an dengan tenang — tanpa sambungan internet.'**
  String get homeCaption;

  /// No description provided for @continueEyebrow.
  ///
  /// In id, this message translates to:
  /// **'LANJUTKAN MEMBACA'**
  String get continueEyebrow;

  /// No description provided for @continueButton.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get continueButton;

  /// No description provided for @noHistoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat baca.'**
  String get noHistoryTitle;

  /// No description provided for @startFromFatihah.
  ///
  /// In id, this message translates to:
  /// **'Mulai dari Al-Fatihah'**
  String get startFromFatihah;

  /// No description provided for @surahSegment.
  ///
  /// In id, this message translates to:
  /// **'Surah'**
  String get surahSegment;

  /// No description provided for @juzSegment.
  ///
  /// In id, this message translates to:
  /// **'Juz'**
  String get juzSegment;

  /// No description provided for @ayatCount.
  ///
  /// In id, this message translates to:
  /// **'ayat'**
  String get ayatCount;

  /// No description provided for @homeGreeting.
  ///
  /// In id, this message translates to:
  /// **'Assalamu\'alaikum,'**
  String get homeGreeting;

  /// No description provided for @lastReadLabel.
  ///
  /// In id, this message translates to:
  /// **'Terakhir Baca'**
  String get lastReadLabel;

  /// No description provided for @prayerScheduleTitle.
  ///
  /// In id, this message translates to:
  /// **'Jadwal Sholat'**
  String get prayerScheduleTitle;

  /// No description provided for @dailyVerseLabel.
  ///
  /// In id, this message translates to:
  /// **'Ayat Hari Ini'**
  String get dailyVerseLabel;

  /// No description provided for @dailyVerseError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat ayat hari ini.'**
  String get dailyVerseError;

  /// No description provided for @shareVerse.
  ///
  /// In id, this message translates to:
  /// **'Bagikan ayat ini'**
  String get shareVerse;

  /// No description provided for @qaKiblat.
  ///
  /// In id, this message translates to:
  /// **'Kiblat'**
  String get qaKiblat;

  /// No description provided for @qaDoaHarian.
  ///
  /// In id, this message translates to:
  /// **'Doa Harian'**
  String get qaDoaHarian;

  /// No description provided for @qaZakat.
  ///
  /// In id, this message translates to:
  /// **'Zakat'**
  String get qaZakat;

  /// No description provided for @qaMasjidTerdekat.
  ///
  /// In id, this message translates to:
  /// **'Masjid Terdekat'**
  String get qaMasjidTerdekat;

  /// No description provided for @comingSoon.
  ///
  /// In id, this message translates to:
  /// **'Segera hadir'**
  String get comingSoon;

  /// No description provided for @doaSetelahSholatTitle.
  ///
  /// In id, this message translates to:
  /// **'Doa Ba\'da Sholat'**
  String get doaSetelahSholatTitle;

  /// No description provided for @doaSetelahSholatCaption.
  ///
  /// In id, this message translates to:
  /// **'Kumpulan doa & dzikir yang dibaca setelah sholat fardhu 5 waktu'**
  String get doaSetelahSholatCaption;

  /// No description provided for @doaSetelahSholatHomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Doa Ba\'da Sholat'**
  String get doaSetelahSholatHomeTitle;

  /// No description provided for @doaSetelahSholatHomeSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Dzikir & doa setelah sholat fardhu'**
  String get doaSetelahSholatHomeSubtitle;

  /// No description provided for @prayerTimesEyebrow.
  ///
  /// In id, this message translates to:
  /// **'WAKTU SHOLAT'**
  String get prayerTimesEyebrow;

  /// No description provided for @nextPrayerLabel.
  ///
  /// In id, this message translates to:
  /// **'Sholat berikutnya'**
  String get nextPrayerLabel;

  /// No description provided for @prayerCountdownPrefix.
  ///
  /// In id, this message translates to:
  /// **'dalam'**
  String get prayerCountdownPrefix;

  /// No description provided for @prayerScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Jadwal Sholat'**
  String get prayerScreenTitle;

  /// No description provided for @qiblaTitle.
  ///
  /// In id, this message translates to:
  /// **'Arah Kiblat'**
  String get qiblaTitle;

  /// No description provided for @qiblaCaption.
  ///
  /// In id, this message translates to:
  /// **'Arahkan jarum ke kiblat'**
  String get qiblaCaption;

  /// No description provided for @qiblaAlignHint.
  ///
  /// In id, this message translates to:
  /// **'Arahkan perangkat ke kiblat'**
  String get qiblaAlignHint;

  /// No description provided for @sunriseLabel.
  ///
  /// In id, this message translates to:
  /// **'Terbit'**
  String get sunriseLabel;

  /// No description provided for @changeLocation.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get changeLocation;

  /// No description provided for @locationUpdated.
  ///
  /// In id, this message translates to:
  /// **'Lokasi diperbarui'**
  String get locationUpdated;

  /// No description provided for @navSholat.
  ///
  /// In id, this message translates to:
  /// **'Sholat'**
  String get navSholat;

  /// No description provided for @prayerError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat jadwal sholat.'**
  String get prayerError;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get retry;

  /// No description provided for @notificationsSection.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get notificationsSection;

  /// No description provided for @prayerNotificationsLabel.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi Waktu Shalat'**
  String get prayerNotificationsLabel;

  /// No description provided for @prayerNotificationsSublabel.
  ///
  /// In id, this message translates to:
  /// **'Pengingat otomatis saat masuk waktu shalat'**
  String get prayerNotificationsSublabel;

  /// No description provided for @prayerNotificationsDenied.
  ///
  /// In id, this message translates to:
  /// **'Izin notifikasi ditolak. Aktifkan lewat pengaturan sistem.'**
  String get prayerNotificationsDenied;

  /// No description provided for @prayerNotificationsTest.
  ///
  /// In id, this message translates to:
  /// **'Uji Notifikasi'**
  String get prayerNotificationsTest;

  /// No description provided for @prayerNotificationsTestSublabel.
  ///
  /// In id, this message translates to:
  /// **'Kirim notifikasi uji coba sekarang'**
  String get prayerNotificationsTestSublabel;

  /// No description provided for @prayerNotificationsTestSend.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get prayerNotificationsTestSend;

  /// No description provided for @prayerNotificationsTestTitle.
  ///
  /// In id, this message translates to:
  /// **'Waktu Shalat'**
  String get prayerNotificationsTestTitle;

  /// No description provided for @prayerNotificationsTestBody.
  ///
  /// In id, this message translates to:
  /// **'Ini notifikasi uji coba. Notifikasi waktu shalat aktif.'**
  String get prayerNotificationsTestBody;

  /// No description provided for @prayerNotificationsTestSent.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi uji coba dikirim'**
  String get prayerNotificationsTestSent;

  /// No description provided for @dzikirReminderLabel.
  ///
  /// In id, this message translates to:
  /// **'Dzikir Pagi & Petang'**
  String get dzikirReminderLabel;

  /// No description provided for @dzikirReminderSublabel.
  ///
  /// In id, this message translates to:
  /// **'Pengingat harian untuk membaca dzikir pagi dan petang'**
  String get dzikirReminderSublabel;

  /// No description provided for @dzikirReminderDenied.
  ///
  /// In id, this message translates to:
  /// **'Izin notifikasi ditolak. Aktifkan lewat pengaturan sistem.'**
  String get dzikirReminderDenied;

  /// No description provided for @hijriEventReminderLabel.
  ///
  /// In id, this message translates to:
  /// **'Pengingat Peristiwa Hijriah'**
  String get hijriEventReminderLabel;

  /// No description provided for @hijriEventReminderSublabel.
  ///
  /// In id, this message translates to:
  /// **'Pengingat otomatis pada hari peristiwa penting di kalender Islam'**
  String get hijriEventReminderSublabel;

  /// No description provided for @hijriEventReminderDenied.
  ///
  /// In id, this message translates to:
  /// **'Izin notifikasi ditolak. Aktifkan lewat pengaturan sistem.'**
  String get hijriEventReminderDenied;

  /// No description provided for @dzikirReminderMorningTitle.
  ///
  /// In id, this message translates to:
  /// **'Dzikir Pagi'**
  String get dzikirReminderMorningTitle;

  /// No description provided for @dzikirReminderMorningBody.
  ///
  /// In id, this message translates to:
  /// **'Waktunya membaca dzikir pagi.'**
  String get dzikirReminderMorningBody;

  /// No description provided for @dzikirReminderEveningTitle.
  ///
  /// In id, this message translates to:
  /// **'Dzikir Petang'**
  String get dzikirReminderEveningTitle;

  /// No description provided for @dzikirReminderEveningBody.
  ///
  /// In id, this message translates to:
  /// **'Waktunya membaca dzikir petang.'**
  String get dzikirReminderEveningBody;

  /// No description provided for @adzanVoiceLabel.
  ///
  /// In id, this message translates to:
  /// **'Suara Adzan'**
  String get adzanVoiceLabel;

  /// No description provided for @adzanVoiceDownloading.
  ///
  /// In id, this message translates to:
  /// **'Mengunduh suara adzan...'**
  String get adzanVoiceDownloading;

  /// No description provided for @adzanVoiceChanged.
  ///
  /// In id, this message translates to:
  /// **'Suara adzan diperbarui'**
  String get adzanVoiceChanged;

  /// No description provided for @adzanVoiceDownloadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengunduh suara adzan. Periksa koneksi internet.'**
  String get adzanVoiceDownloadFailed;

  /// No description provided for @adzanVoiceSholatLabel.
  ///
  /// In id, this message translates to:
  /// **'Suara Adzan Sholat'**
  String get adzanVoiceSholatLabel;

  /// No description provided for @adzanVoiceFajrLabel.
  ///
  /// In id, this message translates to:
  /// **'Suara Adzan Fajr/Subuh'**
  String get adzanVoiceFajrLabel;

  /// No description provided for @adzanVoiceSholatHint.
  ///
  /// In id, this message translates to:
  /// **'Dipakai untuk sholat selain subuh'**
  String get adzanVoiceSholatHint;

  /// No description provided for @adzanVoiceFajrHint.
  ///
  /// In id, this message translates to:
  /// **'Dipakai khusus untuk adzan subuh'**
  String get adzanVoiceFajrHint;

  /// No description provided for @adzanTestSholat.
  ///
  /// In id, this message translates to:
  /// **'Suara Sholat'**
  String get adzanTestSholat;

  /// No description provided for @adzanTestFajr.
  ///
  /// In id, this message translates to:
  /// **'Suara Fajr'**
  String get adzanTestFajr;

  /// No description provided for @testHijriEvent.
  ///
  /// In id, this message translates to:
  /// **'Peristiwa Hijriah'**
  String get testHijriEvent;

  /// No description provided for @browseEyebrow.
  ///
  /// In id, this message translates to:
  /// **'BACA'**
  String get browseEyebrow;

  /// No description provided for @browseTitle.
  ///
  /// In id, this message translates to:
  /// **'Al-Qur\'an'**
  String get browseTitle;

  /// No description provided for @browseCaption.
  ///
  /// In id, this message translates to:
  /// **'Jelajahi 114 surah, 30 juz, atau cari ayat dan terjemahan.'**
  String get browseCaption;

  /// No description provided for @surahListTitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar Surah'**
  String get surahListTitle;

  /// No description provided for @juzListTitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar Juz'**
  String get juzListTitle;

  /// No description provided for @quickAccessEyebrow.
  ///
  /// In id, this message translates to:
  /// **'DAFTAR LENGKAP'**
  String get quickAccessEyebrow;

  /// No description provided for @quickSurahCaption.
  ///
  /// In id, this message translates to:
  /// **'114 surah'**
  String get quickSurahCaption;

  /// No description provided for @quickJuzCaption.
  ///
  /// In id, this message translates to:
  /// **'30 juz'**
  String get quickJuzCaption;

  /// No description provided for @makkiyah.
  ///
  /// In id, this message translates to:
  /// **'Makkiyah'**
  String get makkiyah;

  /// No description provided for @madaniyah.
  ///
  /// In id, this message translates to:
  /// **'Madaniyah'**
  String get madaniyah;

  /// No description provided for @browseSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari surah atau ayat...'**
  String get browseSearchHint;

  /// No description provided for @favoritSegment.
  ///
  /// In id, this message translates to:
  /// **'Favorit'**
  String get favoritSegment;

  /// No description provided for @favoritEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada surah favorit'**
  String get favoritEmptyTitle;

  /// No description provided for @favoritEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Tandai ayat saat membaca — surah dengan penanda akan muncul di sini.'**
  String get favoritEmptyMessage;

  /// No description provided for @penandaCount.
  ///
  /// In id, this message translates to:
  /// **'penanda'**
  String get penandaCount;

  /// No description provided for @back.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get back;

  /// No description provided for @fontSmaller.
  ///
  /// In id, this message translates to:
  /// **'Perkecil teks Arab (Ctrl −)'**
  String get fontSmaller;

  /// No description provided for @fontLarger.
  ///
  /// In id, this message translates to:
  /// **'Perbesar teks Arab (Ctrl +)'**
  String get fontLarger;

  /// No description provided for @jumpToAyah.
  ///
  /// In id, this message translates to:
  /// **'Lompat ke ayat'**
  String get jumpToAyah;

  /// No description provided for @jumpLabel.
  ///
  /// In id, this message translates to:
  /// **'Ayat'**
  String get jumpLabel;

  /// No description provided for @jumpHint.
  ///
  /// In id, this message translates to:
  /// **'1–'**
  String get jumpHint;

  /// No description provided for @jumpOutOfRange.
  ///
  /// In id, this message translates to:
  /// **'Nomor di luar jangkauan'**
  String get jumpOutOfRange;

  /// No description provided for @jumpButton.
  ///
  /// In id, this message translates to:
  /// **'Lompat'**
  String get jumpButton;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @tafsirAction.
  ///
  /// In id, this message translates to:
  /// **'Tafsir'**
  String get tafsirAction;

  /// No description provided for @tafsirHeader.
  ///
  /// In id, this message translates to:
  /// **'Tafsir · Kementerian Agama RI'**
  String get tafsirHeader;

  /// No description provided for @bookmarkAyah.
  ///
  /// In id, this message translates to:
  /// **'Tandai ayat ini'**
  String get bookmarkAyah;

  /// No description provided for @removeBookmark.
  ///
  /// In id, this message translates to:
  /// **'Hapus penanda'**
  String get removeBookmark;

  /// No description provided for @endOfSurah.
  ///
  /// In id, this message translates to:
  /// **'Selesai membaca'**
  String get endOfSurah;

  /// No description provided for @nextSurah.
  ///
  /// In id, this message translates to:
  /// **'Surah berikutnya'**
  String get nextSurah;

  /// No description provided for @backToHome.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke Beranda'**
  String get backToHome;

  /// No description provided for @surahMeta.
  ///
  /// In id, this message translates to:
  /// **'Surah {number} • {ayahCount} Ayat'**
  String surahMeta(int number, int ayahCount);

  /// No description provided for @playAyah.
  ///
  /// In id, this message translates to:
  /// **'Putar ayat ini'**
  String get playAyah;

  /// No description provided for @shareAyah.
  ///
  /// In id, this message translates to:
  /// **'Bagikan ayat'**
  String get shareAyah;

  /// No description provided for @readerSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan baca'**
  String get readerSettings;

  /// No description provided for @hideTranslation.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan terjemahan'**
  String get hideTranslation;

  /// No description provided for @audioReciter.
  ///
  /// In id, this message translates to:
  /// **'Mishary Alafasy'**
  String get audioReciter;

  /// No description provided for @audioCaption.
  ///
  /// In id, this message translates to:
  /// **'Surah {surah} — Ayat {ayah}'**
  String audioCaption(String surah, int ayah);

  /// No description provided for @audioPlay.
  ///
  /// In id, this message translates to:
  /// **'Putar'**
  String get audioPlay;

  /// No description provided for @audioPause.
  ///
  /// In id, this message translates to:
  /// **'Jeda'**
  String get audioPause;

  /// No description provided for @audioPrev.
  ///
  /// In id, this message translates to:
  /// **'Sebelumnya'**
  String get audioPrev;

  /// No description provided for @audioNext.
  ///
  /// In id, this message translates to:
  /// **'Berikutnya'**
  String get audioNext;

  /// No description provided for @audioSpeedLabel.
  ///
  /// In id, this message translates to:
  /// **'Kecepatan putar'**
  String get audioSpeedLabel;

  /// No description provided for @audioVolume.
  ///
  /// In id, this message translates to:
  /// **'Volume'**
  String get audioVolume;

  /// No description provided for @audioQueue.
  ///
  /// In id, this message translates to:
  /// **'Daftar putar'**
  String get audioQueue;

  /// No description provided for @audioClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup pemutar'**
  String get audioClose;

  /// No description provided for @audioError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memutar audio. Periksa koneksi internet.'**
  String get audioError;

  /// No description provided for @murottalDownload.
  ///
  /// In id, this message translates to:
  /// **'Unduh murottal surah ini'**
  String get murottalDownload;

  /// No description provided for @murottalDownloading.
  ///
  /// In id, this message translates to:
  /// **'Mengunduh murottal...'**
  String get murottalDownloading;

  /// No description provided for @murottalCancel.
  ///
  /// In id, this message translates to:
  /// **'Batalkan unduhan'**
  String get murottalCancel;

  /// No description provided for @murottalDownloaded.
  ///
  /// In id, this message translates to:
  /// **'Murottal tersimpan — ketuk untuk menghapus'**
  String get murottalDownloaded;

  /// No description provided for @murottalDeleteConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus murottal?'**
  String get murottalDeleteConfirmTitle;

  /// No description provided for @murottalDeleteConfirmMessage.
  ///
  /// In id, this message translates to:
  /// **'Hapus rekaman surah ini dari perangkat?'**
  String get murottalDeleteConfirmMessage;

  /// No description provided for @murottalDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get murottalDelete;

  /// No description provided for @murottalDownloadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengunduh murottal. Periksa koneksi internet.'**
  String get murottalDownloadFailed;

  /// No description provided for @murottalDownloadDone.
  ///
  /// In id, this message translates to:
  /// **'Murottal surah ini tersimpan untuk diputar offline.'**
  String get murottalDownloadDone;

  /// No description provided for @searchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari surah, ayat, atau terjemahan'**
  String get searchHint;

  /// No description provided for @openSearch.
  ///
  /// In id, this message translates to:
  /// **'Cari'**
  String get openSearch;

  /// No description provided for @closeSearch.
  ///
  /// In id, this message translates to:
  /// **'Tutup pencarian'**
  String get closeSearch;

  /// No description provided for @searchGroupSurah.
  ///
  /// In id, this message translates to:
  /// **'SURAH'**
  String get searchGroupSurah;

  /// No description provided for @searchGroupAyah.
  ///
  /// In id, this message translates to:
  /// **'AYAT'**
  String get searchGroupAyah;

  /// No description provided for @searchGroupTranslation.
  ///
  /// In id, this message translates to:
  /// **'TERJEMAHAN'**
  String get searchGroupTranslation;

  /// No description provided for @noResultsTitle.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hasil'**
  String get noResultsTitle;

  /// No description provided for @noResultsHint.
  ///
  /// In id, this message translates to:
  /// **'Periksa ejaan atau coba kata lain'**
  String get noResultsHint;

  /// No description provided for @popularSurahs.
  ///
  /// In id, this message translates to:
  /// **'Surah populer'**
  String get popularSurahs;

  /// No description provided for @bookmarksEyebrow.
  ///
  /// In id, this message translates to:
  /// **'PENANDA BACA'**
  String get bookmarksEyebrow;

  /// No description provided for @bookmarksTitle.
  ///
  /// In id, this message translates to:
  /// **'Favorit & Penanda'**
  String get bookmarksTitle;

  /// No description provided for @bookmarksCaption.
  ///
  /// In id, this message translates to:
  /// **'Ayat yang kamu tandai tersimpan di perangkat ini.'**
  String get bookmarksCaption;

  /// No description provided for @bookmarksEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada penanda baca'**
  String get bookmarksEmptyTitle;

  /// No description provided for @bookmarksEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Tandai ayat dengan ikon bookmark saat membaca — ayat akan muncul di sini.'**
  String get bookmarksEmptyMessage;

  /// No description provided for @startReading.
  ///
  /// In id, this message translates to:
  /// **'Mulai membaca'**
  String get startReading;

  /// No description provided for @removeBookmarkConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus penanda ini?'**
  String get removeBookmarkConfirm;

  /// No description provided for @remove.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get remove;

  /// No description provided for @favoritTab.
  ///
  /// In id, this message translates to:
  /// **'Favorit'**
  String get favoritTab;

  /// No description provided for @penandaTab.
  ///
  /// In id, this message translates to:
  /// **'Penanda'**
  String get penandaTab;

  /// No description provided for @juzPage.
  ///
  /// In id, this message translates to:
  /// **'Juz {juz} • Halaman {page}'**
  String juzPage(int juz, int page);

  /// No description provided for @todayLabel.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get todayLabel;

  /// No description provided for @yesterdayLabel.
  ///
  /// In id, this message translates to:
  /// **'Kemarin'**
  String get yesterdayLabel;

  /// No description provided for @daysAgo.
  ///
  /// In id, this message translates to:
  /// **'{n} hari lalu'**
  String daysAgo(int n);

  /// No description provided for @weeksAgo.
  ///
  /// In id, this message translates to:
  /// **'{n} mgg lalu'**
  String weeksAgo(int n);

  /// No description provided for @bookmarksFavoritEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada favorit'**
  String get bookmarksFavoritEmptyTitle;

  /// No description provided for @bookmarksFavoritEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Tandai ayat dengan ikon bookmark saat membaca — favoritmu akan muncul di sini.'**
  String get bookmarksFavoritEmptyMessage;

  /// No description provided for @bookmarksPenandaEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada penanda'**
  String get bookmarksPenandaEmptyTitle;

  /// No description provided for @bookmarksPenandaEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Riwayat bacaanmu akan muncul di sini setelah kamu membaca surah.'**
  String get bookmarksPenandaEmptyMessage;

  /// No description provided for @settingsEyebrow.
  ///
  /// In id, this message translates to:
  /// **'PENGATURAN'**
  String get settingsEyebrow;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @settingsCaption.
  ///
  /// In id, this message translates to:
  /// **'Atur tampilan, notifikasi, dan data sesuai keinginanmu.'**
  String get settingsCaption;

  /// No description provided for @appearanceSection.
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get appearanceSection;

  /// No description provided for @themeModeLabel.
  ///
  /// In id, this message translates to:
  /// **'Mode tema'**
  String get themeModeLabel;

  /// No description provided for @themeModeSublabel.
  ///
  /// In id, this message translates to:
  /// **'Ikuti tema sistem operasi.'**
  String get themeModeSublabel;

  /// No description provided for @themeSystem.
  ///
  /// In id, this message translates to:
  /// **'Sistem'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get themeDark;

  /// No description provided for @quranFontSizeLabel.
  ///
  /// In id, this message translates to:
  /// **'Ukuran teks Arab'**
  String get quranFontSizeLabel;

  /// No description provided for @quranFontSizeSublabel.
  ///
  /// In id, this message translates to:
  /// **'Lebih besar untuk kenyamanan baca jarak jauh; terjemahan menyesuaikan secara otomatis.'**
  String get quranFontSizeSublabel;

  /// No description provided for @reset.
  ///
  /// In id, this message translates to:
  /// **'Setel ulang'**
  String get reset;

  /// No description provided for @showTranslationLabel.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan terjemahan'**
  String get showTranslationLabel;

  /// No description provided for @alignLabel.
  ///
  /// In id, this message translates to:
  /// **'Perataan teks Arab'**
  String get alignLabel;

  /// No description provided for @alignRight.
  ///
  /// In id, this message translates to:
  /// **'Rata kanan'**
  String get alignRight;

  /// No description provided for @alignCenter.
  ///
  /// In id, this message translates to:
  /// **'Rata tengah'**
  String get alignCenter;

  /// No description provided for @alignNote.
  ///
  /// In id, this message translates to:
  /// **'Perataan tengah dapat membantu pada ayat pendek.'**
  String get alignNote;

  /// No description provided for @readingSection.
  ///
  /// In id, this message translates to:
  /// **'Baca'**
  String get readingSection;

  /// No description provided for @tafsirDefaultLabel.
  ///
  /// In id, this message translates to:
  /// **'Tafsir default terbuka'**
  String get tafsirDefaultLabel;

  /// No description provided for @tajwidColorLabel.
  ///
  /// In id, this message translates to:
  /// **'Warna tajwid'**
  String get tajwidColorLabel;

  /// No description provided for @tajwidColorSublabel.
  ///
  /// In id, this message translates to:
  /// **'Warnai hukum bacaan tajwid pada teks Al-Qur\'an.'**
  String get tajwidColorSublabel;

  /// No description provided for @tajwidColorTooltip.
  ///
  /// In id, this message translates to:
  /// **'Warna tajwid'**
  String get tajwidColorTooltip;

  /// No description provided for @restoreLastReadLabel.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan posisi baca terakhir'**
  String get restoreLastReadLabel;

  /// No description provided for @dataSection.
  ///
  /// In id, this message translates to:
  /// **'Data & Sumber'**
  String get dataSection;

  /// No description provided for @dataSourceLabel.
  ///
  /// In id, this message translates to:
  /// **'Teks, terjemahan, dan tafsir — Quran Kementerian Agama RI. Semua data tersimpan offline di perangkat.'**
  String get dataSourceLabel;

  /// No description provided for @dataVersionLabel.
  ///
  /// In id, this message translates to:
  /// **'Versi data'**
  String get dataVersionLabel;

  /// No description provided for @licenseLabel.
  ///
  /// In id, this message translates to:
  /// **'Lisensi'**
  String get licenseLabel;

  /// No description provided for @shortcutsSection.
  ///
  /// In id, this message translates to:
  /// **'Pintasan keyboard'**
  String get shortcutsSection;

  /// No description provided for @shortcutSearch.
  ///
  /// In id, this message translates to:
  /// **'Cari — Ctrl K'**
  String get shortcutSearch;

  /// No description provided for @shortcutZoomIn.
  ///
  /// In id, this message translates to:
  /// **'Perbesar teks Arab — Ctrl +'**
  String get shortcutZoomIn;

  /// No description provided for @shortcutZoomOut.
  ///
  /// In id, this message translates to:
  /// **'Perkecil teks Arab — Ctrl −'**
  String get shortcutZoomOut;

  /// No description provided for @shortcutClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup panel — Esc'**
  String get shortcutClose;

  /// No description provided for @resetDataSection.
  ///
  /// In id, this message translates to:
  /// **'Data pengguna'**
  String get resetDataSection;

  /// No description provided for @resetDataLabel.
  ///
  /// In id, this message translates to:
  /// **'Reset data'**
  String get resetDataLabel;

  /// No description provided for @resetDataSublabel.
  ///
  /// In id, this message translates to:
  /// **'Hapus riwayat baca, target khatam, sujud tilawah, posisi baca, dan penanda baca.'**
  String get resetDataSublabel;

  /// No description provided for @resetDataConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Reset semua data?'**
  String get resetDataConfirmTitle;

  /// No description provided for @resetDataConfirmMessage.
  ///
  /// In id, this message translates to:
  /// **'Riwayat baca, target khatam, sujud tilawah, posisi baca, dan penanda baca akan dihapus permanen. Teks Al-Qur\'an dan pengaturan tampilan tidak terpengaruh.'**
  String get resetDataConfirmMessage;

  /// No description provided for @resetDataConfirm.
  ///
  /// In id, this message translates to:
  /// **'Reset data'**
  String get resetDataConfirm;

  /// No description provided for @resetDataDone.
  ///
  /// In id, this message translates to:
  /// **'Data pengguna berhasil direset.'**
  String get resetDataDone;

  /// No description provided for @reciterLabel.
  ///
  /// In id, this message translates to:
  /// **'Qari'**
  String get reciterLabel;

  /// No description provided for @reciterDefault.
  ///
  /// In id, this message translates to:
  /// **'Mishary Rashid Alafasy'**
  String get reciterDefault;

  /// No description provided for @reciterDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Qari'**
  String get reciterDialogTitle;

  /// No description provided for @reciterChanged.
  ///
  /// In id, this message translates to:
  /// **'Qari berhasil diganti'**
  String get reciterChanged;

  /// No description provided for @reciterLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat daftar qari'**
  String get reciterLoadFailed;

  /// No description provided for @statsEyebrow.
  ///
  /// In id, this message translates to:
  /// **'STATISTIK'**
  String get statsEyebrow;

  /// No description provided for @statsTitle.
  ///
  /// In id, this message translates to:
  /// **'Statistik'**
  String get statsTitle;

  /// No description provided for @statsCaption.
  ///
  /// In id, this message translates to:
  /// **'Jejak baca dan progres khatammu, tersimpan di perangkat ini.'**
  String get statsCaption;

  /// No description provided for @statsError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat data.'**
  String get statsError;

  /// No description provided for @statsStreakLabel.
  ///
  /// In id, this message translates to:
  /// **'Hari beruntun'**
  String get statsStreakLabel;

  /// No description provided for @statsTodayLabel.
  ///
  /// In id, this message translates to:
  /// **'Ayat dibaca hari ini'**
  String get statsTodayLabel;

  /// No description provided for @statsKhatamEyebrow.
  ///
  /// In id, this message translates to:
  /// **'PROGRES KHATAM'**
  String get statsKhatamEyebrow;

  /// No description provided for @statsJuzsOf.
  ///
  /// In id, this message translates to:
  /// **'dari 30 juz'**
  String get statsJuzsOf;

  /// No description provided for @statsKhatamCaption.
  ///
  /// In id, this message translates to:
  /// **'Baca 1 juz per hari untuk khatam dalam 30 hari.'**
  String get statsKhatamCaption;

  /// No description provided for @statsTotalDaysLabel.
  ///
  /// In id, this message translates to:
  /// **'Total hari membaca'**
  String get statsTotalDaysLabel;

  /// No description provided for @statsTotalAyahsLabel.
  ///
  /// In id, this message translates to:
  /// **'Total ayat dibaca'**
  String get statsTotalAyahsLabel;

  /// No description provided for @khatamPlan30.
  ///
  /// In id, this message translates to:
  /// **'Khatam 30 hari'**
  String get khatamPlan30;

  /// No description provided for @khatamPickDate.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal'**
  String get khatamPickDate;

  /// No description provided for @khatamJuz.
  ///
  /// In id, this message translates to:
  /// **'Juz'**
  String get khatamJuz;

  /// No description provided for @khatamJuzToday.
  ///
  /// In id, this message translates to:
  /// **'hari ini'**
  String get khatamJuzToday;

  /// No description provided for @khatamDaysLeft.
  ///
  /// In id, this message translates to:
  /// **'Sisa'**
  String get khatamDaysLeft;

  /// No description provided for @khatamDays.
  ///
  /// In id, this message translates to:
  /// **'hari'**
  String get khatamDays;

  /// No description provided for @khatamTargetLabel.
  ///
  /// In id, this message translates to:
  /// **'Target'**
  String get khatamTargetLabel;

  /// No description provided for @khatamClear.
  ///
  /// In id, this message translates to:
  /// **'Hapus target'**
  String get khatamClear;

  /// No description provided for @khatamClearConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus target khatam ini?'**
  String get khatamClearConfirm;

  /// No description provided for @khatamDone.
  ///
  /// In id, this message translates to:
  /// **'Target khatam tercapai'**
  String get khatamDone;

  /// No description provided for @calendarEyebrow.
  ///
  /// In id, this message translates to:
  /// **'KALENDER BACA'**
  String get calendarEyebrow;

  /// No description provided for @calendarTitle.
  ///
  /// In id, this message translates to:
  /// **'30 hari terakhir'**
  String get calendarTitle;

  /// No description provided for @calendarCaption.
  ///
  /// In id, this message translates to:
  /// **'Ayat yang dibaca setiap hari — 30 hari terakhir.'**
  String get calendarCaption;

  /// No description provided for @calendarFew.
  ///
  /// In id, this message translates to:
  /// **'Sedikit'**
  String get calendarFew;

  /// No description provided for @calendarMany.
  ///
  /// In id, this message translates to:
  /// **'Banyak'**
  String get calendarMany;

  /// No description provided for @sujudLabel.
  ///
  /// In id, this message translates to:
  /// **'Sujud tilawah'**
  String get sujudLabel;

  /// No description provided for @sujudOf.
  ///
  /// In id, this message translates to:
  /// **'dari 15 sujud tilawah'**
  String get sujudOf;

  /// No description provided for @sujudMark.
  ///
  /// In id, this message translates to:
  /// **'Tandai sujud tilawah'**
  String get sujudMark;

  /// No description provided for @sujudUnmark.
  ///
  /// In id, this message translates to:
  /// **'Hapus tanda sujud'**
  String get sujudUnmark;

  /// No description provided for @zenEnter.
  ///
  /// In id, this message translates to:
  /// **'Mode fokus (Ctrl B)'**
  String get zenEnter;

  /// No description provided for @zenExit.
  ///
  /// In id, this message translates to:
  /// **'Keluar mode fokus (Esc)'**
  String get zenExit;

  /// No description provided for @zenSnackbarExitHint.
  ///
  /// In id, this message translates to:
  /// **'Keluar dengan Esc atau Ctrl B.'**
  String get zenSnackbarExitHint;

  /// No description provided for @copyAyah.
  ///
  /// In id, this message translates to:
  /// **'Salin'**
  String get copyAyah;

  /// No description provided for @copyAyahDone.
  ///
  /// In id, this message translates to:
  /// **'Ayat tersalin ke papan klip.'**
  String get copyAyahDone;

  /// No description provided for @historyEyebrow.
  ///
  /// In id, this message translates to:
  /// **'RIWAYAT BACA'**
  String get historyEyebrow;

  /// No description provided for @historyProgressOf.
  ///
  /// In id, this message translates to:
  /// **'dari'**
  String get historyProgressOf;

  /// No description provided for @historyReadLabel.
  ///
  /// In id, this message translates to:
  /// **'Ayat'**
  String get historyReadLabel;

  /// No description provided for @changeTheme.
  ///
  /// In id, this message translates to:
  /// **'Ganti tema'**
  String get changeTheme;

  /// No description provided for @paperThemeLabel.
  ///
  /// In id, this message translates to:
  /// **'Tema kertas'**
  String get paperThemeLabel;

  /// No description provided for @paperThemeSublabel.
  ///
  /// In id, this message translates to:
  /// **'Warna kertas kolom baca — hangat di kedua mode.'**
  String get paperThemeSublabel;

  /// No description provided for @paperHangat.
  ///
  /// In id, this message translates to:
  /// **'Hangat'**
  String get paperHangat;

  /// No description provided for @paperKlasik.
  ///
  /// In id, this message translates to:
  /// **'Klasik'**
  String get paperKlasik;

  /// No description provided for @paperPucat.
  ///
  /// In id, this message translates to:
  /// **'Pucat'**
  String get paperPucat;

  /// No description provided for @tahlilTitle.
  ///
  /// In id, this message translates to:
  /// **'Tahlil & Doa'**
  String get tahlilTitle;

  /// No description provided for @tahlilCaption.
  ///
  /// In id, this message translates to:
  /// **'Bacaan tahlil lengkap dengan doanya'**
  String get tahlilCaption;

  /// No description provided for @ratibTitle.
  ///
  /// In id, this message translates to:
  /// **'Ratib Al-Haddad'**
  String get ratibTitle;

  /// No description provided for @ratibCaption.
  ///
  /// In id, this message translates to:
  /// **'Wirid malam karya Habib Abdullah Al-Haddad'**
  String get ratibCaption;

  /// No description provided for @spiritualNav.
  ///
  /// In id, this message translates to:
  /// **'Wirid & Doa'**
  String get spiritualNav;

  /// No description provided for @dzikirTitle.
  ///
  /// In id, this message translates to:
  /// **'Dzikir Pagi & Petang'**
  String get dzikirTitle;

  /// No description provided for @dzikirCaption.
  ///
  /// In id, this message translates to:
  /// **'Dzikir pagi dan petang beserta doanya'**
  String get dzikirCaption;

  /// No description provided for @dzikirPagi.
  ///
  /// In id, this message translates to:
  /// **'Pagi'**
  String get dzikirPagi;

  /// No description provided for @dzikirPetang.
  ///
  /// In id, this message translates to:
  /// **'Petang'**
  String get dzikirPetang;

  /// No description provided for @dzikirEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada dzikir ditemukan'**
  String get dzikirEmpty;

  /// No description provided for @niatShalatTitle.
  ///
  /// In id, this message translates to:
  /// **'Niat Shalat'**
  String get niatShalatTitle;

  /// No description provided for @niatShalatCaption.
  ///
  /// In id, this message translates to:
  /// **'Niat shalat wajib dan sunnah'**
  String get niatShalatCaption;

  /// No description provided for @tadabburTitle.
  ///
  /// In id, this message translates to:
  /// **'Tadabbur Harian'**
  String get tadabburTitle;

  /// No description provided for @tadabburCaption.
  ///
  /// In id, this message translates to:
  /// **'Renungan ayat Al-Qur\'an untuk setiap hari'**
  String get tadabburCaption;

  /// No description provided for @tadabburReflection.
  ///
  /// In id, this message translates to:
  /// **'Renungan'**
  String get tadabburReflection;

  /// No description provided for @asmaulHusnaTitle.
  ///
  /// In id, this message translates to:
  /// **'Asmaul Husna'**
  String get asmaulHusnaTitle;

  /// No description provided for @asmaulHusnaCaption.
  ///
  /// In id, this message translates to:
  /// **'99 nama Allah beserta artinya'**
  String get asmaulHusnaCaption;

  /// No description provided for @asmaulHusnaSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari nama atau arti...'**
  String get asmaulHusnaSearchHint;

  /// No description provided for @asmaulHusnaEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ditemukan'**
  String get asmaulHusnaEmpty;

  /// No description provided for @asmaulHusnaEmptyHint.
  ///
  /// In id, this message translates to:
  /// **'Coba kata kunci lain.'**
  String get asmaulHusnaEmptyHint;

  /// No description provided for @asmaulHusnaArti.
  ///
  /// In id, this message translates to:
  /// **'Arti'**
  String get asmaulHusnaArti;

  /// No description provided for @asmaulHusnaCatatan.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get asmaulHusnaCatatan;

  /// No description provided for @asmaulHusnaClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get asmaulHusnaClose;

  /// No description provided for @doaHarianTitle.
  ///
  /// In id, this message translates to:
  /// **'Doa Harian'**
  String get doaHarianTitle;

  /// No description provided for @doaHarianCaption.
  ///
  /// In id, this message translates to:
  /// **'Kumpulan doa sehari-hari lengkap dengan teks Arab dan terjemahan.'**
  String get doaHarianCaption;

  /// No description provided for @doaSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari doa...'**
  String get doaSearchHint;

  /// No description provided for @doaEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ditemukan'**
  String get doaEmpty;

  /// No description provided for @doaEmptyHint.
  ///
  /// In id, this message translates to:
  /// **'Coba kata kunci atau kategori lain.'**
  String get doaEmptyHint;

  /// No description provided for @doaBookmarkAdd.
  ///
  /// In id, this message translates to:
  /// **'Tandai doa ini'**
  String get doaBookmarkAdd;

  /// No description provided for @doaBookmarkRemove.
  ///
  /// In id, this message translates to:
  /// **'Hapus tanda doa'**
  String get doaBookmarkRemove;

  /// No description provided for @tahlilHeaderTitle.
  ///
  /// In id, this message translates to:
  /// **'Bacaan Tahlil'**
  String get tahlilHeaderTitle;

  /// No description provided for @tahlilHeaderDesc.
  ///
  /// In id, this message translates to:
  /// **'Tahlil adalah rangkaian dzikir dan doa yang dibaca untuk memohon ampunan dan rahmat Allah SWT, seringkali ditujukan bagi mereka yang telah meninggal dunia. Bacalah dengan khusyuk dan tenang.'**
  String get tahlilHeaderDesc;

  /// No description provided for @audioComingSoon.
  ///
  /// In id, this message translates to:
  /// **'Audio segera hadir'**
  String get audioComingSoon;

  /// No description provided for @readNTimes.
  ///
  /// In id, this message translates to:
  /// **'DIBACA {n} KALI'**
  String readNTimes(int n);

  /// No description provided for @ratibulHaddadTitle.
  ///
  /// In id, this message translates to:
  /// **'Ratibul Haddad'**
  String get ratibulHaddadTitle;

  /// No description provided for @ratibIntroChip.
  ///
  /// In id, this message translates to:
  /// **'Pengenalan'**
  String get ratibIntroChip;

  /// No description provided for @ratibIntroDesc.
  ///
  /// In id, this message translates to:
  /// **'Disusun oleh Al-Habib Abdullah bin Alwi bin Muhammad Al-Haddad. Ratib ini merupakan kumpulan doa dan zikir yang diambil dari Al-Quran dan hadits, dibaca untuk memohon perlindungan, keberkahan, dan kedekatan kepada Allah SWT.'**
  String get ratibIntroDesc;

  /// No description provided for @ratibFullTitle.
  ///
  /// In id, this message translates to:
  /// **'Ratibul Haddad Full'**
  String get ratibFullTitle;

  /// No description provided for @playingLabel.
  ///
  /// In id, this message translates to:
  /// **'Sedang Memutar'**
  String get playingLabel;

  /// No description provided for @counterLabel.
  ///
  /// In id, this message translates to:
  /// **'Hitung'**
  String get counterLabel;

  /// No description provided for @counterReset.
  ///
  /// In id, this message translates to:
  /// **'Reset hitungan'**
  String get counterReset;

  /// No description provided for @amalanIbadahTitle.
  ///
  /// In id, this message translates to:
  /// **'Amalan Ibadah'**
  String get amalanIbadahTitle;

  /// No description provided for @amalanIbadahCaption.
  ///
  /// In id, this message translates to:
  /// **'Ceklis amalan harianmu dan pantau progres ibadah setiap hari'**
  String get amalanIbadahCaption;

  /// No description provided for @amalanGoalProgress.
  ///
  /// In id, this message translates to:
  /// **'Progres Target Harian'**
  String get amalanGoalProgress;

  /// No description provided for @amalanGoalSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pertahankan semangatmu!'**
  String get amalanGoalSubtitle;

  /// No description provided for @amalanProgress.
  ///
  /// In id, this message translates to:
  /// **'{done}/{total} Selesai'**
  String amalanProgress(int done, int total);

  /// No description provided for @amalanSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari amalan...'**
  String get amalanSearchHint;

  /// No description provided for @amalanLearnMore.
  ///
  /// In id, this message translates to:
  /// **'Pelajari'**
  String get amalanLearnMore;

  /// No description provided for @amalanDetailPenjelasan.
  ///
  /// In id, this message translates to:
  /// **'Penjelasan'**
  String get amalanDetailPenjelasan;

  /// No description provided for @amalanDetailDalil.
  ///
  /// In id, this message translates to:
  /// **'Dalil'**
  String get amalanDetailDalil;

  /// No description provided for @amalanEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ditemukan'**
  String get amalanEmpty;

  /// No description provided for @amalanEmptyHint.
  ///
  /// In id, this message translates to:
  /// **'Coba kata kunci atau kategori lain.'**
  String get amalanEmptyHint;

  /// No description provided for @amalanCatSemua.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get amalanCatSemua;

  /// No description provided for @amalanCatWajib.
  ///
  /// In id, this message translates to:
  /// **'Wajib'**
  String get amalanCatWajib;

  /// No description provided for @amalanCatSunnah.
  ///
  /// In id, this message translates to:
  /// **'Sunnah'**
  String get amalanCatSunnah;

  /// No description provided for @amalanCatDzikir.
  ///
  /// In id, this message translates to:
  /// **'Dzikir'**
  String get amalanCatDzikir;

  /// No description provided for @amalanCatSosial.
  ///
  /// In id, this message translates to:
  /// **'Sosial'**
  String get amalanCatSosial;

  /// No description provided for @amalanToggleDone.
  ///
  /// In id, this message translates to:
  /// **'Tandai selesai'**
  String get amalanToggleDone;

  /// No description provided for @amalanToggleUndone.
  ///
  /// In id, this message translates to:
  /// **'Tandai belum selesai'**
  String get amalanToggleUndone;

  /// No description provided for @masjidTerdekatTitle.
  ///
  /// In id, this message translates to:
  /// **'Masjid Terdekat'**
  String get masjidTerdekatTitle;

  /// No description provided for @masjidSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari masjid atau lokasi...'**
  String get masjidSearchHint;

  /// No description provided for @masjidFilterHint.
  ///
  /// In id, this message translates to:
  /// **'Filter'**
  String get masjidFilterHint;

  /// No description provided for @masjidCatSemua.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get masjidCatSemua;

  /// No description provided for @masjidCatParkirLuas.
  ///
  /// In id, this message translates to:
  /// **'Parkir Luas'**
  String get masjidCatParkirLuas;

  /// No description provided for @masjidCatToilet.
  ///
  /// In id, this message translates to:
  /// **'Toilet'**
  String get masjidCatToilet;

  /// No description provided for @masjidCatAc.
  ///
  /// In id, this message translates to:
  /// **'AC'**
  String get masjidCatAc;

  /// No description provided for @masjidCatDisabilitas.
  ///
  /// In id, this message translates to:
  /// **'Ramah Disabilitas'**
  String get masjidCatDisabilitas;

  /// No description provided for @masjidRute.
  ///
  /// In id, this message translates to:
  /// **'Rute'**
  String get masjidRute;

  /// No description provided for @masjidDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail'**
  String get masjidDetail;

  /// No description provided for @masjidLoading.
  ///
  /// In id, this message translates to:
  /// **'Mencari masjid di sekitar Anda...'**
  String get masjidLoading;

  /// No description provided for @masjidError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat data masjid'**
  String get masjidError;

  /// No description provided for @masjidErrorHint.
  ///
  /// In id, this message translates to:
  /// **'Periksa koneksi internet lalu coba lagi.'**
  String get masjidErrorHint;

  /// No description provided for @masjidRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get masjidRetry;

  /// No description provided for @masjidEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada masjid ditemukan'**
  String get masjidEmpty;

  /// No description provided for @masjidEmptyHint.
  ///
  /// In id, this message translates to:
  /// **'Coba ubah kata kunci atau filter.'**
  String get masjidEmptyHint;

  /// No description provided for @masjidLocationUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Lokasi tidak tersedia'**
  String get masjidLocationUnavailable;

  /// No description provided for @masjidLocationUnavailableHint.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan izin lokasi untuk mencari masjid di sekitar Anda.'**
  String get masjidLocationUnavailableHint;

  /// No description provided for @masjidLocationLinuxHint.
  ///
  /// In id, this message translates to:
  /// **'Fitur ini memerlukan perangkat dengan GPS dan tidak tersedia di desktop.'**
  String get masjidLocationLinuxHint;

  /// No description provided for @masjidRecenter.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke lokasi Anda'**
  String get masjidRecenter;

  /// No description provided for @masjidDetailAddress.
  ///
  /// In id, this message translates to:
  /// **'Alamat'**
  String get masjidDetailAddress;

  /// No description provided for @masjidDetailDistance.
  ///
  /// In id, this message translates to:
  /// **'Jarak'**
  String get masjidDetailDistance;

  /// No description provided for @masjidDetailAmenities.
  ///
  /// In id, this message translates to:
  /// **'Fasilitas'**
  String get masjidDetailAmenities;

  /// No description provided for @masjidDetailHours.
  ///
  /// In id, this message translates to:
  /// **'Jam Buka'**
  String get masjidDetailHours;

  /// No description provided for @masjidNoAddress.
  ///
  /// In id, this message translates to:
  /// **'Alamat tidak tercantum'**
  String get masjidNoAddress;

  /// No description provided for @masjidNoAmenities.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada informasi fasilitas'**
  String get masjidNoAmenities;

  /// No description provided for @masjidRouteError.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat membuka aplikasi peta'**
  String get masjidRouteError;

  /// No description provided for @masjidCachedNote.
  ///
  /// In id, this message translates to:
  /// **'Data tersimpan — koneksi gagal, menampilkan hasil terakhir.'**
  String get masjidCachedNote;

  /// No description provided for @personalityTitle.
  ///
  /// In id, this message translates to:
  /// **'Analisis Kepribadian'**
  String get personalityTitle;

  /// No description provided for @personalityHeaderTitle.
  ///
  /// In id, this message translates to:
  /// **'Kepribadian Spiritual'**
  String get personalityHeaderTitle;

  /// No description provided for @personalitySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan pola bacaanmu dari riwayat membaca Al-Qur\'an.'**
  String get personalitySubtitle;

  /// No description provided for @personalityError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat analisis.'**
  String get personalityError;

  /// No description provided for @personalityDnaTitle.
  ///
  /// In id, this message translates to:
  /// **'DNA Bacaan'**
  String get personalityDnaTitle;

  /// No description provided for @personalityThemeSabar.
  ///
  /// In id, this message translates to:
  /// **'Sabar & Syukur'**
  String get personalityThemeSabar;

  /// No description provided for @personalityThemeKisah.
  ///
  /// In id, this message translates to:
  /// **'Kisah Para Nabi'**
  String get personalityThemeKisah;

  /// No description provided for @personalityThemeTauhid.
  ///
  /// In id, this message translates to:
  /// **'Tauhid & Akidah'**
  String get personalityThemeTauhid;

  /// No description provided for @personalityActiveSlotLabel.
  ///
  /// In id, this message translates to:
  /// **'Waktu Aktif'**
  String get personalityActiveSlotLabel;

  /// No description provided for @personalitySlotSubuh.
  ///
  /// In id, this message translates to:
  /// **'Subuh'**
  String get personalitySlotSubuh;

  /// No description provided for @personalitySlotPagi.
  ///
  /// In id, this message translates to:
  /// **'Pagi'**
  String get personalitySlotPagi;

  /// No description provided for @personalitySlotSiang.
  ///
  /// In id, this message translates to:
  /// **'Siang'**
  String get personalitySlotSiang;

  /// No description provided for @personalitySlotSore.
  ///
  /// In id, this message translates to:
  /// **'Sore'**
  String get personalitySlotSore;

  /// No description provided for @personalitySlotMalam.
  ///
  /// In id, this message translates to:
  /// **'Malam'**
  String get personalitySlotMalam;

  /// No description provided for @personalityFavoriteLabel.
  ///
  /// In id, this message translates to:
  /// **'Surah Favorit'**
  String get personalityFavoriteLabel;

  /// No description provided for @personalityNextTitle.
  ///
  /// In id, this message translates to:
  /// **'Langkah Selanjutnya'**
  String get personalityNextTitle;

  /// No description provided for @personalityNextButton.
  ///
  /// In id, this message translates to:
  /// **'Mulai Membaca'**
  String get personalityNextButton;

  /// No description provided for @personalityEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data bacaan'**
  String get personalityEmptyTitle;

  /// No description provided for @personalityEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Analisis ini dihitung dari riwayat baca yang tersimpan. Mulailah membaca untuk melihat hasilnya.'**
  String get personalityEmptyMessage;

  /// No description provided for @personalityEmptyCta.
  ///
  /// In id, this message translates to:
  /// **'Mulai Membaca'**
  String get personalityEmptyCta;

  /// No description provided for @statsPersonalityTitle.
  ///
  /// In id, this message translates to:
  /// **'Analisis Kepribadian'**
  String get statsPersonalityTitle;

  /// No description provided for @statsPersonalityCaption.
  ///
  /// In id, this message translates to:
  /// **'Pola bacaanmu: DNA bacaan, waktu aktif, dan surah favorit.'**
  String get statsPersonalityCaption;

  /// No description provided for @learningTitle.
  ///
  /// In id, this message translates to:
  /// **'Pusat Belajar'**
  String get learningTitle;

  /// No description provided for @learningSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari materi pembelajaran...'**
  String get learningSearchHint;

  /// No description provided for @learningSearchEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada materi yang cocok'**
  String get learningSearchEmpty;

  /// No description provided for @learningSearchEmptyHint.
  ///
  /// In id, this message translates to:
  /// **'Coba kata kunci lain.'**
  String get learningSearchEmptyHint;

  /// No description provided for @learningKategoriTitle.
  ///
  /// In id, this message translates to:
  /// **'Kategori Pembelajaran'**
  String get learningKategoriTitle;

  /// No description provided for @learningHeroLabel.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan Belajar'**
  String get learningHeroLabel;

  /// No description provided for @learningSelesai.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get learningSelesai;

  /// No description provided for @learningLangkah.
  ///
  /// In id, this message translates to:
  /// **'Langkah'**
  String get learningLangkah;

  /// No description provided for @learningLangkahDari.
  ///
  /// In id, this message translates to:
  /// **'dari'**
  String get learningLangkahDari;

  /// No description provided for @learningCourseCount.
  ///
  /// In id, this message translates to:
  /// **'Kursus'**
  String get learningCourseCount;

  /// No description provided for @learningDaftarLangkah.
  ///
  /// In id, this message translates to:
  /// **'Daftar Langkah'**
  String get learningDaftarLangkah;

  /// No description provided for @learningMarkDone.
  ///
  /// In id, this message translates to:
  /// **'Tandai Selesai'**
  String get learningMarkDone;

  /// No description provided for @learningMarkUndone.
  ///
  /// In id, this message translates to:
  /// **'Tandai Belum Selesai'**
  String get learningMarkUndone;

  /// No description provided for @learningNextLesson.
  ///
  /// In id, this message translates to:
  /// **'Langkah Berikutnya'**
  String get learningNextLesson;

  /// No description provided for @learningBackToCourse.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke Kursus'**
  String get learningBackToCourse;

  /// No description provided for @learningCatShalat.
  ///
  /// In id, this message translates to:
  /// **'Belajar Shalat'**
  String get learningCatShalat;

  /// No description provided for @learningCatShalatSub.
  ///
  /// In id, this message translates to:
  /// **'Wudhu, Gerakan, Doa'**
  String get learningCatShalatSub;

  /// No description provided for @learningCatNgaji.
  ///
  /// In id, this message translates to:
  /// **'Belajar Ngaji'**
  String get learningCatNgaji;

  /// No description provided for @learningCatNgajiSub.
  ///
  /// In id, this message translates to:
  /// **'Huruf Hijaiyah, Tajwid Dasar'**
  String get learningCatNgajiSub;

  /// No description provided for @learningCatEdukasi.
  ///
  /// In id, this message translates to:
  /// **'Edukasi Islam'**
  String get learningCatEdukasi;

  /// No description provided for @learningCatEdukasiSub.
  ///
  /// In id, this message translates to:
  /// **'Adab, Sejarah Nabi'**
  String get learningCatEdukasiSub;

  /// No description provided for @learningHomeEntryTitle.
  ///
  /// In id, this message translates to:
  /// **'Pusat Belajar'**
  String get learningHomeEntryTitle;

  /// No description provided for @learningHomeEntrySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Belajar shalat, ngaji, dan edukasi Islam.'**
  String get learningHomeEntrySubtitle;

  /// No description provided for @hijriTitle.
  ///
  /// In id, this message translates to:
  /// **'Kalender Hijriah'**
  String get hijriTitle;

  /// No description provided for @qaKalenderHijriah.
  ///
  /// In id, this message translates to:
  /// **'Kalender Hijriah'**
  String get qaKalenderHijriah;

  /// No description provided for @hijriYearSuffix.
  ///
  /// In id, this message translates to:
  /// **'H'**
  String get hijriYearSuffix;

  /// No description provided for @gregorianYearSuffix.
  ///
  /// In id, this message translates to:
  /// **'M'**
  String get gregorianYearSuffix;

  /// No description provided for @hijriWeekdaySen.
  ///
  /// In id, this message translates to:
  /// **'Sen'**
  String get hijriWeekdaySen;

  /// No description provided for @hijriWeekdaySel.
  ///
  /// In id, this message translates to:
  /// **'Sel'**
  String get hijriWeekdaySel;

  /// No description provided for @hijriWeekdayRab.
  ///
  /// In id, this message translates to:
  /// **'Rab'**
  String get hijriWeekdayRab;

  /// No description provided for @hijriWeekdayKam.
  ///
  /// In id, this message translates to:
  /// **'Kam'**
  String get hijriWeekdayKam;

  /// No description provided for @hijriWeekdayJum.
  ///
  /// In id, this message translates to:
  /// **'Jum'**
  String get hijriWeekdayJum;

  /// No description provided for @hijriWeekdaySab.
  ///
  /// In id, this message translates to:
  /// **'Sab'**
  String get hijriWeekdaySab;

  /// No description provided for @hijriWeekdayAhad.
  ///
  /// In id, this message translates to:
  /// **'Ahad'**
  String get hijriWeekdayAhad;

  /// No description provided for @hijriTodayLabel.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get hijriTodayLabel;

  /// No description provided for @profileTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileNameDefault.
  ///
  /// In id, this message translates to:
  /// **'Pengguna'**
  String get profileNameDefault;

  /// No description provided for @profileNameDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah Nama'**
  String get profileNameDialogTitle;

  /// No description provided for @profileNameHint.
  ///
  /// In id, this message translates to:
  /// **'Nama kamu'**
  String get profileNameHint;

  /// No description provided for @profileSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get profileSave;

  /// No description provided for @profileSurahRead.
  ///
  /// In id, this message translates to:
  /// **'Surah Dibaca'**
  String get profileSurahRead;

  /// No description provided for @profileAyahRead.
  ///
  /// In id, this message translates to:
  /// **'Ayat Dibaca'**
  String get profileAyahRead;

  /// No description provided for @profileStreakDays.
  ///
  /// In id, this message translates to:
  /// **'Hari Beruntun'**
  String get profileStreakDays;

  /// No description provided for @profileHistoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Bacaan Terakhir'**
  String get profileHistoryTitle;

  /// No description provided for @profileHistoryEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat baca.'**
  String get profileHistoryEmpty;

  /// No description provided for @profileHistoryEmptyHint.
  ///
  /// In id, this message translates to:
  /// **'Mulai membaca untuk melihat riwayatmu di sini.'**
  String get profileHistoryEmptyHint;

  /// No description provided for @profileSettingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get profileSettingsTitle;

  /// No description provided for @profileThemeLabel.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get profileThemeLabel;

  /// No description provided for @profileLanguageLabel.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get profileLanguageLabel;

  /// No description provided for @profileLanguageValue.
  ///
  /// In id, this message translates to:
  /// **'Indonesia'**
  String get profileLanguageValue;

  /// No description provided for @profileTimeJustNow.
  ///
  /// In id, this message translates to:
  /// **'Baru saja'**
  String get profileTimeJustNow;

  /// No description provided for @profileTimeMinutesAgo.
  ///
  /// In id, this message translates to:
  /// **'menit lalu'**
  String get profileTimeMinutesAgo;

  /// No description provided for @profileTimeHoursAgo.
  ///
  /// In id, this message translates to:
  /// **'jam lalu'**
  String get profileTimeHoursAgo;

  /// No description provided for @profileTimeYesterday.
  ///
  /// In id, this message translates to:
  /// **'Kemarin'**
  String get profileTimeYesterday;

  /// No description provided for @profileTimeDaysAgo.
  ///
  /// In id, this message translates to:
  /// **'hari lalu'**
  String get profileTimeDaysAgo;

  /// No description provided for @zakatTitle.
  ///
  /// In id, this message translates to:
  /// **'Kalkulator Zakat'**
  String get zakatTitle;

  /// No description provided for @zakatSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Hitung zakat fitrah, mal, emas & perak, penghasilan, dan pertanian'**
  String get zakatSubtitle;

  /// No description provided for @zakatTabFitrah.
  ///
  /// In id, this message translates to:
  /// **'Fitrah'**
  String get zakatTabFitrah;

  /// No description provided for @zakatTabMal.
  ///
  /// In id, this message translates to:
  /// **'Mal'**
  String get zakatTabMal;

  /// No description provided for @zakatTabEmasPerak.
  ///
  /// In id, this message translates to:
  /// **'Emas & Perak'**
  String get zakatTabEmasPerak;

  /// No description provided for @zakatTabPenghasilan.
  ///
  /// In id, this message translates to:
  /// **'Penghasilan'**
  String get zakatTabPenghasilan;

  /// No description provided for @zakatTabPertanian.
  ///
  /// In id, this message translates to:
  /// **'Pertanian'**
  String get zakatTabPertanian;

  /// No description provided for @zakatJumlahJiwa.
  ///
  /// In id, this message translates to:
  /// **'Jumlah jiwa'**
  String get zakatJumlahJiwa;

  /// No description provided for @zakatHargaBeras.
  ///
  /// In id, this message translates to:
  /// **'Harga beras per kg (Rp)'**
  String get zakatHargaBeras;

  /// No description provided for @zakatTotalHarta.
  ///
  /// In id, this message translates to:
  /// **'Total harta (Rp)'**
  String get zakatTotalHarta;

  /// No description provided for @zakatHargaEmas.
  ///
  /// In id, this message translates to:
  /// **'Harga emas per gram (Rp)'**
  String get zakatHargaEmas;

  /// No description provided for @zakatGramEmas.
  ///
  /// In id, this message translates to:
  /// **'Gram emas'**
  String get zakatGramEmas;

  /// No description provided for @zakatGramPerak.
  ///
  /// In id, this message translates to:
  /// **'Gram perak'**
  String get zakatGramPerak;

  /// No description provided for @zakatHargaPerak.
  ///
  /// In id, this message translates to:
  /// **'Harga perak per gram (Rp)'**
  String get zakatHargaPerak;

  /// No description provided for @zakatPenghasilanBulanan.
  ///
  /// In id, this message translates to:
  /// **'Penghasilan per bulan (Rp)'**
  String get zakatPenghasilanBulanan;

  /// No description provided for @zakatHasilPanen.
  ///
  /// In id, this message translates to:
  /// **'Hasil panen (kg)'**
  String get zakatHasilPanen;

  /// No description provided for @zakatHargaHasil.
  ///
  /// In id, this message translates to:
  /// **'Harga hasil panen per kg (Rp)'**
  String get zakatHargaHasil;

  /// No description provided for @zakatIrigasiAlami.
  ///
  /// In id, this message translates to:
  /// **'Irigasi alami (hujan)'**
  String get zakatIrigasiAlami;

  /// No description provided for @zakatIrigasiBerbayar.
  ///
  /// In id, this message translates to:
  /// **'Irigasi berbayar'**
  String get zakatIrigasiBerbayar;

  /// No description provided for @zakatHitung.
  ///
  /// In id, this message translates to:
  /// **'Hitung Zakat'**
  String get zakatHitung;

  /// No description provided for @zakatHasil.
  ///
  /// In id, this message translates to:
  /// **'Hasil Perhitungan'**
  String get zakatHasil;

  /// No description provided for @zakatWajib.
  ///
  /// In id, this message translates to:
  /// **'Wajib zakat'**
  String get zakatWajib;

  /// No description provided for @zakatBelumWajib.
  ///
  /// In id, this message translates to:
  /// **'Belum wajib zakat'**
  String get zakatBelumWajib;

  /// No description provided for @zakatNisab.
  ///
  /// In id, this message translates to:
  /// **'Nisab'**
  String get zakatNisab;

  /// No description provided for @zakatJumlahZakat.
  ///
  /// In id, this message translates to:
  /// **'Jumlah zakat'**
  String get zakatJumlahZakat;

  /// No description provided for @zakatCatatanBelumNisab.
  ///
  /// In id, this message translates to:
  /// **'Belum mencapai nisab'**
  String get zakatCatatanBelumNisab;

  /// No description provided for @zakatRupiah.
  ///
  /// In id, this message translates to:
  /// **'Rp'**
  String get zakatRupiah;

  /// No description provided for @zakatFieldRequired.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi semua kolom terlebih dahulu'**
  String get zakatFieldRequired;

  /// No description provided for @zakatHargaHasilHint.
  ///
  /// In id, this message translates to:
  /// **'Kosongkan untuk menghitung dalam kg'**
  String get zakatHargaHasilHint;

  /// No description provided for @onboardingSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In id, this message translates to:
  /// **'Mulai'**
  String get onboardingStart;

  /// No description provided for @onboardingWelcomeEyebrow.
  ///
  /// In id, this message translates to:
  /// **'SELAMAT DATANG'**
  String get onboardingWelcomeEyebrow;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Al-Qur\'an'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeTagline.
  ///
  /// In id, this message translates to:
  /// **'Pendamping ibadah harianmu — membaca, sholat, dan dzikir dalam satu tempat.'**
  String get onboardingWelcomeTagline;

  /// No description provided for @onboardingReadTitle.
  ///
  /// In id, this message translates to:
  /// **'Baca Al-Qur\'an'**
  String get onboardingReadTitle;

  /// No description provided for @onboardingReadDesc.
  ///
  /// In id, this message translates to:
  /// **'114 surah dan 30 juz lengkap, dengan bacaan Arab yang jelas dan rapi.'**
  String get onboardingReadDesc;

  /// No description provided for @onboardingChipTranslation.
  ///
  /// In id, this message translates to:
  /// **'Terjemahan'**
  String get onboardingChipTranslation;

  /// No description provided for @onboardingChipTafsir.
  ///
  /// In id, this message translates to:
  /// **'Tafsir'**
  String get onboardingChipTafsir;

  /// No description provided for @onboardingChipTajwid.
  ///
  /// In id, this message translates to:
  /// **'Warna tajwid'**
  String get onboardingChipTajwid;

  /// No description provided for @onboardingHijriTitle.
  ///
  /// In id, this message translates to:
  /// **'Kalender Hijriah'**
  String get onboardingHijriTitle;

  /// No description provided for @onboardingHijriDesc.
  ///
  /// In id, this message translates to:
  /// **'Lihat tanggal hijriah dan tandai perjalanan khatam Al-Qur\'anmu.'**
  String get onboardingHijriDesc;

  /// No description provided for @onboardingChipHijriDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Hijriah'**
  String get onboardingChipHijriDate;

  /// No description provided for @onboardingChipKhatam.
  ///
  /// In id, this message translates to:
  /// **'Target Khatam'**
  String get onboardingChipKhatam;

  /// No description provided for @onboardingHijriLabel.
  ///
  /// In id, this message translates to:
  /// **'HIJRIAH'**
  String get onboardingHijriLabel;

  /// No description provided for @onboardingHijriYear.
  ///
  /// In id, this message translates to:
  /// **'1448 H'**
  String get onboardingHijriYear;

  /// No description provided for @onboardingMosqueTitle.
  ///
  /// In id, this message translates to:
  /// **'Temukan Masjid'**
  String get onboardingMosqueTitle;

  /// No description provided for @onboardingMosqueDesc.
  ///
  /// In id, this message translates to:
  /// **'Lacak masjid terdekat dan arah kiblat di sekitarmu.'**
  String get onboardingMosqueDesc;

  /// No description provided for @onboardingChipNearbyMosque.
  ///
  /// In id, this message translates to:
  /// **'Masjid Terdekat'**
  String get onboardingChipNearbyMosque;

  /// No description provided for @onboardingChipQibla.
  ///
  /// In id, this message translates to:
  /// **'Arah Kiblat'**
  String get onboardingChipQibla;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
