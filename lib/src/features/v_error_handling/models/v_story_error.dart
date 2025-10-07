import 'package:flutter/foundation.dart';

/// Base class for all story viewer errors
@immutable
abstract class VStoryError implements Exception {
  const VStoryError({
    required this.message,
    this.code,
    this.stackTrace,
    this.originalError,
    this.isRetryable = true,
    this.requiresUserAction = false,
  });

  // Factory constructors for common error types
  const factory VStoryError.unknown({
    required String message,
    String? code,
    StackTrace? stackTrace,
    Object? originalError,
  }) = VGenericError.unknown;

  const factory VStoryError.storyNotFound(String message) =
      VGenericError.storyNotFound;

  const factory VStoryError.indexOutOfBounds(String message) =
      VGenericError.indexOutOfBounds;

  const factory VStoryError.invalidConfiguration(String message) =
      VGenericError.invalidConfiguration;

  const factory VStoryError.invalidArgument(String message) =
      VGenericError.invalidArgument;

  /// Error message
  final String message;

  /// Optional error code
  final String? code;

  /// Stack trace if available
  final StackTrace? stackTrace;

  /// Original error that caused this error
  final Object? originalError;

  /// Whether this error can be retried
  final bool isRetryable;

  /// Whether this error requires user intervention
  final bool requiresUserAction;

  @override
  String toString() =>
      'VStoryError: $message${code != null ? ' (code: $code)' : ''}';
}

/// Error related to media loading
class VMediaLoadError extends VStoryError {
  const VMediaLoadError({
    required super.message,
    super.code,
    super.stackTrace,
    super.originalError,
    this.url,
    this.mediaType,
  });

  /// URL or path that failed to load
  final String? url;

  /// Type of media (image, video)
  final String? mediaType;

  @override
  String toString() =>
      'VMediaLoadError: $message${url != null ? ' (url: $url)' : ''}';
}

/// Error related to network operations
class VNetworkError extends VStoryError {
  const VNetworkError({
    required super.message,
    super.code,
    super.stackTrace,
    super.originalError,
    this.statusCode,
  });

  /// HTTP status code if applicable
  final int? statusCode;

  @override
  String toString() =>
      'VNetworkError: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}

/// Error related to cache operations
class VCacheError extends VStoryError {
  const VCacheError({
    required super.message,
    super.code,
    super.stackTrace,
    super.originalError,
    this.operation,
  });

  /// Cache operation that failed (read, write, delete)
  final String? operation;

  @override
  String toString() =>
      'VCacheError: $message${operation != null ? ' (operation: $operation)' : ''}';
}

/// Error related to permissions
class VPermissionError extends VStoryError {
  const VPermissionError({
    required super.message,
    super.code,
    super.stackTrace,
    super.originalError,
    this.permission,
  });

  /// Permission that was denied
  final String? permission;

  @override
  String toString() =>
      'VPermissionError: $message${permission != null ? ' (permission: $permission)' : ''}';
}

/// Generic error for unexpected failures
class VGenericError extends VStoryError {
  const VGenericError({
    required super.message,
    super.code,
    super.stackTrace,
    super.originalError,
    super.isRetryable,
    super.requiresUserAction,
  });

  const VGenericError.unknown({
    required String message,
    String? code,
    StackTrace? stackTrace,
    Object? originalError,
  }) : super(
         message: message,
         code: code ?? 'UNKNOWN_ERROR',
         stackTrace: stackTrace,
         originalError: originalError,
         isRetryable: true,
         requiresUserAction: false,
       );

  const VGenericError.storyNotFound(String message)
    : super(
        message: message,
        code: 'STORY_NOT_FOUND',
        isRetryable: false,
        requiresUserAction: true,
      );

  const VGenericError.indexOutOfBounds(String message)
    : super(
        message: message,
        code: 'INDEX_OUT_OF_BOUNDS',
        isRetryable: false,
        requiresUserAction: true,
      );

  const VGenericError.invalidConfiguration(String message)
    : super(
        message: message,
        code: 'INVALID_CONFIGURATION',
        isRetryable: false,
        requiresUserAction: true,
      );

  const VGenericError.invalidArgument(String message)
    : super(
        message: message,
        code: 'INVALID_ARGUMENT',
        isRetryable: false,
        requiresUserAction: true,
      );
}
