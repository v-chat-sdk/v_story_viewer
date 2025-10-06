import 'package:flutter/material.dart';

/// A button for sending a reply.
class VReplySendButton extends StatelessWidget {
  /// Creates a new instance of [VReplySendButton].
  const VReplySendButton({
    this.onPressed,
    this.color,
    super.key,
  });

  /// A callback for when the button is pressed.
  final VoidCallback? onPressed;

  /// The color of the button.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.send),
      color: color ?? Colors.white,
      onPressed: onPressed,
    );
  }
}
