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
    const headerSafeZoneHeight = 80.0;
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(top: headerSafeZoneHeight),
            child: SizedBox(
              width: size.width * config.leftTapZoneWidth,
              height: size.height - headerSafeZoneHeight,
              child: GestureDetector(
                onTap: () {
                  callbacks.onTapPrevious?.call();
                },
                behavior: HitTestBehavior.translucent,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(top: headerSafeZoneHeight),
            child: SizedBox(
              width: size.width * config.rightTapZoneWidth,
              height: size.height - headerSafeZoneHeight,
              child: GestureDetector(
                onTap: () {
                  callbacks.onTapNext?.call();
                },
                behavior: HitTestBehavior.translucent,
              ),
            ),
          ),
        ),
        Align(
          child: Padding(
            padding: EdgeInsets.only(top: headerSafeZoneHeight),
            child: SizedBox(
              width: size.width,
              height: size.height - headerSafeZoneHeight,
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
        ),
      ],
    );
  }
}
