import 'dart:async';
import 'dart:math' as math;
import '../models/v_story_error.dart';
import '../models/v_generic_error.dart';
import '../models/v_timeout_error.dart';

/// Retry policy for network operations
class VRetryPolicy {
  /// Maximum number of retry attempts
  final int maxAttempts;
  
  /// Initial delay before first retry
  final Duration initialDelay;
  
  /// Maximum delay between retries
  final Duration maxDelay;
  
  /// Factor to multiply delay by for each retry
  final double backoffFactor;
  
  /// Whether to add jitter to delays
  final bool useJitter;
  
  /// Random instance for jitter
  static final _random = math.Random();
  
  const VRetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffFactor = 2.0,
    this.useJitter = true,
  });
  
  /// Default retry policy
  static const VRetryPolicy defaultPolicy = VRetryPolicy();
  
  /// Aggressive retry policy for critical operations
  static const VRetryPolicy aggressive = VRetryPolicy(
    maxAttempts: 5,
    initialDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 10),
    backoffFactor: 1.5,
  );
  
  /// Conservative retry policy for non-critical operations
  static const VRetryPolicy conservative = VRetryPolicy(
    maxAttempts: 2,
    initialDelay: Duration(seconds: 2),
    maxDelay: Duration(minutes: 1),
    backoffFactor: 3.0,
  );
  
  /// Execute operation with retry policy
  Future<T> execute<T>(
    Future<T> Function() operation, {
    bool Function(dynamic error)? shouldRetry,
    void Function(int attempt, dynamic error)? onRetry,
  }) async {
    int attempt = 0;
    dynamic lastError;
    
    while (attempt < maxAttempts) {
      try {
        return await operation();
      } catch (error) {
        lastError = error;
        attempt++;
        
        // Check if we should retry
        if (attempt >= maxAttempts) {
          break;
        }
        
        if (shouldRetry != null && !shouldRetry(error)) {
          break;
        }
        
        // Default retry logic for VStoryError
        if (error is VStoryError && !error.isRetryable) {
          break;
        }
        
        // Calculate delay
        final delay = _calculateDelay(attempt);
        
        // Notify about retry
        onRetry?.call(attempt, error);
        
        // Wait before retry
        await Future.delayed(delay);
      }
    }
    
    // All retries failed
    if (lastError is VStoryError) {
      throw lastError;
    } else {
      throw VGenericError(
        'Operation failed after $attempt attempts',
        lastError,
      );
    }
  }
  
  /// Execute operation with timeout and retry
  Future<T> executeWithTimeout<T>(
    Future<T> Function() operation,
    Duration timeout, {
    bool Function(dynamic error)? shouldRetry,
    void Function(int attempt, dynamic error)? onRetry,
  }) async {
    return execute(
      () => operation().timeout(
        timeout,
        onTimeout: () {
          throw VTimeoutError(
            'Operation timed out',
            'executeWithTimeout',
            timeout,
          );
        },
      ),
      shouldRetry: shouldRetry,
      onRetry: onRetry,
    );
  }
  
  /// Stream with retry policy
  Stream<T> executeStream<T>(
    Stream<T> Function() streamFactory, {
    bool Function(dynamic error)? shouldRetry,
    void Function(int attempt, dynamic error)? onRetry,
  }) async* {
    int attempt = 0;
    dynamic lastError;
    
    while (attempt < maxAttempts) {
      try {
        await for (final value in streamFactory()) {
          yield value;
        }
        return; // Stream completed successfully
      } catch (error) {
        lastError = error;
        attempt++;
        
        // Check if we should retry
        if (attempt >= maxAttempts) {
          break;
        }
        
        if (shouldRetry != null && !shouldRetry(error)) {
          break;
        }
        
        // Default retry logic for VStoryError
        if (error is VStoryError && !error.isRetryable) {
          break;
        }
        
        // Calculate delay
        final delay = _calculateDelay(attempt);
        
        // Notify about retry
        onRetry?.call(attempt, error);
        
        // Wait before retry
        await Future.delayed(delay);
      }
    }
    
    // All retries failed
    if (lastError is VStoryError) {
      throw lastError;
    } else {
      throw VGenericError(
        'Stream operation failed after $attempt attempts',
        lastError,
      );
    }
  }
  
  /// Calculate delay for retry attempt
  Duration _calculateDelay(int attempt) {
    // Calculate exponential backoff
    final exponentialDelay = initialDelay.inMilliseconds * 
        math.pow(backoffFactor, attempt - 1);
    
    // Apply maximum delay cap
    final cappedDelay = math.min(
      exponentialDelay.toInt(),
      maxDelay.inMilliseconds,
    );
    
    // Add jitter if enabled
    if (useJitter) {
      final jitter = _random.nextDouble() * 0.3; // 0-30% jitter
      final jitteredDelay = cappedDelay * (1 + jitter);
      return Duration(milliseconds: jitteredDelay.toInt());
    }
    
    return Duration(milliseconds: cappedDelay);
  }
  
  /// Check if error should be retried
  static bool shouldRetryError(dynamic error) {
    if (error is VStoryError) {
      return error.isRetryable;
    }
    
    // Retry on common network errors
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socket') ||
           errorString.contains('timeout') ||
           errorString.contains('connection') ||
           errorString.contains('network');
  }
}