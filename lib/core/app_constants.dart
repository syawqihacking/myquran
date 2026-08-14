/// App-wide constants for MyQuran.
class AppConstants {
  AppConstants._();

  static const String appName = 'MyQuran';

  // Prebuilt quran.db schema version. Must match tool/build_db.py
  // (PRAGMA user_version) and the asset's on-disk user version; a mismatch
  // forces the app to re-copy the asset on next launch.
  // Bumped to 2 when the prebuilt schema changed (tafsir table name).
  static const int quranDbSchemaVersion = 2;

  // Runtime user.db schema version (drift-managed). Independent from the
  // quran.db asset version — bump ONLY together with a real migration in
  // UserDatabase.migration. Keep in sync with the on-disk user_version so
  // drift never runs an upgrade without a strategy.
  // v2 = reading_log table (reading stats / khatam plan).
  // v3 = sajda_log, khatam_targets, surah_positions tables; reciters.url_template
  //      and ayah_audio.last_accessed_at columns (audio phase-2 seam); reciter seed.
  static const int userDbSchemaVersion = 3;

  // Quran font scale steps (design system §2.4).
  static const int minQuranFontStep = 1;
  static const int maxQuranFontStep = 9;
  static const int defaultQuranFontStep = 5;

  // Databases.
  static const String dbSubDir = 'myquran';
  static const String quranDbFile = 'quran.db';
  static const String userDbFile = 'user.db';
  static const String quranDbAsset = 'assets/db/quran.db';

  // Font families (pubspec declarations).
  static const String fontQuran = 'AmiriQuran';
  static const String fontUi = 'Inter';
  static const String fontArabic = 'NotoSansArabic';

  // Window.
  static const double minWindowWidth = 800;
  static const double minWindowHeight = 600;

  // Layout (design system §3 / screens §0).
  static const double sidebarFullWidth = 264;
  static const double sidebarRailWidth = 76;
  static const double sidebarBreakpoint = 1040;
  static const double mobileBreakpoint = 600;
  static const double contentColumnMaxWidth = 760;
  static const double readerMaxWidth = 1040;
  static const double readerMinWidth = 680;
  static const double searchCardWidth = 640;
}
