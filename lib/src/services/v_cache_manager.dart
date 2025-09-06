import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'v_download_progress.dart';
import 'v_cache_policy.dart';
import 'v_retry_policy.dart';
import 'v_web_cache_config.dart';

/// Enhanced cache manager with URL-specific progress tracking.
/// 
/// This wraps flutter_cache_manager to provide progress streams
/// that emit VDownloadProgress events with URL identification.
class VCacheManager {
  /// Singleton instance
  static final VCacheManager _instance = VCacheManager._internal();
  
  /// Factory constructor returns singleton
  factory VCacheManager() => _instance;
  
  /// Private constructor
  VCacheManager._internal();
  
  /// The underlying flutter_cache_manager instance
  late final CacheManager _cacheManager = _createCacheManager();
  
  /// Stream controller for download progress events
  final StreamController<VDownloadProgress> _progressController = 
      StreamController<VDownloadProgress>.broadcast();
  
  /// Active download tracking
  final Map<String, StreamSubscription> _activeDownloads = {};
  
  /// Cache policy
  final VCachePolicy policy = VCachePolicy.standard();
  
  /// Retry policy for network failures
  final VRetryPolicy _retryPolicy = VRetryPolicy(
    config: VRetryConfig.defaultConfig(),
  );
  
  /// Retry statistics for monitoring
  final VRetryStatistics _retryStats = VRetryStatistics();
  
  /// Gets the progress stream
  Stream<VDownloadProgress> get progressStream => _progressController.stream;
  
  /// Creates the cache manager with custom configuration
  CacheManager _createCacheManager() {
    // Use web-safe configuration that handles platform differences
    return CacheManager(VWebCacheConfig.createConfig());
  }
  
  /// Gets a file from cache or downloads it with progress tracking
  Future<File> getFile(String url, {Map<String, String>? headers}) async {
    // Emit initial progress
    _emitProgress(VDownloadProgress.initial(url));
    
    try {
      // Check if already cached
      final fileInfo = await _cacheManager.getFileFromCache(url);
      if (fileInfo != null) {
        // On web, we can't use existsSync() or lengthSync()
        if (kIsWeb) {
          _emitProgress(VDownloadProgress.completed(url, totalSize: 0));
          return fileInfo.file;
        } else if (fileInfo.file.existsSync()) {
          _emitProgress(VDownloadProgress.completed(
            url,
            totalSize: fileInfo.file.lengthSync(),
          ));
          return fileInfo.file;
        }
      }
      
      // Download with progress tracking
      return await _downloadWithProgress(url, headers: headers);
    } catch (e) {
      _emitProgress(VDownloadProgress.error(url, e.toString()));
      rethrow;
    }
  }
  
  /// Downloads a file with progress tracking and retry logic
  Future<File> _downloadWithProgress(
    String url, {
    Map<String, String>? headers,
  }) async {
    // Cancel any existing download for this URL
    await _cancelDownload(url);
    
    // Use retry policy for resilient downloading
    return await _retryPolicy.execute(
      () async {
        // Start downloading and emit intermediate progress
        _emitProgress(VDownloadProgress(
          url: url,
          progress: 0.1,  // Starting download
          downloadedSize: 0,
          isComplete: false,
        ));
        
        final fileInfo = await _cacheManager.downloadFile(
          url,
          authHeaders: headers,
        );
        
        // Download completed
        final totalSize = kIsWeb ? 0 : fileInfo.file.lengthSync();
        _emitProgress(VDownloadProgress.completed(
          url,
          totalSize: totalSize,
        ));
        
        // Record success
        _retryStats.recordOperation(success: true, retries: 0);
        
        return fileInfo.file;
      },
      onRetry: (attempt, error) {
        // Emit retry progress
        _emitProgress(VDownloadProgress(
          url: url,
          progress: 0.0,
          downloadedSize: 0,
          isComplete: false,
          retryAttempt: attempt,
          error: error.toString(),
        ));
        
      },
      onError: (error) {
        // Final error after all retries
        _emitProgress(VDownloadProgress.error(url, error.toString()));
        _retryStats.recordOperation(success: false, retries: _retryPolicy.config.maxAttempts);
      },
    );
  }
  
  /// Gets a file stream with progress tracking
  Future<FileInfo> getFileStream(
    String url, {
    Map<String, String>? headers,
  }) async {
    // Emit initial progress
    _emitProgress(VDownloadProgress.initial(url));
    
    try {
      // Download the file
      final fileInfo = await _cacheManager.downloadFile(
        url,
        authHeaders: headers,
      );
      
      // Emit completion progress
      final totalSize = kIsWeb ? 0 : fileInfo.file.lengthSync();
      _emitProgress(VDownloadProgress.completed(
        url,
        totalSize: totalSize,
      ));
      
      return fileInfo;
    } catch (error) {
      _emitProgress(VDownloadProgress.error(url, error.toString()));
      rethrow;
    }
  }
  
  /// Preloads multiple URLs with progress tracking
  Future<void> preloadUrls(List<String> urls) async {
    final futures = <Future>[];
    
    for (final url in urls) {
      futures.add(getFile(url).catchError((e) {
        return File(''); // Return dummy file on error
      }));
    }
    
    await Future.wait(futures);
  }
  
  /// Checks if a URL is cached
  Future<bool> isCached(String url) async {
    final fileInfo = await _cacheManager.getFileFromCache(url);
    // On web, we can't check if file exists, so just check if fileInfo exists
    if (kIsWeb) {
      return fileInfo != null;
    }
    return fileInfo != null && fileInfo.file.existsSync();
  }
  
  /// Gets file info from cache
  Future<FileInfo?> getFileInfo(String url) async {
    return await _cacheManager.getFileFromCache(url);
  }
  
  /// Gets a cached file by URL - downloads if not cached
  Future<File> getCachedFile(String url) async {
    return await getFile(url);
  }
  
  /// Removes a specific URL from cache
  Future<void> removeFile(String url) async {
    await _cacheManager.removeFile(url);
  }
  
  /// Clears all cache
  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
    _progressController.add(VDownloadProgress(
      url: 'cache_cleared',
      progress: 0.0,
      downloadedSize: 0,
      isComplete: true,
    ));
  }
  
  /// Removes old cache entries
  Future<void> removeOldCache() async {
    await _cacheManager.emptyCache();
  }
  
  /// Cancels a download
  Future<void> _cancelDownload(String url) async {
    final subscription = _activeDownloads[url];
    if (subscription != null) {
      await subscription.cancel();
      _activeDownloads.remove(url);
    }
  }
  
  /// Cancels all active downloads
  Future<void> cancelAllDownloads() async {
    for (final subscription in _activeDownloads.values) {
      await subscription.cancel();
    }
    _activeDownloads.clear();
  }
  
  /// Emits a progress event
  void _emitProgress(VDownloadProgress progress) {
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }
  
  /// Gets progress stream for a specific URL
  Stream<VDownloadProgress> getProgressForUrl(String url) {
    return progressStream.where((progress) => progress.url == url);
  }
  
  /// Gets cache statistics
  Future<Map<String, dynamic>> getCacheStatistics() async {
    // This would need custom implementation as flutter_cache_manager
    // doesn't provide direct cache statistics
    return {
      'activeDownloads': _activeDownloads.length,
      'policy': policy.toJson(),
      'retryStats': _retryStats.toJson(),
    };
  }
  
  /// Disposes the cache manager
  void dispose() {
    cancelAllDownloads();
    _progressController.close();
  }
}