import 'dart:async';

import '../models/v_download_progress.dart';

/// Manages progress streaming with listener optimization
///
/// Separates progress broadcast logic from download management.
class VProgressStreamer {
  VProgressStreamer() {
    _controller = StreamController<VDownloadProgress>.broadcast();
  }

  late final StreamController<VDownloadProgress> _controller;
  bool _isDisposed = false;

  Stream<VDownloadProgress> get stream => _controller.stream;

  /// Emit progress update with optimization checks
  void emitProgress(VDownloadProgress progress) {
    if (_isDisposed || _controller.isClosed) return;

    if (!_controller.hasListener) return;

    _controller.add(progress);
  }

  /// Create and emit progress update
  void emit({
    required String storyId,
    required String url,
    required double progress,
    required int downloaded,
    required VDownloadStatus status,
    int? total,
    String? error,
  }) {
    emitProgress(
      VDownloadProgress(
        storyId: storyId,
        url: url,
        progress: progress.clamp(0.0, 1.0),
        downloadedBytes: downloaded,
        totalBytes: total,
        status: status,
        error: error,
      ),
    );
  }

  void dispose() {
    _isDisposed = true;
    _controller.close();
  }
}
