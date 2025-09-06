import 'v_story_error.dart';

/// Timeout error
class VTimeoutError extends VStoryError {
  /// Operation that timed out
  final String operation;
  
  /// Timeout duration
  final Duration timeout;
  
  const VTimeoutError(
    super.message,
    this.operation,
    this.timeout, [
    super.originalError,
  ]);
  
  VTimeoutError.withTimestamp(
    super.message,
    this.operation,
    this.timeout, [
    super.originalError,
  ]) : super.withTimestamp();
  
  @override
  bool get isRetryable => true;
  
  @override
  String get userMessage => 'Request timed out. Tap to retry.';
  
  @override
  String get code => 'TIMEOUT_ERROR';
}