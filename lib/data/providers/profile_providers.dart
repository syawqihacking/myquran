import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_strings.dart';
import '../repositories/reading_history_repository.dart';
import 'database_providers.dart';

// ---- Profil Pengguna ---------------------------------------------------------

/// The user's display name, persisted in shared_preferences under
/// `profile_name`. Defaults to "Pengguna" — honest, no fabricated identity.
class ProfileNameController extends Notifier<String> {
  static const _kName = 'profile_name';

  @override
  String build() =>
      ref.read(sharedPreferencesProvider).getString(_kName) ??
      S.profileNameDefault;

  /// Saves the trimmed name; empty input falls back to the default.
  void setName(String name) {
    final value = name.trim();
    state = value.isEmpty ? S.profileNameDefault : value;
    ref.read(sharedPreferencesProvider).setString(_kName, state);
  }
}

final profileNameProvider = NotifierProvider<ProfileNameController, String>(
  ProfileNameController.new,
);

/// Distinct surahs the user has read, derived from `reading_log` joined to the
/// ayah table (bounded to the 200 most recent rows like the history repo).
/// Auto-refreshes on `reading_log` changes via the drift table stream.
final surahsReadCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(userDatabaseProvider);
  final ayahRepo = ref.watch(ayahRepositoryProvider);
  final recent = user.select(user.readingLog)..limit(200);
  return recent.watch().asyncMap((entries) async {
    if (entries.isEmpty) return 0;
    final ayahs = await ayahRepo.getAyahsByIds(
      entries.map((e) => e.ayahId).toSet().toList(),
    );
    return ayahs.map((a) => a.surahId).toSet().length;
  });
});

/// Recently-read surahs for the Profil "Riwayat Bacaan Terakhir" list.
final profileRecentSurahsProvider = StreamProvider<List<RecentSurahRead>>(
  (ref) =>
      ref.watch(readingHistoryRepositoryProvider).watchRecentSurahs(limit: 8),
);
