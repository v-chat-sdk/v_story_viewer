/// Download progress information with URL for UI filtering
///
/// When multiple stories are downloading simultaneously, the UI can filter
/// progress updates by matching the URL with the current story's media URL.
class VDownloadProgress {
  /// Creates a download progress instance
  ///
  /// Validates input parameters:
  /// - [url] must not be empty
  /// - [progress] must be between 0.0 and 1.0
  /// - [downloadedBytes] must be non-negative
  /// - [totalBytes] if provided must be non-negative and >= downloadedBytes
  const VDownloadProgress({
    required this.url,
    required this.progress,
    required this.downloadedBytes,
    required this.status,
    this.totalBytes,
    this.error,
  })  : assert(url != '', 'url must not be empty'),
        assert(
          progress >= 0.0 && progress <= 1.0,
          'progress must be between 0.0 and 1.0',
        ),
        assert(downloadedBytes >= 0, 'downloadedBytes must be non-negative'),
        assert(
          totalBytes == null || totalBytes >= 0,
          'totalBytes must be non-negative if provided',
        ),
        assert(
          totalBytes == null || totalBytes >= downloadedBytes,
          'totalBytes must be >= downloadedBytes',
        );

  /// URL of the downloading file (critical for UI filtering)
  ///
  /// Example: When user navigates story1 → story2 → story3 quickly,
  /// the UI widget for story1 filters by `progress.url == story1.media.networkUrl`
  final String url;

  /// Download progress from 0.0 to 1.0
  final double progress;

  /// Number of bytes downloaded so far
  final int downloadedBytes;

  /// Total file size in bytes (null if unknown)
  final int? totalBytes;

  /// Current download status
  final VDownloadStatus status;

  /// Error message if status is error
  final String? error;

  /// Whether the download is complete
  bool get isComplete => status == VDownloadStatus.completed;

  /// Whether the download has an error
  bool get hasError => status == VDownloadStatus.error;

  /// Whether the download is in progress
  bool get isDownloading => status == VDownloadStatus.downloading;

  /// Progress as percentage text (e.g., "45%")
  String get percentageText => '${(progress * 100).toInt()}%';

  /// Formatted downloaded size (e.g., "2.5 MB")
  String get downloadedSizeText => _formatBytes(downloadedBytes);

  /// Formatted total size (e.g., "5.0 MB" or "Unknown")
  String get totalSizeText =>
      totalBytes != null ? _formatBytes(totalBytes!) : 'Unknown';

  /// Download size text (e.g., "2.5 MB / 5.0 MB")
  String get sizeText => '$downloadedSizeText / $totalSizeText';

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Creates a copy with updated values
  VDownloadProgress copyWith({
    String? url,
    double? progress,
    int? downloadedBytes,
    int? totalBytes,
    VDownloadStatus? status,
    String? error,
  }) {
    return VDownloadProgress(
      url: url ?? this.url,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'VDownloadProgress(url: $url, progress: $percentageText, '
        'size: $sizeText, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VDownloadProgress &&
        other.url == url &&
        other.progress == progress &&
        other.downloadedBytes == downloadedBytes &&
        other.totalBytes == totalBytes &&
        other.status == status &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      url,
      progress,
      downloadedBytes,
      totalBytes,
      status,
      error,
    );
  }
}

/// Download status states
enum VDownloadStatus {
  /// Download is idle (not started)
  idle,

  /// Download is in progress
  downloading,

  /// Download completed successfully
  completed,

  /// Download failed with error
  error,
}
