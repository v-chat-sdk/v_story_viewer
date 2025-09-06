import 'v_story_error.dart';

/// Permission error
class VPermissionError extends VStoryError {
  /// Permission that was denied
  final String permission;
  
  const VPermissionError(
    super.message,
    this.permission, [
    super.originalError,
  ]);
  
  VPermissionError.withTimestamp(
    super.message,
    this.permission, [
    super.originalError,
  ]) : super.withTimestamp();
  
  @override
  bool get isRetryable => false;
  
  @override
  String get userMessage => 'Permission required: $permission';
  
  @override
  String get code => 'PERMISSION_DENIED';
}