import 'package:flutter/material.dart';

import '../models/v_gesture_config.dart';
import 'v_gesture_callbacks.dart';

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
    final size = MediaQuery.of(context).size;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Story content at the bottom
        child,

        // Left tap zone for previous story (20% of screen width)
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: size.width * config.leftTapZoneWidth,
            height: size.height,
            child: GestureDetector(
              onTap: callbacks.onTapPrevious,
              behavior: HitTestBehavior.translucent,
            ),
          ),
        ),

        // Right tap zone for next story (20% of screen width)
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: size.width * config.rightTapZoneWidth,
            height: size.height,
            child: GestureDetector(
              onTap: callbacks.onTapNext,
              behavior: HitTestBehavior.translucent,
            ),
          ),
        ),

        // Full screen overlay for long press pause/resume and vertical swipe
        Align(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: GestureDetector(
              onDoubleTap: callbacks.onDoubleTap,
              onLongPressDown: (_) => callbacks.onLongPressStart?.call(),
              onLongPressUp: () => callbacks.onLongPressEnd?.call(),
              onLongPressEnd: (_) => callbacks.onLongPressEnd?.call(),
              onLongPressCancel: () => callbacks.onLongPressEnd?.call(),

              onVerticalDragEnd: (details) {
                final velocity = details.velocity.pixelsPerSecond.dy;
                if (velocity > config.swipeVelocityThreshold) {
                  callbacks.onSwipeDown?.call();
                }
              },
              behavior: HitTestBehavior.translucent,
            ),
          ),
        ),
      ],
    );
  }
}
