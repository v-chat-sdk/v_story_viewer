import 'package:flutter/material.dart';

import '../models/v_gesture_config.dart';
import 'v_double_tap_detector.dart';
import 'v_gesture_callbacks.dart';
import 'v_long_press_detector.dart';
import 'v_swipe_detector.dart';
import 'v_tap_zones.dart';

/// Main gesture wrapper that combines all gesture detectors
///
/// This widget wraps the story content and provides comprehensive gesture handling:
/// - Left/right tap zones for navigation (previous/next story)
/// - Long press for pause/resume
/// - Swipe down to dismiss
/// - Double tap for reactions (optional)
class VGestureWrapper extends StatelessWidget {
  const VGestureWrapper({
    required this.child,
    required this.callbacks,
    this.config = const VGestureConfig(),
    super.key,
  });

  /// The story content to wrap with gesture detection
  final Widget child;

  /// Callbacks for gesture events
  final VGestureCallbacks callbacks;

  /// Configuration for gesture behavior
  final VGestureConfig config;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Story content at the bottom
        child,

        // Swipe detector layer
        Positioned.fill(
          child: VSwipeDetector(
            config: config,
            callbacks: callbacks,
          ),
        ),

        // Long press detector layer
        Positioned.fill(
          child: VLongPressDetector(
            config: config,
            callbacks: callbacks,
          ),
        ),

        // Double tap detector layer
        Positioned.fill(
          child: VDoubleTapDetector(
            config: config,
            callbacks: callbacks,
          ),
        ),

        // Tap zones layer (on top to have priority)
        VTapZones(
          config: config,
          callbacks: callbacks,
        ),
      ],
    );
  }
}
