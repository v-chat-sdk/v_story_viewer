import 'v_base_story.dart';
import 'v_story_group.dart';

/// Configuration options for story list behavior
class VStoryListConfig {
  /// Whether to show viewed stories
  final bool showViewedStories;
  
  /// Whether to sort groups by unviewed count
  final bool sortByUnviewed;
  
  /// Whether to loop back to first group after last
  final bool loopGroups;
  
  /// Whether to auto-advance to next group when current group completes
  final bool autoAdvanceToNextGroup;
  
  /// Creates story list configuration
  const VStoryListConfig({
    this.showViewedStories = true,
    this.sortByUnviewed = true,
    this.loopGroups = false,
    this.autoAdvanceToNextGroup = true,
  });
}

/// Represents a collection of story groups from multiple users.
/// 
/// This is the top-level container for managing all stories
/// in the viewer, providing navigation and state management
/// across different user groups.
class VStoryList {
  /// List of story groups from different users
  final List<VStoryGroup> groups;
  
  /// Configuration for list behavior
  final VStoryListConfig config;
  
  /// Creates a story list with multiple user groups
  const VStoryList({
    required this.groups,
    this.config = const VStoryListConfig(),
  }) : assert(groups.length > 0, 'Story list must contain at least one group');
  
  /// Total number of groups in the list
  int get groupCount => groups.length;
  
  /// Total number of stories across all groups
  int get totalStoryCount {
    return groups.fold(0, (sum, group) => sum + group.storyCount);
  }
  
  /// Total number of unviewed stories across all groups
  int get totalUnviewedCount {
    return groups.fold(0, (sum, group) => sum + group.unviewedCount);
  }
  
  /// Whether there are any unviewed stories
  bool get hasUnviewed => totalUnviewedCount > 0;
  
  /// Whether all stories have been viewed
  bool get allViewed => totalUnviewedCount == 0;
  
  /// Gets groups sorted according to configuration
  List<VStoryGroup> get sortedGroups {
    if (!config.sortByUnviewed) return groups;
    
    // Sort groups with unviewed stories first
    final sorted = List<VStoryGroup>.from(groups);
    sorted.sort((a, b) {
      // Groups with unviewed stories come first
      if (a.hasUnviewed && !b.hasUnviewed) return -1;
      if (!a.hasUnviewed && b.hasUnviewed) return 1;
      // Within each category, maintain original order
      return 0;
    });
    return sorted;
  }
  
  /// Gets visible groups based on configuration
  List<VStoryGroup> get visibleGroups {
    if (config.showViewedStories) {
      return sortedGroups;
    }
    return sortedGroups.where((group) => group.hasUnviewed).toList();
  }
  
  /// Gets a group by user ID
  VStoryGroup? getGroupByUserId(String userId) {
    try {
      return groups.firstWhere((group) => group.user.id == userId);
    } catch (e) {
      return null;
    }
  }
  
  /// Gets the index of a group by user ID
  int getGroupIndex(String userId) {
    return groups.indexWhere((group) => group.user.id == userId);
  }
  
  /// Gets all stories as a flat list
  List<VBaseStory> getAllStories() {
    return groups.expand((group) => group.stories).toList();
  }
  
  /// Gets the first group with unviewed stories
  VStoryGroup? get firstUnviewedGroup {
    try {
      return groups.firstWhere(
        (group) => group.hasUnviewed,
        orElse: () => groups.first,
      );
    } catch (e) {
      return groups.isNotEmpty ? groups.first : null;
    }
  }
  
  /// Gets the next group after the specified user ID
  VStoryGroup? getNextGroup(String currentUserId) {
    final currentIndex = getGroupIndex(currentUserId);
    if (currentIndex >= 0) {
      if (currentIndex < groups.length - 1) {
        return groups[currentIndex + 1];
      } else if (config.loopGroups && groups.isNotEmpty) {
        return groups.first;
      }
    }
    return null;
  }
  
  /// Gets the previous group before the specified user ID
  VStoryGroup? getPreviousGroup(String currentUserId) {
    final currentIndex = getGroupIndex(currentUserId);
    if (currentIndex > 0) {
      return groups[currentIndex - 1];
    } else if (currentIndex == 0 && config.loopGroups && groups.isNotEmpty) {
      return groups.last;
    }
    return null;
  }
  
  /// Finds a story by its ID across all groups
  VBaseStory? findStoryById(String storyId) {
    for (final group in groups) {
      final story = group.getStoryById(storyId);
      if (story != null) return story;
    }
    return null;
  }
  
  /// Finds which group contains a specific story ID
  VStoryGroup? findGroupContainingStory(String storyId) {
    for (final group in groups) {
      if (group.getStoryById(storyId) != null) {
        return group;
      }
    }
    return null;
  }
  
  /// Creates a copy of this list with updated groups
  VStoryList copyWith({
    List<VStoryGroup>? groups,
    VStoryListConfig? config,
  }) {
    return VStoryList(
      groups: groups ?? this.groups,
      config: config ?? this.config,
    );
  }
  
  /// Updates a specific group in the list
  VStoryList updateGroup(String userId, VStoryGroup updatedGroup) {
    final updatedGroups = groups.map((group) {
      return group.user.id == userId ? updatedGroup : group;
    }).toList();
    
    return copyWith(groups: updatedGroups);
  }
  
  /// Marks a story as viewed
  VStoryList markStoryAsViewed(String storyId) {
    final updatedGroups = groups.map((group) {
      final story = group.getStoryById(storyId);
      if (story != null) {
        return group.markStoryAsViewed(storyId);
      }
      return group;
    }).toList();
    
    return copyWith(groups: updatedGroups);
  }
  
  /// Marks all stories in a group as viewed
  VStoryList markGroupAsViewed(String userId) {
    final updatedGroups = groups.map((group) {
      return group.user.id == userId ? group.markAllAsViewed() : group;
    }).toList();
    
    return copyWith(groups: updatedGroups);
  }
  
  /// Marks all stories as viewed
  VStoryList markAllAsViewed() {
    final updatedGroups = groups.map((group) => group.markAllAsViewed()).toList();
    return copyWith(groups: updatedGroups);
  }
  
  /// Gets statistics about the story list
  Map<String, dynamic> getStatistics() {
    return {
      'totalGroups': groupCount,
      'totalStories': totalStoryCount,
      'totalUnviewed': totalUnviewedCount,
      'viewedPercentage': totalStoryCount > 0
          ? ((totalStoryCount - totalUnviewedCount) / totalStoryCount * 100)
              .toStringAsFixed(1)
          : '0.0',
      'groupsWithUnviewed': groups.where((g) => g.hasUnviewed).length,
    };
  }
  
  @override
  String toString() => 'VStoryList(groups: $groupCount, stories: $totalStoryCount)';
}