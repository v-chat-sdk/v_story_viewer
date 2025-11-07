import 'dart:io';

import 'package:flutter/foundation.dart';
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
    _progressStreamer = VProgressStreamer();
    _initializeCacheManager();
    _errorHandler = VCacheErrorHandler(progressStreamer: _progressStreamer);
  }

  final VCacheConfig _config;
  CacheManager? _cacheManager;
  late final VProgressStreamer _progressStreamer;
  VDownloadManager? _downloadManager;
  late final VCacheErrorHandler _errorHandler;
  bool _isDisposed = false;

  void _initializeCacheManager() {
    if (kIsWeb) {
      _cacheManager = null;
      _downloadManager = null;
      return;
    }

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
    _downloadManager = VDownloadManager(
      cacheManager: _cacheManager!,
      config: _config,
    );
  }

  Stream<VDownloadProgress> get mediaDownloadProgressStream =>
      _progressStreamer.stream;

  /// Get file from VPlatformFile with story ID for progress tracking
  Future<VPlatformFile?> getFile(
    VPlatformFile platformFile,
    String storyId,
  ) async {
    if (_isDisposed) return null;
    try {
      final result = await _getFileByType(platformFile, storyId);
      return _isDisposed ? null : result;
    } catch (e) {
      if (!_isDisposed) {
        _errorHandler.handleFileError(e, platformFile, storyId);
      }
      return null;
    }
  }

  Future<VPlatformFile?> _getFileByType(
    VPlatformFile platformFile,
    String storyId,
  ) async {
    if (platformFile.networkUrl != null) {
      return _getFromNetwork(platformFile.networkUrl!, storyId);
    }

    if (platformFile.fileLocalPath != null) {
      if (kIsWeb) {
        return null;
      }
      return VPlatformFile.fromPath(fileLocalPath: platformFile.fileLocalPath!);
    }

    if (platformFile.assetsPath != null) {
      if (kIsWeb) {
        return platformFile;
      }
      final file = await VFileHandler.loadFromAssets(platformFile.assetsPath!);
      return VPlatformFile.fromPath(fileLocalPath: file.path);
    }

    if (platformFile.bytes != null) {
      if (kIsWeb) {
        return platformFile;
      }
      final bytes = VFileHandler.toUint8List(platformFile.bytes!);
      final file = await VFileHandler.saveBytesToFile(bytes);
      return VPlatformFile.fromPath(fileLocalPath: file.path);
    }

    return null;
  }

  Future<VPlatformFile?> _getFromNetwork(String url, String storyId) async {
    if (_isDisposed) return null;
    if (kIsWeb) {
      if (!_isDisposed) {
        _progressStreamer.emit(
          storyId: storyId,
          url: url,
          progress: 1,
          downloaded: 0,
          total: 0,
          status: VDownloadStatus.completed,
        );
      }
      return _isDisposed ? null : VPlatformFile.fromUrl(networkUrl: url);
    }
    final existingDownloadFuture = _downloadManager?.getActiveDownload(url);
    if (existingDownloadFuture != null) {
      final existingFile = await existingDownloadFuture;
      if (_isDisposed) return null;
      if (existingFile != null) {
        return VPlatformFile.fromPath(fileLocalPath: existingFile.path);
      }
    }
    if (_isDisposed) return null;
    final file = await _downloadManager?.startDownload(
      url,
      () => _performNetworkFetch(url, storyId),
    );
    return _isDisposed || file == null
        ? null
        : VPlatformFile.fromPath(fileLocalPath: file.path);
  }

  Future<File?> _performNetworkFetch(String url, String storyId) async {
    try {
      final cachedFile = await _downloadManager!.getFromCache(url);
      if (cachedFile != null && !_downloadManager!.isCacheStale(cachedFile)) {
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
    return _downloadManager!.downloadWithProgress(
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
    if (kIsWeb) return;
    await _cacheManager!.emptyCache();
    notifyListeners();
  }

  Future<void> removeFile(String url) async {
    if (kIsWeb) return;
    await _cacheManager!.removeFile(url);
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _errorHandler.markDisposed();
    _downloadManager?.dispose();
    _progressStreamer.dispose();
    super.dispose();
  }
}
