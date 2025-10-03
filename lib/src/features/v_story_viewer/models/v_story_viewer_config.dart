import 'package:flutter/foundation.dart';

/// Configuration options for VStoryViewer
@immutable
class VStoryViewerConfig {
  const VStoryViewerConfig({
    this.enableHapticFeedback = true,
    this.pauseOnLongPress = true,
    this.dismissOnSwipeDown = true,
    this.autoMoveToNextGroup = true,
    this.restartGroupWhenAllViewed = false,
  });

  /// Enable haptic feedback for gestures
  final bool enableHapticFeedback;

  /// Pause story on long press
  final bool pauseOnLongPress;

  /// Dismiss viewer on swipe down gesture
  final bool dismissOnSwipeDown;

  /// Automatically move to next group after current group completes
  final bool autoMoveToNextGroup;

  /// Restart group from beginning when all stories viewed
  final bool restartGroupWhenAllViewed;

  /// Default configuration
  static const defaultConfig = VStoryViewerConfig();

  VStoryViewerConfig copyWith({
    bool? enableHapticFeedback,
    bool? pauseOnLongPress,
    bool? dismissOnSwipeDown,
    bool? autoMoveToNextGroup,
    bool? restartGroupWhenAllViewed,
  }) {
    return VStoryViewerConfig(
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      pauseOnLongPress: pauseOnLongPress ?? this.pauseOnLongPress,
      dismissOnSwipeDown: dismissOnSwipeDown ?? this.dismissOnSwipeDown,
      autoMoveToNextGroup: autoMoveToNextGroup ?? this.autoMoveToNextGroup,
      restartGroupWhenAllViewed:
          restartGroupWhenAllViewed ?? this.restartGroupWhenAllViewed,
    );
  }
}
