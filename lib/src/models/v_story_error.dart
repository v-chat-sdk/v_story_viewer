/// Structured error types for story loading failures.
///
/// This sealed class provides rich error information including:
/// - Error type classification for handling specific cases
/// - Original exception and stack trace for debugging
/// - Human-readable message for display
///
/// ## Error Types
/// | Type | When Triggered |
/// |------|----------------|
/// | [VStoryLoadError] | General content loading failure |
/// | [VStoryNetworkError] | Network connectivity issues |
/// | [VStoryTimeoutError] | Request timed out |
/// | [VStoryCacheError] | Cache read/write failure |
/// | [VStoryFormatError] | Unsupported media format |
/// | [VStoryPermissionError] | Storage/network permission denied |
///
/// ## Usage in Callback
/// ```dart
/// VStoryViewer(
///   onError: (group, item, error) {
///     switch (error) {
///       case VStoryNetworkError():
///         showSnackBar('Check your internet connection');
///       case VStoryTimeoutError():
///         showSnackBar('Loading timed out, please retry');
///       case VStoryCacheError():
///         clearCache();
///       case VStoryFormatError():
///         log('Unsupported format: ${error.message}');
///       case VStoryPermissionError():
///         requestPermission();
///       case VStoryLoadError():
///         log('Load failed: ${error.message}');
///     }
///   },
/// )
/// ```
sealed class VStoryError {
  /// Human-readable error message.
  final String message;

  /// The original exception that caused this error.
  final Object? originalError;

  /// Stack trace from the original exception.
  final StackTrace? stackTrace;

  const VStoryError({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => '$runtimeType: $message';
}

/// General content loading failure.
///
/// Used when content fails to load but the specific cause is unknown
/// or doesn't fit other error categories.
final class VStoryLoadError extends VStoryError {
  const VStoryLoadError({
    required super.message,
    super.originalError,
    super.stackTrace,
  });

  /// Creates a load error from an exception.
  factory VStoryLoadError.fromException(
    Object error, [
    StackTrace? stackTrace,
  ]) {
    return VStoryLoadError(
      message: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Network connectivity issues.
///
/// Triggered when:
/// - No internet connection
/// - DNS resolution failure
/// - Server unreachable
/// - Connection refused
final class VStoryNetworkError extends VStoryError {
  const VStoryNetworkError({
    required super.message,
    super.originalError,
    super.stackTrace,
  });

  /// Creates a network error from an exception.
  factory VStoryNetworkError.fromException(
    Object error, [
    StackTrace? stackTrace,
  ]) {
    return VStoryNetworkError(
      message: 'Network error: ${error.toString()}',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Request timed out.
///
/// Triggered when:
/// - HTTP request exceeds timeout duration
/// - Video/audio initialization timeout
/// - Cache operation timeout
final class VStoryTimeoutError extends VStoryError {
  /// The timeout duration that was exceeded.
  final Duration? timeout;

  const VStoryTimeoutError({
    required super.message,
    this.timeout,
    super.originalError,
    super.stackTrace,
  });

  /// Creates a timeout error with specified duration.
  factory VStoryTimeoutError.withDuration(
    Duration timeout, [
    Object? originalError,
    StackTrace? stackTrace,
  ]) {
    return VStoryTimeoutError(
      message: 'Request timed out after ${timeout.inSeconds}s',
      timeout: timeout,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }
}

/// Cache read/write failure.
///
/// Triggered when:
/// - Disk space insufficient
/// - Cache file corrupted
/// - Cache directory inaccessible
/// - File system error during caching
final class VStoryCacheError extends VStoryError {
  const VStoryCacheError({
    required super.message,
    super.originalError,
    super.stackTrace,
  });

  /// Creates a cache error from an exception.
  factory VStoryCacheError.fromException(
    Object error, [
    StackTrace? stackTrace,
  ]) {
    return VStoryCacheError(
      message: 'Cache error: ${error.toString()}',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Unsupported media format.
///
/// Triggered when:
/// - Video codec not supported
/// - Audio format not supported
/// - Image format not recognized
/// - Corrupted media file
final class VStoryFormatError extends VStoryError {
  /// The unsupported format identifier (e.g., "hevc", "opus").
  final String? format;

  const VStoryFormatError({
    required super.message,
    this.format,
    super.originalError,
    super.stackTrace,
  });

  /// Creates a format error for a specific format.
  factory VStoryFormatError.unsupported(
    String format, [
    Object? originalError,
    StackTrace? stackTrace,
  ]) {
    return VStoryFormatError(
      message: 'Unsupported format: $format',
      format: format,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }
}

/// Storage/network permission denied.
///
/// Triggered when:
/// - Storage read/write permission denied
/// - Network permission denied (iOS)
/// - Local network access denied
final class VStoryPermissionError extends VStoryError {
  /// The permission that was denied (e.g., "storage", "network").
  final String? permission;

  const VStoryPermissionError({
    required super.message,
    this.permission,
    super.originalError,
    super.stackTrace,
  });

  /// Creates a permission error for a specific permission.
  factory VStoryPermissionError.denied(
    String permission, [
    Object? originalError,
    StackTrace? stackTrace,
  ]) {
    return VStoryPermissionError(
      message: 'Permission denied: $permission',
      permission: permission,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }
}
