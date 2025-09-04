import 'dart:async';
import '../models/v_base_story.dart';
import '../models/v_story_group.dart';
import '../models/v_story_list.dart';
import 'v_story_persistence.dart';

/// Manages view states and progress tracking for stories.
/// 
/// This manager coordinates between the persistence layer and
/// the UI layer, handling partial progress tracking, new story
/// indicators, and state synchronization.
class VViewStateManager {
  /// Singleton instance
  static final VViewStateManager _instance = VViewStateManager._internal();
  
  /// Factory constructor returns singleton
  factory VViewStateManager() => _instance;
  
  /// Private constructor
  VViewStateManager._internal();
  
  /// Persistence service
  final VStoryPersistence _persistence = VStoryPersistence();
  
  /// Stream controller for view state changes
  StreamController<ViewStateEvent>? _viewStateController;
  
  /// Stream of view state events
  Stream<ViewStateEvent> get viewStateStream {
    _viewStateController ??= StreamController<ViewStateEvent>.broadcast();
    return _viewStateController!.stream;
  }
  
  /// Cache of viewed story IDs
  Set<String> _viewedStoryIds = {};
  
  /// Cache of story progress
  final Map<String, double> _progressCache = {};
  
  /// Current user viewing stories
  String? _currentUserId;
  
  /// Initialize the view state manager
  Future<void> initialize() async {
    // Ensure stream controller is created
    _viewStateController ??= StreamController<ViewStateEvent>.broadcast();
    await _persistence.initialize();
    await _loadViewedStories();
  }
  
  /// Load viewed stories from persistence
  Future<void> _loadViewedStories() async {
    _viewedStoryIds = await _persistence.getViewedStoryIds();
  }
  
  /// Set current user context
  void setCurrentUser(String userId) {
    _currentUserId = userId;
  }
  
  /// Start viewing a story
  Future<void> startViewing(VBaseStory story) async {
    // Check if already viewed
    final isAlreadyViewed = _viewedStoryIds.contains(story.id);
    
    if (!isAlreadyViewed) {
      // Emit new story viewing event if controller exists and not closed
      if (_viewStateController != null && !_viewStateController!.isClosed) {
        _viewStateController!.add(ViewStateEvent(
          type: ViewStateEventType.newStoryStarted,
          storyId: story.id,
          userId: _currentUserId,
        ));
      }
    }
    
    // Update last viewed timestamp
    await _persistence.updateLastViewed();
  }
  
  /// Update progress for current story
  Future<void> updateProgress(String storyId, double progress) async {
    _progressCache[storyId] = progress;
    
    // Save partial progress
    if (progress > 0 && progress < 1.0) {
      await _persistence.saveProgress(storyId, progress);
    }
    
    // Emit progress update event if controller exists and not closed
    if (_viewStateController != null && !_viewStateController!.isClosed) {
      _viewStateController!.add(ViewStateEvent(
        type: ViewStateEventType.progressUpdated,
        storyId: storyId,
        progress: progress,
        userId: _currentUserId,
      ));
    }
  }
  
  /// Mark story as viewed
  Future<void> markAsViewed(VBaseStory story) async {
    if (_viewedStoryIds.contains(story.id)) {
      return; // Already viewed
    }
    
    // Update local cache
    _viewedStoryIds.add(story.id);
    
    // Persist to storage
    await _persistence.markStoryAsViewed(story.id, userId: _currentUserId);
    
    // Clear any saved progress
    await _persistence.clearProgress(story.id);
    _progressCache.remove(story.id);
    
    // Emit viewed event if controller exists and not closed
    if (_viewStateController != null && !_viewStateController!.isClosed) {
      _viewStateController!.add(ViewStateEvent(
        type: ViewStateEventType.storyViewed,
        storyId: story.id,
        userId: _currentUserId,
      ));
    }
  }
  
  /// Check if story has been viewed
  bool isStoryViewed(String storyId) {
    return _viewedStoryIds.contains(storyId);
  }
  
  /// Get saved progress for a story
  Future<double> getStoryProgress(String storyId) async {
    // Check memory cache first
    if (_progressCache.containsKey(storyId)) {
      return _progressCache[storyId]!;
    }
    
    // Load from persistence
    final progress = await _persistence.getProgress(storyId);
    _progressCache[storyId] = progress;
    return progress;
  }
  
  /// Get unviewed count for a story group
  int getUnviewedCount(VStoryGroup group) {
    int count = 0;
    for (final story in group.stories) {
      if (!isStoryViewed(story.id)) {
        count++;
      }
    }
    return count;
  }
  
  /// Get total unviewed count for story list
  int getTotalUnviewedCount(VStoryList storyList) {
    int count = 0;
    for (final group in storyList.groups) {
      count += getUnviewedCount(group);
    }
    return count;
  }
  
  /// Find first unviewed story in a group
  VBaseStory? findFirstUnviewed(VStoryGroup group) {
    for (final story in group.stories) {
      if (!isStoryViewed(story.id)) {
        return story;
      }
    }
    return null; // All viewed
  }
  
  /// Find first unviewed group in story list
  VStoryGroup? findFirstUnviewedGroup(VStoryList storyList) {
    for (final group in storyList.groups) {
      if (getUnviewedCount(group) > 0) {
        return group;
      }
    }
    return null; // All groups fully viewed
  }
  
  /// Get story sequence with view states
  List<StoryViewState> getStorySequence(VStoryGroup group) {
    final sequence = <StoryViewState>[];
    
    for (final story in group.stories) {
      sequence.add(StoryViewState(
        story: story,
        isViewed: isStoryViewed(story.id),
        progress: _progressCache[story.id] ?? 0.0,
      ));
    }
    
    return sequence;
  }
  
  /// Navigate to next unviewed story
  VBaseStory? getNextUnviewed(VStoryList storyList, String currentStoryId) {
    bool foundCurrent = false;
    
    for (final group in storyList.groups) {
      for (final story in group.stories) {
        if (foundCurrent && !isStoryViewed(story.id)) {
          return story;
        }
        if (story.id == currentStoryId) {
          foundCurrent = true;
        }
      }
    }
    
    return null; // No more unviewed stories
  }
  
  /// Clear all view states
  Future<void> clearAllViewStates() async {
    _viewedStoryIds.clear();
    _progressCache.clear();
    await _persistence.clearAllViewedStories();
    
    // Emit reset event if controller exists and not closed
    if (_viewStateController != null && !_viewStateController!.isClosed) {
      _viewStateController!.add(ViewStateEvent(
        type: ViewStateEventType.allStatesCleared,
      ));
    }
  }
  
  /// Clear view states for a specific user
  Future<void> clearUserViewStates(String userId) async {
    await _persistence.clearUserViewedStories(userId);
    await _loadViewedStories(); // Reload cache
    
    // Emit user states cleared event if controller exists and not closed
    if (_viewStateController != null && !_viewStateController!.isClosed) {
      _viewStateController!.add(ViewStateEvent(
        type: ViewStateEventType.userStatesCleared,
        userId: userId,
      ));
    }
  }
  
  /// Export view state data
  Future<Map<String, dynamic>> exportViewStates() async {
    return await _persistence.exportViewState();
  }
  
  /// Import view state data
  Future<void> importViewStates(Map<String, dynamic> data) async {
    await _persistence.importViewState(data);
    await _loadViewedStories(); // Reload cache
  }
  
  /// Get view statistics
  ViewStatistics getStatistics(VStoryList storyList) {
    int totalStories = 0;
    int viewedStories = 0;
    int partiallyViewed = 0;
    
    for (final group in storyList.groups) {
      for (final story in group.stories) {
        totalStories++;
        
        if (isStoryViewed(story.id)) {
          viewedStories++;
        } else if (_progressCache.containsKey(story.id) &&
            _progressCache[story.id]! > 0) {
          partiallyViewed++;
        }
      }
    }
    
    return ViewStatistics(
      totalStories: totalStories,
      viewedStories: viewedStories,
      partiallyViewed: partiallyViewed,
      unviewedStories: totalStories - viewedStories - partiallyViewed,
      viewPercentage: totalStories > 0 ? viewedStories / totalStories : 0.0,
    );
  }
  
  /// Dispose of resources
  void dispose() {
    _viewStateController?.close();
    _viewStateController = null;
  }
}

/// Event types for view state changes
enum ViewStateEventType {
  /// A new story has started playing
  newStoryStarted,
  
  /// Story progress has been updated
  progressUpdated,
  
  /// Story has been marked as viewed
  storyViewed,
  
  /// All view states have been cleared
  allStatesCleared,
  
  /// User-specific states have been cleared
  userStatesCleared,
}

/// View state event
class ViewStateEvent {
  /// Event type
  final ViewStateEventType type;
  
  /// Story ID (if applicable)
  final String? storyId;
  
  /// User ID (if applicable)
  final String? userId;
  
  /// Progress value (if applicable)
  final double? progress;
  
  /// Timestamp of event
  final DateTime timestamp;
  
  /// Creates a view state event
  ViewStateEvent({
    required this.type,
    this.storyId,
    this.userId,
    this.progress,
  }) : timestamp = DateTime.now();
}

/// Story with its view state
class StoryViewState {
  /// The story
  final VBaseStory story;
  
  /// Whether the story has been viewed
  final bool isViewed;
  
  /// Current progress (0.0 to 1.0)
  final double progress;
  
  /// Creates a story view state
  const StoryViewState({
    required this.story,
    required this.isViewed,
    required this.progress,
  });
  
  /// Whether story is partially viewed
  bool get isPartiallyViewed => progress > 0 && progress < 1.0 && !isViewed;
  
  /// Whether story is new (never viewed)
  bool get isNew => !isViewed && progress == 0;
}

/// Statistics about view states
class ViewStatistics {
  /// Total number of stories
  final int totalStories;
  
  /// Number of viewed stories
  final int viewedStories;
  
  /// Number of partially viewed stories
  final int partiallyViewed;
  
  /// Number of unviewed stories
  final int unviewedStories;
  
  /// Percentage of stories viewed
  final double viewPercentage;
  
  /// Creates view statistics
  const ViewStatistics({
    required this.totalStories,
    required this.viewedStories,
    required this.partiallyViewed,
    required this.unviewedStories,
    required this.viewPercentage,
  });
  
  /// Get formatted percentage string
  String get formattedPercentage => '${(viewPercentage * 100).toStringAsFixed(1)}%';
}