import 'v_story_error.dart';
import 'v_controller_error_type.dart';

/// Controller error
class VControllerError extends VStoryError {
  /// Type of controller error
  final VControllerErrorType errorType;
  
  const VControllerError(
    super.message,
    this.errorType, [
    super.originalError,
  ]);
  
  VControllerError.withTimestamp(
    super.message,
    this.errorType, [
    super.originalError,
  ]) : super.withTimestamp();
  
  @override
  bool get isRetryable => errorType != VControllerErrorType.disposed;
  
  @override
  String get userMessage {
    switch (errorType) {
      case VControllerErrorType.initialization:
        return 'Failed to initialize player';
      case VControllerErrorType.playback:
        return 'Playback error occurred';
      case VControllerErrorType.disposed:
        return 'Player was closed';
      case VControllerErrorType.unsupported:
        return 'Format not supported';
    }
  }
  
  @override
  String get code => 'CONTROLLER_${errorType.name.toUpperCase()}';
}