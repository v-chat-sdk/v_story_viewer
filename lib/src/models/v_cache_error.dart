import 'v_story_error.dart';

/// Cache error
class VCacheError extends VStoryError {
  /// Cache operation that failed
  final String operation;
  
  const VCacheError(
    super.message,
    this.operation, [
    super.originalError,
  ]);
  
  VCacheError.withTimestamp(
    super.message,
    this.operation, [
    super.originalError,
  ]) : super.withTimestamp();
  
  @override
  bool get isRetryable => true;
  
  @override
  String get userMessage => 'Storage error. Retrying...';
  
  @override
  String get code => 'CACHE_ERROR';
}