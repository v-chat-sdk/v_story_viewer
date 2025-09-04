import 'v_retry_policy.dart';

/// Defines caching policies for story media.
class VCachePolicy {
  /// Duration before cached content is considered stale
  final Duration stalePeriod;
  
  /// Maximum number of cached objects
  final int maxCacheObjects;
  
  /// Maximum cache size in bytes (not enforced by flutter_cache_manager)
  final int maxCacheSize;
  
  /// Whether to preload next stories
  final bool preloadNext;
  
  /// Number of stories to preload
  final int preloadCount;
  
  /// Retry policy for failed downloads
  final VRetryPolicy retryPolicy;
  
  /// Creates a cache policy
  const VCachePolicy({
    required this.stalePeriod,
    required this.maxCacheObjects,
    required this.maxCacheSize,
    required this.preloadNext,
    required this.preloadCount,
    required this.retryPolicy,
  });
  
  /// Creates a standard cache policy (24 hours)
  factory VCachePolicy.standard() {
    return VCachePolicy(
      stalePeriod: const Duration(hours: 24),
      maxCacheObjects: 200,
      maxCacheSize: 100 * 1024 * 1024, // 100 MB
      preloadNext: true,
      preloadCount: 2,
      retryPolicy: VRetryPolicy(),
    );
  }
  
  /// Creates an aggressive cache policy (7 days)
  factory VCachePolicy.aggressive() {
    return VCachePolicy(
      stalePeriod: const Duration(days: 7),
      maxCacheObjects: 500,
      maxCacheSize: 200 * 1024 * 1024, // 200 MB
      preloadNext: true,
      preloadCount: 3,
      retryPolicy: VRetryPolicy(config: VRetryConfig.aggressive()),
    );
  }
  
  /// Creates a minimal cache policy (1 hour)
  factory VCachePolicy.minimal() {
    return VCachePolicy(
      stalePeriod: const Duration(hours: 1),
      maxCacheObjects: 50,
      maxCacheSize: 50 * 1024 * 1024, // 50 MB
      preloadNext: false,
      preloadCount: 0,
      retryPolicy: VRetryPolicy(config: VRetryConfig.conservative()),
    );
  }
  
  /// Creates a policy for offline mode (30 days)
  factory VCachePolicy.offline() {
    return VCachePolicy(
      stalePeriod: const Duration(days: 30),
      maxCacheObjects: 1000,
      maxCacheSize: 500 * 1024 * 1024, // 500 MB
      preloadNext: true,
      preloadCount: 5,
      retryPolicy: VRetryPolicy(config: VRetryConfig.conservative()), // Don't retry much in offline mode
    );
  }
  
  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'stalePeriod': stalePeriod.inHours,
      'maxCacheObjects': maxCacheObjects,
      'maxCacheSize': maxCacheSize,
      'preloadNext': preloadNext,
      'preloadCount': preloadCount,
      'retryPolicy': retryPolicy.config.toJson(),
    };
  }
}

