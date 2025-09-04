import '../models/v_story_state.dart';

/// Manages valid state transitions for story playback.
/// 
/// This class ensures that state transitions follow the defined
/// state machine rules and prevents invalid transitions.
class VStateTransitions {
  /// Private constructor to prevent instantiation
  VStateTransitions._();
  
  /// Checks if a transition from one state to another is valid
  static bool isValidTransition(
    VStoryPlaybackState from,
    VStoryPlaybackState to,
  ) {
    // Same state transitions are always valid (no-op)
    if (from == to) return true;
    
    // Define valid transitions based on state machine
    switch (from) {
      case VStoryPlaybackState.initial:
        // From initial, can only go to loading or error
        return to == VStoryPlaybackState.loading ||
               to == VStoryPlaybackState.error;
        
      case VStoryPlaybackState.loading:
        // From loading, can go to playing, error, or back to initial
        return to == VStoryPlaybackState.playing ||
               to == VStoryPlaybackState.error ||
               to == VStoryPlaybackState.initial;
        
      case VStoryPlaybackState.playing:
        // From playing, can pause, complete, or error
        return to == VStoryPlaybackState.paused ||
               to == VStoryPlaybackState.completed ||
               to == VStoryPlaybackState.error ||
               to == VStoryPlaybackState.initial;
        
      case VStoryPlaybackState.paused:
        // From paused, can resume playing, complete, or reset
        return to == VStoryPlaybackState.playing ||
               to == VStoryPlaybackState.completed ||
               to == VStoryPlaybackState.initial ||
               to == VStoryPlaybackState.error;
        
      case VStoryPlaybackState.completed:
        // From completed, can only reset to initial
        return to == VStoryPlaybackState.initial;
        
      case VStoryPlaybackState.error:
        // From error, can retry (loading) or reset
        return to == VStoryPlaybackState.loading ||
               to == VStoryPlaybackState.initial;
    }
  }
  
  /// Attempts to transition between states
  static TransitionResult attemptTransition(
    VStoryState currentState,
    VStoryPlaybackState targetState,
  ) {
    if (!isValidTransition(currentState.playbackState, targetState)) {
      return TransitionResult(
        success: false,
        error: 'Invalid transition from ${currentState.playbackState} to $targetState',
        currentState: currentState,
      );
    }
    
    // Perform the transition
    VStoryState newState;
    switch (targetState) {
      case VStoryPlaybackState.initial:
        newState = currentState.reset();
        break;
        
      case VStoryPlaybackState.loading:
        newState = currentState.toLoading();
        break;
        
      case VStoryPlaybackState.playing:
        newState = currentState.toPlaying();
        break;
        
      case VStoryPlaybackState.paused:
        newState = currentState.toPaused();
        break;
        
      case VStoryPlaybackState.completed:
        newState = currentState.toCompleted();
        break;
        
      case VStoryPlaybackState.error:
        newState = currentState.toError('Transition error');
        break;
    }
    
    return TransitionResult(
      success: true,
      currentState: currentState,
      newState: newState,
    );
  }
  
  /// Gets allowed transitions from a given state
  static List<VStoryPlaybackState> getAllowedTransitions(
    VStoryPlaybackState from,
  ) {
    final allowed = <VStoryPlaybackState>[];
    
    for (final state in VStoryPlaybackState.values) {
      if (isValidTransition(from, state) && from != state) {
        allowed.add(state);
      }
    }
    
    return allowed;
  }
  
  /// Checks if a state can be retried (go back to loading)
  static bool canRetry(VStoryPlaybackState state) {
    return state == VStoryPlaybackState.error;
  }
  
  /// Checks if a state can be reset
  static bool canReset(VStoryPlaybackState state) {
    return state != VStoryPlaybackState.initial;
  }
  
  /// Checks if playback can be started from a state
  static bool canStartPlayback(VStoryPlaybackState state) {
    return state == VStoryPlaybackState.initial ||
           state == VStoryPlaybackState.paused ||
           state == VStoryPlaybackState.error;
  }
  
  /// Checks if playback can be paused from a state
  static bool canPausePlayback(VStoryPlaybackState state) {
    return state == VStoryPlaybackState.playing;
  }
  
  /// Gets a human-readable description of a transition
  static String describeTransition(
    VStoryPlaybackState from,
    VStoryPlaybackState to,
  ) {
    if (from == to) {
      return 'No change (already in ${from.name} state)';
    }
    
    final valid = isValidTransition(from, to);
    if (!valid) {
      return 'Invalid transition: ${from.name} → ${to.name}';
    }
    
    // Provide meaningful descriptions for valid transitions
    switch ('${from.name}_${to.name}') {
      case 'initial_loading':
        return 'Starting to load story';
      case 'loading_playing':
        return 'Story loaded, starting playback';
      case 'playing_paused':
        return 'Pausing story playback';
      case 'paused_playing':
        return 'Resuming story playback';
      case 'playing_completed':
        return 'Story playback completed';
      case 'error_loading':
        return 'Retrying story load';
      case 'error_initial':
        return 'Resetting after error';
      default:
        return '${from.name} → ${to.name}';
    }
  }
}

/// Result of a state transition attempt
class TransitionResult {
  /// Whether the transition was successful
  final bool success;
  
  /// Error message if transition failed
  final String? error;
  
  /// The current state before transition
  final VStoryState currentState;
  
  /// The new state after transition (if successful)
  final VStoryState? newState;
  
  /// Creates a transition result
  const TransitionResult({
    required this.success,
    this.error,
    required this.currentState,
    this.newState,
  });
  
  @override
  String toString() {
    if (success) {
      return 'TransitionResult(success: true, '
          '${currentState.playbackState} → ${newState?.playbackState})';
    }
    return 'TransitionResult(success: false, error: $error)';
  }
}