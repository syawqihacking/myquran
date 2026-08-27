import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/window_state_service.dart';
import '../db/quran_database.dart';
import '../db/user_database.dart';
import '../repositories/quran_repositories.dart';
import '../repositories/reading_history_repository.dart';
import '../repositories/reading_stats_repository.dart';
import '../repositories/spiritual_repository.dart';
import '../repositories/user_repositories.dart';

/// Overridden in `main()` with the awaited instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('overridden in main'),
);

/// Persists/restores the desktop window geometry across sessions.
final windowStateServiceProvider = Provider<WindowStateService>(
  (ref) => WindowStateService(ref.watch(sharedPreferencesProvider)),
);

final quranDatabaseProvider = Provider<QuranDatabase>((ref) {
  final db = QuranDatabase();
  ref.onDispose(db.close);
  return db;
});

final userDatabaseProvider = Provider<UserDatabase>((ref) {
  final db = UserDatabase();
  ref.onDispose(db.close);
  return db;
});

final surahRepositoryProvider = Provider(
  (ref) => SurahRepository(ref.watch(quranDatabaseProvider)),
);

final ayahRepositoryProvider = Provider(
  (ref) => AyahRepository(ref.watch(quranDatabaseProvider)),
);

final searchRepositoryProvider = Provider(
  (ref) => SearchRepository(ref.watch(quranDatabaseProvider)),
);

final bookmarkRepositoryProvider = Provider(
  (ref) => BookmarkRepository(
    ref.watch(userDatabaseProvider),
    ref.watch(quranDatabaseProvider),
  ),
);

final lastReadRepositoryProvider = Provider(
  (ref) => LastReadRepository(ref.watch(userDatabaseProvider)),
);

final doaBookmarkRepositoryProvider = Provider(
  (ref) => DoaBookmarkRepository(ref.watch(userDatabaseProvider)),
);

final readingStatsRepositoryProvider = Provider(
  (ref) => ReadingStatsRepository(ref.watch(userDatabaseProvider)),
);

final sajdaRepositoryProvider = Provider(
  (ref) => SajdaRepository(ref.watch(userDatabaseProvider)),
);

final khatamRepositoryProvider = Provider(
  (ref) => KhatamRepository(ref.watch(userDatabaseProvider)),
);

final surahPositionRepositoryProvider = Provider(
  (ref) => SurahPositionRepository(ref.watch(userDatabaseProvider)),
);

final readingHistoryRepositoryProvider = Provider(
  (ref) => ReadingHistoryRepository(
    ref.watch(userDatabaseProvider),
    ref.watch(quranDatabaseProvider),
  ),
);
