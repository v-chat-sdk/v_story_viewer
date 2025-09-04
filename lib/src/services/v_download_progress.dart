/// Represents download progress for a specific URL.
class VDownloadProgress {
  /// The URL being downloaded
  final String url;
  
  /// Progress value between 0.0 and 1.0
  final double progress;
  
  /// Total size in bytes (if known)
  final int? totalSize;
  
  /// Downloaded size in bytes
  final int downloadedSize;
  
  /// Whether the download is complete
  final bool isComplete;
  
  /// Error message if download failed
  final String? error;
  
  /// Retry attempt number (if retrying)
  final int? retryAttempt;
  
  /// Whether the download has an error
  bool get hasError => error != null;
  
  /// Whether this is a retry
  bool get isRetry => retryAttempt != null && retryAttempt! > 0;
  
  /// Creates a download progress instance
  const VDownloadProgress({
    required this.url,
    required this.progress,
    this.totalSize,
    required this.downloadedSize,
    required this.isComplete,
    this.error,
    this.retryAttempt,
  });
  
  /// Creates an initial progress (0%)
  factory VDownloadProgress.initial(String url) {
    return VDownloadProgress(
      url: url,
      progress: 0.0,
      downloadedSize: 0,
      isComplete: false,
    );
  }
  
  /// Creates a completed progress (100%)
  factory VDownloadProgress.completed(String url, {int? totalSize}) {
    return VDownloadProgress(
      url: url,
      progress: 1.0,
      totalSize: totalSize,
      downloadedSize: totalSize ?? 0,
      isComplete: true,
    );
  }
  
  /// Creates an error progress
  factory VDownloadProgress.error(String url, String error) {
    return VDownloadProgress(
      url: url,
      progress: 0.0,
      downloadedSize: 0,
      isComplete: false,
      error: error,
    );
  }
  
  /// Gets a human-readable progress percentage
  String get progressPercentage => '${(progress * 100).toStringAsFixed(1)}%';
  
  /// Gets a human-readable size string
  String get sizeString {
    if (totalSize == null) {
      return _formatBytes(downloadedSize);
    }
    return '${_formatBytes(downloadedSize)} / ${_formatBytes(totalSize!)}';
  }
  
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Creates a copy with updated fields
  VDownloadProgress copyWith({
    String? url,
    double? progress,
    int? totalSize,
    int? downloadedSize,
    bool? isComplete,
    String? error,
    int? retryAttempt,
  }) {
    return VDownloadProgress(
      url: url ?? this.url,
      progress: progress ?? this.progress,
      totalSize: totalSize ?? this.totalSize,
      downloadedSize: downloadedSize ?? this.downloadedSize,
      isComplete: isComplete ?? this.isComplete,
      error: error ?? this.error,
      retryAttempt: retryAttempt ?? this.retryAttempt,
    );
  }
  
  @override
  String toString() {
    if (hasError) {
      return 'VDownloadProgress(url: $url, error: $error)';
    }
    return 'VDownloadProgress(url: $url, progress: $progressPercentage, size: $sizeString)';
  }
}