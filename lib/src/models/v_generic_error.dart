import 'v_story_error.dart';

/// Generic error for unexpected failures
class VGenericError extends VStoryError {
  const VGenericError(
    super.message, [
    super.originalError,
  ]);
  
  VGenericError.withTimestamp(
    super.message, [
    super.originalError,
  ]) : super.withTimestamp();
  
  @override
  bool get isRetryable => false;
  
  @override
  String get userMessage => 'Something went wrong';
  
  @override
  String get code => 'GENERIC_ERROR';
}