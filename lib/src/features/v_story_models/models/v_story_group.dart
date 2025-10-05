import 'package:flutter/foundation.dart';

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

  /// Get story at index safely
  VBaseStory? storyAt(int index) =>
      index >= 0 && index < stories.length ? stories[index] : null;


  /// Get index of story
  int indexOf(VBaseStory story) => stories.indexOf(story);

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

  /// Mark a specific story as viewed
  VStoryGroup markStoryAsViewed(String storyId) {
    final storyIndex = stories.indexWhere((s) => s.id == storyId);
    if (storyIndex == -1 || stories[storyIndex].isViewed) {
      return this;
    }
    final updatedStories = List<VBaseStory>.from(stories);
    updatedStories[storyIndex] = stories[storyIndex].copyWith(isViewed: true);
    return copyWith(stories: updatedStories);
  }

  /// Mark all stories as viewed
  VStoryGroup markAllAsViewed() {
    final updatedStories = stories.map((story) {
      return story.copyWith(isViewed: true);
    }).toList();
    return copyWith(stories: updatedStories);
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VStoryGroup &&
          runtimeType == other.runtimeType &&
          groupId == other.groupId;

  @override
  int get hashCode => groupId.hashCode;

  @override
  String toString() =>
      'VStoryGroup(id: ${user.id}, user: ${user.username}, stories: ${stories.length})';
}
