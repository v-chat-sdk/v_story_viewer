import 'v_story_error.dart';

/// Security error
class VSecurityError extends VStoryError {
  const VSecurityError(super.message, [super.originalError]);
  
  VSecurityError.withTimestamp(
    super.message, [
    super.originalError,
  ]) : super.withTimestamp();
  
  @override
  bool get isRetryable => false;
  
  @override
  String get userMessage => 'Security validation failed';
  
  @override
  String get code => 'SECURITY_ERROR';
}