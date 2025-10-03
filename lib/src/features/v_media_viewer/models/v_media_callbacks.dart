import 'package:flutter/foundation.dart';

/// Callbacks for media controller events
///
/// These callbacks enable the orchestrator (VStoryViewer) to respond to
/// media-related events during story playback.
@immutable
class VMediaCallbacks {
  const VMediaCallbacks({
    this.onMediaReady,
    this.onMediaError,
    this.onPaused,
    this.onResumed,
    this.onDurationKnown,
    this.onLoadingProgress,
  });

  /// Called when media is fully loaded and ready to display
  ///
  /// The orchestrator should start the progress animation when this is called.
  final VoidCallback? onMediaReady;

  /// Called when media fails to load
  ///
  /// The orchestrator can decide to skip to the next story or show an error state.
  /// Passes the error message for logging or display purposes.
  final void Function(String error)? onMediaError;

  /// Called when media playback is paused
  ///
  /// Useful for synchronizing with progress bar pause state.
  final VoidCallback? onPaused;

  /// Called when media playback is resumed
  ///
  /// Useful for synchronizing with progress bar resume state.
  final VoidCallback? onResumed;

  /// Called when video duration becomes known
  ///
  /// Only applicable to video stories. The orchestrator can update
  /// the story duration or adjust progress animation accordingly.
  final void Function(Duration duration)? onDurationKnown;

  /// Called during media loading with progress updates (0.0 to 1.0)
  ///
  /// Useful for showing download progress indicators for network content.
  final void Function(double progress)? onLoadingProgress;

  /// Creates an empty callbacks instance (for testing or default usage)
  static const empty = VMediaCallbacks();
}
