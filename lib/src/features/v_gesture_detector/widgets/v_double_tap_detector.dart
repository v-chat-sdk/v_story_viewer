import 'package:flutter/material.dart';

import '../models/v_gesture_config.dart';
import 'v_gesture_callbacks.dart';

/// Widget that detects double tap gestures for reactions
class VDoubleTapDetector extends StatelessWidget {
  const VDoubleTapDetector({
    required this.config,
    required this.callbacks,
    super.key,
  });

  final VGestureConfig config;
  final VGestureCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    if (!config.enableDoubleTap) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onDoubleTap: callbacks.onDoubleTap,
      behavior: HitTestBehavior.translucent,
    );
  }
}
