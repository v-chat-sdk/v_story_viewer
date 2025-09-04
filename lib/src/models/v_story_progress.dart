import 'v_story_state.dart';

/// Tracks progress across multiple stories in a viewing session.
class VStoryProgress {
  /// Map of story ID to its current state
  final Map<String, VStoryState> storyStates;
  
  /// ID of the currently active story
  final String? currentStoryId;
  
  /// ID of the current user/group
  final String? currentUserId;
  
  /// Total number of stories
  final int totalStories;
  
  /// Number of viewed stories
  final int viewedStories;
  
  /// Creates a story progress tracker
  const VStoryProgress({
    required this.storyStates,
    this.currentStoryId,
    this.currentUserId,
    this.totalStories = 0,
    this.viewedStories = 0,
  });
  
  /// Creates an empty progress tracker
  factory VStoryProgress.empty() {
    return const VStoryProgress(
      storyStates: {},
      totalStories: 0,
      viewedStories: 0,
    );
  }
  
  /// Gets the current story state
  VStoryState? get currentState {
    if (currentStoryId == null) return null;
    return storyStates[currentStoryId];
  }
  
  /// Whether all stories have been viewed
  bool get allViewed => viewedStories >= totalStories && totalStories > 0;
  
  /// Percentage of stories viewed (0.0 to 1.0)
  double get viewProgress {
    if (totalStories == 0) return 0.0;
    return (viewedStories / totalStories).clamp(0.0, 1.0);
  }
  
  /// Updates the state for a specific story
  VStoryProgress updateStoryState(String storyId, VStoryState state) {
    final newStates = Map<String, VStoryState>.from(storyStates);
    final oldState = newStates[storyId];
    newStates[storyId] = state;
    
    // Update viewed count if story just completed
    int newViewedCount = viewedStories;
    if (state.isViewed && !(oldState?.isViewed ?? false)) {
      newViewedCount++;
    }
    
    return VStoryProgress(
      storyStates: newStates,
      currentStoryId: currentStoryId,
      currentUserId: currentUserId,
      totalStories: totalStories,
      viewedStories: newViewedCount,
    );
  }
  
  /// Sets the current story
  VStoryProgress setCurrentStory(String storyId, {String? userId}) {
    return VStoryProgress(
      storyStates: storyStates,
      currentStoryId: storyId,
      currentUserId: userId ?? currentUserId,
      totalStories: totalStories,
      viewedStories: viewedStories,
    );
  }
  
  /// Marks a story as viewed
  VStoryProgress markAsViewed(String storyId) {
    final state = storyStates[storyId];
    if (state == null || state.isViewed) return this;
    
    return updateStoryState(
      storyId,
      state.copyWith(isViewed: true),
    );
  }
  
  /// Resets progress for a specific story
  VStoryProgress resetStory(String storyId) {
    final newStates = Map<String, VStoryState>.from(storyStates);
    newStates[storyId] = VStoryState.initial();
    
    return VStoryProgress(
      storyStates: newStates,
      currentStoryId: currentStoryId,
      currentUserId: currentUserId,
      totalStories: totalStories,
      viewedStories: viewedStories,
    );
  }
  
  /// Resets all progress
  VStoryProgress resetAll() {
    return VStoryProgress(
      storyStates: {},
      currentStoryId: null,
      currentUserId: null,
      totalStories: totalStories,
      viewedStories: 0,
    );
  }
  
  /// Creates a copy with updated fields
  VStoryProgress copyWith({
    Map<String, VStoryState>? storyStates,
    String? currentStoryId,
    String? currentUserId,
    int? totalStories,
    int? viewedStories,
  }) {
    return VStoryProgress(
      storyStates: storyStates ?? this.storyStates,
      currentStoryId: currentStoryId ?? this.currentStoryId,
      currentUserId: currentUserId ?? this.currentUserId,
      totalStories: totalStories ?? this.totalStories,
      viewedStories: viewedStories ?? this.viewedStories,
    );
  }
  
  /// Gets statistics about the progress
  Map<String, dynamic> getStatistics() {
    int playing = 0;
    int paused = 0;
    int completed = 0;
    int errors = 0;
    
    for (final state in storyStates.values) {
      switch (state.playbackState) {
        case VStoryPlaybackState.playing:
          playing++;
          break;
        case VStoryPlaybackState.paused:
          paused++;
          break;
        case VStoryPlaybackState.completed:
          completed++;
          break;
        case VStoryPlaybackState.error:
          errors++;
          break;
        default:
          break;
      }
    }
    
    return {
      'total': totalStories,
      'viewed': viewedStories,
      'viewProgress': '${(viewProgress * 100).toStringAsFixed(1)}%',
      'playing': playing,
      'paused': paused,
      'completed': completed,
      'errors': errors,
      'currentStory': currentStoryId,
      'currentUser': currentUserId,
    };
  }
  
  @override
  String toString() {
    return 'VStoryProgress('
        'current: $currentStoryId, '
        'viewed: $viewedStories/$totalStories'
        ')';
  }
}