import 'package:flutter/foundation.dart';

import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_story_group.dart';

/// Controller for managing story navigation
///
/// Handles navigation between stories and groups with proper edge case handling.
/// Provides thread-safe navigation using _isNavigating flag.
class VStoryNavigationController extends ChangeNotifier {
  VStoryNavigationController({
    required List<VStoryGroup> storyGroups,
    int initialGroupIndex = 0,
    int initialStoryIndex = 0,
  }) : assert(storyGroups.isNotEmpty, 'Story groups cannot be empty'),
       assert(
         initialGroupIndex >= 0 && initialGroupIndex < storyGroups.length,
         'Initial group index out of bounds',
       ),
       assert(
         initialStoryIndex >= 0 &&
             initialStoryIndex < storyGroups[initialGroupIndex].stories.length,
         'Initial story index out of bounds',
       ),
       _storyGroups = storyGroups,
       _currentGroupIndex = initialGroupIndex,
       _currentStoryIndex = initialStoryIndex;

  final List<VStoryGroup> _storyGroups;
  int _currentGroupIndex;
  int _currentStoryIndex;
  bool _isNavigating = false;

  /// Get current group index
  int get currentGroupIndex => _currentGroupIndex;

  /// Get current story index within group
  int get currentStoryIndex => _currentStoryIndex;

  /// Get current story group
  VStoryGroup get currentGroup => _storyGroups[_currentGroupIndex];

  /// Get current story
  VBaseStory get currentStory => currentGroup.stories[_currentStoryIndex];

  /// Get all story groups
  List<VStoryGroup> get storyGroups => _storyGroups;

  /// Check if there is a next story
  bool get hasNextStory {
    return _currentStoryIndex < currentGroup.stories.length - 1;
  }

  /// Check if there is a previous story
  bool get hasPreviousStory {
    return _currentStoryIndex > 0;
  }

  /// Check if there is a next group
  bool get hasNextGroup {
    return _currentGroupIndex < _storyGroups.length - 1;
  }

  /// Check if there is a previous group
  bool get hasPreviousGroup {
    return _currentGroupIndex > 0;
  }

  /// Navigate to next story
  ///
  /// Returns true if navigation succeeded, false if at end of group.
  /// Use [nextGroup] to move to next group.
  bool nextStory() {
    if (_isNavigating) return false;
    _isNavigating = true;

    try {
      if (hasNextStory) {
        _currentStoryIndex++;
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      _isNavigating = false;
    }
  }

  /// Navigate to previous story
  ///
  /// Returns true if navigation succeeded, false if at beginning of group.
  /// Use [previousGroup] to move to previous group.
  bool previousStory() {
    if (_isNavigating) return false;
    _isNavigating = true;

    try {
      if (hasPreviousStory) {
        _currentStoryIndex--;
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      _isNavigating = false;
    }
  }

  /// Navigate to next group
  ///
  /// Returns true if navigation succeeded, false if at last group.
  /// Resets story index to 0 when moving to new group.
  bool nextGroup() {
    if (_isNavigating) return false;
    _isNavigating = true;

    try {
      if (hasNextGroup) {
        _currentGroupIndex++;
        _currentStoryIndex = 0;
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      _isNavigating = false;
    }
  }

  /// Navigate to previous group
  ///
  /// Returns true if navigation succeeded, false if at first group.
  /// Sets story index to last story of previous group.
  bool previousGroup() {
    if (_isNavigating) return false;
    _isNavigating = true;

    try {
      if (hasPreviousGroup) {
        _currentGroupIndex--;
        // Go to last story of previous group
        _currentStoryIndex =
            _storyGroups[_currentGroupIndex].stories.length - 1;
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      _isNavigating = false;
    }
  }

  /// Jump to specific group and story
  ///
  /// Validates indices before jumping.
  /// Returns true if navigation succeeded.
  bool jumpTo({required int groupIndex, required int storyIndex}) {
    if (_isNavigating) return false;
    _isNavigating = true;

    try {
      // Validate indices
      if (groupIndex < 0 || groupIndex >= _storyGroups.length) {
        return false;
      }

      final group = _storyGroups[groupIndex];
      if (storyIndex < 0 || storyIndex >= group.stories.length) {
        return false;
      }

      // Update indices
      _currentGroupIndex = groupIndex;
      _currentStoryIndex = storyIndex;
      notifyListeners();
      return true;
    } finally {
      _isNavigating = false;
    }
  }

  /// Restart current group from beginning
  void restartGroup() {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      _currentStoryIndex = 0;
      notifyListeners();
    } finally {
      _isNavigating = false;
    }
  }
}
