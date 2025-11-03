import 'package:flutter/foundation.dart';

import '../../../core/models/v_story_result.dart';
import '../services/v_story_service.dart';
import 'v_base_story.dart';
import 'v_story_user.dart';

/// Story group model representing a collection of stories from a single user
///
/// Delegates business logic to the unified VStoryService for better maintainability.
@immutable
class VStoryGroup {
  VStoryGroup({required this.user, required this.stories, this.metadata})
      : assert(stories.isNotEmpty, 'Stories list cannot be empty');

  final VStoryUser user;
  final List<VBaseStory> stories;
  final Map<String, dynamic>? metadata;

  static const _service = VStoryService();

  String get groupId => user.id;

  int get unviewedCount => _service.countUnviewed(stories);

  int get viewedCount => _service.countViewed(stories);

  bool get hasUnviewedStories => _service.hasUnviewed(stories);

  int get firstUnviewedIndex => _service.firstUnviewedIndex(stories);

  VBaseStory get firstUnviewedStory => stories[firstUnviewedIndex];

  bool get isCompletelyViewed => unviewedCount == 0;

  bool get isCompletelyUnviewed => viewedCount == 0;

  VStoryResult<VBaseStory> storyAt(int index) {
    return _service.storyAt(stories, index);
  }

  int indexOf(VBaseStory story) => _service.indexOf(stories, story);

  VStoryResult<VBaseStory> findStoryById(String storyId) {
    return _service.findById(stories, storyId, groupId);
  }

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

  VStoryResult<VStoryGroup> markStoryAsViewed(String storyId) {
    final result = _service.markAsViewed(stories, storyId, groupId);
    return result.map((updatedStories) => copyWith(stories: updatedStories));
  }

  VStoryGroup markAllAsViewed() {
    final updatedStories = _service.markAllAsViewed(stories);
    return copyWith(stories: updatedStories);
  }

  VStoryResult<VStoryGroup> validate() {
    final validationResult = _service.validate(stories);
    return validationResult.map((_) => this);
  }

  VStoryViewingStats get viewingStats => VStoryViewingStats(
        totalStories: stories.length,
        viewedStories: viewedCount,
        unviewedStories: unviewedCount,
        viewingProgress: viewedCount / stories.length,
      );

  @override
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

  final int totalStories;
  final int viewedStories;
  final int unviewedStories;
  final double viewingProgress;

  int get viewingPercentage => (viewingProgress * 100).round();

  bool get isComplete => viewingProgress >= 1.0;

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
      'progress: ${viewingPercentage}%)';
}
