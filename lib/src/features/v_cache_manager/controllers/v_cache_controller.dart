import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:v_platform/v_platform.dart';
import '../models/v_cache_callbacks.dart';
import '../models/v_cache_config.dart';
import '../models/v_cache_error.dart';
import '../models/v_download_progress.dart';
import '../utils/v_file_handler.dart';

/// Controller for cache management with progress streaming
///
/// Handles all VPlatformFile source types (network, file, assets, bytes)
/// and provides real-time download progress via stream.
class VCacheController extends ChangeNotifier {
  /// Creates a cache controller
  VCacheController({VCacheConfig? config, VCacheCallbacks? callbacks})
    : _config = config ?? VCacheConfig.defaultConfig,
      _callbacks = callbacks ?? VCacheCallbacks.empty {
    const key = 'v_story_sdk';
    _cacheManager = CacheManager(
      Config(
        key,
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 40,
        repo: JsonCacheInfoRepository(databaseName: key),
        fileSystem: IOFileSystem(key),
        fileService: HttpFileService(),
      ),
    );
    _progressController = StreamController<VDownloadProgress>.broadcast();
  }

  final VCacheConfig _config;
  final VCacheCallbacks _callbacks;
  late final CacheManager _cacheManager;
  late final StreamController<VDownloadProgress> _progressController;

  /// Track active downloads to prevent duplicates
  final Map<String, Future<File?>> _activeDownloads = {};

  /// Track if controller is disposed
  bool _isDisposed = false;

  /// Stream of download progress updates
  ///
  /// Emits progress with URL for all active downloads.
  /// UI widgets can filter by URL to show progress for specific stories.
  ///
  /// Example:
  /// ```dart
  /// StreamBuilder<VDownloadProgress>(
  ///   stream: cacheController.progressStream,
  ///   builder: (context, snapshot) {
  ///     if (snapshot.hasData) {
  ///       final progress = snapshot.data!;
  ///       if (progress.url == currentStory.media.networkUrl) {
  ///         return CircularProgressIndicator(value: progress.progress);
  ///       }
  ///     }
  ///     return SizedBox();
  ///   },
  /// )
  /// ```
  Stream<VDownloadProgress> get progressStream => _progressController.stream;

  /// Get file from VPlatformFile
  ///
  /// Handles all VPlatformFile source types:
  /// - Network URL: Downloads with progress and caching
  /// - File path: Returns File directly (no caching needed)
  /// - Asset path: Loads from assets bundle
  /// - Bytes: Saves to temp file
  ///
  /// Returns null if file cannot be loaded.
  Future<File?> getFile(VPlatformFile platformFile) async {
    if (_isDisposed) return null;
    try {
      if (platformFile.networkUrl != null) {
        return await _getFromNetwork(platformFile.networkUrl!);
      } else if (platformFile.fileLocalPath != null) {
        return File(platformFile.fileLocalPath!);
      } else if (platformFile.assetsPath != null) {
        return await VFileHandler.loadFromAssets(platformFile.assetsPath!);
      } else if (platformFile.bytes != null) {
        final bytes = VFileHandler.toUint8List(platformFile.bytes!);
        return await VFileHandler.saveBytesToFile(bytes);
      }
    } catch (e) {
      // Handle errors gracefully
      if (!_isDisposed) {
        final url =
            platformFile.networkUrl ??
            platformFile.fileLocalPath ??
            platformFile.assetsPath ??
            'bytes';
        _handleError(VCacheFileSystemError(e.toString(), url));
      }
    }
    return null;
  }

  /// Get file from network with caching and progress
  ///
  /// Prevents duplicate downloads by checking active downloads map
  Future<File?> _getFromNetwork(String url) async {
    if (_isDisposed) return null;

    // Check if download is already in progress
    final existingDownload = _activeDownloads[url];
    if (existingDownload != null) {
      return existingDownload;
    }

    // Start new download and track it
    final downloadFuture = _performNetworkFetch(url);
    _activeDownloads[url] = downloadFuture;

    try {
      return await downloadFuture;
    } finally {
      // Clean up tracking after completion
      // The future stored in the map is already completed/awaited above
      // ignore: unawaited_futures
      _activeDownloads.remove(url);
    }
  }

  /// Perform actual network fetch with cache checking
  Future<File?> _performNetworkFetch(String url) async {
    try {
      final cachedFile = await _cacheManager.getFileFromCache(url);
      if (cachedFile != null && !_isCacheStale(cachedFile)) {
        _safeCallOnCacheHit(url, cachedFile.file);
        _emitProgress(url, 1, 0, 0, VDownloadStatus.completed);

        return cachedFile.file;
      }
      return await _downloadWithProgress(url);
    } catch (e) {
      final error = VCacheNetworkError(e.toString(), url);
      _handleError(error);
      return null;
    }
  }

  /// Check if cached file is stale
  bool _isCacheStale(FileInfo fileInfo) {
    final validTill = fileInfo.validTill;
    return validTill.isBefore(DateTime.now());
  }

  /// Download file with progress updates and retry logic
  Future<File?> _downloadWithProgress(String url, {int attempt = 0}) async {
    if (_isDisposed) return null;

    try {
      _safeCallOnDownloadStart(url);
      _emitProgress(url, 0, 0, null, VDownloadStatus.downloading);

      final stream = _cacheManager.getFileStream(url,withProgress: true,);
      await for (final result in stream) {
        if (_isDisposed) return null;

        if (result is DownloadProgress) {
          _emitProgress(
            url,
            result.progress ?? 0.0,
            result.downloaded,
            result.totalSize,
            VDownloadStatus.downloading,
          );
        } else if (result is FileInfo) {
          final fileSize = await result.file.length();
          _emitProgress(url, 1, fileSize, fileSize, VDownloadStatus.completed);
          _safeCallOnComplete(url, result.file);
          return result.file;
        }
      }
    } catch (e) {
      if (_isDisposed) return null;

      if (attempt < _config.maxRetries) {
        final delay = _config.retryPolicy.calculateDelay(attempt);
        await Future<void>.delayed(delay);
        return _downloadWithProgress(url, attempt: attempt + 1);
      }

      final error = VCacheRetryExhaustedError(
        'Download failed after ${attempt + 1} attempts',
        url,
        attempts: attempt + 1,
        lastError: e,
      );
      _handleError(error);
      return null;
    }
    return null;
  }

  /// Handle errors safely with proper error types
  void _handleError(VCacheError error) {
    if (_isDisposed) return;

    _emitProgress(error.url, 0, 0, null, VDownloadStatus.error, error.message);
    _safeCallOnError(error.url, error.message);
  }

  /// Safe callback wrappers to check disposal state
  void _safeCallOnDownloadStart(String url) {
    if (!_isDisposed) {
      _callbacks.onDownloadStart?.call(url);
    }
  }

  void _safeCallOnCacheHit(String url, File file) {
    if (!_isDisposed) {
      _callbacks.onCacheHit?.call(url, file);
    }
  }

  void _safeCallOnComplete(String url, File file) {
    if (!_isDisposed) {
      _callbacks.onComplete?.call(url, file);
    }
  }

  void _safeCallOnError(String url, String error) {
    if (!_isDisposed) {
      _callbacks.onError?.call(url, error);
    }
  }

  /// Emit progress update to stream with listener check optimization
  void _emitProgress(
    String url,
    double progress,
    int downloaded,
    int? total,
    VDownloadStatus status, [
    String? error,
  ]) {
    // Check disposal and listener state before emitting
    if (_isDisposed || _progressController.isClosed) {
      return;
    }

    // Optimization: skip emission if no one is listening
    if (!_progressController.hasListener) {
      return;
    }

    // Clamp progress to valid range [0.0, 1.0]
    final clampedProgress = progress.clamp(0.0, 1.0);

    _progressController.add(
      VDownloadProgress(
        url: url,
        progress: clampedProgress,
        downloadedBytes: downloaded,
        totalBytes: total,
        status: status,
        error: error,
      ),
    );
  }

  /// Clear all cached files
  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
    notifyListeners();
  }

  /// Remove specific file from cache
  Future<void> removeFile(String url) async {
    await _cacheManager.removeFile(url);
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _activeDownloads.clear();
    _progressController.close();
    super.dispose();
  }
}
