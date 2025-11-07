import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../models/v_cache_config.dart';
import '../models/v_cache_error.dart';
import '../models/v_download_progress.dart';

/// Manages file downloads with retry logic and progress tracking
///
/// Separates download orchestration from cache controller.
class VDownloadManager {
  VDownloadManager({
    required CacheManager cacheManager,
    required VCacheConfig config,
  }) : _cacheManager = cacheManager,
       _config = config;

  final CacheManager _cacheManager;
  final VCacheConfig _config;
  final Map<String, Future<File?>> _activeDownloads = {};

  bool _isDisposed = false;

  /// Check if download is already in progress
  bool isDownloading(String url) => _activeDownloads.containsKey(url);

  /// Get existing download future if active
  Future<File?>? getActiveDownload(String url) => _activeDownloads[url];

  /// Start a new download and track it
  Future<File?> startDownload(
    String url,
    Future<File?> Function() downloadFunction,
  ) async {
    if (_isDisposed) return null;
    final downloadFuture = downloadFunction();
    _activeDownloads[url] = downloadFuture;
    try {
      final result = await downloadFuture;
      if (_isDisposed) {
        return null;
      }
      return result;
    } finally {
      // ignore: unawaited_futures - Map.remove() is synchronous and doesn't return Future
      _activeDownloads.remove(url);
    }
  }

  /// Download file with progress updates and retry logic
  Future<File?> downloadWithProgress(
    String url,
    String storyId, {
    required void Function(VDownloadProgress) onProgress,
    required void Function(VCacheManagerError) onError,
  }) async {
    if (_isDisposed) return null;
    for (var attempt = 0; attempt <= _config.maxRetries; attempt++) {
      try {
        onProgress(
          _createProgress(storyId, url, 0, 0, VDownloadStatus.downloading),
        );
        final stream = _cacheManager.getFileStream(url, withProgress: true);
        await for (final result in stream) {
          if (_isDisposed) return null;
          if (result is DownloadProgress) {
            onProgress(
              _createProgress(
                storyId,
                url,
                result.progress ?? 0,
                result.downloaded,
                VDownloadStatus.downloading,
                result.totalSize,
              ),
            );
          } else if (result is FileInfo) {
            final fileSize = await result.file.length();
            onProgress(
              _createProgress(
                storyId,
                url,
                1,
                fileSize,
                VDownloadStatus.completed,
                fileSize,
              ),
            );
            return result.file;
          }
        }
      } catch (e) {
        if (_isDisposed) return null;
        if (attempt >= _config.maxRetries) {
          final error = VCacheRetryExhaustedError(
            'Download failed after ${attempt + 1} attempts',
            url,
            attempts: attempt + 1,
            lastError: e,
          );
          onError(error);
          return null;
        }
        final delay = _config.retryPolicy.calculateDelay(attempt);
        await Future<void>.delayed(delay);
      }
    }
    return null;
  }

  /// Check if cached file is stale
  bool isCacheStale(FileInfo fileInfo) {
    return fileInfo.validTill.isBefore(DateTime.now());
  }

  /// Get file from cache
  Future<FileInfo?> getFromCache(String url) async {
    return _cacheManager.getFileFromCache(url);
  }

  VDownloadProgress _createProgress(
    String storyId,
    String url,
    double progress,
    int downloaded,
    VDownloadStatus status, [
    int? total,
    String? error,
  ]) {
    return VDownloadProgress(
      storyId: storyId,
      url: url,
      progress: progress.clamp(0, 1),
      downloadedBytes: downloaded,
      totalBytes: total,
      status: status,
      error: error,
    );
  }

  void dispose() {
    _isDisposed = true;
    _activeDownloads.clear();
  }
}
