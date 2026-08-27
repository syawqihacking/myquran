import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/quran_palette.dart';
import 'database_providers.dart';

/// Supported app languages.
enum AppLocale {
  id('id', 'Indonesia'),
  en('en', 'English'),
  ar('ar', 'العربية');

  const AppLocale(this.code, this.displayName);
  final String code;
  final String displayName;

  Locale toLocale() => Locale(code);
}

class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = AppLocale.id,
    this.quranFontStep = AppConstants.defaultQuranFontStep,
    this.showTranslation = true,
    this.alignArabicRight = true,
    this.tafsirOpenByDefault = false,
    this.restoreLastRead = true,
    this.paperTheme = PaperTheme.hangat,
    this.tajwidColor = false,
  });

  final ThemeMode themeMode;
  final AppLocale locale;
  final int quranFontStep;
  final bool showTranslation;
  final bool alignArabicRight;
  final bool tafsirOpenByDefault;
  final bool restoreLastRead;
  final PaperTheme paperTheme;
  final bool tajwidColor;

  SettingsState copyWith({
    ThemeMode? themeMode,
    AppLocale? locale,
    int? quranFontStep,
    bool? showTranslation,
    bool? alignArabicRight,
    bool? tafsirOpenByDefault,
    bool? restoreLastRead,
    PaperTheme? paperTheme,
    bool? tajwidColor,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      quranFontStep: quranFontStep ?? this.quranFontStep,
      showTranslation: showTranslation ?? this.showTranslation,
      alignArabicRight: alignArabicRight ?? this.alignArabicRight,
      tafsirOpenByDefault: tafsirOpenByDefault ?? this.tafsirOpenByDefault,
      restoreLastRead: restoreLastRead ?? this.restoreLastRead,
      paperTheme: paperTheme ?? this.paperTheme,
      tajwidColor: tajwidColor ?? this.tajwidColor,
    );
  }
}

class SettingsController extends Notifier<SettingsState> {
  static const _kThemeMode = 'theme_mode';
  static const _kLocale = 'app_locale';
  static const _kFontStep = 'quran_font_step';
  static const _kShowTranslation = 'show_translation';
  static const _kAlign = 'align_arabic_right';
  static const _kTafsirDefault = 'tafsir_open_default';
  static const _kRestoreLastRead = 'restore_last_read';
  static const _kPaperTheme = 'paper_theme';
  static const _kTajwid = 'tajwid_color';

  @override
  SettingsState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final savedLocale = prefs.getString(_kLocale);
    return SettingsState(
      themeMode:
          ThemeMode.values.asNameMap()[prefs.getString(_kThemeMode)] ??
          ThemeMode.system,
      locale: AppLocale.values.asNameMap()[savedLocale] ?? AppLocale.id,
      quranFontStep:
          prefs.getInt(_kFontStep) ?? AppConstants.defaultQuranFontStep,
      showTranslation: prefs.getBool(_kShowTranslation) ?? true,
      alignArabicRight: prefs.getBool(_kAlign) ?? true,
      tafsirOpenByDefault: prefs.getBool(_kTafsirDefault) ?? false,
      restoreLastRead: prefs.getBool(_kRestoreLastRead) ?? true,
      paperTheme:
          PaperTheme.values.asNameMap()[prefs.getString(_kPaperTheme)] ??
          PaperTheme.hangat,
      tajwidColor: prefs.getBool(_kTajwid) ?? false,
    );
  }

  void _save() {
    final prefs = ref.read(sharedPreferencesProvider);
    final s = state;
    prefs.setString(_kThemeMode, s.themeMode.name);
    prefs.setString(_kLocale, s.locale.name);
    prefs.setInt(_kFontStep, s.quranFontStep);
    prefs.setBool(_kShowTranslation, s.showTranslation);
    prefs.setBool(_kAlign, s.alignArabicRight);
    prefs.setBool(_kTafsirDefault, s.tafsirOpenByDefault);
    prefs.setBool(_kRestoreLastRead, s.restoreLastRead);
    prefs.setString(_kPaperTheme, s.paperTheme.name);
    prefs.setBool(_kTajwid, s.tajwidColor);
  }

  void setThemeMode(ThemeMode m) {
    state = state.copyWith(themeMode: m);
    _save();
  }

  void setFontStep(int step) {
    final clamped = step < AppConstants.minQuranFontStep
        ? AppConstants.minQuranFontStep
        : (step > AppConstants.maxQuranFontStep
              ? AppConstants.maxQuranFontStep
              : step);
    state = state.copyWith(quranFontStep: clamped);
    _save();
  }

  void resetFontStep() => setFontStep(AppConstants.defaultQuranFontStep);

  void setShowTranslation(bool v) {
    state = state.copyWith(showTranslation: v);
    _save();
  }

  void setAlignArabicRight(bool v) {
    state = state.copyWith(alignArabicRight: v);
    _save();
  }

  void setTafsirOpenByDefault(bool v) {
    state = state.copyWith(tafsirOpenByDefault: v);
    _save();
  }

  void setRestoreLastRead(bool v) {
    state = state.copyWith(restoreLastRead: v);
    _save();
  }

  void setPaperTheme(PaperTheme p) {
    state = state.copyWith(paperTheme: p);
    _save();
  }

  void setTajwidColor(bool v) {
    state = state.copyWith(tajwidColor: v);
    _save();
  }

  void setLocale(AppLocale l) {
    state = state.copyWith(locale: l);
    _save();
  }
}

final settingsProvider = NotifierProvider<SettingsController, SettingsState>(
  SettingsController.new,
);

// ---- Onboarding -----------------------------------------------------------

/// Whether the first-launch onboarding has been completed (or skipped).
/// Persisted in shared_preferences under `onboarding_done` — the same local
/// storage every other setting uses, so no extra dependency is needed.
class OnboardingController extends Notifier<bool> {
  static const _kOnboardingDone = 'onboarding_done';

  @override
  bool build() =>
      ref.read(sharedPreferencesProvider).getBool(_kOnboardingDone) ?? false;

  /// Marks onboarding as seen: flips the state immediately (so the app shell
  /// replaces the onboarding screen) and persists the flag for future launches.
  Future<void> complete() async {
    state = true;
    await ref.read(sharedPreferencesProvider).setBool(_kOnboardingDone, true);
  }
}

final onboardingDoneProvider = NotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);
