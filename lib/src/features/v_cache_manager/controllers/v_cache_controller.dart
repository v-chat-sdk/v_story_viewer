import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:v_platform/v_platform.dart';

import '../models/v_cache_config.dart';
import '../models/v_download_progress.dart';
import '../utils/v_cache_error_handler.dart';
import '../utils/v_download_manager.dart';
import '../utils/v_file_handler.dart';
import '../utils/v_progress_streamer.dart';

/// Controller for cache management with progress streaming
///
/// Handles all VPlatformFile source types with delegated responsibilities.
/// Cache events are emitted via progressStream for UI integration.
class VCacheController extends ChangeNotifier {
  VCacheController({VCacheConfig? config})
      : _config = config ?? VCacheConfig.defaultConfig {
    _initializeCacheManager();
    _progressStreamer = VProgressStreamer();
    _downloadManager = VDownloadManager(
      cacheManager: _cacheManager,
      config: _config,
    );
    _errorHandler = VCacheErrorHandler(
      progressStreamer: _progressStreamer,
    );
  }

  final VCacheConfig _config;
  late final CacheManager _cacheManager;
  late final VProgressStreamer _progressStreamer;
  late final VDownloadManager _downloadManager;
  late final VCacheErrorHandler _errorHandler;

  bool _isDisposed = false;

  void _initializeCacheManager() {
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
  }

  Stream<VDownloadProgress> get progressStream => _progressStreamer.stream;

  /// Get file from VPlatformFile with story ID for progress tracking
  Future<File?> getFile(VPlatformFile platformFile, String storyId) async {
    if (_isDisposed) return null;

    try {
      return await _getFileByType(platformFile, storyId);
    } catch (e) {
      _errorHandler.handleFileError(e, platformFile, storyId);
      return null;
    }
  }

  Future<File?> _getFileByType(VPlatformFile platformFile, String storyId) async {
    if (platformFile.networkUrl != null) {
      return _getFromNetwork(platformFile.networkUrl!, storyId);
    }

    if (platformFile.fileLocalPath != null) {
      return File(platformFile.fileLocalPath!);
    }

    if (platformFile.assetsPath != null) {
      return VFileHandler.loadFromAssets(platformFile.assetsPath!);
    }

    if (platformFile.bytes != null) {
      final bytes = VFileHandler.toUint8List(platformFile.bytes!);
      return VFileHandler.saveBytesToFile(bytes);
    }

    return null;
  }

  Future<File?> _getFromNetwork(String url, String storyId) async {
    if (_isDisposed) return null;

    final existingDownload = _downloadManager.getActiveDownload(url);
    if (existingDownload != null) {
      return existingDownload;
    }

    return _downloadManager.startDownload(url, () => _performNetworkFetch(url, storyId));
  }

  Future<File?> _performNetworkFetch(String url, String storyId) async {
    try {
      final cachedFile = await _downloadManager.getFromCache(url);

      if (cachedFile != null && !_downloadManager.isCacheStale(cachedFile)) {
        return _handleCacheHit(url, cachedFile.file, storyId);
      }

      return await _downloadWithProgress(url, storyId);
    } catch (e) {
      _errorHandler.handleNetworkError(e, url, storyId);
      return null;
    }
  }

  File _handleCacheHit(String url, File file, String storyId) {
    _progressStreamer.emit(
      storyId: storyId,
      url: url,
      progress: 1,
      downloaded: 0,
      total: 0,
      status: VDownloadStatus.completed,
    );
    return file;
  }

  Future<File?> _downloadWithProgress(String url, String storyId) async {
    return _downloadManager.downloadWithProgress(
      url,
      storyId,
      onProgress: (progress) {
        _progressStreamer.emitProgress(progress);
      },
      onError: (error) {
        _progressStreamer.emit(
          storyId: storyId,
          url: error.url,
          progress: 0,
          downloaded: 0,
          status: VDownloadStatus.error,
          error: error.message,
        );
      },
    );
  }

  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
    notifyListeners();
  }

  Future<void> removeFile(String url) async {
    await _cacheManager.removeFile(url);
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _errorHandler.markDisposed();
    _downloadManager.dispose();
    _progressStreamer.dispose();
    super.dispose();
  }
}
