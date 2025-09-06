/// Error types for story viewer
abstract class VStoryError {
  /// Error message
  final String message;
  
  /// Original error object if available
  final dynamic originalError;
  
  /// Timestamp when error occurred
  final DateTime? timestamp;
  
  const VStoryError(
    this.message, [
    this.originalError,
  ]) : timestamp = null;
  
  /// Creates error with current timestamp
  VStoryError.withTimestamp(
    this.message, [
    this.originalError,
  ]) : timestamp = DateTime.now();
  
  /// Whether this error can be retried
  bool get isRetryable;
  
  /// User-friendly error message
  String get userMessage;
  
  /// Error code for debugging
  String get code;
  
  @override
  String toString() => 'VStoryError.$runtimeType: $message';
}

