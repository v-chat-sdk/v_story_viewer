import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Callback for tracking download progress.
///
/// The [progress] parameter is 0.0 to 1.0 (0% to 100%).
typedef DownloadProgressCallback = void Function(double progress);

/// Cache manager for story video and audio files.
///
/// Provides local caching of media files for faster subsequent access
/// and offline playback. **Only active on mobile platforms (Android/iOS)**.
/// Web and desktop always stream directly from URLs.
///
/// ## Platform Support
/// | Platform | Caching |
/// |----------|---------|
/// | Android | Supported |
/// | iOS | Supported |
/// | Web | Not supported (streams directly) |
/// | Desktop | Not supported (streams directly) |
///
/// ## Basic Usage
/// Cache manager is initialized automatically by [VStoryViewer] when
/// [VStoryConfig.enableCaching] is `true`.
///
/// ## Manual Usage
/// ```dart
/// // Check platform support
/// if (StoryCacheManager.isCachingSupported) {
///   // Initialize with custom settings
///   StoryCacheManager.instance.initialize(
///     maxCacheSize: 500 * 1024 * 1024, // 500MB
///     maxCacheAge: Duration(days: 7),
///     maxCacheObjects: 100,
///   );
///
///   // Download with progress
///   final file = await StoryCacheManager.instance.downloadFile(
///     'https://example.com/video.mp4',
///     'video_key',
///     onProgress: (progress) => print('${(progress * 100).toInt()}%'),
///   );
///
///   // Get cached file
///   final cached = await StoryCacheManager.instance.getCachedFile('video_key');
///
///   // Preload in background
///   await StoryCacheManager.instance.preloadFile(url, cacheKey);
///
///   // Clear cache
///   await StoryCacheManager.instance.clearCache();
/// }
/// ```
///
/// ## Configuration
/// Configure via [VStoryConfig]:
/// ```dart
/// VStoryConfig(
///   enableCaching: true,
///   maxCacheSize: 500 * 1024 * 1024, // 500MB
///   maxCacheAge: Duration(days: 7),
///   maxCacheObjects: 100,
/// )
/// ```
///
/// ## Cache Keys
/// Use [VVideoStory.cacheKey] or [VVoiceStory.cacheKey] which extract
/// a normalized URL without query parameters for consistent caching.
///
/// ## See Also
/// - [VStoryConfig.enableCaching] to enable/disable caching
/// - [VStoryConfig.maxCacheSize] for cache size limit
/// - [VStoryConfig.maxCacheAge] for cache expiration
class StoryCacheManager {
  static StoryCacheManager? _instance;
  CacheManager? _cacheManager;
  StoryCacheManager._();

  /// Singleton instance of the cache manager.
  ///
  /// Always use this to access cache functionality:
  /// ```dart
  /// StoryCacheManager.instance.getCachedFile(key);
  /// ```
  static StoryCacheManager get instance {
    _instance ??= StoryCacheManager._();
    return _instance!;
  }

  /// Whether caching is supported on the current platform.
  ///
  /// Returns `true` only on Android and iOS.
  /// Web and desktop platforms always return `false`.
  static bool get isCachingSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Initialize cache manager with custom config
  void initialize({
    int maxCacheSize = 500 * 1024 * 1024,
    Duration maxCacheAge = const Duration(days: 7),
    int maxCacheObjects = 100,
  }) {
    if (!isCachingSupported) return;
    _cacheManager = CacheManager(
      Config(
        'story_media_cache',
        stalePeriod: maxCacheAge,
        maxNrOfCacheObjects: maxCacheObjects,
        repo: JsonCacheInfoRepository(databaseName: 'story_media_cache'),
        fileService: HttpFileService(),
      ),
    );
  }

  CacheManager get _manager {
    if (_cacheManager == null) {
      initialize();
    }
    return _cacheManager!;
  }

  /// Get cached file if exists, returns null if not cached
  Future<File?> getCachedFile(String cacheKey) async {
    if (!isCachingSupported) return null;
    try {
      final fileInfo = await _manager.getFileFromCache(cacheKey);
      if (fileInfo != null && await fileInfo.file.exists()) {
        return fileInfo.file;
      }
    } catch (e) {
      assert(() {
        debugPrint('StoryCacheManager error: $e');
        return true;
      }());
    }
    return null;
  }

  /// Download file with progress tracking
  /// Returns local file path when complete
  Future<File?> downloadFile(
    String url,
    String cacheKey, {
    DownloadProgressCallback? onProgress,
  }) async {
    if (!isCachingSupported) return null;
    try {
      final stream = _manager.getFileStream(
        url,
        key: cacheKey,
        withProgress: true,
      );
      await for (final result in stream) {
        if (result is DownloadProgress) {
          final progress = result.totalSize != null && result.totalSize! > 0
              ? result.downloaded / result.totalSize!
              : 0.0;
          onProgress?.call(progress);
        } else if (result is FileInfo) {
          onProgress?.call(1.0);
          return result.file;
        }
      }
    } catch (e) {
      assert(() {
        debugPrint('StoryCacheManager error: $e');
        return true;
      }());
    }
    return null;
  }

  /// Preload file in background (no progress callback needed)
  Future<void> preloadFile(String url, String cacheKey) async {
    if (!isCachingSupported) return;
    try {
      await _manager.downloadFile(url, key: cacheKey);
    } catch (e) {
      assert(() {
        debugPrint('StoryCacheManager error: $e');
        return true;
      }());
    }
  }

  /// Remove specific file from cache
  Future<void> removeFile(String cacheKey) async {
    if (!isCachingSupported) return;
    try {
      await _manager.removeFile(cacheKey);
    } catch (e) {
      assert(() {
        debugPrint('StoryCacheManager error: $e');
        return true;
      }());
    }
  }

  /// Clear entire story cache
  Future<void> clearCache() async {
    if (!isCachingSupported) return;
    try {
      await _manager.emptyCache();
    } catch (e) {
      assert(() {
        debugPrint('StoryCacheManager error: $e');
        return true;
      }());
    }
  }

  /// Dispose cache manager
  void dispose() {
    _cacheManager?.dispose();
    _cacheManager = null;
  }
}
