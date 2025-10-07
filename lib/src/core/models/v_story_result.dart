/// Result types for better error handling in v_story_viewer
///
/// Provides type-safe error handling without throwing exceptions
/// or relying on nullable returns.
library v_story_result;

import '../../../v_story_viewer.dart';

/// Base sealed class for Result pattern implementation
///
/// Represents an operation that can either succeed with a value [T]
/// or fail with a [VStoryError].
///
/// Example:
/// ```dart
/// VStoryResult<VBaseStory> loadStory(String id) {
///   final story = _findStory(id);
///   if (story == null) {
///     return VStoryFailure(VStoryError.storyNotFound(id));
///   }
///   return VStorySuccess(story);
/// }
///
/// // Usage
/// final result = loadStory('story123');
/// switch (result) {
///   case VStorySuccess(value: final story):
///     displayStory(story);
///   case VStoryFailure(error: final error):
///     showError(error.message);
/// }
/// ```
sealed class VStoryResult<T> {
  const VStoryResult();

  /// Returns true if this result represents a successful operation
  bool get isSuccess => this is VStorySuccess<T>;

  /// Returns true if this result represents a failed operation
  bool get isFailure => this is VStoryFailure<T>;

  /// Gets the success value or null if this is a failure
  T? get valueOrNull => switch (this) {
    VStorySuccess(value: final value) => value,
    VStoryFailure() => null,
  };

  /// Gets the error or null if this is a success
  VStoryError? get errorOrNull => switch (this) {
    VStorySuccess() => null,
    VStoryFailure(error: final error) => error,
  };

  /// Transforms the success value using the provided function
  VStoryResult<R> map<R>(R Function(T value) transform) => switch (this) {
    VStorySuccess(value: final value) => VStorySuccess(transform(value)),
    VStoryFailure(error: final error) => VStoryFailure(error),
  };

  /// Chains another result-returning operation
  VStoryResult<R> flatMap<R>(VStoryResult<R> Function(T value) transform) =>
      switch (this) {
        VStorySuccess(value: final value) => transform(value),
        VStoryFailure(error: final error) => VStoryFailure(error),
      };

  /// Provides a fallback value for failure cases
  T getOrElse(T Function(VStoryError error) fallback) => switch (this) {
    VStorySuccess(value: final value) => value,
    VStoryFailure(error: final error) => fallback(error),
  };

  /// Executes side effects based on the result
  void fold({
    required void Function(T value) onSuccess,
    required void Function(VStoryError error) onFailure,
  }) {
    switch (this) {
      case VStorySuccess(value: final value):
        onSuccess(value);
      case VStoryFailure(error: final error):
        onFailure(error);
    }
  }
}

/// Represents a successful operation result
class VStorySuccess<T> extends VStoryResult<T> {
  const VStorySuccess(this.value);

  /// The successful result value
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VStorySuccess<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'VStorySuccess($value)';
}

/// Represents a failed operation result
class VStoryFailure<T> extends VStoryResult<T> {
  const VStoryFailure(this.error);

  /// The error that caused the operation to fail
  final VStoryError error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VStoryFailure<T> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'VStoryFailure($error)';
}

/// Extension methods for working with Result types
extension VStoryResultExtensions<T> on VStoryResult<T> {
  /// Converts this result to a Future for async operations
  Future<T> toFuture() async {
    switch (this) {
      case VStorySuccess(value: final value):
        return value;
      case VStoryFailure(error: final error):
        throw error;
    }
  }

  /// Creates a Result from a Future, catching exceptions
  static Future<VStoryResult<T>> fromFuture<T>(Future<T> future) async {
    try {
      final value = await future;
      return VStorySuccess(value);
    } catch (error, stackTrace) {
      if (error is VStoryError) {
        return VStoryFailure(error);
      }
      return VStoryFailure(
        VStoryError.unknown(message: error.toString(), stackTrace: stackTrace),
      );
    }
  }

  /// Creates a Result from a nullable value
  static VStoryResult<T> fromNullable<T>(
    T? value, {
    required VStoryError Function() orElse,
  }) {
    if (value != null) {
      return VStorySuccess(value);
    }
    return VStoryFailure(orElse());
  }
}

/// Utility functions for creating common Result types
class VStoryResults {
  VStoryResults._();

  /// Creates a success result
  static VStoryResult<T> success<T>(T value) => VStorySuccess(value);

  /// Creates a failure result
  static VStoryResult<T> failure<T>(VStoryError error) => VStoryFailure(error);

  /// Creates a result from a try-catch block
  static VStoryResult<T> tryRun<T>(T Function() operation) {
    try {
      final value = operation();
      return VStorySuccess(value);
    } catch (error, stackTrace) {
      if (error is VStoryError) {
        return VStoryFailure(error);
      }
      return VStoryFailure(
        VStoryError.unknown(message: error.toString(), stackTrace: stackTrace),
      );
    }
  }

  /// Combines multiple results into a single result containing a list
  static VStoryResult<List<T>> combine<T>(List<VStoryResult<T>> results) {
    final values = <T>[];
    for (final result in results) {
      switch (result) {
        case VStorySuccess(value: final value):
          values.add(value);
        case VStoryFailure(error: final error):
          return VStoryFailure(error);
      }
    }
    return VStorySuccess(values);
  }

  /// Returns the first successful result or the last failure
  static VStoryResult<T> firstSuccess<T>(List<VStoryResult<T>> results) {
    if (results.isEmpty) {
      return VStoryFailure(
        VStoryError.invalidArgument('Results list cannot be empty'),
      );
    }

    VStoryError? lastError;
    for (final result in results) {
      switch (result) {
        case VStorySuccess():
          return result;
        case VStoryFailure(error: final error):
          lastError = error;
      }
    }

    return VStoryFailure(lastError!);
  }
}
