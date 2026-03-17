import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:reels/core/constants/app_constants.dart';
import 'package:reels/core/errors/exceptions.dart';
import 'package:reels/core/utils/app_logger.dart';

abstract class VideoCacheDataSource {
  Future<String?> getCachedVideoPath(String videoUrl);
  Future<String> cacheVideo(String videoUrl);
  Future<void> clearOldCache();
}

class VideoCacheDataSourceImpl implements VideoCacheDataSource {
  /// Generates a stable file name from a URL using MD5.
  String _cacheKeyFor(String url) {
    final bytes = utf8.encode(url);
    final digest = md5.convert(bytes);
    return '$digest.mp4';
  }

  Future<Directory> _getCacheDir() async {
    final base = await getTemporaryDirectory();
    final cacheDir = Directory('${base.path}/${AppConstants.videoCacheDir}');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  @override
  Future<String?> getCachedVideoPath(String videoUrl) async {
    try {
      final dir = await _getCacheDir();
      final file = File('${dir.path}/${_cacheKeyFor(videoUrl)}');
      if (await file.exists()) {
        AppLogger.debug('Cache hit for: $videoUrl');
        return file.path;
      }
      AppLogger.debug('Cache miss for: $videoUrl');
      return null;
    } catch (e) {
      AppLogger.warning('Error checking cache: $e');
      return null;
    }
  }

  @override
  Future<String> cacheVideo(String videoUrl) async {
    try {
      final dir = await _getCacheDir();
      final file = File('${dir.path}/${_cacheKeyFor(videoUrl)}');

      // Return immediately if already cached
      if (await file.exists()) {
        AppLogger.debug('Already cached: $videoUrl');
        return file.path;
      }

      AppLogger.info('Downloading video to cache: $videoUrl');
      final response = await http.get(Uri.parse(videoUrl));

      if (response.statusCode != 200) {
        throw CacheException(
            'Failed to download video: HTTP ${response.statusCode}');
      }

      await file.writeAsBytes(response.bodyBytes);
      AppLogger.info('Cached video: ${file.path}');

      // Clean old files to respect max cache size
      await clearOldCache();

      return file.path;
    } on CacheException {
      rethrow;
    } catch (e) {
      AppLogger.error('Error caching video', e);
      throw CacheException('Unexpected caching error: $e');
    }
  }

  @override
  Future<void> clearOldCache() async {
    try {
      final dir = await _getCacheDir();
      final files = await dir.list().toList();

      // Sort by last modified (oldest first)
      final fileEntities = files.whereType<File>().toList()
        ..sort((a, b) => a
            .statSync()
            .modified
            .compareTo(b.statSync().modified));

      // Remove oldest files if over the count limit
      while (fileEntities.length > AppConstants.maxCachedVideos) {
        final oldest = fileEntities.removeAt(0);
        await oldest.delete();
        AppLogger.debug('Evicted old cache: ${oldest.path}');
      }

      // Also check total size
      int totalSize = 0;
      for (final f in fileEntities) {
        totalSize += await f.length();
      }

      while (totalSize > AppConstants.maxCacheSizeBytes &&
          fileEntities.isNotEmpty) {
        final oldest = fileEntities.removeAt(0);
        totalSize -= await oldest.length();
        await oldest.delete();
        AppLogger.debug('Evicted by size: ${oldest.path}');
      }
    } catch (e) {
      AppLogger.warning('Error clearing old cache: $e');
    }
  }
}
