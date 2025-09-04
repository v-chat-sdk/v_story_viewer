/// Represents the current state of a story during playback.
enum VStoryPlaybackState {
  /// Initial state before any loading
  initial,
  
  /// Story is loading (media/content)
  loading,
  
  /// Story is currently playing
  playing,
  
  /// Story is paused
  paused,
  
  /// Story has completed playback
  completed,
  
  /// Story has encountered an error
  error,
}

/// Contains the complete state information for a story.
class VStoryState {
  /// Current playback state
  final VStoryPlaybackState playbackState;
  
  /// Progress value between 0.0 and 1.0
  final double progress;
  
  /// Duration of the current story
  final Duration duration;
  
  /// Elapsed time for the current story
  final Duration elapsed;
  
  /// Whether the story is buffering (for video/network content)
  final bool isBuffering;
  
  /// Error message if state is error
  final String? errorMessage;
  
  /// Whether the story has been viewed
  final bool isViewed;
  
  /// Whether the story is muted (for video stories)
  final bool isMuted;
  
  /// Creates a story state
  const VStoryState({
    this.playbackState = VStoryPlaybackState.initial,
    this.progress = 0.0,
    this.duration = Duration.zero,
    this.elapsed = Duration.zero,
    this.isBuffering = false,
    this.errorMessage,
    this.isViewed = false,
    this.isMuted = false,
  });
  
  /// Creates an initial state
  factory VStoryState.initial() {
    return const VStoryState();
  }
  
  /// Creates a loading state
  factory VStoryState.loading() {
    return const VStoryState(
      playbackState: VStoryPlaybackState.loading,
      isBuffering: true,
    );
  }
  
  /// Creates a playing state
  factory VStoryState.playing({
    required Duration duration,
    Duration elapsed = Duration.zero,
    double progress = 0.0,
    bool isMuted = false,
  }) {
    return VStoryState(
      playbackState: VStoryPlaybackState.playing,
      duration: duration,
      elapsed: elapsed,
      progress: progress,
      isMuted: isMuted,
    );
  }
  
  /// Creates a paused state
  factory VStoryState.paused({
    required Duration duration,
    required Duration elapsed,
    required double progress,
    bool isMuted = false,
  }) {
    return VStoryState(
      playbackState: VStoryPlaybackState.paused,
      duration: duration,
      elapsed: elapsed,
      progress: progress,
      isMuted: isMuted,
    );
  }
  
  /// Creates a completed state
  factory VStoryState.completed({
    required Duration duration,
  }) {
    return VStoryState(
      playbackState: VStoryPlaybackState.completed,
      duration: duration,
      elapsed: duration,
      progress: 1.0,
      isViewed: true,
    );
  }
  
  /// Creates an error state
  factory VStoryState.error(String message) {
    return VStoryState(
      playbackState: VStoryPlaybackState.error,
      errorMessage: message,
    );
  }
  
  /// Whether the story is currently active (playing or paused)
  bool get isActive =>
      playbackState == VStoryPlaybackState.playing ||
      playbackState == VStoryPlaybackState.paused;
  
  /// Whether the story can be played
  bool get canPlay =>
      playbackState != VStoryPlaybackState.playing &&
      playbackState != VStoryPlaybackState.error;
  
  /// Whether the story can be paused
  bool get canPause => playbackState == VStoryPlaybackState.playing;
  
  /// Whether the story has finished
  bool get isFinished => playbackState == VStoryPlaybackState.completed;
  
  /// Whether the story has an error
  bool get hasError => playbackState == VStoryPlaybackState.error;
  
  /// Whether the story is loading
  bool get isLoading => playbackState == VStoryPlaybackState.loading;
  
  /// Whether the story is currently playing
  bool get isPlaying => playbackState == VStoryPlaybackState.playing;
  
  /// Whether the story is currently paused
  bool get isPaused => playbackState == VStoryPlaybackState.paused;
  
  /// Gets remaining time for the story
  Duration get remaining => duration - elapsed;
  
  /// Creates a copy with updated fields
  VStoryState copyWith({
    VStoryPlaybackState? playbackState,
    double? progress,
    Duration? duration,
    Duration? elapsed,
    bool? isBuffering,
    String? errorMessage,
    bool? isViewed,
    bool? isMuted,
  }) {
    return VStoryState(
      playbackState: playbackState ?? this.playbackState,
      progress: progress ?? this.progress,
      duration: duration ?? this.duration,
      elapsed: elapsed ?? this.elapsed,
      isBuffering: isBuffering ?? this.isBuffering,
      errorMessage: errorMessage ?? this.errorMessage,
      isViewed: isViewed ?? this.isViewed,
      isMuted: isMuted ?? this.isMuted,
    );
  }
  
  /// Updates progress based on elapsed time
  VStoryState updateProgress(Duration elapsed) {
    if (duration == Duration.zero) return this;
    
    final progress = (elapsed.inMilliseconds / duration.inMilliseconds)
        .clamp(0.0, 1.0);
    
    return copyWith(
      elapsed: elapsed,
      progress: progress,
    );
  }
  
  /// Transitions to loading state
  VStoryState toLoading() {
    return copyWith(
      playbackState: VStoryPlaybackState.loading,
      isBuffering: true,
      progress: 0.0,
      elapsed: Duration.zero,
    );
  }
  
  /// Transitions to playing state
  VStoryState toPlaying({Duration? duration}) {
    return copyWith(
      playbackState: VStoryPlaybackState.playing,
      isBuffering: false,
      duration: duration ?? this.duration,
    );
  }
  
  /// Transitions to paused state
  VStoryState toPaused() {
    return copyWith(
      playbackState: VStoryPlaybackState.paused,
    );
  }
  
  /// Transitions to completed state
  VStoryState toCompleted() {
    return copyWith(
      playbackState: VStoryPlaybackState.completed,
      progress: 1.0,
      elapsed: duration,
      isViewed: true,
    );
  }
  
  /// Transitions to error state
  VStoryState toError(String message) {
    return copyWith(
      playbackState: VStoryPlaybackState.error,
      errorMessage: message,
      isBuffering: false,
    );
  }
  
  /// Resets the state to initial
  VStoryState reset() {
    return VStoryState.initial();
  }
  
  @override
  String toString() {
    return 'VStoryState('
        'state: $playbackState, '
        'progress: ${(progress * 100).toStringAsFixed(1)}%, '
        'elapsed: ${elapsed.inSeconds}s/${duration.inSeconds}s'
        ')';
  }
}