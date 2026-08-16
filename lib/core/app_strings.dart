/// Indonesian UI strings (plain, respectful — design direction §5).
abstract final class S {
  static const appName = 'MyQuran';

  // Home.
  static const homeEyebrow = 'AL-QUR\'AN';
  static const homeTitle = 'Beranda';
  static const homeCaption = 'Baca Al-Qur\'an dengan tenang — tanpa sambungan internet.';
  static const continueEyebrow = 'LANJUTKAN MEMBACA';
  static const continueButton = 'Lanjutkan';
  static const noHistoryTitle = 'Belum ada riwayat baca.';
  static const startFromFatihah = 'Mulai dari Al-Fatihah';
  static const surahSegment = 'Surah';
  static const juzSegment = 'Juz';
  static const ayatCount = 'ayat';

  // Beranda (Stitch remodel) — greeting, hero, quick actions, daily verse.
  static const homeGreeting = 'Assalamu\'alaikum,';
  static const lastReadLabel = 'Terakhir Baca';
  static const prayerScheduleTitle = 'Jadwal Sholat';
  static const dailyVerseLabel = 'Ayat Hari Ini';
  static const dailyVerseError = 'Gagal memuat ayat hari ini.';
  static const shareVerse = 'Bagikan ayat ini';
  static const qaKiblat = 'Kiblat';
  static const qaDoaHarian = 'Doa Harian';
  static const qaZakat = 'Zakat';
  static const qaMasjidTerdekat = 'Masjid Terdekat';
  static const comingSoon = 'Segera hadir';

  // Prayer times.
  static const prayerTimesEyebrow = 'WAKTU SHOLAT';
  static const nextPrayerLabel = 'Sholat berikutnya';
  static const prayerCountdownPrefix = 'dalam';

  // Prayer screen (Jadwal Shalat & Kiblat).
  static const prayerScreenTitle = 'Jadwal Sholat';
  static const qiblaTitle = 'Arah Kiblat';
  static const qiblaCaption = 'Arahkan jarum ke kiblat';
  static const qiblaAlignHint = 'Arahkan perangkat ke kiblat';
  static const sunriseLabel = 'Terbit';
  static const changeLocation = 'Ubah';
  static const locationUpdated = 'Lokasi diperbarui';
  static const navSholat = 'Sholat';
  static const prayerError = 'Gagal memuat jadwal sholat.';
  static const retry = 'Coba lagi';

  // Prayer notifications (adzan reminders).
  static const notificationsSection = 'Notifikasi';
  static const prayerNotificationsLabel = 'Notifikasi Waktu Shalat';
  static const prayerNotificationsSublabel =
      'Pengingat otomatis saat masuk waktu shalat';
  static const prayerNotificationsDenied =
      'Izin notifikasi ditolak. Aktifkan lewat pengaturan sistem.';
  static const prayerNotificationsTest = 'Uji Notifikasi';
  static const prayerNotificationsTestSublabel =
      'Kirim notifikasi uji coba sekarang';
  static const prayerNotificationsTestSend = 'Kirim';
  static const prayerNotificationsTestTitle = 'Waktu Shalat';
  static const prayerNotificationsTestBody =
      'Ini notifikasi uji coba. Notifikasi waktu shalat aktif.';
  static const prayerNotificationsTestSent = 'Notifikasi uji coba dikirim';
  static const dzikirReminderLabel = 'Dzikir Pagi & Petang';
  static const dzikirReminderSublabel =
      'Pengingat harian untuk membaca dzikir pagi dan petang';
  static const dzikirReminderDenied =
      'Izin notifikasi ditolak. Aktifkan lewat pengaturan sistem.';
  static const dzikirReminderMorningTitle = 'Dzikir Pagi';
  static const dzikirReminderMorningBody = 'Waktunya membaca dzikir pagi.';
  static const dzikirReminderEveningTitle = 'Dzikir Petang';
  static const dzikirReminderEveningBody = 'Waktunya membaca dzikir petang.';
  static const adzanVoiceLabel = 'Suara Adzan';
  static const adzanVoiceDownloading = 'Mengunduh suara adzan...';
  static const adzanVoiceChanged = 'Suara adzan diperbarui';
  static const adzanVoiceDownloadFailed =
      'Gagal mengunduh suara adzan. Periksa koneksi internet.';

  // Browse (unified surah/juz/search page).
  static const browseEyebrow = 'BACA';
  static const browseTitle = 'Al-Qur\'an';
  static const browseCaption =
      'Jelajahi 114 surah, 30 juz, atau cari ayat dan terjemahan.';
  static const surahListTitle = 'Daftar Surah';
  static const juzListTitle = 'Daftar Juz';
  static const quickAccessEyebrow = 'DAFTAR LENGKAP';
  static const quickSurahCaption = '114 surah';
  static const quickJuzCaption = '30 juz';

  // Surah list item.
  static const makkiyah = 'Makkiyah';
  static const madaniyah = 'Madaniyah';

  // Browse — Stitch remodel (Daftar Surah).
  static const browseSearchHint = 'Cari surah atau ayat...';
  static const favoritSegment = 'Favorit';
  static const favoritEmptyTitle = 'Belum ada surah favorit';
  static const favoritEmptyMessage =
      'Tandai ayat saat membaca — surah dengan penanda akan muncul di sini.';
  static const penandaCount = 'penanda';

  // Reader.
  static const back = 'Kembali';
  static const fontSmaller = 'Perkecil teks Arab (Ctrl −)';
  static const fontLarger = 'Perbesar teks Arab (Ctrl +)';
  static const jumpToAyah = 'Lompat ke ayat';
  static const jumpLabel = 'Ayat';
  static const jumpHint = '1–';
  static const jumpOutOfRange = 'Nomor di luar jangkauan';
  static const jumpButton = 'Lompat';
  static const cancel = 'Batal';
  static const tafsirAction = 'Tafsir';
  static const tafsirHeader = 'Tafsir · Kementerian Agama RI';
  static const bookmarkAyah = 'Tandai ayat ini';
  static const removeBookmark = 'Hapus penanda';
  static const endOfSurah = 'Selesai membaca';
  static const nextSurah = 'Surah berikutnya';
  static const backToHome = 'Kembali ke Beranda';

  // Reader — Baca Al-Quran (Stitch remodel).
  static String surahMeta(int number, int ayahCount) =>
      'Surah $number • $ayahCount Ayat';
  static const playAyah = 'Putar ayat ini';
  static const shareAyah = 'Bagikan ayat';
  static const readerSettings = 'Pengaturan baca';
  static const hideTranslation = 'Sembunyikan terjemahan';

  // Reader — audio (sticky player, phase-2 seam).
  static const audioReciter = 'Mishary Alafasy';
  static String audioCaption(String surah, int ayah) =>
      'Surah $surah — Ayat $ayah';
  static const audioPlay = 'Putar';
  static const audioPause = 'Jeda';
  static const audioPrev = 'Sebelumnya';
  static const audioNext = 'Berikutnya';
  static const audioSpeedLabel = 'Kecepatan putar';
  static const audioVolume = 'Volume';
  static const audioQueue = 'Daftar putar';
  static const audioClose = 'Tutup pemutar';

  // Reader — offline murottal (download a surah's recitation).
  static const murottalDownload = 'Unduh murottal surah ini';
  static const murottalDownloading = 'Mengunduh murottal...';
  static const murottalCancel = 'Batalkan unduhan';
  static const murottalDownloaded = 'Murottal tersimpan — ketuk untuk menghapus';
  static const murottalDeleteConfirmTitle = 'Hapus murottal?';
  static const murottalDeleteConfirmMessage =
      'Hapus rekaman surah ini dari perangkat?';
  static const murottalDelete = 'Hapus';
  static const murottalDownloadFailed =
      'Gagal mengunduh murottal. Periksa koneksi internet.';
  static const murottalDownloadDone =
      'Murottal surah ini tersimpan untuk diputar offline.';

  // Search.
  static const searchHint = 'Cari surah, ayat, atau terjemahan';
  static const openSearch = 'Cari';
  static const closeSearch = 'Tutup pencarian';
  static const searchGroupSurah = 'SURAH';
  static const searchGroupAyah = 'AYAT';
  static const searchGroupTranslation = 'TERJEMAHAN';
  static const noResultsTitle = 'Tidak ada hasil';
  static const noResultsHint = 'Periksa ejaan atau coba kata lain';
  static const popularSurahs = 'Surah populer';

  // Bookmarks.
  static const bookmarksEyebrow = 'PENANDA BACA';
  static const bookmarksTitle = 'Favorit & Penanda';
  static const bookmarksCaption = 'Ayat yang kamu tandai tersimpan di perangkat ini.';
  static const bookmarksEmptyTitle = 'Belum ada penanda baca';
  static const bookmarksEmptyMessage =
      'Tandai ayat dengan ikon bookmark saat membaca — ayat akan muncul di sini.';
  static const startReading = 'Mulai membaca';
  static const removeBookmarkConfirm = 'Hapus penanda ini?';
  static const remove = 'Hapus';

  // Bookmarks — Favorit & Penanda (Stitch remodel).
  static const favoritTab = 'Favorit';
  static const penandaTab = 'Penanda';
  static String juzPage(int juz, int page) => 'Juz $juz • Halaman $page';
  static const todayLabel = 'Hari ini';
  static const yesterdayLabel = 'Kemarin';
  static String daysAgo(int n) => '$n hari lalu';
  static String weeksAgo(int n) => '$n mgg lalu';
  static const bookmarksFavoritEmptyTitle = 'Belum ada favorit';
  static const bookmarksFavoritEmptyMessage =
      'Tandai ayat dengan ikon bookmark saat membaca — favoritmu akan muncul di sini.';
  static const bookmarksPenandaEmptyTitle = 'Belum ada penanda';
  static const bookmarksPenandaEmptyMessage =
      'Riwayat bacaanmu akan muncul di sini setelah kamu membaca surah.';

  // Settings.
  static const settingsEyebrow = 'PENGATURAN';
  static const settingsTitle = 'Pengaturan';
  static const appearanceSection = 'Tampilan';
  static const themeModeLabel = 'Mode tema';
  static const themeModeSublabel = 'Ikuti tema sistem operasi.';
  static const themeSystem = 'Sistem';
  static const themeLight = 'Terang';
  static const themeDark = 'Gelap';
  static const quranFontSizeLabel = 'Ukuran teks Arab';
  static const quranFontSizeSublabel =
      'Lebih besar untuk kenyamanan baca jarak jauh; terjemahan menyesuaikan secara otomatis.';
  static const reset = 'Setel ulang';
  static const showTranslationLabel = 'Tampilkan terjemahan';
  static const alignLabel = 'Perataan teks Arab';
  static const alignRight = 'Rata kanan';
  static const alignCenter = 'Rata tengah';
  static const alignNote = 'Perataan tengah dapat membantu pada ayat pendek.';
  static const readingSection = 'Baca';
  static const tafsirDefaultLabel = 'Tafsir default terbuka';
  static const tajwidColorLabel = 'Warna tajwid';
  static const tajwidColorSublabel =
      'Warnai hukum bacaan tajwid pada teks Al-Qur\'an.';
  static const tajwidColorTooltip = 'Warna tajwid';
  static const restoreLastReadLabel = 'Pulihkan posisi baca terakhir';
  static const dataSection = 'Data & Sumber';
  static const dataSourceLabel = 'Teks, terjemahan, dan tafsir — Quran Kementerian Agama RI. Semua data tersimpan offline di perangkat.';
  static const dataVersionLabel = 'Versi data';
  static const licenseLabel = 'Lisensi';
  static const shortcutsSection = 'Pintasan keyboard';
  static const shortcutSearch = 'Cari — Ctrl K';
  static const shortcutZoomIn = 'Perbesar teks Arab — Ctrl +';
  static const shortcutZoomOut = 'Perkecil teks Arab — Ctrl −';
  static const shortcutClose = 'Tutup panel — Esc';

  // Settings — reset data.
  static const resetDataSection = 'Data pengguna';
  static const resetDataLabel = 'Reset data';
  static const resetDataSublabel =
      'Hapus riwayat baca, target khatam, sujud tilawah, posisi baca, dan penanda baca.';
  static const resetDataConfirmTitle = 'Reset semua data?';
  static const resetDataConfirmMessage =
      'Riwayat baca, target khatam, sujud tilawah, posisi baca, dan penanda baca akan dihapus permanen. Teks Al-Qur\'an dan pengaturan tampilan tidak terpengaruh.';
  static const resetDataConfirm = 'Reset data';
  static const resetDataDone = 'Data pengguna berhasil direset.';

  // Stats.
  static const statsEyebrow = 'STATISTIK';
  static const statsTitle = 'Statistik';
  static const statsCaption =
      'Jejak baca dan progres khatammu, tersimpan di perangkat ini.';
  static const statsError = 'Gagal memuat data.';
  static const statsStreakLabel = 'Hari beruntun';
  static const statsTodayLabel = 'Ayat dibaca hari ini';
  static const statsKhatamEyebrow = 'PROGRES KHATAM';
  static const statsJuzsOf = 'dari 30 juz';
  static const statsKhatamCaption = 'Baca 1 juz per hari untuk khatam dalam 30 hari.';
  static const statsTotalDaysLabel = 'Total hari membaca';
  static const statsTotalAyahsLabel = 'Total ayat dibaca';

  // Stats — khatam planner.
  static const khatamPlan30 = 'Khatam 30 hari';
  static const khatamPickDate = 'Pilih tanggal';
  static const khatamJuz = 'Juz';
  static const khatamJuzToday = 'hari ini';
  static const khatamDaysLeft = 'Sisa';
  static const khatamDays = 'hari';
  static const khatamTargetLabel = 'Target';
  static const khatamClear = 'Hapus target';
  static const khatamClearConfirm = 'Hapus target khatam ini?';
  static const khatamDone = 'Target khatam tercapai';

  // Stats — kalender baca.
  static const calendarEyebrow = 'KALENDER BACA';
  static const calendarTitle = '30 hari terakhir';
  static const calendarCaption =
      'Ayat yang dibaca setiap hari — 30 hari terakhir.';
  static const calendarFew = 'Sedikit';
  static const calendarMany = 'Banyak';
  static const sujudLabel = 'Sujud tilawah';
  static const sujudOf = 'dari 15 sujud tilawah';

  // Reader — sujud tilawah.
  static const sujudMark = 'Tandai sujud tilawah';
  static const sujudUnmark = 'Hapus tanda sujud';

  // Reader — zen mode (mode fokus membaca).
  static const zenEnter = 'Mode fokus (Ctrl B)';
  static const zenExit = 'Keluar mode fokus (Esc)';
  static const zenSnackbarExitHint = 'Keluar dengan Esc atau Ctrl B.';

  // Reader — salin ayat.
  static const copyAyah = 'Salin';
  static const copyAyahDone = 'Ayat tersalin ke papan klip.';

  // Home — riwayat baca.
  static const historyEyebrow = 'RIWAYAT BACA';
  static const historyProgressOf = 'dari';
  static const historyReadLabel = 'Ayat';

  static const changeTheme = 'Ganti tema';

  // Settings — tema kertas.
  static const paperThemeLabel = 'Tema kertas';
  static const paperThemeSublabel =
      'Warna kertas kolom baca — hangat di kedua mode.';
  static const paperHangat = 'Hangat';
  static const paperKlasik = 'Klasik';
  static const paperPucat = 'Pucat';

  // Spiritual content (Tahlil, Doa, Ratib Al-Haddad).
  static const tahlilTitle = 'Tahlil & Doa';
  static const tahlilCaption = 'Bacaan tahlil lengkap dengan doanya';
  static const ratibTitle = 'Ratib Al-Haddad';
  static const ratibCaption = 'Wirid malam karya Habib Abdullah Al-Haddad';
  static const spiritualNav = 'Wirid & Doa';

  // Dzikir Pagi & Petang.
  static const dzikirTitle = 'Dzikir Pagi & Petang';
  static const dzikirCaption = 'Dzikir pagi dan petang beserta doanya';
  static const dzikirPagi = 'Pagi';
  static const dzikirPetang = 'Petang';
  static const dzikirEmpty = 'Tidak ada dzikir ditemukan';

  // Niat Shalat.
  static const niatShalatTitle = 'Niat Shalat';
  static const niatShalatCaption = 'Niat shalat wajib dan sunnah';

  // Tadabbur Harian.
  static const tadabburTitle = 'Tadabbur Harian';
  static const tadabburCaption = 'Renungan ayat Al-Qur\'an untuk setiap hari';
  static const tadabburReflection = 'Renungan';


  // Doa Harian (daily prayers).
  static const doaHarianTitle = 'Doa Harian';
  static const doaHarianCaption =
      'Kumpulan doa sehari-hari lengkap dengan teks Arab dan terjemahan.';
  static const doaSearchHint = 'Cari doa...';
  static const doaEmpty = 'Tidak ditemukan';
  static const doaEmptyHint = 'Coba kata kunci atau kategori lain.';
  static const doaBookmarkAdd = 'Tandai doa ini';
  static const doaBookmarkRemove = 'Hapus tanda doa';

  // Spiritual reader (Tahlil & Doa, Ratib, Doa detail).
  static const tahlilHeaderTitle = 'Bacaan Tahlil';
  static const tahlilHeaderDesc =
      'Tahlil adalah rangkaian dzikir dan doa yang dibaca untuk memohon ampunan dan rahmat Allah SWT, seringkali ditujukan bagi mereka yang telah meninggal dunia. Bacalah dengan khusyuk dan tenang.';
  static const audioComingSoon = 'Audio segera hadir';
  static String readNTimes(int n) => 'DIBACA $n KALI';

  // Ratibul Haddad screen.
  static const ratibulHaddadTitle = 'Ratibul Haddad';
  static const ratibIntroChip = 'Pengenalan';
  static const ratibIntroDesc =
      'Disusun oleh Al-Habib Abdullah bin Alwi bin Muhammad Al-Haddad. Ratib ini merupakan kumpulan doa dan zikir yang diambil dari Al-Quran dan hadits, dibaca untuk memohon perlindungan, keberkahan, dan kedekatan kepada Allah SWT.';
  static const ratibFullTitle = 'Ratibul Haddad Full';
  static const playingLabel = 'Sedang Memutar';
  static const counterLabel = 'Hitung';
  static const counterReset = 'Reset hitungan';

  // Amalan Ibadah (daily deeds tracker).
  static const amalanIbadahTitle = 'Amalan Ibadah';
  static const amalanIbadahCaption =
      'Ceklis amalan harianmu dan pantau progres ibadah setiap hari';
  static const amalanGoalProgress = 'Progres Target Harian';
  static const amalanGoalSubtitle = 'Pertahankan semangatmu!';
  static String amalanProgress(int done, int total) => '$done/$total Selesai';
  static const amalanSearchHint = 'Cari amalan...';
  static const amalanLearnMore = 'Pelajari';
  static const amalanDetailPenjelasan = 'Penjelasan';
  static const amalanDetailDalil = 'Dalil';
  static const amalanEmpty = 'Tidak ditemukan';
  static const amalanEmptyHint = 'Coba kata kunci atau kategori lain.';
  static const amalanCatSemua = 'Semua';
  static const amalanCatWajib = 'Wajib';
  static const amalanCatSunnah = 'Sunnah';
  static const amalanCatDzikir = 'Dzikir';
  static const amalanCatSosial = 'Sosial';
  static const amalanToggleDone = 'Tandai selesai';
  static const amalanToggleUndone = 'Tandai belum selesai';

  // Masjid Terdekat (nearby mosque).
  static const masjidTerdekatTitle = 'Masjid Terdekat';
  static const masjidSearchHint = 'Cari masjid atau lokasi...';
  static const masjidFilterHint = 'Filter';
  static const masjidCatSemua = 'Semua';
  static const masjidCatParkirLuas = 'Parkir Luas';
  static const masjidCatToilet = 'Toilet';
  static const masjidCatAc = 'AC';
  static const masjidCatDisabilitas = 'Ramah Disabilitas';
  static const masjidRute = 'Rute';
  static const masjidDetail = 'Detail';
  static const masjidLoading = 'Mencari masjid di sekitar Anda...';
  static const masjidError = 'Gagal memuat data masjid';
  static const masjidErrorHint = 'Periksa koneksi internet lalu coba lagi.';
  static const masjidRetry = 'Coba Lagi';
  static const masjidEmpty = 'Tidak ada masjid ditemukan';
  static const masjidEmptyHint = 'Coba ubah kata kunci atau filter.';
  static const masjidLocationUnavailable = 'Lokasi tidak tersedia';
  static const masjidLocationUnavailableHint =
      'Aktifkan izin lokasi untuk mencari masjid di sekitar Anda.';
  static const masjidLocationLinuxHint =
      'Fitur ini memerlukan perangkat dengan GPS dan tidak tersedia di desktop.';
  static const masjidRecenter = 'Kembali ke lokasi Anda';
  static const masjidDetailAddress = 'Alamat';
  static const masjidDetailDistance = 'Jarak';
  static const masjidDetailAmenities = 'Fasilitas';
  static const masjidDetailHours = 'Jam Buka';
  static const masjidNoAddress = 'Alamat tidak tercantum';
  static const masjidNoAmenities = 'Tidak ada informasi fasilitas';
  static const masjidRouteError = 'Tidak dapat membuka aplikasi peta';
  static const masjidCachedNote =
      'Data tersimpan — koneksi gagal, menampilkan hasil terakhir.';

  // Analisis Kepribadian (personality analysis).
  static const personalityTitle = 'Analisis Kepribadian';
  static const personalityHeaderTitle = 'Kepribadian Spiritual';
  static const personalitySubtitle =
      'Ringkasan pola bacaanmu dari riwayat membaca Al-Qur\'an.';
  static const personalityError = 'Gagal memuat analisis.';
  static const personalityDnaTitle = 'DNA Bacaan';
  static const personalityThemeSabar = 'Sabar & Syukur';
  static const personalityThemeKisah = 'Kisah Para Nabi';
  static const personalityThemeTauhid = 'Tauhid & Akidah';
  static const personalityActiveSlotLabel = 'Waktu Aktif';
  static const personalitySlotSubuh = 'Subuh';
  static const personalitySlotPagi = 'Pagi';
  static const personalitySlotSiang = 'Siang';
  static const personalitySlotSore = 'Sore';
  static const personalitySlotMalam = 'Malam';
  static const personalityFavoriteLabel = 'Surah Favorit';
  static const personalityNextTitle = 'Langkah Selanjutnya';
  static const personalityNextButton = 'Mulai Membaca';
  static const personalityEmptyTitle = 'Belum ada data bacaan';
  static const personalityEmptyMessage =
      'Analisis ini dihitung dari riwayat baca yang tersimpan. '
      'Mulailah membaca untuk melihat hasilnya.';
  static const personalityEmptyCta = 'Mulai Membaca';

  // Statistik — entry card menuju Analisis Kepribadian.
  static const statsPersonalityTitle = 'Analisis Kepribadian';
  static const statsPersonalityCaption =
      'Pola bacaanmu: DNA bacaan, waktu aktif, dan surah favorit.';

  // Pusat Belajar (learning center).
  static const learningTitle = 'Pusat Belajar';
  static const learningSearchHint = 'Cari materi pembelajaran...';
  static const learningSearchEmpty = 'Tidak ada materi yang cocok';
  static const learningSearchEmptyHint = 'Coba kata kunci lain.';
  static const learningKategoriTitle = 'Kategori Pembelajaran';
  static const learningHeroLabel = 'Lanjutkan Belajar';
  static const learningSelesai = 'Selesai';
  static const learningLangkah = 'Langkah';
  static const learningLangkahDari = 'dari';
  static const learningCourseCount = 'Kursus';
  static const learningDaftarLangkah = 'Daftar Langkah';
  static const learningMarkDone = 'Tandai Selesai';
  static const learningMarkUndone = 'Tandai Belum Selesai';
  static const learningNextLesson = 'Langkah Berikutnya';
  static const learningBackToCourse = 'Kembali ke Kursus';
  static const learningCatShalat = 'Belajar Shalat';
  static const learningCatShalatSub = 'Wudhu, Gerakan, Doa';
  static const learningCatNgaji = 'Belajar Ngaji';
  static const learningCatNgajiSub = 'Huruf Hijaiyah, Tajwid Dasar';
  static const learningCatEdukasi = 'Edukasi Islam';
  static const learningCatEdukasiSub = 'Adab, Sejarah Nabi';
  static const learningHomeEntryTitle = 'Pusat Belajar';
  static const learningHomeEntrySubtitle =
      'Belajar shalat, ngaji, dan edukasi Islam.';

  // Kalender Hijriah (Hijri calendar).
  static const hijriTitle = 'Kalender Hijriah';
  static const qaKalenderHijriah = 'Kalender Hijriah';
  static const hijriYearSuffix = 'H';
  static const gregorianYearSuffix = 'M';
  // Short weekday header labels, aligned to Dart weekday order (1=Senin..7=Ahad).
  static const hijriWeekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Ahad'];
  static const hijriTodayLabel = 'Hari ini';

  // Profil Pengguna (user profile).
  static const profileTitle = 'Profil';
  static const profileNameDefault = 'Pengguna';
  static const profileNameDialogTitle = 'Ubah Nama';
  static const profileNameHint = 'Nama kamu';
  static const profileSave = 'Simpan';
  static const profileSurahRead = 'Surah Dibaca';
  static const profileAyahRead = 'Ayat Dibaca';
  static const profileStreakDays = 'Hari Beruntun';
  static const profileHistoryTitle = 'Riwayat Bacaan Terakhir';
  static const profileHistoryEmpty = 'Belum ada riwayat baca.';
  static const profileHistoryEmptyHint =
      'Mulai membaca untuk melihat riwayatmu di sini.';
  static const profileSettingsTitle = 'Pengaturan';
  static const profileThemeLabel = 'Pengaturan';
  static const profileLanguageLabel = 'Bahasa';
  static const profileLanguageValue = 'Indonesia';
  static const profileTimeJustNow = 'Baru saja';
  static const profileTimeMinutesAgo = 'menit lalu';
  static const profileTimeHoursAgo = 'jam lalu';
  static const profileTimeYesterday = 'Kemarin';
  static const profileTimeDaysAgo = 'hari lalu';
}
