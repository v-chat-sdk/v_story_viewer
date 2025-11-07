import 'package:flutter/material.dart';

/// A button for closing the emoji picker in the reply system.
class VReplyCloseButton extends StatelessWidget {
  /// Creates a new instance of [VReplyCloseButton].
  const VReplyCloseButton({required this.onPressed, this.color, super.key});

  /// Callback when the close button is pressed.
  final VoidCallback onPressed;

  /// The color of the close button icon.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.close,
        color: color ?? Colors.white.withValues(alpha: 0.7),
        size: 24,
      ),
      onPressed: onPressed,
      tooltip: 'Close emoji picker',
      splashRadius: 24,
    );
  }
}
