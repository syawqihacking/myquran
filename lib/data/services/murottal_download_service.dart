import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../db/quran_database.dart';
import 'just_audio_service.dart';

/// Downloads a full surah's recitation (murottal) as individual mp3 files into
/// persistent app storage so it can be played back offline.
///
/// Files live under `getApplicationDocumentsDirectory()/murottal_offline/
/// `<surahId>/<ayahNumber>.mp3`. Each ayah is fetched from the same URL
/// templates used for streaming ([audioUrlFor] + the qurancdn fallback) and
/// written to disk. A partially-downloaded surah is never reported as done.
class MurottalDownloadService {
  MurottalDownloadService({required this.resolveUrlTemplates});

  final Future<List<String>> Function() resolveUrlTemplates;

  /// Absolute path of the local mp3 for [ayahNumber] of [surahId], or null
  /// when it has not been downloaded yet.
  Future<String?> localFileFor(int surahId, int ayahNumber) async {
    final file = await _fileFor(surahId, ayahNumber);
    return await file.exists() ? file.path : null;
  }

  /// Whether every ayah of [surahId] (1..[totalAyahs]) is present on disk.
  Future<bool> isSurahDownloaded(int surahId, int totalAyahs) async {
    for (var n = 1; n <= totalAyahs; n++) {
      if (await localFileFor(surahId, n) == null) return false;
    }
    return true;
  }

  /// Downloads all [ayahs] of a surah. Reports progress via [onProgress]
  /// (count of ayahs written so far). Stops early (leaving a partial download)
  /// when [isCancelled] returns true. Throws on network/HTTP failure so the
  /// caller can surface an honest error and never mark the surah as done.
  Future<void> downloadSurah(
    int surahId,
    List<Ayah> ayahs, {
    required void Function(int done) onProgress,
    required bool Function() isCancelled,
  }) async {
    final templates = await resolveUrlTemplates();
    if (templates.isEmpty) {
      throw HttpException('murottal download failed: no URL template');
    }
    final primary = templates.first;

    var done = 0;
    for (final ayah in ayahs) {
      if (isCancelled()) return;
      final file = await _fileFor(surahId, ayah.ayahNumber);
      if (await file.exists()) {
        done++;
        onProgress(done);
        continue;
      }
      final url = audioUrlFor(ayah.surahId, ayah.ayahNumber, primary);
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) {
        throw HttpException('murottal download failed: ${res.statusCode}');
      }
      await file.parent.create(recursive: true);
      await file.writeAsBytes(res.bodyBytes, flush: true);
      done++;
      onProgress(done);
    }
  }

  /// Removes all downloaded files for [surahId].
  Future<void> deleteSurah(int surahId) async {
    final dir = await _dirFor(surahId);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<File> _fileFor(int surahId, int ayahNumber) async =>
      File(p.join((await _dirFor(surahId)).path, '$ayahNumber.mp3'));

  Future<Directory> _dirFor(int surahId) async => Directory(
        p.join(
          (await getApplicationDocumentsDirectory()).path,
          'murottal_offline',
          '$surahId',
        ),
      );
}
