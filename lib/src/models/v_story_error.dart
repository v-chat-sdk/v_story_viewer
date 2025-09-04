/// Error types for story viewer
sealed class VStoryError {
  /// Error message
  final String message;
  
  /// Original error object if available
  final dynamic originalError;
  
  /// Timestamp when error occurred
  final DateTime? timestamp;
  
  const VStoryError(
    this.message, [
    this.originalError,
  ]) : timestamp = null;
  
  /// Creates error with current timestamp
  VStoryError.withTimestamp(
    this.message, [
    this.originalError,
  ]) : timestamp = DateTime.now();
  
  /// Whether this error can be retried
  bool get isRetryable;
  
  /// User-friendly error message
  String get userMessage;
  
  /// Error code for debugging
  String get code;
  
  @override
  String toString() => 'VStoryError.$runtimeType: $message';
}

/// Media loading error
class VMediaLoadError extends VStoryError {
  /// The file that failed to load
  final String? fileSource;
  
  /// Media type that failed
  final String mediaType;
  
  const VMediaLoadError(
    super.message,
    this.fileSource,
    this.mediaType, [
    super.originalError,
  ]);
  
  VMediaLoadError.withTimestamp(
    super.message,
    this.fileSource,
    this.mediaType, [
    super.originalError,
  ]) : super.withTimestamp();
  
  @override
  bool get isRetryable => true;
  
  @override
  String get userMessage => 'Failed to load $mediaType. Tap to retry.';
  
  @override
  String get code => 'MEDIA_LOAD_ERROR';
}

/// Network error
class VNetworkError extends VStoryError {
  /// URL that failed
  final String url;
  
  /// HTTP status code if available
  final int? statusCode;
  
  const VNetworkError(
    super.message,
    this.url, [
    this.statusCode,
    super.originalError,
  ]);
  
  VNetworkError.withTimestamp(
    super.message,
    this.url, [
    this.statusCode,
    super.originalError,
  ]) : super.withTimestamp();
  
  @override
  bool get isRetryable => statusCode == null || statusCode! >= 500 || statusCode == 408;
  
  @override
  String get userMessage {
    if (statusCode == 404) {
      return 'Content not found';
    } else if (statusCode != null && statusCode! >= 500) {
      return 'Server error. Please try again.';
    } else {
      return 'Network error. Check your connection.';
    }
  }
  
  @override
  String get code => 'NETWORK_ERROR_$statusCode';
}

/// Controller error
class VControllerError extends VStoryError {
  /// Type of controller error
  final VControllerErrorType errorType;
  
  const VControllerError(
    super.message,
    this.errorType, [
    super.originalError,
  ]);
  
  VControllerError.withTimestamp(
    super.message,
    this.errorType, [
    super.originalError,
  ]) : super.withTimestamp();
  
  @override
  bool get isRetryable => errorType != VControllerErrorType.disposed;
  
  @override
  String get userMessage {
    switch (errorType) {
      case VControllerErrorType.initialization:
        return 'Failed to initialize player';
      case VControllerErrorType.playback:
        return 'Playback error occurred';
      case VControllerErrorType.disposed:
        return 'Player was closed';
      case VControllerErrorType.unsupported:
        return 'Format not supported';
    }
  }
  
  @override
  String get code => 'CONTROLLER_${errorType.name.toUpperCase()}';
}

/// Controller error types
enum VControllerErrorType {
  initialization,
  playback,
  disposed,
  unsupported,
}

/// Cache error
class VCacheError extends VStoryError {
  /// Cache operation that failed
  final String operation;
  
  const VCacheError(
    super.message,
    this.operation, [
    super.originalError,
  ]);
  
  VCacheError.withTimestamp(
    super.message,
    this.operation, [
    super.originalError,
  ]) : super.withTimestamp();
  
  @override
  bool get isRetryable => true;
  
  @override
  String get userMessage => 'Storage error. Retrying...';
  
  @override
  String get code => 'CACHE_ERROR';
}

/// Permission error
class VPermissionError extends VStoryError {
  /// Permission that was denied
  final String permission;
  
  const VPermissionError(
    super.message,
    this.permission, [
    super.originalError,
  ]);
  
  VPermissionError.withTimestamp(
    super.message,
    this.permission, [
    super.originalError,
  ]) : super.withTimestamp();
  
  @override
  bool get isRetryable => false;
  
  @override
  String get userMessage => 'Permission required: $permission';
  
  @override
  String get code => 'PERMISSION_DENIED';
}

/// Timeout error
class VTimeoutError extends VStoryError {
  /// Operation that timed out
  final String operation;
  
  /// Timeout duration
  final Duration timeout;
  
  const VTimeoutError(
    super.message,
    this.operation,
    this.timeout, [
    super.originalError,
  ]);
  
  VTimeoutError.withTimestamp(
    super.message,
    this.operation,
    this.timeout, [
    super.originalError,
  ]) : super.withTimestamp();
  
  @override
  bool get isRetryable => true;
  
  @override
  String get userMessage => 'Request timed out. Tap to retry.';
  
  @override
  String get code => 'TIMEOUT_ERROR';
}

/// Generic error for unexpected failures
class VGenericError extends VStoryError {
  const VGenericError(
    super.message, [
    super.originalError,
  ]);
  
  VGenericError.withTimestamp(
    super.message, [
    super.originalError,
  ]) : super.withTimestamp();
  
  @override
  bool get isRetryable => false;
  
  @override
  String get userMessage => 'Something went wrong';
  
  @override
  String get code => 'GENERIC_ERROR';
}

/// Security error
class VSecurityError extends VStoryError {
  const VSecurityError(super.message, [super.originalError]);
  
  VSecurityError.withTimestamp(
    super.message, [
    super.originalError,
  ]) : super.withTimestamp();
  
  @override
  bool get isRetryable => false;
  
  @override
  String get userMessage => 'Security validation failed';
  
  @override
  String get code => 'SECURITY_ERROR';
}