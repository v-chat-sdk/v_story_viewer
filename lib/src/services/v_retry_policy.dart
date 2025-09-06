import 'dart:async';
import 'dart:math' as math;

/// Configuration for retry policy with exponential backoff.
class VRetryConfig {
  /// Maximum number of retry attempts
  final int maxAttempts;
  
  /// Initial delay before first retry (milliseconds)
  final int initialDelayMs;
  
  /// Maximum delay between retries (milliseconds)
  final int maxDelayMs;
  
  /// Backoff multiplier for exponential backoff
  final double backoffMultiplier;
  
  /// Whether to add jitter to prevent thundering herd
  final bool useJitter;
  
  /// Timeout for each attempt (milliseconds)
  final int? timeoutMs;
  
  /// Creates a retry configuration
  const VRetryConfig({
    this.maxAttempts = 3,
    this.initialDelayMs = 1000,
    this.maxDelayMs = 30000,
    this.backoffMultiplier = 2.0,
    this.useJitter = true,
    this.timeoutMs,
  });
  
  /// Creates a default configuration
  factory VRetryConfig.defaultConfig() => const VRetryConfig();
  
  /// Creates an aggressive retry configuration
  factory VRetryConfig.aggressive() => const VRetryConfig(
    maxAttempts: 5,
    initialDelayMs: 500,
    maxDelayMs: 10000,
    backoffMultiplier: 1.5,
  );
  
  /// Creates a conservative retry configuration
  factory VRetryConfig.conservative() => const VRetryConfig(
    maxAttempts: 2,
    initialDelayMs: 2000,
    maxDelayMs: 60000,
    backoffMultiplier: 3.0,
  );
  
  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'maxAttempts': maxAttempts,
      'initialDelayMs': initialDelayMs,
      'maxDelayMs': maxDelayMs,
      'backoffMultiplier': backoffMultiplier,
      'useJitter': useJitter,
      'timeoutMs': timeoutMs,
    };
  }
}

/// Retry policy with exponential backoff for network operations.
class VRetryPolicy {
  /// Retry configuration
  final VRetryConfig config;
  
  /// Random generator for jitter
  final math.Random _random = math.Random();
  
  /// Creates a retry policy
  VRetryPolicy({
    this.config = const VRetryConfig(),
  });
  
  /// Executes an operation with retry logic
  Future<T> execute<T>(
    Future<T> Function() operation, {
    bool Function(Object error)? retryIf,
    void Function(int attempt, Object error)? onRetry,
    void Function(Object error)? onError,
  }) async {
    int attempt = 0;
    Object? lastError;
    
    while (attempt < config.maxAttempts) {
      try {
        // Add timeout if configured
        if (config.timeoutMs != null) {
          return await operation().timeout(
            Duration(milliseconds: config.timeoutMs!),
            onTimeout: () {
              throw TimeoutException(
                'Operation timed out after ${config.timeoutMs}ms',
              );
            },
          );
        } else {
          return await operation();
        }
      } catch (error) {
        lastError = error;
        attempt++;
        
        // Check if we should retry
        final shouldRetry = retryIf?.call(error) ?? _defaultRetryIf(error);
        
        if (!shouldRetry || attempt >= config.maxAttempts) {
          onError?.call(error);
          rethrow;
        }
        
        // Calculate delay
        final delay = _calculateDelay(attempt);
        
        // Notify retry callback
        onRetry?.call(attempt, error);
        
        // Wait before retrying
        await Future.delayed(Duration(milliseconds: delay));
      }
    }
    
    // This should never be reached, but throw last error just in case
    throw lastError ?? Exception('Retry failed with unknown error');
  }
  
  /// Executes a stream operation with retry logic
  Stream<T> executeStream<T>(
    Stream<T> Function() operation, {
    bool Function(Object error)? retryIf,
    void Function(int attempt, Object error)? onRetry,
  }) {
    StreamController<T>? controller;
    StreamSubscription<T>? subscription;
    int attempt = 0;
    
    void retry() async {
      attempt++;
      
      if (attempt > config.maxAttempts) {
        controller?.addError(
          Exception('Max retry attempts (${config.maxAttempts}) exceeded'),
        );
        controller?.close();
        return;
      }
      
      // Calculate delay
      final delay = attempt > 1 ? _calculateDelay(attempt - 1) : 0;
      
      if (delay > 0) {
        await Future.delayed(Duration(milliseconds: delay));
      }
      
      try {
        subscription = operation().listen(
          (data) {
            controller?.add(data);
          },
          onError: (error) {
            final shouldRetry = retryIf?.call(error) ?? _defaultRetryIf(error);
            
            if (shouldRetry && attempt < config.maxAttempts) {
              onRetry?.call(attempt, error);
              subscription?.cancel();
              retry();
            } else {
              controller?.addError(error);
              controller?.close();
            }
          },
          onDone: () {
            controller?.close();
          },
          cancelOnError: false,
        );
      } catch (error) {
        final shouldRetry = retryIf?.call(error) ?? _defaultRetryIf(error);
        
        if (shouldRetry && attempt < config.maxAttempts) {
          onRetry?.call(attempt, error);
          retry();
        } else {
          controller?.addError(error);
          controller?.close();
        }
      }
    }
    
    controller = StreamController<T>(
      onListen: retry,
      onCancel: () {
        subscription?.cancel();
      },
    );
    
    return controller.stream;
  }
  
  /// Calculates delay with exponential backoff and optional jitter
  int _calculateDelay(int attempt) {
    // Calculate exponential backoff
    final exponentialDelay = config.initialDelayMs * 
        math.pow(config.backoffMultiplier, attempt - 1);
    
    // Cap at maximum delay
    var delay = math.min(exponentialDelay.round(), config.maxDelayMs);
    
    // Add jitter if configured
    if (config.useJitter) {
      // Add random jitter between 0% and 25% of delay
      final jitter = _random.nextInt(delay ~/ 4);
      delay += jitter;
    }
    
    return delay;
  }
  
  /// Default retry condition
  bool _defaultRetryIf(Object error) {
    // Retry on network-related errors
    if (error is TimeoutException) {
      return true;
    }
    
    // Check for common network error patterns
    final errorString = error.toString().toLowerCase();
    final networkErrors = [
      'socketexception',
      'handshakeexception',
      'connection refused',
      'connection reset',
      'network unreachable',
      'host unreachable',
      'timeout',
      'temporary failure',
    ];
    
    return networkErrors.any((pattern) => errorString.contains(pattern));
  }
}

/// Exception thrown when operation times out
class TimeoutException implements Exception {
  /// The error message
  final String message;
  
  /// Creates a timeout exception
  TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: $message';
}

/// Retry statistics for monitoring
class VRetryStatistics {
  /// Total number of operations
  int totalOperations = 0;
  
  /// Number of successful operations
  int successfulOperations = 0;
  
  /// Number of failed operations
  int failedOperations = 0;
  
  /// Total number of retries
  int totalRetries = 0;
  
  /// Maximum retries for a single operation
  int maxRetriesPerOperation = 0;
  
  /// Records an operation result
  void recordOperation({
    required bool success,
    required int retries,
  }) {
    totalOperations++;
    
    if (success) {
      successfulOperations++;
    } else {
      failedOperations++;
    }
    
    totalRetries += retries;
    maxRetriesPerOperation = math.max(maxRetriesPerOperation, retries);
  }
  
  /// Gets success rate
  double get successRate {
    if (totalOperations == 0) return 0.0;
    return successfulOperations / totalOperations;
  }
  
  /// Gets average retries per operation
  double get averageRetries {
    if (totalOperations == 0) return 0.0;
    return totalRetries / totalOperations;
  }
  
  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalOperations': totalOperations,
      'successfulOperations': successfulOperations,
      'failedOperations': failedOperations,
      'totalRetries': totalRetries,
      'maxRetriesPerOperation': maxRetriesPerOperation,
      'successRate': successRate,
      'averageRetries': averageRetries,
    };
  }
}