import 'v_story_error.dart';

/// Network error
class VNetworkError extends VStoryError {
  /// URL that failed
  final String url;
  
  /// HTTP status code if available
  final int? statusCode;
  
  const VNetworkError(
    super.message,
    this.url, [
    this.statusCode,
    super.originalError,
  ]);
  
  VNetworkError.withTimestamp(
    super.message,
    this.url, [
    this.statusCode,
    super.originalError,
  ]) : super.withTimestamp();
  
  @override
  bool get isRetryable => statusCode == null || statusCode! >= 500 || statusCode == 408;
  
  @override
  String get userMessage {
    if (statusCode == 404) {
      return 'Content not found';
    } else if (statusCode != null && statusCode! >= 500) {
      return 'Server error. Please try again.';
    } else {
      return 'Network error. Check your connection.';
    }
  }
  
  @override
  String get code => 'NETWORK_ERROR_$statusCode';
}