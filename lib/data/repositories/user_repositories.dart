import '../db/quran_database.dart';
import '../db/user_database.dart';
import 'quran_repositories.dart';

class BookmarkEntry {
  const BookmarkEntry({
    required this.bookmark,
    required this.ayah,
    required this.surah,
  });

  final Bookmark bookmark;
  final Ayah ayah;
  final Surah surah;
}

/// Bookmarks + last-read live in `user.db`; ayah/surah details are joined
/// from `quran.db` at read time (cross-DB join is not possible in drift).
class BookmarkRepository {
  BookmarkRepository(UserDatabase user, QuranDatabase quran)
      : _user = user,
        _ayahs = AyahRepository(quran),
        _surahs = SurahRepository(quran);

  final UserDatabase _user;
  final AyahRepository _ayahs;
  final SurahRepository _surahs;

  Stream<List<BookmarkEntry>> watchBookmarks() {
    return _user.select(_user.bookmarks).watch().asyncMap((bms) async {
      if (bms.isEmpty) return <BookmarkEntry>[];
      final ayahs = await _ayahs.getAyahsByIds(
          bms.map((b) => b.ayahId).toList());
      final ayahById = {for (final a in ayahs) a.id: a};
      final surahs =
          await _surahs.getSurahsByIds(ayahs.map((a) => a.surahId).toSet().toList());
      final surahById = {for (final s in surahs) s.id: s};

      final out = <BookmarkEntry>[];
      for (final bm in bms) {
        final ayah = ayahById[bm.ayahId];
        if (ayah == null) continue;
        final surah = surahById[ayah.surahId];
        if (surah == null) continue;
        out.add(BookmarkEntry(bookmark: bm, ayah: ayah, surah: surah));
      }
      out.sort((a, b) => a.ayah.id.compareTo(b.ayah.id));
      return out;
    });
  }

  Future<bool> isBookmarked(int ayahId) async {
    final r = await (_user.select(_user.bookmarks)
          ..where((t) => t.ayahId.equals(ayahId)))
        .getSingleOrNull();
    return r != null;
  }

  Future<void> toggleBookmark(int ayahId) async {
    final existing = await (_user.select(_user.bookmarks)
          ..where((t) => t.ayahId.equals(ayahId)))
        .getSingleOrNull();
    if (existing != null) {
      await (_user.delete(_user.bookmarks)
            ..where((t) => t.ayahId.equals(ayahId)))
          .go();
    } else {
      await _user.into(_user.bookmarks).insert(
            BookmarksCompanion.insert(
              ayahId: ayahId,
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
    }
  }
}

class LastReadRepository {
  LastReadRepository(this._user);

  final UserDatabase _user;

  Stream<LastRead?> watch() => _user.select(_user.lastReads).watchSingleOrNull();

  Future<void> setLastRead(int ayahId) => _user.into(_user.lastReads)
      .insertOnConflictUpdate(LastRead(
        id: 0,
        ayahId: ayahId,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ));
}
