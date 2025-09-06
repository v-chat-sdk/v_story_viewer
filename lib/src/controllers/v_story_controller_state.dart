import '../models/v_story_state.dart';
import '../models/v_story_progress.dart';
import '../models/v_story_list.dart';
import '../models/v_base_story.dart';

/// Represents the complete state of the story controller.
class VStoryControllerState {
  /// The story list being viewed
  final VStoryList storyList;

  /// Current story being displayed
  final VBaseStory? currentStory;

  /// Current story playback state
  final VStoryState storyState;

  /// Overall progress tracking
  final VStoryProgress progress;

  /// Whether the controller is initialized
  final bool isInitialized;


  /// Whether the app is in foreground
  final bool isAppActive;

  /// Current user ID being viewed
  final String? currentUserId;

  /// Current story ID being viewed
  final String? currentStoryId;

  /// Creates a controller state
  const VStoryControllerState({
    required this.storyList,
    this.currentStory,
    this.storyState = const VStoryState(),
    this.progress = const VStoryProgress(storyStates: {}),
    this.isInitialized = false,
    this.isAppActive = true,
    this.currentUserId,
    this.currentStoryId,
  });

  /// Creates an initial state
  factory VStoryControllerState.initial() {
    return VStoryControllerState(storyList: VStoryList(groups: []));
  }

  /// Whether there is a current story
  bool get hasCurrentStory => currentStory != null;

  /// Whether the controller is ready for playback
  bool get isReady => isInitialized && hasCurrentStory;

  /// Whether playback is currently active
  bool get isPlaying => storyState.playbackState == VStoryPlaybackState.playing;

  /// Whether playback is paused
  bool get isPaused => storyState.playbackState == VStoryPlaybackState.paused;

  /// Gets the index of the current story in its group
  int get storyIndex {
    if (currentStoryId == null) return 0;

    final group = storyList.findGroupContainingStory(currentStoryId!);
    if (group == null) return 0;

    return group.stories.indexWhere((story) => story.id == currentStoryId);
  }

  /// Creates a copy with updated fields
  VStoryControllerState copyWith({
    VStoryList? storyList,
    VBaseStory? currentStory,
    VStoryState? storyState,
    VStoryProgress? progress,
    bool? isInitialized,
    bool? isAppActive,
    String? currentUserId,
    String? currentStoryId,
  }) {
    return VStoryControllerState(
      storyList: storyList ?? this.storyList,
      currentStory: currentStory ?? this.currentStory,
      storyState: storyState ?? this.storyState,
      progress: progress ?? this.progress,
      isInitialized: isInitialized ?? this.isInitialized,
      isAppActive: isAppActive ?? this.isAppActive,
      currentUserId: currentUserId ?? this.currentUserId,
      currentStoryId: currentStoryId ?? this.currentStoryId,
    );
  }

  /// Updates the current story and resets progress
  VStoryControllerState updateCurrentStory(VBaseStory story, {String? userId}) {
    return copyWith(
      currentStory: story,
      currentStoryId: story.id,
      currentUserId: userId,
      storyState: VStoryState.initial(), // Reset state for new story
    );
  }

  /// Updates the story state
  VStoryControllerState updateStoryState(VStoryState newState) {
    // Update progress if story completed
    VStoryProgress updatedProgress = progress;
    if (currentStoryId != null && newState.isFinished) {
      updatedProgress = progress.markAsViewed(currentStoryId!);
    }

    return copyWith(storyState: newState, progress: updatedProgress);
  }


  /// Updates app active state
  VStoryControllerState updateAppActive(bool active) {
    return copyWith(isAppActive: active);
  }

  @override
  String toString() {
    return 'VStoryControllerState('
        'initialized: $isInitialized, '
        'story: $currentStoryId, '
        'state: ${storyState.playbackState}, '
        'progress: ${storyState.progress}'
        ')';
  }
}
