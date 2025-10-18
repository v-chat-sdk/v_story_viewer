import 'package:flutter/foundation.dart';

import '../../../core/models/v_story_events.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_viewer/utils/v_story_event_manager.dart';

/// Abstract base controller for all media types
///
/// Provides common functionality for pause/resume, loading, and error handling.
/// Subclasses implement specific media loading logic via [loadMedia] method.
///
/// Uses Template Method pattern for lifecycle management.
/// Uses event-based communication via VStoryEventManager singleton.
abstract class VBaseMediaController extends ChangeNotifier {
  VBaseMediaController();

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
    _setLoadingState(story);
    try {
      await loadMedia(story);
      _setReadyState();
    } catch (e) {
      _setErrorState(e.toString());
    }
  }

  void _setLoadingState(VBaseStory story) {
    _currentStory = story;
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _setReadyState() {
    _isLoading = false;
    notifyListeners();
    if (_currentStory != null) {
      VStoryEventManager.instance.enqueue(
        VMediaReadyEvent(story: _currentStory!),
      );
    }
  }

  void _setErrorState(String error) {
    _isLoading = false;
    _hasError = true;
    _errorMessage = error;
    notifyListeners();
    if (_currentStory != null) {
      VStoryEventManager.instance.enqueue(
        VMediaErrorEvent(error: error, story: _currentStory!),
      );
    }
  }

  /// Pause media playback (if applicable)
  void pause() {
    if (!_isPaused) {
      _isPaused = true;
      notifyListeners();
      pauseMedia();
      if (_currentStory != null) {
        VStoryEventManager.instance.enqueue(
          VStoryPauseStateChangedEvent(isPaused: true, story: _currentStory!),
        );
      }
    }
  }

  /// Resume media playback (if applicable)
  void resume() {
    if (_isPaused) {
      _isPaused = false;
      notifyListeners();
      resumeMedia();
      if (_currentStory != null) {
        VStoryEventManager.instance.enqueue(
          VStoryPauseStateChangedEvent(isPaused: false, story: _currentStory!),
        );
      }
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

  /// Notify that video duration is known
  @protected
  void notifyDuration(Duration duration) {
    if (_currentStory != null) {
      VStoryEventManager.instance.enqueue(
        VDurationKnownEvent(duration: duration, story: _currentStory!),
      );
    }
  }

  /// Manually trigger ready event (for synchronous media like text)
  @protected
  void notifyReady() {
    if (_currentStory != null) {
      VStoryEventManager.instance.enqueue(
        VMediaReadyEvent(story: _currentStory!),
      );
    }
  }

  /// Manually trigger error event
  @protected
  void notifyError(String error) {
    _hasError = true;
    _errorMessage = error;
    if (_currentStory != null) {
      VStoryEventManager.instance.enqueue(
        VMediaErrorEvent(error: error, story: _currentStory!),
      );
    }
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
