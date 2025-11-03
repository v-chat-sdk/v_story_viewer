/// Base class for cache-related errors
///
/// Provides better error differentiation than plain strings,
/// allowing callers to handle specific error types appropriately.
sealed class VCacheManagerError implements Exception {
  const VCacheManagerError(this.message, this.url);

  /// Error message describing what went wrong
  final String message;

  /// URL that caused the error
  final String url;

  @override
  String toString() => 'VCacheManagerError: $message (url: $url)';
}

/// Network-related download errors
class VCacheNetworkError extends VCacheManagerError {
  const VCacheNetworkError(super.message, super.url, {this.statusCode});

  /// HTTP status code if available
  final int? statusCode;

  @override
  String toString() {
    final code = statusCode != null ? ' (status: $statusCode)' : '';
    return 'VCacheNetworkError: $message$code (url: $url)';
  }
}

/// File system errors (permissions, disk space, etc.)
class VCacheFileSystemError extends VCacheManagerError {
  const VCacheFileSystemError(super.message, super.url);
}

/// Errors that occurred after max retry attempts
class VCacheRetryExhaustedError extends VCacheManagerError {
  const VCacheRetryExhaustedError(
    super.message,
    super.url, {
    required this.attempts,
    this.lastError,
  });

  /// Number of retry attempts made
  final int attempts;

  /// The last error that caused the failure
  final Object? lastError;

  @override
  String toString() {
    return 'VCacheRetryExhaustedError: $message after $attempts attempts '
        '(url: $url, lastError: $lastError)';
  }
}
