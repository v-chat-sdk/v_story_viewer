/// Comprehensive state machine for story viewer state management
///
/// Provides type-safe state transitions with validation and side effects
/// for better control flow and debugging capabilities.
library v_story_state_machine;

import 'package:flutter/foundation.dart';

import '../../features/v_error_handling/models/v_story_error.dart';
import '../constants/v_story_constants.dart';
import 'v_story_navigation.dart';

/// Base sealed class for all story viewer states
///
/// Provides compile-time exhaustiveness checking and type safety
/// for state-dependent operations.
sealed class VStoryViewerState {
  const VStoryViewerState();

  /// Whether the viewer can accept user navigation gestures
  bool get canNavigate => switch (this) {
    VIdleState() => true,
    VPlayingState() => true,
    VPausedState() => true,
    VLoadingState() => false,
    VNavigatingState() => false,
    VErrorState() => false,
    VDisposedState() => false,
  };

  /// Whether media content is currently playing
  bool get isPlaying => switch (this) {
    VPlayingState() => true,
    _ => false,
  };

  /// Whether the viewer is in a loading state
  bool get isLoading => switch (this) {
    VLoadingState() => true,
    _ => false,
  };

  /// Whether the viewer is paused
  bool get isPaused => switch (this) {
    VPausedState() => true,
    _ => false,
  };

  /// Whether the viewer has an error
  bool get hasError => switch (this) {
    VErrorState() => true,
    _ => false,
  };

  /// Whether the viewer is disposed
  bool get isDisposed => switch (this) {
    VDisposedState() => true,
    _ => false,
  };

  /// Gets the current story position if available
  VStoryPosition? get currentPosition => switch (this) {
    VIdleState(position: final pos) => pos,
    VPlayingState(position: final pos) => pos,
    VPausedState(position: final pos) => pos,
    VLoadingState(position: final pos) => pos,
    VNavigatingState(position: final pos) => pos,
    _ => null,
  };

  /// Gets the current error if in error state
  VStoryError? get currentError => switch (this) {
    VErrorState(error: final error) => error,
    _ => null,
  };

  /// Gets human-readable state description for debugging
  String get debugDescription => switch (this) {
    VIdleState() => 'Idle (ready for interaction)',
    VPlayingState() => 'Playing story content',
    VPausedState() => 'Paused by user interaction',
    VLoadingState() => 'Loading media content',
    VNavigatingState() => 'Transitioning between stories',
    VErrorState() => 'Error occurred',
    VDisposedState() => 'Disposed (cleanup completed)',
  };
}

/// Initial idle state - ready for user interaction
@immutable
class VIdleState extends VStoryViewerState {
  const VIdleState({required this.position});

  final VStoryPosition position;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VIdleState && position == other.position;

  @override
  int get hashCode => position.hashCode;

  @override
  String toString() => 'VIdleState(position: $position)';
}

/// Currently playing a story
@immutable
class VPlayingState extends VStoryViewerState {
  const VPlayingState({
    required this.position,
    required this.progress,
    required this.startTime,
  });

  final VStoryPosition position;
  final double progress; // 0.0 to 1.0
  final DateTime startTime;

  /// Duration since playback started
  Duration get playbackDuration => DateTime.now().difference(startTime);

  /// Estimated remaining time based on current progress
  Duration get estimatedRemainingTime {
    if (progress <= 0) return VStoryDurationConstants.defaultImageDuration;

    final elapsedRatio = progress;
    final totalDuration = playbackDuration.inMilliseconds / elapsedRatio;
    return Duration(milliseconds: (totalDuration * (1 - elapsedRatio)).round());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VPlayingState &&
          position == other.position &&
          progress == other.progress &&
          startTime == other.startTime;

  @override
  int get hashCode => Object.hash(position, progress, startTime);

  @override
  String toString() =>
      'VPlayingState(position: $position, progress: ${(progress * 100).toStringAsFixed(1)}%)';
}

/// Paused state - user interaction has paused playback
@immutable
class VPausedState extends VStoryViewerState {
  const VPausedState({
    required this.position,
    required this.progress,
    required this.pauseReason,
    required this.pausedAt,
  });

  final VStoryPosition position;
  final double progress; // Progress when paused
  final VPauseReason pauseReason;
  final DateTime pausedAt;

  /// Duration since pause began
  Duration get pauseDuration => DateTime.now().difference(pausedAt);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VPausedState &&
          position == other.position &&
          progress == other.progress &&
          pauseReason == other.pauseReason;

  @override
  int get hashCode => Object.hash(position, progress, pauseReason);

  @override
  String toString() =>
      'VPausedState(position: $position, reason: $pauseReason, duration: ${pauseDuration.inSeconds}s)';
}

/// Loading state - downloading or preparing media
@immutable
class VLoadingState extends VStoryViewerState {
  const VLoadingState({
    required this.position,
    required this.loadingProgress,
    required this.loadingType,
    required this.startedAt,
  });

  final VStoryPosition position;
  final double loadingProgress; // 0.0 to 1.0
  final VLoadingType loadingType;
  final DateTime startedAt;

  /// Duration since loading started
  Duration get loadingDuration => DateTime.now().difference(startedAt);

  /// Whether loading is nearly complete
  bool get isNearlyComplete => loadingProgress >= 0.9;

  /// Whether loading is taking too long
  bool get isTakingTooLong => loadingDuration > const Duration(seconds: 10);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VLoadingState &&
          position == other.position &&
          loadingProgress == other.loadingProgress &&
          loadingType == other.loadingType;

  @override
  int get hashCode => Object.hash(position, loadingProgress, loadingType);

  @override
  String toString() =>
      'VLoadingState(position: $position, type: $loadingType, progress: ${(loadingProgress * 100).toStringAsFixed(1)}%)';
}

/// Navigating state - transitioning between stories
@immutable
class VNavigatingState extends VStoryViewerState {
  const VNavigatingState({
    required this.position,
    required this.targetPosition,
    required this.direction,
    required this.startedAt,
  });

  final VStoryPosition position; // Current position
  final VStoryPosition targetPosition; // Target position
  final VStoryNavigationDirection direction;
  final DateTime startedAt;

  /// Duration since navigation started
  Duration get navigationDuration => DateTime.now().difference(startedAt);

  /// Whether navigation is taking too long
  bool get isTakingTooLong =>
      navigationDuration > VStoryAnimationConstants.storyTransitionDuration * 2;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VNavigatingState &&
          position == other.position &&
          targetPosition == other.targetPosition &&
          direction == other.direction;

  @override
  int get hashCode => Object.hash(position, targetPosition, direction);

  @override
  String toString() =>
      'VNavigatingState(from: $position, to: $targetPosition, direction: $direction)';
}

/// Error state - something went wrong
@immutable
class VErrorState extends VStoryViewerState {
  const VErrorState({
    required this.error,
    required this.previousState,
    required this.occurredAt,
    this.retryCount = 0,
  });

  final VStoryError error;
  final VStoryViewerState? previousState;
  final DateTime occurredAt;
  final int retryCount;

  /// Duration since error occurred
  Duration get errorDuration => DateTime.now().difference(occurredAt);

  /// Whether this error can be retried
  bool get canRetry => error.isRetryable && retryCount < 3;

  /// Whether error should auto-dismiss
  bool get shouldAutoDismiss =>
      errorDuration > VStoryErrorConstants.errorDisplayDuration &&
      !error.requiresUserAction;

  /// Creates a new error state with incremented retry count
  VErrorState withIncrementedRetry() => VErrorState(
    error: error,
    previousState: previousState,
    occurredAt: occurredAt,
    retryCount: retryCount + 1,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VErrorState &&
          error == other.error &&
          retryCount == other.retryCount;

  @override
  int get hashCode => Object.hash(error, retryCount);

  @override
  String toString() =>
      'VErrorState(error: ${error.code}, retryCount: $retryCount, duration: ${errorDuration.inSeconds}s)';
}

/// Disposed state - cleanup completed
@immutable
class VDisposedState extends VStoryViewerState {
  const VDisposedState({required this.disposedAt});

  final DateTime disposedAt;

  @override
  bool operator ==(Object other) => other is VDisposedState;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'VDisposedState(at: $disposedAt)';
}

/// Reasons why playback might be paused
enum VPauseReason {
  userLongPress('User long press'),
  replyInput('Reply input focused'),
  carouselScrolling('Carousel scrolling'),
  appInBackground('App backgrounded'),
  phoneCall('Incoming call'),
  manual('Manual pause');

  const VPauseReason(this.description);
  final String description;

  @override
  String toString() => description;
}

/// Types of loading operations
enum VLoadingType {
  mediaDownload('Downloading media'),
  mediaDecoding('Decoding media'),
  cacheLoading('Loading from cache'),
  initialization('Initializing player');

  const VLoadingType(this.description);
  final String description;

  @override
  String toString() => description;
}

/// State machine for managing story viewer state transitions
class VStoryStateMachine extends ChangeNotifier {
  VStoryStateMachine({VStoryViewerState? initialState})
    : _currentState =
          initialState ?? const VIdleState(position: VStoryPosition.initial()),
      _stateHistory = [];

  VStoryViewerState _currentState;
  final List<VStoryStateTransition> _stateHistory;

  /// Current state of the story viewer
  VStoryViewerState get currentState => _currentState;

  /// History of state transitions for debugging
  List<VStoryStateTransition> get stateHistory =>
      List.unmodifiable(_stateHistory);

  /// Gets the last state transition
  VStoryStateTransition? get lastTransition =>
      _stateHistory.isNotEmpty ? _stateHistory.last : null;

  /// Number of state transitions
  int get transitionCount => _stateHistory.length;

  /// Transitions to a new state with validation
  bool transitionTo(VStoryViewerState newState, {String? reason}) {
    if (!_canTransitionTo(newState)) {
      debugPrint(
        'Invalid state transition: ${_currentState.runtimeType} -> ${newState.runtimeType}',
      );
      return false;
    }

    final oldState = _currentState;
    final transition = VStoryStateTransition(
      fromState: oldState,
      toState: newState,
      timestamp: DateTime.now(),
      reason: reason,
    );

    _stateHistory.add(transition);
    _currentState = newState;

    // Trim history to prevent memory leaks
    if (_stateHistory.length > 50) {
      _stateHistory.removeAt(0);
    }

    notifyListeners();
    return true;
  }

  /// Validates if transition is allowed
  bool _canTransitionTo(VStoryViewerState newState) {
    // Can't transition from disposed state
    if (_currentState is VDisposedState) return false;

    // Can always transition to error or disposed state
    if (newState is VErrorState || newState is VDisposedState) return true;

    return switch ((_currentState, newState)) {
      // From idle
      (VIdleState(), VPlayingState()) => true,
      (VIdleState(), VLoadingState()) => true,
      (VIdleState(), VNavigatingState()) => true,

      // From playing
      (VPlayingState(), VPausedState()) => true,
      (VPlayingState(), VNavigatingState()) => true,
      (VPlayingState(), VIdleState()) => true,

      // From paused
      (VPausedState(), VPlayingState()) => true,
      (VPausedState(), VNavigatingState()) => true,
      (VPausedState(), VIdleState()) => true,

      // From loading
      (VLoadingState(), VPlayingState()) => true,
      (VLoadingState(), VIdleState()) => true,

      // From navigating
      (VNavigatingState(), VPlayingState()) => true,
      (VNavigatingState(), VIdleState()) => true,
      (VNavigatingState(), VLoadingState()) => true,

      // From error
      (VErrorState(), VLoadingState()) => true,
      (VErrorState(), VIdleState()) => true,
      (VErrorState(), VPlayingState()) => true,

      _ => false,
    };
  }

  /// Force transition (for error recovery)
  void forceTransitionTo(VStoryViewerState newState, {String? reason}) {
    final transition = VStoryStateTransition(
      fromState: _currentState,
      toState: newState,
      timestamp: DateTime.now(),
      reason: reason ?? 'Force transition',
      isForced: true,
    );

    _stateHistory.add(transition);
    _currentState = newState;
    notifyListeners();
  }

  /// Revert to previous state if possible
  bool revertToPreviousState({String? reason}) {
    if (_stateHistory.isEmpty) return false;

    final lastValidState = _stateHistory
        .where((t) => t.toState is! VErrorState && t.toState is! VDisposedState)
        .lastOrNull
        ?.toState;

    if (lastValidState == null) return false;

    return transitionTo(lastValidState, reason: reason ?? 'Revert to previous');
  }

  /// Gets state duration for current state
  Duration get currentStateDuration {
    final lastTransition = _stateHistory.lastOrNull;
    if (lastTransition == null) return Duration.zero;
    return DateTime.now().difference(lastTransition.timestamp);
  }

  /// Clears state history (useful for testing)
  void clearHistory() {
    _stateHistory.clear();
  }

  @override
  void dispose() {
    if (_currentState is! VDisposedState) {
      transitionTo(VDisposedState(disposedAt: DateTime.now()));
    }
    super.dispose();
  }

  @override
  String toString() =>
      'VStoryStateMachine(current: $_currentState, transitions: ${_stateHistory.length})';
}

/// Represents a state transition for debugging and analytics
@immutable
class VStoryStateTransition {
  const VStoryStateTransition({
    required this.fromState,
    required this.toState,
    required this.timestamp,
    this.reason,
    this.isForced = false,
  });

  final VStoryViewerState fromState;
  final VStoryViewerState toState;
  final DateTime timestamp;
  final String? reason;
  final bool isForced;

  /// Duration of the previous state
  Duration get stateDuration => timestamp.difference(timestamp);

  @override
  String toString() =>
      'Transition(${fromState.runtimeType} -> ${toState.runtimeType}${reason != null ? ', reason: $reason' : ''}${isForced ? ' [FORCED]' : ''})';
}

/// Extension for getting the last element or null
extension _ListExtension<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
