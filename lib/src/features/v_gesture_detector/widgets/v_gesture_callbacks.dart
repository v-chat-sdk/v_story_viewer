import 'package:flutter/foundation.dart';

/// Callbacks for gesture events
class VGestureCallbacks {
  const VGestureCallbacks({
    this.onTapPrevious,
    this.onTapNext,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.onSwipeDown,
    this.onDoubleTap,
  });

  /// Called when user taps left zone (previous story)
  final VoidCallback? onTapPrevious;

  /// Called when user taps right zone (next story)
  final VoidCallback? onTapNext;

  /// Called when user starts long press (pause)
  final VoidCallback? onLongPressStart;

  /// Called when user ends long press (resume)
  final VoidCallback? onLongPressEnd;

  /// Called when user swipes down (dismiss)
  final VoidCallback? onSwipeDown;

  /// Called when user double taps (reaction)
  final VoidCallback? onDoubleTap;
}
