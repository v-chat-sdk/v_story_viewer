import 'package:flutter/foundation.dart';

import '../../../core/models/v_story_result.dart';
import '../services/v_story_mutation_service.dart';
import '../services/v_story_query_service.dart';
import '../services/v_story_validation_service.dart';
import 'v_base_story.dart';
import 'v_story_user.dart';

/// Story group model representing a collection of stories from a single user
///
/// Delegates business logic to specialized services for better maintainability.
@immutable
class VStoryGroup {
  VStoryGroup({required this.user, required this.stories, this.metadata})
      : assert(stories.isNotEmpty, 'Stories list cannot be empty');

  final VStoryUser user;
  final List<VBaseStory> stories;
  final Map<String, dynamic>? metadata;

  static const _queryService = VStoryQueryService();
  static const _mutationService = VStoryMutationService();
  static const _validationService = VStoryValidationService();

  String get groupId => user.id;

  int get unviewedCount => _queryService.countUnviewed(stories);

  int get viewedCount => _queryService.countViewed(stories);

  bool get hasUnviewedStories => _queryService.hasUnviewed(stories);

  int get firstUnviewedIndex => _queryService.firstUnviewedIndex(stories);

  VBaseStory get firstUnviewedStory => stories[firstUnviewedIndex];

  bool get isCompletelyViewed => unviewedCount == 0;

  bool get isCompletelyUnviewed => viewedCount == 0;

  VStoryResult<VBaseStory> storyAt(int index) {
    return _queryService.storyAt(stories, index);
  }

  @Deprecated('Use storyAt(index) which returns VStoryResult instead')
  VBaseStory? storyAtOrNull(int index) {
    return index >= 0 && index < stories.length ? stories[index] : null;
  }

  int indexOf(VBaseStory story) => _queryService.indexOf(stories, story);

  VStoryResult<VBaseStory> findStoryById(String storyId) {
    return _queryService.findById(stories, storyId, groupId);
  }

  @Deprecated('Use findStoryById(storyId) which returns VStoryResult instead')
  VBaseStory? getStoryById(String storyId) {
    final result = findStoryById(storyId);
    return result.valueOrNull;
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
    final result = _mutationService.markAsViewed(stories, storyId, groupId);
    return result.map((updatedStories) => copyWith(stories: updatedStories));
  }

  @Deprecated(
    'Use markStoryAsViewed(storyId) which returns VStoryResult instead',
  )
  VStoryGroup markStoryAsViewedLegacy(String storyId) {
    return markStoryAsViewed(storyId).getOrElse((_) => this);
  }

  VStoryGroup markAllAsViewed() {
    final updatedStories = _mutationService.markAllAsViewed(stories);
    return copyWith(stories: updatedStories);
  }

  VStoryResult<VStoryGroup> validate() {
    final validationResult = _validationService.validate(stories);
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
