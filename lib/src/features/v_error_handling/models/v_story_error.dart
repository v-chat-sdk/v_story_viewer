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
    required super.message,
    super.code = 'UNKNOWN_ERROR',
    super.stackTrace,
    super.originalError,
  }) : super(isRetryable: true, requiresUserAction: false);

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
