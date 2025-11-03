import '../../../core/models/v_story_result.dart';
import '../../v_error_handling/models/v_story_error.dart';
import '../models/v_base_story.dart';

/// Unified service for story collection operations
///
/// Consolidates query, mutation, and validation logic for story collections.
class VStoryService {
  const VStoryService();

  // ============================================================================
  // Query Operations
  // ============================================================================

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

  // ============================================================================
  // Mutation Operations
  // ============================================================================

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

  // ============================================================================
  // Validation Operations
  // ============================================================================

  /// Validate story list for consistency
  VStoryResult<void> validate(List<VBaseStory> stories) {
    final emptyCheck = _checkNotEmpty(stories);
    if (emptyCheck != null) return emptyCheck;

    final duplicateCheck = _checkNoDuplicates(stories);
    if (duplicateCheck != null) return duplicateCheck;

    final idCheck = _checkValidIds(stories);
    if (idCheck != null) return idCheck;

    return VStorySuccess(null);
  }

  VStoryResult<void>? _checkNotEmpty(List<VBaseStory> stories) {
    if (stories.isEmpty) {
      return VStoryFailure(
        VStoryError.invalidConfiguration(
          'Story group cannot have empty stories list',
        ),
      );
    }
    return null;
  }

  VStoryResult<void>? _checkNoDuplicates(List<VBaseStory> stories) {
    final storyIds = stories.map((s) => s.id).toSet();
    if (storyIds.length != stories.length) {
      return VStoryFailure(
        VStoryError.invalidConfiguration(
          'Story group contains duplicate story IDs',
        ),
      );
    }
    return null;
  }

  VStoryResult<void>? _checkValidIds(List<VBaseStory> stories) {
    for (final story in stories) {
      if (story.id.isEmpty) {
        return VStoryFailure(
          VStoryError.invalidConfiguration(
            'Story group contains story with empty ID',
          ),
        );
      }
    }
    return null;
  }
}
