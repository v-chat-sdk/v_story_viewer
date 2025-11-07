import 'package:flutter/material.dart';

import '../models/v_gesture_velocity.dart';

/// Widget that displays gesture velocity feedback
class VVelocityIndicator extends StatelessWidget {
  const VVelocityIndicator({
    required this.velocityData,
    this.position = const Offset(50, 100),
    this.size = 120,
    super.key,
  });

  /// Velocity data to display
  final VGestureVelocityData velocityData;

  /// Position on screen to display the indicator
  final Offset position;

  /// Size of the indicator circle
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getSpeedColor().withValues(alpha: 0.3),
          border: Border.all(
            color: _getSpeedColor(),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              velocityData.direction.arrow,
              style: TextStyle(
                fontSize: size * 0.3,
                fontWeight: FontWeight.bold,
                color: _getSpeedColor(),
              ),
            ),
            SizedBox(height: size * 0.05),
            Text(
              velocityData.speed.label,
              style: TextStyle(
                fontSize: size * 0.12,
                fontWeight: FontWeight.w600,
                color: _getSpeedColor(),
              ),
            ),
            Text(
              '${velocityData.pixelsPerSecond.toInt()} px/s',
              style: TextStyle(
                fontSize: size * 0.08,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get color based on gesture speed
  Color _getSpeedColor() {
    return switch (velocityData.speed) {
      VGestureSpeed.slow => Colors.blue,
      VGestureSpeed.normal => Colors.green,
      VGestureSpeed.fast => Colors.orange,
      VGestureSpeed.veryFast => Colors.red,
    };
  }
}

/// Animated progress indicator for swipe velocity
class VSwipeProgressIndicator extends StatefulWidget {
  const VSwipeProgressIndicator({
    required this.velocityData,
    this.height = 4,
    this.duration = const Duration(milliseconds: 300),
    super.key,
  });

  /// Velocity data containing swipe speed information
  final VGestureVelocityData velocityData;

  /// Height of the progress bar
  final double height;

  /// Duration of the animation
  final Duration duration;

  @override
  State<VSwipeProgressIndicator> createState() =>
      _VSwipeProgressIndicatorState();
}

class _VSwipeProgressIndicatorState extends State<VSwipeProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Calculate progress based on velocity
    // Max velocity considered is 500 px/s
    final maxVelocity = 500;
    final progress = (widget.velocityData.pixelsPerSecond / maxVelocity)
        .clamp(0, 1)
        .toDouble();

    _progressAnimation = Tween<double>(begin: 0, end: progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(VSwipeProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.velocityData != widget.velocityData) {
      _controller.reset();
      final maxVelocity = 500;
      final progress = (widget.velocityData.pixelsPerSecond / maxVelocity)
          .clamp(0, 1)
          .toDouble();

      _progressAnimation = Tween<double>(begin: 0, end: progress).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );

      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.height / 2),
          child: LinearProgressIndicator(
            value: _progressAnimation.value,
            minHeight: widget.height,
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(_progressAnimation.value),
            ),
          ),
        );
      },
    );
  }

  /// Get color based on progress
  Color _getProgressColor(double value) {
    if (value < 0.2) {
      return Colors.blue;
    } else if (value < 0.5) {
      return Colors.green;
    } else if (value < 0.8) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

/// Overlay widget for displaying velocity indicator with animations
class VVelocityOverlay extends StatelessWidget {
  const VVelocityOverlay({
    required this.child,
    required this.velocityData,
    this.showIndicator = true,
    this.showProgressBar = true,
    this.fadeOutDuration = const Duration(milliseconds: 500),
    super.key,
  });

  /// The main content widget
  final Widget child;

  /// Velocity data to display
  final VGestureVelocityData velocityData;

  /// Whether to show the velocity indicator circle
  final bool showIndicator;

  /// Whether to show the velocity progress bar
  final bool showProgressBar;

  /// Duration before fade out
  final Duration fadeOutDuration;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (showProgressBar && velocityData.isSwipe)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 4,
              child: VSwipeProgressIndicator(
                velocityData: velocityData,
              ),
            ),
          ),
        if (showIndicator && velocityData.isSwipe)
          VVelocityIndicator(
            velocityData: velocityData,
          ),
      ],
    );
  }
}
