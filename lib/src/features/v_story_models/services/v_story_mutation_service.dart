import '../../../core/models/v_story_result.dart';
import '../../v_error_handling/models/v_story_error.dart';
import '../models/v_base_story.dart';

/// Service for mutating story collections
///
/// Extracts mutation logic from VStoryGroup model.
class VStoryMutationService {
  const VStoryMutationService();

  /// Mark story as viewed by ID
  VStoryResult<List<VBaseStory>> markAsViewed(
    List<VBaseStory> stories,
    String storyId,
    String groupId,
  ) {
    final storyIndex = stories.indexWhere((s) => s.id == storyId);

    if (storyIndex == -1) {
      return VStoryFailure(
        VStoryError.storyNotFound(
          'Story "$storyId" not found in group "$groupId"',
        ),
      );
    }

    if (stories[storyIndex].isViewed) {
      return VStorySuccess(stories);
    }

    final updatedStories = List<VBaseStory>.from(stories);
    updatedStories[storyIndex] = stories[storyIndex].copyWith(isViewed: true);
    return VStorySuccess(updatedStories);
  }

  /// Mark all stories as viewed
  List<VBaseStory> markAllAsViewed(List<VBaseStory> stories) {
    return stories.map((story) => story.copyWith(isViewed: true)).toList();
  }
}
