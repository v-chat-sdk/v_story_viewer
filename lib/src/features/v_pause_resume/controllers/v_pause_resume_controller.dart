import 'package:flutter/foundation.dart';

import '../models/v_pause_reason.dart';
import '../models/v_pause_resume_callbacks.dart';

/// Unified controller for managing pause/resume state
/// Acts as single source of truth for all pause/resume operations
class VPauseResumeController extends ChangeNotifier {
  /// Creates a new instance of [VPauseResumeController]
  VPauseResumeController({VPauseResumeCallbacks? callbacks})
    : _callbacks = callbacks ?? const VPauseResumeCallbacks();

  final VPauseResumeCallbacks _callbacks;
  bool _isPaused = false;
  VPauseReason? _pauseReason;

  /// Whether the story is currently paused
  bool get isPaused => _isPaused;

  /// The reason why the story is paused (null if not paused)
  VPauseReason? get pauseReason => _pauseReason;

  /// Pause the story with the given reason
  void pause(VPauseReason reason) {
    _isPaused = true;
    _pauseReason = reason;
    _callbacks.onPause?.call(reason);
    notifyListeners();
  }

  /// Resume the story
  void resume() {
    if (!_isPaused) return;
    _isPaused = false;
    _pauseReason = null;
    _callbacks.onResume?.call();
    notifyListeners();
  }

  /// Toggle pause/resume state with the given reason
  void toggle(VPauseReason reason) {
    if (_isPaused) {
      resume();
    } else {
      pause(reason);
    }
  }

  /// Resume only if paused due to specific reason
  /// Returns true if resumed, false if wasn't paused or paused for different reason
  bool resumeIfPausedFor(VPauseReason reason) {
    if (_isPaused && _pauseReason == reason) {
      resume();
      return true;
    }
    return false;
  }

  /// Check if paused due to specific reason
  bool isPausedFor(VPauseReason reason) {
    return _isPaused && _pauseReason == reason;
  }

  /// Force resume regardless of pause reason
  /// Use with caution - should only be called when you know what you're doing
  void forceResume() {
    if (_isPaused) {
      resume();
    }
  }
}
