import 'package:flutter/foundation.dart';
import 'v_pause_reason.dart';

/// Callbacks for pause/resume events
class VPauseResumeCallbacks {
  /// Creates a new instance of [VPauseResumeCallbacks]
  const VPauseResumeCallbacks({this.onPause, this.onResume, this.onToggle});

  /// Called when story is paused with the reason
  final void Function(VPauseReason reason)? onPause;

  /// Called when story is resumed
  final VoidCallback? onResume;

  /// Called when pause state is toggled with current pause state
  final void Function(bool isPaused)? onToggle;
}
