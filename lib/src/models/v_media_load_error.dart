import 'v_story_error.dart';

/// Media loading error
class VMediaLoadError extends VStoryError {
  /// The file that failed to load
  final String? fileSource;
  
  /// Media type that failed
  final String mediaType;
  
  const VMediaLoadError(
    super.message,
    this.fileSource,
    this.mediaType, [
    super.originalError,
  ]);
  
  VMediaLoadError.withTimestamp(
    super.message,
    this.fileSource,
    this.mediaType, [
    super.originalError,
  ]) : super.withTimestamp();
  
  @override
  bool get isRetryable => true;
  
  @override
  String get userMessage => 'Failed to load $mediaType. Tap to retry.';
  
  @override
  String get code => 'MEDIA_LOAD_ERROR';
}