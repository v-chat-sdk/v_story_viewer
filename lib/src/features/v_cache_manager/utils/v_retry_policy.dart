/// Retry policy for handling failed downloads
class VRetryPolicy {
  /// Creates a retry policy
  ///
  /// Validates:
  /// - [baseDelay] must be positive
  VRetryPolicy({
    required this.type,
    this.baseDelay = const Duration(seconds: 1),
  }) : assert(baseDelay > Duration.zero, 'baseDelay must be positive');

  /// Creates an exponential backoff retry policy
  ///
  /// Delays increase exponentially: 1s, 2s, 4s, 8s, 16s...
  /// This is the recommended policy for network operations.
  VRetryPolicy.exponential({Duration baseDelay = const Duration(seconds: 1)})
    : assert(baseDelay > Duration.zero, 'baseDelay must be positive'),
      type = VRetryType.exponential,
      baseDelay = baseDelay;

  /// Creates a linear retry policy
  ///
  /// Delays remain constant: 2s, 2s, 2s, 2s...
  /// Useful when you want predictable retry timing.
  VRetryPolicy.linear({Duration baseDelay = const Duration(seconds: 2)})
    : assert(baseDelay > Duration.zero, 'baseDelay must be positive'),
      type = VRetryType.linear,
      baseDelay = baseDelay;

  /// Type of retry strategy
  final VRetryType type;

  /// Base delay for calculating retry delays
  final Duration baseDelay;

  /// Calculates the delay for a given retry attempt (0-indexed)
  ///
  /// Example for exponential with baseDelay = 1s:
  /// - attempt 0: 1s
  /// - attempt 1: 2s
  /// - attempt 2: 4s
  /// - attempt 3: 8s
  ///
  /// Example for linear with baseDelay = 2s:
  /// - attempt 0: 2s
  /// - attempt 1: 2s
  /// - attempt 2: 2s
  ///
  /// Validates:
  /// - [attempt] must be non-negative
  Duration calculateDelay(int attempt) {
    assert(attempt >= 0, 'attempt must be non-negative');
    switch (type) {
      case VRetryType.exponential:
        // Cap multiplier at 10 to prevent overflow (max 1024x base delay)
        final cappedAttempt = attempt > 10 ? 10 : attempt;
        final multiplier = 1 << cappedAttempt;
        return baseDelay * multiplier;
      case VRetryType.linear:
        return baseDelay;
    }
  }

  @override
  String toString() {
    return 'VRetryPolicy(type: $type, baseDelay: $baseDelay)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VRetryPolicy &&
        other.type == type &&
        other.baseDelay == baseDelay;
  }

  @override
  int get hashCode => Object.hash(type, baseDelay);
}

/// Types of retry strategies
enum VRetryType {
  /// Exponential backoff: delays increase exponentially (1s, 2s, 4s, 8s...)
  exponential,

  /// Linear backoff: delays remain constant (2s, 2s, 2s, 2s...)
  linear,
}
