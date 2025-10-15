import '../../../core/models/v_story_result.dart';
import '../../v_error_handling/models/v_story_error.dart';
import '../models/v_base_story.dart';

/// Service for querying story collections
///
/// Extracts query logic from VStoryGroup model.
class VStoryQueryService {
  const VStoryQueryService();

  /// Get story at index with bounds checking
  VStoryResult<VBaseStory> storyAt(List<VBaseStory> stories, int index) {
    if (index < 0 || index >= stories.length) {
      return VStoryFailure(
        VStoryError.indexOutOfBounds(
          'Index $index out of bounds. Valid: 0-${stories.length - 1}',
        ),
      );
    }
    return VStorySuccess(stories[index]);
  }

  /// Find story by ID
  VStoryResult<VBaseStory> findById(
    List<VBaseStory> stories,
    String storyId,
    String groupId,
  ) {
    try {
      final story = stories.firstWhere((s) => s.id == storyId);
      return VStorySuccess(story);
    } catch (e) {
      return VStoryFailure(
        VStoryError.storyNotFound(
          'Story "$storyId" not found in group "$groupId"',
        ),
      );
    }
  }

  /// Get first unviewed story index
  int firstUnviewedIndex(List<VBaseStory> stories) {
    final index = stories.indexWhere((story) => !story.isViewed);
    return index != -1 ? index : 0;
  }

  /// Count unviewed stories
  int countUnviewed(List<VBaseStory> stories) {
    return stories.where((story) => !story.isViewed).length;
  }

  /// Count viewed stories
  int countViewed(List<VBaseStory> stories) {
    return stories.where((story) => story.isViewed).length;
  }

  /// Check if any story is unviewed
  bool hasUnviewed(List<VBaseStory> stories) {
    return stories.any((story) => !story.isViewed);
  }

  /// Get index of specific story
  int indexOf(List<VBaseStory> stories, VBaseStory story) {
    return stories.indexOf(story);
  }
}
