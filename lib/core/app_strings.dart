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
  static const bookmarksTitle = 'Penanda';
  static const bookmarksCaption = 'Ayat yang kamu tandai tersimpan di perangkat ini.';
  static const bookmarksEmptyTitle = 'Belum ada penanda baca';
  static const bookmarksEmptyMessage =
      'Tandai ayat dengan ikon bookmark saat membaca — ayat akan muncul di sini.';
  static const startReading = 'Mulai membaca';
  static const removeBookmarkConfirm = 'Hapus penanda ini?';
  static const remove = 'Hapus';

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
}
