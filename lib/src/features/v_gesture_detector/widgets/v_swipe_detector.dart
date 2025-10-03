import 'package:flutter/material.dart';

import '../models/v_gesture_config.dart';
import 'v_gesture_callbacks.dart';

/// Widget that detects vertical swipe gestures for dismissal
class VSwipeDetector extends StatelessWidget {
  const VSwipeDetector({
    required this.config,
    required this.callbacks,
    super.key,
  });

  final VGestureConfig config;
  final VGestureCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    if (!config.enableSwipe) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onVerticalDragEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond.dy;
        if (velocity > config.swipeVelocityThreshold) {
          callbacks.onSwipeDown?.call();
        }
      },
      behavior: HitTestBehavior.translucent,
    );
  }
}
