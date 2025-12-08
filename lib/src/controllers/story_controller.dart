import 'package:flutter/foundation.dart';
import '../models/v_story_group.dart';
import '../models/v_story_item.dart';

/// Playback state of the story viewer.
///
/// Used by [StoryController] to track current playback status.
enum StoryState {
  /// Content is loading (network request, media initialization)
  loading,

  /// Story is actively playing (progress advancing)
  playing,

  /// Story is paused (user action, app background, focus lost)
  paused,

  /// Content failed to load
  error,
}

/// State controller for [VStoryViewer] using [ChangeNotifier].
///
/// Manages navigation between stories and groups, playback state,
/// and progress tracking. Used internally by [VStoryViewer].
///
/// ## State Management
/// - **Group navigation**: Move between users with [nextGroup], [previousGroup]
/// - **Story navigation**: Move within a user's stories with [next], [previous]
/// - **Playback control**: [pause], [resume], [setState]
/// - **Progress tracking**: [setProgress] updates current story progress
///
/// ## Usage (Internal)
/// ```dart
/// final controller = StoryController(
///   storyGroups: groups,
///   initialGroupIndex: 0,
/// );
///
/// // Navigate
/// controller.next();     // Next story in group
/// controller.previous(); // Previous story in group
/// controller.nextGroup(); // Next user
/// controller.previousGroup(); // Previous user
///
/// // Control playback
/// controller.pause();
/// controller.resume();
///
/// // Track progress
/// controller.setProgress(0.5); // 50% complete
///
/// // Listen for changes
/// controller.addListener(() {
///   print('State: ${controller.state}');
///   print('Progress: ${controller.progress}');
/// });
/// ```
///
/// ## Navigation Behavior
/// - [nextGroup]: Starts at first story of next user
/// - [previousGroup]: Starts at LAST story of previous user (Instagram-style)
/// - Navigation methods return `false` if at boundary (first/last)
///
/// ## Sorted Stories
/// Stories are accessed via [VStoryGroup.sortedStories] which orders
/// unseen stories before seen stories.
///
/// ## Note
/// This is an internal implementation detail. Most users should interact
/// with [VStoryViewer] callbacks rather than the controller directly.
class StoryController extends ChangeNotifier {
  /// All story groups being viewed.
  final List<VStoryGroup> storyGroups;
  int _currentGroupIndex;
  int _currentItemIndex;
  StoryState _state;
  double _progress;
  bool _isDisposed = false;
  bool _navigatingToPreviousGroup = false;

  /// Creates a story controller.
  ///
  /// [storyGroups] must not be empty.
  /// [initialGroupIndex] defaults to 0 (first user).
  StoryController({
    required this.storyGroups,
    int initialGroupIndex = 0,
  })  : _currentGroupIndex = initialGroupIndex,
        _currentItemIndex = 0,
        _state = StoryState.loading,
        _progress = 0.0;
  // Getters
  int get currentGroupIndex => _currentGroupIndex;
  int get currentItemIndex => _currentItemIndex;
  StoryState get state => _state;
  double get progress => _progress;
  VStoryGroup get currentGroup => storyGroups[_currentGroupIndex];

  /// Get current item from sorted stories (unseen first, then seen)
  VStoryItem get currentItem => currentGroup.sortedStories[_currentItemIndex];
  bool get isFirstStory => _currentItemIndex == 0;
  bool get isLastStory =>
      _currentItemIndex >= currentGroup.sortedStories.length - 1;
  bool get isFirstGroup => _currentGroupIndex == 0;
  bool get isLastGroup => _currentGroupIndex >= storyGroups.length - 1;
  // Setters
  void setProgress(double value) {
    if (_isDisposed) return;
    final clamped = value.clamp(0.0, 1.0);
    if ((_progress - clamped).abs() > 0.001) {
      _progress = clamped;
      notifyListeners();
    }
  }

  void setState(StoryState newState) {
    if (_isDisposed) return;
    _state = newState;
    notifyListeners();
  }

  /// Move to next story within current group
  bool next() {
    if (_isDisposed) return false;
    if (!isLastStory) {
      _currentItemIndex++;
      _progress = 0.0;
      _state = StoryState.loading;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Move to previous story within current group
  bool previous() {
    if (_isDisposed) return false;
    if (!isFirstStory) {
      _currentItemIndex--;
      _progress = 0.0;
      _state = StoryState.loading;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Move to next user group
  bool nextGroup() {
    if (_isDisposed) return false;
    if (!isLastGroup) {
      _currentGroupIndex++;
      _currentItemIndex = 0;
      _progress = 0.0;
      _state = StoryState.loading;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Move to previous user group (starts at last story for backward navigation)
  bool previousGroup() {
    if (_isDisposed) return false;
    if (!isFirstGroup) {
      _navigatingToPreviousGroup = true;
      _currentGroupIndex--;
      _currentItemIndex = currentGroup.sortedStories.length - 1;
      _progress = 0.0;
      _state = StoryState.loading;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Go to specific group
  void goToGroup(int index) {
    if (_isDisposed) return;
    if (index >= 0 && index < storyGroups.length) {
      _currentGroupIndex = index;
      if (_navigatingToPreviousGroup) {
        _currentItemIndex = currentGroup.sortedStories.length - 1;
        _navigatingToPreviousGroup = false;
      } else {
        _currentItemIndex = 0;
      }
      _progress = 0.0;
      _state = StoryState.loading;
      notifyListeners();
    }
  }

  /// Pause current story
  void pause() {
    if (_isDisposed) return;
    if (_state == StoryState.playing) {
      _state = StoryState.paused;
      notifyListeners();
    }
  }

  /// Resume current story
  void resume() {
    if (_isDisposed) return;
    if (_state == StoryState.paused) {
      _state = StoryState.playing;
      notifyListeners();
    }
  }

  /// Reset to initial state
  void reset() {
    if (_isDisposed) return;
    _currentGroupIndex = 0;
    _currentItemIndex = 0;
    _progress = 0.0;
    _state = StoryState.loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
