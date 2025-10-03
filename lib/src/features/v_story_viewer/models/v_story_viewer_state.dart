import 'package:flutter/foundation.dart';

import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_story_group.dart';

/// Playback state for story viewer
enum VStoryPlaybackState {
  /// Story is currently playing
  playing,

  /// Story is paused
  paused,

  /// Story is stopped/idle
  stopped,

  /// Media is loading
  loading,

  /// Error occurred
  error,
}

/// State model for story viewer
@immutable
class VStoryViewerState {
  const VStoryViewerState({
    required this.playbackState,
    this.currentGroup,
    this.currentStory,
    this.currentGroupIndex,
    this.currentStoryIndex,
    this.error,
  });

  /// Initial/default state
  factory VStoryViewerState.initial() {
    return const VStoryViewerState(
      playbackState: VStoryPlaybackState.stopped,
    );
  }

  /// Loading state
  factory VStoryViewerState.loading() {
    return const VStoryViewerState(
      playbackState: VStoryPlaybackState.loading,
    );
  }

  /// Error state
  factory VStoryViewerState.error(String error) {
    return VStoryViewerState(
      playbackState: VStoryPlaybackState.error,
      error: error,
    );
  }

  /// Current playback state
  final VStoryPlaybackState playbackState;

  /// Current story group being viewed
  final VStoryGroup? currentGroup;

  /// Current story being viewed
  final VBaseStory? currentStory;

  /// Index of current group
  final int? currentGroupIndex;

  /// Index of current story within group
  final int? currentStoryIndex;

  /// Error message if any
  final String? error;

  /// Check if viewer is currently playing
  bool get isPlaying => playbackState == VStoryPlaybackState.playing;

  /// Check if viewer is paused
  bool get isPaused => playbackState == VStoryPlaybackState.paused;

  /// Check if viewer is loading
  bool get isLoading => playbackState == VStoryPlaybackState.loading;

  /// Check if viewer has error
  bool get hasError => playbackState == VStoryPlaybackState.error;

  VStoryViewerState copyWith({
    VStoryPlaybackState? playbackState,
    VStoryGroup? currentGroup,
    VBaseStory? currentStory,
    int? currentGroupIndex,
    int? currentStoryIndex,
    String? error,
  }) {
    return VStoryViewerState(
      playbackState: playbackState ?? this.playbackState,
      currentGroup: currentGroup ?? this.currentGroup,
      currentStory: currentStory ?? this.currentStory,
      currentGroupIndex: currentGroupIndex ?? this.currentGroupIndex,
      currentStoryIndex: currentStoryIndex ?? this.currentStoryIndex,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VStoryViewerState &&
          runtimeType == other.runtimeType &&
          playbackState == other.playbackState &&
          currentGroupIndex == other.currentGroupIndex &&
          currentStoryIndex == other.currentStoryIndex;

  @override
  int get hashCode =>
      playbackState.hashCode ^
      currentGroupIndex.hashCode ^
      currentStoryIndex.hashCode;

  @override
  String toString() {
    return 'VStoryViewerState(state: $playbackState, group: $currentGroupIndex, story: $currentStoryIndex)';
  }
}
