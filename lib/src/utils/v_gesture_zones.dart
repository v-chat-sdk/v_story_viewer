import 'package:flutter/widgets.dart';

/// Configuration for gesture handling in story viewer
class VGestureConfig {
  /// Whether tap gestures are enabled
  final bool tapEnabled;

  /// Whether swipe gestures are enabled
  final bool swipeEnabled;

  /// Whether long press gestures are enabled
  final bool longPressEnabled;

  /// Whether double tap gestures are enabled
  final bool enableDoubleTap;

  /// Whether long press gestures are enabled (alias for longPressEnabled)
  bool get enableLongPress => longPressEnabled;

  /// Whether swipe gestures are enabled (alias for swipeEnabled)
  bool get enableSwipeGestures => swipeEnabled;

  /// Whether haptic feedback is enabled
  final bool enableHapticFeedback;

  /// Minimum swipe velocity to trigger navigation
  final double swipeVelocityThreshold;

  /// Minimum swipe velocity to trigger navigation (alias)
  double get minSwipeVelocity => swipeVelocityThreshold;

  /// Minimum swipe distance to trigger navigation
  final double swipeDistanceThreshold;

  /// Minimum swipe distance to trigger navigation (alias)
  double get minSwipeDistance => swipeDistanceThreshold;

  /// Left zone percentage
  final double leftZonePercentage;

  /// Right zone percentage
  final double rightZonePercentage;

  /// Creates a gesture configuration
  const VGestureConfig({
    this.tapEnabled = true,
    this.swipeEnabled = true,
    this.longPressEnabled = true,
    this.enableDoubleTap = true,
    this.enableHapticFeedback = true,
    this.swipeVelocityThreshold = 200.0,
    this.swipeDistanceThreshold = 50.0,
    this.leftZonePercentage = 0.3,
    this.rightZonePercentage = 0.3,
  });
}

/// Defines the different gesture zones on the screen.
enum VGestureZone {
  /// Left side of the screen (for previous navigation)
  left,

  /// Right side of the screen (for next navigation)
  right,
}

/// Utilities for determining gesture zones on the screen.
class VGestureZones {
  /// Private constructor to prevent instantiation
  VGestureZones._();

  /// Gets the gesture zone for a tap position
  /// Now only returns left or right based on 50% split
  static VGestureZone getZone(
    Offset tapPositionx,
    Size screenSize,
    double tapPosition,
  ) {
    if (tapPosition < screenSize.width * 0.5) {
      return VGestureZone.left;
    } else {
      return VGestureZone.right;
    }
  }

  /// Gets the zone for a tap details
  static VGestureZone getZoneFromDetails(
    TapUpDetails details,
    BuildContext context, {
    double? leftZonePercent,
    double? rightZonePercent,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final tapPosition = details.globalPosition.dx;
    return getZone(details.localPosition, screenSize, tapPosition);
  }

  /// Checks if a position is in the left zone
  static bool isInLeftZone(
    Offset position,
    Size screenSize, {
    double? leftZonePercent,
  }) {
    final centerX = screenSize.width / 2;
    return position.dx < centerX;
  }

  /// Checks if a position is in the right zone
  static bool isInRightZone(
    Offset position,
    Size screenSize, {
    double? rightZonePercent,
  }) {
    final centerX = screenSize.width / 2;
    return position.dx >= centerX;
  }

  /// Gets zone boundaries for visual feedback
  static Map<String, double> getZoneBoundaries(
    Size screenSize, {
    double? leftZonePercent,
    double? rightZonePercent,
  }) {
    // Simple 50/50 split
    final centerX = screenSize.width / 2;

    return {
      'leftBoundary': centerX,
      'rightBoundary': centerX,
      'leftWidth': centerX,
      'rightWidth': centerX,
    };
  }

  /// Gets a debug string for a zone
  static String getZoneDebugString(VGestureZone zone) {
    switch (zone) {
      case VGestureZone.left:
        return 'Left Zone (Previous)';
      case VGestureZone.right:
        return 'Right Zone (Next)';
    }
  }
}
