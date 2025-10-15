import 'package:v_platform/v_platform.dart';

import '../models/v_cache_callbacks.dart';
import '../models/v_cache_error.dart';
import '../models/v_download_progress.dart';
import 'v_progress_streamer.dart';

/// Handles error scenarios for cache operations
class VCacheErrorHandler {
  VCacheErrorHandler({
    required VProgressStreamer progressStreamer,
    required VCacheCallbacks callbacks,
  })  : _progressStreamer = progressStreamer,
        _callbacks = callbacks;

  final VProgressStreamer _progressStreamer;
  final VCacheCallbacks _callbacks;
  bool _isDisposed = false;

  void handleFileError(Object error, VPlatformFile platformFile, String storyId) {
    if (_isDisposed) return;

    final url = _extractUrl(platformFile);
    final cacheError = VCacheFileSystemError(error.toString(), url);
    _handleError(cacheError, storyId);
  }

  void handleNetworkError(Object error, String url, String storyId) {
    if (_isDisposed) return;

    final cacheError = VCacheNetworkError(error.toString(), url);
    _handleError(cacheError, storyId);
  }

  void _handleError(VCacheManagerError error, String storyId) {
    if (_isDisposed) return;

    _progressStreamer.emit(
      storyId: storyId,
      url: error.url,
      progress: 0,
      downloaded: 0,
      status: VDownloadStatus.error,
      error: error.message,
    );

    _safeCallOnError(error.url, error.message);
  }

  String _extractUrl(VPlatformFile platformFile) {
    return platformFile.networkUrl ??
        platformFile.fileLocalPath ??
        platformFile.assetsPath ??
        'bytes';
  }

  void _safeCallOnError(String url, String error) {
    if (!_isDisposed) {
      _callbacks.onError?.call(url, error);
    }
  }

  void markDisposed() {
    _isDisposed = true;
  }
}
