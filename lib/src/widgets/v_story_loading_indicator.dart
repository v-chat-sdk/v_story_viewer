import 'package:flutter/material.dart';

/// Loading indicator for story media.
class VStoryLoadingIndicator extends StatelessWidget {
  /// Loading indicator color
  final Color color;

  /// Loading indicator size
  final double size;

  /// Background color
  final Color backgroundColor;

  /// Whether to show circular progress
  final bool showProgress;

  /// Current progress value (0.0 to 1.0)
  final double? progress;

  /// Creates a loading indicator
  const VStoryLoadingIndicator({
    super.key,
    this.color = Colors.white,
    this.size = 50.0,
    this.backgroundColor = Colors.black54,
    this.showProgress = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: showProgress && progress != null
              ? CircularProgressIndicator(
                  value: progress,
                  color: color,
                  strokeWidth: 3.0,
                )
              : CircularProgressIndicator(color: color, strokeWidth: 3.0),
        ),
      ),
    );
  }
}