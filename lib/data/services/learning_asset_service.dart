import 'dart:io';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Downloads shalat & wudhu assets from GitHub Release on demand, caches them
/// to the app documents directory so they work offline after first fetch.
///
/// Each category (shalat, wudu) is a zip on the release. The zip is downloaded
/// once per category; individual files are extracted on the fly so the app never
/// stores the zip itself — just the extracted files.
class LearningAssetService {
  LearningAssetService({required this.client});

  final http.Client client;

  static const _releaseBase =
      'https://github.com/syawqihacking/myquran/releases/download/assets-v1';

  /// Returns the absolute local file path for [imageAsset]
  /// (e.g. `'assets/shalat/berdiri_alfatihah.jpg'`).
  ///
  /// If the file is already cached on disk, returns immediately.
  /// Otherwise downloads & extracts the full category zip, then returns the
  /// resolved path. Returns `null` if the download fails or the asset is not
  /// recognised.
  Future<String?> localFileFor(String imageAsset) async {
    final category = _categoryFor(imageAsset);
    if (category == null) return null;

    final baseDir = await getApplicationDocumentsDirectory();
    final filePath = p.join(baseDir.path, 'learning_assets', imageAsset);
    final file = File(filePath);

    // Already cached → return path.
    if (await file.exists()) return filePath;

    // Download & extract the category zip.
    final ok = await _downloadCategory(category, baseDir);
    if (!ok) return null;

    // Retry after extraction.
    return await file.exists() ? filePath : null;
  }

  /// Determines the category name from the asset path prefix.
  /// Returns `null` for unrecognised paths.
  String? _categoryFor(String assetPath) {
    if (assetPath.startsWith('assets/shalat/')) return 'shalat';
    if (assetPath.startsWith("assets/wudu'/")) return 'wudu';
    return null;
  }

  /// Downloads the category zip from GitHub Release, extracts all files into
  /// `[baseDir]/learning_assets/`, and returns `true` on success.
  Future<bool> _downloadCategory(String category, Directory baseDir) async {
    try {
      final url = '$_releaseBase/$category.zip';
      final response = await client.get(Uri.parse(url)).timeout(
        const Duration(seconds: 30),
      );
      if (response.statusCode != 200) return false;

      // Extract the zip archive in memory.
      final archive = ZipDecoder().decodeBytes(response.bodyBytes);
      for (final entry in archive) {
        if (entry.isFile) {
          final outPath = p.join(baseDir.path, 'learning_assets', entry.name);
          final outFile = File(outPath);
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(entry.content);
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}