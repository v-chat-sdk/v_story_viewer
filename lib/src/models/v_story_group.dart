import 'v_base_story.dart';
import 'v_story_user.dart';

/// Represents a group of stories from a single user.
/// 
/// This model groups multiple stories by user and provides
/// navigation helpers for finding unviewed content and
/// tracking progress through story sequences.
class VStoryGroup {
  /// The user who created these stories
  final VStoryUser user;
  
  /// List of stories from this user
  final List<VBaseStory> stories;
  
  /// Creates a story group for a specific user
  const VStoryGroup({
    required this.user,
    required this.stories,
  }) : assert(stories.length > 0, 'A story group must contain at least one story');
  
  /// Number of unviewed stories in this group
  int get unviewedCount => stories.where((story) => !story.isViewed).length;
  
  /// Whether this group has any unviewed stories
  bool get hasUnviewed => unviewedCount > 0;
  
  /// Total number of stories in this group
  int get storyCount => stories.length;
  
  /// Whether all stories in this group have been viewed
  bool get allViewed => unviewedCount == 0;
  
  /// Gets the first unviewed story, or the first story if all are viewed
  VBaseStory? get firstUnviewed {
    try {
      return stories.firstWhere(
        (story) => !story.isViewed,
        orElse: () => stories.first,
      );
    } catch (e) {
      return stories.isNotEmpty ? stories.first : null;
    }
  }
  
  /// Gets the index of the first unviewed story
  int get firstUnviewedIndex {
    final index = stories.indexWhere((story) => !story.isViewed);
    return index >= 0 ? index : 0;
  }
  
  /// Gets a story by its ID
  VBaseStory? getStoryById(String storyId) {
    try {
      return stories.firstWhere((story) => story.id == storyId);
    } catch (e) {
      return null;
    }
  }
  
  /// Gets the index of a story by its ID
  int getStoryIndex(String storyId) {
    return stories.indexWhere((story) => story.id == storyId);
  }
  
  /// Gets the next story after the specified story ID
  VBaseStory? getNextStory(String currentStoryId) {
    final currentIndex = getStoryIndex(currentStoryId);
    if (currentIndex >= 0 && currentIndex < stories.length - 1) {
      return stories[currentIndex + 1];
    }
    return null;
  }
  
  /// Gets the previous story before the specified story ID
  VBaseStory? getPreviousStory(String currentStoryId) {
    final currentIndex = getStoryIndex(currentStoryId);
    if (currentIndex > 0) {
      return stories[currentIndex - 1];
    }
    return null;
  }
  
  /// Whether this is the last story in the group
  bool isLastStory(String storyId) {
    final index = getStoryIndex(storyId);
    return index == stories.length - 1;
  }
  
  /// Whether this is the first story in the group
  bool isFirstStory(String storyId) {
    final index = getStoryIndex(storyId);
    return index == 0;
  }
  
  /// Creates a copy of this group with updated stories
  VStoryGroup copyWith({
    VStoryUser? user,
    List<VBaseStory>? stories,
  }) {
    return VStoryGroup(
      user: user ?? this.user,
      stories: stories ?? this.stories,
    );
  }
  
  /// Updates a specific story in the group
  VStoryGroup updateStory(String storyId, VBaseStory updatedStory) {
    final updatedStories = stories.map((story) {
      return story.id == storyId ? updatedStory : story;
    }).toList();
    
    return copyWith(stories: updatedStories);
  }
  
  /// Marks a story as viewed
  VStoryGroup markStoryAsViewed(String storyId) {
    final updatedStories = stories.map((story) {
      if (story.id == storyId && !story.isViewed) {
        return story.copyWith(viewedAt: DateTime.now());
      }
      return story;
    }).toList();
    
    return copyWith(stories: updatedStories);
  }
  
  /// Marks all stories as viewed
  VStoryGroup markAllAsViewed() {
    final now = DateTime.now();
    final updatedStories = stories.map((story) {
      return story.isViewed ? story : story.copyWith(viewedAt: now);
    }).toList();
    
    return copyWith(stories: updatedStories);
  }
  
  @override
  String toString() => 'VStoryGroup(user: ${user.name}, stories: ${stories.length})';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VStoryGroup && other.user.id == user.id;
  }
  
  @override
  int get hashCode => user.id.hashCode;
}