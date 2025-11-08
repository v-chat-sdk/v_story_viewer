import 'package:flutter/material.dart';

/// Configuration for gesture handling
@immutable
class VGestureConfig {
  const VGestureConfig({
    this.leftTapZoneWidth = 0.5,
    this.rightTapZoneWidth = 0.5,
    this.enableTapNavigation = true,
    this.enableLongPress = true,
    this.enableSwipe = true,
    this.swipeVelocityThreshold = 300.0,
    this.enableDoubleTap = false,
    this.showDebugTapZones = false,
    this.groupSwipeDirection = Axis.horizontal,
  });

  /// Width of left tap zone as percentage of screen width (0.0 to 1.0)
  /// Default 0.5 = 50% of screen width for left side (previous story)
  /// With default 50/50 split, long press anywhere pauses/resumes
  final double leftTapZoneWidth;

  /// Width of right tap zone as percentage of screen width (0.0 to 1.0)
  /// Default 0.5 = 50% of screen width for right side (next story)
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

  /// Show debug overlay with tap zone boundaries (development only)
  final bool showDebugTapZones;

  /// Swipe direction for group-to-group navigation
  ///
  /// When [groupSwipeDirection] is [Axis.vertical], the vertical dismiss
  /// gesture is disabled to avoid conflicts with vertical carousel scrolling.
  /// This ensures vertical swipe is exclusively used for group navigation.
  final Axis groupSwipeDirection;

  VGestureConfig copyWith({
    double? leftTapZoneWidth,
    double? rightTapZoneWidth,
    bool? enableTapNavigation,
    bool? enableLongPress,
    bool? enableSwipe,
    double? swipeVelocityThreshold,
    bool? enableDoubleTap,
    bool? showDebugTapZones,
    Axis? groupSwipeDirection,
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
      showDebugTapZones: showDebugTapZones ?? this.showDebugTapZones,
      groupSwipeDirection: groupSwipeDirection ?? this.groupSwipeDirection,
    );
  }
}
