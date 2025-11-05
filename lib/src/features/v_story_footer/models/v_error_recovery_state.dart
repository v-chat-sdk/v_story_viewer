import 'package:flutter/foundation.dart';

import '../../v_error_handling/models/v_story_error.dart';

/// Error recovery state for footer
@immutable
class VErrorRecoveryState {
  const VErrorRecoveryState({
    this.error,
    this.isRetrying = false,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.lastRetryTime,
  });

  /// The error that occurred
  final VStoryError? error;

  /// Whether currently retrying
  final bool isRetrying;

  /// Number of retry attempts made
  final int retryCount;

  /// Maximum number of retries allowed
  final int maxRetries;

  /// Timestamp of last retry attempt
  final DateTime? lastRetryTime;

  /// Whether an error is present
  bool get hasError => error != null;

  /// Whether the error is retryable
  bool get isErrorRetryable => error?.isRetryable ?? false;

  /// Whether we can retry (under max retries and error is retryable)
  bool get canRetry =>
      isErrorRetryable && retryCount < maxRetries && !isRetrying;

  /// Remaining retry attempts
  int get remainingRetries => (maxRetries - retryCount).clamp(0, maxRetries);

  /// Create a copy with modifications
  VErrorRecoveryState copyWith({
    VStoryError? error,
    bool? isRetrying,
    int? retryCount,
    int? maxRetries,
    DateTime? lastRetryTime,
  }) {
    return VErrorRecoveryState(
      error: error ?? this.error,
      isRetrying: isRetrying ?? this.isRetrying,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      lastRetryTime: lastRetryTime ?? this.lastRetryTime,
    );
  }

  /// Clear error state
  VErrorRecoveryState clearError() => const VErrorRecoveryState();

  /// Reset retry count and error
  VErrorRecoveryState reset() => const VErrorRecoveryState();
}
