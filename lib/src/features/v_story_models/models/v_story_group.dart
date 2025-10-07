import 'package:flutter/foundation.dart';

import '../../../core/models/v_story_result.dart';
import '../../v_error_handling/models/v_story_error.dart';
import 'v_base_story.dart';
import 'v_story_user.dart';

/// Story group model representing a collection of stories from a single user
@immutable
class VStoryGroup {
  VStoryGroup({required this.user, required this.stories, this.metadata})
    : assert(stories.isNotEmpty, 'Stories list cannot be empty');

  /// User who owns this story group
  final VStoryUser user;

  /// List of stories in this group
  final List<VBaseStory> stories;

  /// Additional group metadata
  final Map<String, dynamic>? metadata;

  /// Get the count of unviewed stories in this group
  int get unviewedCount => stories.where((story) => !story.isViewed).length;

  String get groupId => user.id;

  /// Get the count of viewed stories in this group
  int get viewedCount => stories.where((story) => story.isViewed).length;

  /// Check if this group has any unviewed stories
  bool get hasUnviewedStories => unviewedCount > 0;

  /// Get the first unviewed story index, or 0 if all are viewed
  int get firstUnviewedIndex {
    final index = stories.indexWhere((story) => !story.isViewed);
    return index != -1 ? index : 0;
  }

  /// Get story at index safely using Result pattern
  VStoryResult<VBaseStory> storyAt(int index) {
    if (index < 0 || index >= stories.length) {
      return VStoryFailure(
        VStoryError.indexOutOfBounds(
          'Story index $index is out of bounds. Valid range: 0-${stories.length - 1}',
        ),
      );
    }
    return VStorySuccess(stories[index]);
  }

  /// Get story at index (legacy nullable method for backward compatibility)
  @Deprecated('Use storyAt(index) which returns VStoryResult instead')
  VBaseStory? storyAtOrNull(int index) =>
      index >= 0 && index < stories.length ? stories[index] : null;

  /// Get index of story
  int indexOf(VBaseStory story) => stories.indexOf(story);

  /// Find story by ID using Result pattern
  VStoryResult<VBaseStory> findStoryById(String storyId) {
    try {
      final story = stories.firstWhere((s) => s.id == storyId);
      return VStorySuccess(story);
    } catch (e) {
      return VStoryFailure(
        VStoryError.storyNotFound(
          'Story with ID "$storyId" not found in group "${user.id}"',
        ),
      );
    }
  }

  /// Get story by ID (legacy nullable method for backward compatibility)
  @Deprecated('Use findStoryById(storyId) which returns VStoryResult instead')
  VBaseStory? getStoryById(String storyId) {
    try {
      return stories.firstWhere((s) => s.id == storyId);
    } catch (e) {
      return null;
    }
  }

  /// Get the first unviewed story, or the first story if all are viewed
  VBaseStory get firstUnviewedStory => stories[firstUnviewedIndex];

  VStoryGroup copyWith({
    VStoryUser? user,
    List<VBaseStory>? stories,
    Map<String, dynamic>? metadata,
  }) {
    return VStoryGroup(
      user: user ?? this.user,
      stories: stories ?? this.stories,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Mark a specific story as viewed using Result pattern
  VStoryResult<VStoryGroup> markStoryAsViewed(String storyId) {
    final storyIndex = stories.indexWhere((s) => s.id == storyId);
    if (storyIndex == -1) {
      return VStoryFailure(
        VStoryError.storyNotFound(
          'Story with ID "$storyId" not found in group "${user.id}"',
        ),
      );
    }

    if (stories[storyIndex].isViewed) {
      // Story already viewed, return current group
      return VStorySuccess(this);
    }

    final updatedStories = List<VBaseStory>.from(stories);
    updatedStories[storyIndex] = stories[storyIndex].copyWith(isViewed: true);
    return VStorySuccess(copyWith(stories: updatedStories));
  }

  /// Mark a specific story as viewed (legacy method for backward compatibility)
  @Deprecated(
    'Use markStoryAsViewed(storyId) which returns VStoryResult instead',
  )
  VStoryGroup markStoryAsViewedLegacy(String storyId) {
    final result = markStoryAsViewed(storyId);
    return result.getOrElse((_) => this);
  }

  /// Mark all stories as viewed
  VStoryGroup markAllAsViewed() {
    final updatedStories = stories.map((story) {
      return story.copyWith(isViewed: true);
    }).toList();
    return copyWith(stories: updatedStories);
  }

  /// Validates the story group for consistency
  VStoryResult<VStoryGroup> validate() {
    // Check for empty stories
    if (stories.isEmpty) {
      return VStoryFailure(
        VStoryError.invalidConfiguration(
          'Story group cannot have empty stories list',
        ),
      );
    }

    // Check for duplicate story IDs
    final storyIds = stories.map((s) => s.id).toSet();
    if (storyIds.length != stories.length) {
      return VStoryFailure(
        VStoryError.invalidConfiguration(
          'Story group contains duplicate story IDs',
        ),
      );
    }

    // Check for null or empty story IDs
    for (final story in stories) {
      if (story.id.isEmpty) {
        return VStoryFailure(
          VStoryError.invalidConfiguration(
            'Story group contains story with empty ID',
          ),
        );
      }
    }

    return VStorySuccess(this);
  }

  /// Gets viewing statistics for this group
  VStoryViewingStats get viewingStats => VStoryViewingStats(
    totalStories: stories.length,
    viewedStories: viewedCount,
    unviewedStories: unviewedCount,
    viewingProgress: viewedCount / stories.length,
  );

  /// Checks if the group is completely viewed
  bool get isCompletelyViewed => unviewedCount == 0;

  /// Checks if the group is completely unviewed
  bool get isCompletelyUnviewed => viewedCount == 0;

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VStoryGroup &&
          runtimeType == other.runtimeType &&
          groupId == other.groupId;

  @override
  int get hashCode => groupId.hashCode;

  @override
  String toString() =>
      'VStoryGroup('
      'id: ${user.id}, '
      'user: ${user.username}, '
      'stories: ${stories.length}, '
      'viewed: $viewedCount, '
      'unviewed: $unviewedCount'
      ')';
}

/// Statistics for story viewing progress
@immutable
class VStoryViewingStats {
  const VStoryViewingStats({
    required this.totalStories,
    required this.viewedStories,
    required this.unviewedStories,
    required this.viewingProgress,
  });

  /// Total number of stories in the group
  final int totalStories;

  /// Number of stories that have been viewed
  final int viewedStories;

  /// Number of stories that haven't been viewed
  final int unviewedStories;

  /// Viewing progress as a value from 0.0 to 1.0
  final double viewingProgress;

  /// Gets viewing progress as a percentage (0-100)
  int get viewingPercentage => (viewingProgress * 100).round();

  /// Checks if viewing is complete
  bool get isComplete => viewingProgress >= 1.0;

  /// Checks if viewing has started
  bool get hasStarted => viewingProgress > 0.0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VStoryViewingStats &&
          totalStories == other.totalStories &&
          viewedStories == other.viewedStories &&
          unviewedStories == other.unviewedStories &&
          viewingProgress == other.viewingProgress;

  @override
  int get hashCode => Object.hash(
    totalStories,
    viewedStories,
    unviewedStories,
    viewingProgress,
  );

  @override
  String toString() =>
      'VStoryViewingStats('
      'total: $totalStories, '
      'viewed: $viewedStories, '
      'unviewed: $unviewedStories, '
      'progress: ${viewingPercentage}%'
      ')';
}
