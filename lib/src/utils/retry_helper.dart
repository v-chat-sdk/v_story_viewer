import 'dart:async';

/// Helper class for exponential backoff retry strategy
class RetryHelper {
  /// Retry an async action with exponential backoff
  /// - [action]: The async function to retry
  /// - [maxRetries]: Maximum number of retry attempts (default: 5)
  /// - [initialDelay]: Initial delay between retries (default: 1 second)
  /// - [timeout]: Timeout for each attempt (default: 30 seconds)
  static Future<T> retry<T>({
    required Future<T> Function() action,
    int maxRetries = 5,
    Duration initialDelay = const Duration(seconds: 1),
    Duration timeout = const Duration(seconds: 30),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;
    while (true) {
      try {
        return await action().timeout(timeout);
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) rethrow;
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff: 1s, 2s, 4s, 8s, 16s
      }
    }
  }
}
