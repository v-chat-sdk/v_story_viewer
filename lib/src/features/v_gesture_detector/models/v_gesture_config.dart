import 'package:flutter/foundation.dart';

/// Configuration for gesture handling
@immutable
class VGestureConfig {
  const VGestureConfig({
    this.leftTapZoneWidth = 0.4,
    this.rightTapZoneWidth = 0.4,
    this.enableTapNavigation = true,
    this.enableLongPress = true,
    this.enableSwipe = true,
    this.swipeVelocityThreshold = 300.0,
    this.enableDoubleTap = false,
  });

  /// Width of left tap zone as percentage of screen width (0.0 to 1.0)
  final double leftTapZoneWidth;

  /// Width of right tap zone as percentage of screen width (0.0 to 1.0)
  final double rightTapZoneWidth;

  /// Enable tap navigation (left/right zones)
  final bool enableTapNavigation;

  /// Enable long press to pause/resume
  final bool enableLongPress;

  /// Enable swipe down to dismiss
  final bool enableSwipe;

  /// Minimum velocity for swipe gesture to trigger (pixels per second)
  final double swipeVelocityThreshold;

  /// Enable double tap gesture
  final bool enableDoubleTap;

  VGestureConfig copyWith({
    double? leftTapZoneWidth,
    double? rightTapZoneWidth,
    bool? enableTapNavigation,
    bool? enableLongPress,
    bool? enableSwipe,
    double? swipeVelocityThreshold,
    bool? enableDoubleTap,
  }) {
    return VGestureConfig(
      leftTapZoneWidth: leftTapZoneWidth ?? this.leftTapZoneWidth,
      rightTapZoneWidth: rightTapZoneWidth ?? this.rightTapZoneWidth,
      enableTapNavigation: enableTapNavigation ?? this.enableTapNavigation,
      enableLongPress: enableLongPress ?? this.enableLongPress,
      enableSwipe: enableSwipe ?? this.enableSwipe,
      swipeVelocityThreshold:
          swipeVelocityThreshold ?? this.swipeVelocityThreshold,
      enableDoubleTap: enableDoubleTap ?? this.enableDoubleTap,
    );
  }
}
