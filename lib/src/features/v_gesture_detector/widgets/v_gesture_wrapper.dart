import 'package:flutter/material.dart';

import '../models/v_gesture_config.dart';
import 'v_gesture_callbacks.dart';

/// Hybrid gesture wrapper combining Pointer Events + GestureDetector
///
/// Architecture:
/// - Pointer Events: Handle quick taps (instant, no gesture arena delay)
/// - GestureDetector: Handle long-press, double-tap, drag (full screen)
///
/// Benefits:
/// ✅ Instant tap response (~50ms instead of 500ms+)
/// ✅ Full-screen long-press support
/// ✅ No gesture arena conflicts
/// ✅ All gestures work anywhere on screen
///
/// How it works:
/// 1. Pointer down → Record position & time
/// 2. Pointer up → Check if it's a quick tap (duration < 200ms, distance < 18pt)
/// 3. If quick tap:
///    - Determine zone (left/right)
///    - Call tap callback IMMEDIATELY
///    - Return early to prevent GestureDetector from handling it
/// 4. If not quick tap (duration >= 200ms):
///    - Let GestureDetector handle long-press/double-tap/drag
class VGestureWrapper extends StatefulWidget {
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
  State<VGestureWrapper> createState() => _VGestureWrapperState();
}

class _VGestureWrapperState extends State<VGestureWrapper> {
  /// Track pointer down position for tap detection
  late Offset _pointerDownPosition;

  /// Track pointer down time for tap detection
  late DateTime _pointerDownTime;

  /// Maximum duration to consider a gesture as a "tap" (not a hold)
  /// Standard Flutter tap is ~200ms
  static const Duration _tapDuration = Duration(milliseconds: 200);

  /// Maximum movement distance to consider a gesture as a "tap" (not a drag/swipe)
  /// Standard Flutter slop is 18 points
  static const double _tapSlop = 18;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Responsive safe zone: viewPadding.top handles notch/dynamic island
    // Add header height (60px is typical for icon buttons + user info)
    final headerSafeZoneHeight = MediaQuery.of(context).viewPadding.top + 60;

    return Semantics(
      label: 'Story viewer gesture controls',
      child: Listener(
        onPointerDown: (PointerDownEvent event) {
          _pointerDownPosition = event.position;
          _pointerDownTime = DateTime.now();
        },
        onPointerUp: (PointerUpEvent event) {
          // Calculate gesture duration and movement distance
          final duration = DateTime.now().difference(_pointerDownTime);
          final distance = (event.position - _pointerDownPosition).distance;

          // Check if this is a tap (quick + small movement)
          // If so, handle it immediately and prevent GestureDetector from seeing it
          if (duration < _tapDuration && distance < _tapSlop) {
            final x = event.position.dx;
            final y = event.position.dy;

            // Exclude header safe zone (responsive based on device notch/dynamic island)
            if (y > headerSafeZoneHeight) {
              // Calculate tap zone boundaries
              final leftZoneWidth = size.width * widget.config.leftTapZoneWidth;
              final rightZoneX =
                  size.width * (1 - widget.config.rightTapZoneWidth);

              if (widget.config.enableTapNavigation) {
                // LEFT TAP - INSTANT RESPONSE (no gesture arena delay!)
                if (x < leftZoneWidth) {
                  widget.callbacks.onTapPrevious?.call();
                  return; // Exit early - prevent GestureDetector
                }
                // RIGHT TAP - INSTANT RESPONSE (no gesture arena delay!)
                else if (x > rightZoneX) {
                  widget.callbacks.onTapNext?.call();
                  return; // Exit early - prevent GestureDetector
                }
              }
            }
          }
          // If we reach here, it's not a tap - let GestureDetector handle
          // long-press/double-tap/drag gestures
        },

        child: GestureDetector(
          // LONG PRESS: Pause/resume (full screen)
          onLongPressDown: (_) => widget.callbacks.onLongPressStart?.call(),
          onLongPressUp: () => widget.callbacks.onLongPressEnd?.call(),
          onLongPressEnd: (_) => widget.callbacks.onLongPressEnd?.call(),
          onLongPressCancel: () => widget.callbacks.onLongPressEnd?.call(),

          // DOUBLE TAP: Reactions (full screen)
          onDoubleTap: widget.callbacks.onDoubleTap,

          // VERTICAL DRAG: Swipe dismiss (full screen)
          onVerticalDragEnd: (DragEndDetails details) {
            if (widget.config.enableSwipe) {
              final velocity = details.velocity.pixelsPerSecond.dy;
              if (velocity > widget.config.swipeVelocityThreshold) {
                widget.callbacks.onSwipeDown?.call();
              }
            }
          },
          // translucent allows gestures to pass through to content
          behavior: HitTestBehavior.translucent,
          child: widget.child,
        ),
      ),
    );
  }
}
