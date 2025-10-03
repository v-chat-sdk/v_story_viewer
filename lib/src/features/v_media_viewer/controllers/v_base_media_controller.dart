import 'package:flutter/foundation.dart';

import '../../v_story_models/models/v_base_story.dart';
import '../models/v_media_callbacks.dart';

/// Abstract base controller for all media types
///
/// Provides common functionality for pause/resume, loading, and error handling.
/// Subclasses implement specific media loading logic via [loadMedia] method.
///
/// Uses Template Method pattern for lifecycle management.
abstract class VBaseMediaController extends ChangeNotifier {
  VBaseMediaController({
    VMediaCallbacks? callbacks,
  }) : _callbacks = callbacks ?? const VMediaCallbacks();

  final VMediaCallbacks _callbacks;

  VBaseStory? _currentStory;
  bool _isLoading = false;
  bool _isPaused = false;
  bool _hasError = false;
  String? _errorMessage;

  /// Current story being displayed
  VBaseStory? get currentStory => _currentStory;

  /// Whether media is currently loading
  bool get isLoading => _isLoading;

  /// Whether media is paused
  bool get isPaused => _isPaused;

  /// Whether media has error
  bool get hasError => _hasError;

  /// Error message if any
  String? get errorMessage => _errorMessage;

  /// Load and prepare media for display
  ///
  /// This is the main entry point called by VStoryViewer.
  /// Uses template method pattern to delegate specific loading to subclasses.
  Future<void> loadStory(VBaseStory story) async {
    _currentStory = story;
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
    try {
      await loadMedia(story);
      _isLoading = false;
      notifyListeners();
      _callbacks.onMediaReady?.call();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = e.toString();
      notifyListeners();
      _callbacks.onMediaError?.call(e.toString());
    }
  }

  /// Pause media playback (if applicable)
  void pause() {
    if (!_isPaused) {
      _isPaused = true;
      notifyListeners();
      pauseMedia();
      _callbacks.onPaused?.call();
    }
  }

  /// Resume media playback (if applicable)
  void resume() {
    if (_isPaused) {
      _isPaused = false;
      notifyListeners();
      resumeMedia();
      _callbacks.onResumed?.call();
    }
  }

  /// Reset controller state
  void reset() {
    _currentStory = null;
    _isLoading = false;
    _isPaused = false;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Update loading progress (0.0 to 1.0)
  @protected
  void updateProgress(double progress) {
    _callbacks.onLoadingProgress?.call(progress);
  }

  /// Notify that video duration is known
  @protected
  void notifyDuration(Duration duration) {
    _callbacks.onDurationKnown?.call(duration);
  }

  /// Manually trigger ready callback (for synchronous media like text)
  @protected
  void notifyReady() {
    _callbacks.onMediaReady?.call();
  }

  /// Manually trigger error callback
  @protected
  void notifyError(String error) {
    _hasError = true;
    _errorMessage = error;
    _callbacks.onMediaError?.call(error);
    notifyListeners();
  }

  /// Load media specific to this controller type
  ///
  /// Called by [loadStory] template method.
  /// Subclasses must implement their specific loading logic here.
  @protected
  Future<void> loadMedia(VBaseStory story);

  /// Pause media-specific playback
  ///
  /// Default implementation does nothing (for static media like images/text).
  /// Override in subclasses that need pause functionality (e.g., video).
  @protected
  void pauseMedia() {}

  /// Resume media-specific playback
  ///
  /// Default implementation does nothing (for static media like images/text).
  /// Override in subclasses that need resume functionality (e.g., video).
  @protected
  void resumeMedia() {}

  @override
  void dispose() {
    reset();
    super.dispose();
  }
}
