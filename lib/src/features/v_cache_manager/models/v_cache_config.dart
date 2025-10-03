import '../utils/v_retry_policy.dart';

/// Configuration for cache manager behavior
class VCacheConfig {
  /// Creates a cache configuration
  ///
  /// Validates input parameters:
  /// - [maxAge] must be positive
  /// - [staleDuration] must be positive and >= maxAge
  /// - [maxRetries] must be non-negative
  VCacheConfig({
    this.maxAge = const Duration(days: 7),
    this.staleDuration = const Duration(days: 30),
    this.maxRetries = 3,
    VRetryPolicy? retryPolicy,
  })  : retryPolicy = retryPolicy ?? VRetryPolicy.exponential(),
        assert(
          maxAge > Duration.zero,
          'maxAge must be positive',
        ),
        assert(
          staleDuration > Duration.zero,
          'staleDuration must be positive',
        ),
        assert(
          staleDuration >= maxAge,
          'staleDuration must be >= maxAge',
        ),
        assert(
          maxRetries >= 0,
          'maxRetries must be non-negative',
        );

  /// Maximum age before cached files are considered stale
  ///
  /// Files older than this will be re-downloaded when accessed.
  /// Default: 7 days
  final Duration maxAge;

  /// Duration to keep stale files before deletion
  ///
  /// Files are kept even when stale to allow offline access.
  /// flutter_cache_manager will clean them up based on this duration.
  /// Default: 30 days
  final Duration staleDuration;

  /// Maximum number of retry attempts for failed downloads
  ///
  /// After this many attempts, the download will fail permanently.
  /// Default: 3 attempts
  final int maxRetries;

  /// Retry policy for handling failed downloads
  ///
  /// Determines the delay between retry attempts.
  /// Default: Exponential backoff (1s, 2s, 4s, 8s...)
  final VRetryPolicy retryPolicy;

  /// Default configuration
  static final defaultConfig = VCacheConfig();

  /// Creates a copy with updated values
  VCacheConfig copyWith({
    Duration? maxAge,
    Duration? staleDuration,
    int? maxRetries,
    VRetryPolicy? retryPolicy,
  }) {
    return VCacheConfig(
      maxAge: maxAge ?? this.maxAge,
      staleDuration: staleDuration ?? this.staleDuration,
      maxRetries: maxRetries ?? this.maxRetries,
      retryPolicy: retryPolicy ?? this.retryPolicy,
    );
  }

  @override
  String toString() {
    return 'VCacheConfig(maxAge: $maxAge, staleDuration: $staleDuration, '
        'maxRetries: $maxRetries, retryPolicy: $retryPolicy)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VCacheConfig &&
        other.maxAge == maxAge &&
        other.staleDuration == staleDuration &&
        other.maxRetries == maxRetries &&
        other.retryPolicy == retryPolicy;
  }

  @override
  int get hashCode {
    return Object.hash(
      maxAge,
      staleDuration,
      maxRetries,
      retryPolicy,
    );
  }
}
