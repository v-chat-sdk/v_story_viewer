import 'package:flutter/material.dart';

/// A button that triggers the reply input.
class VReplyButton extends StatelessWidget {
  /// Creates a new instance of [VReplyButton].
  const VReplyButton({this.onPressed, this.color, this.text, super.key});

  /// A callback for when the button is pressed.
  final VoidCallback? onPressed;

  /// The color of the button.
  final Color? color;

  /// The text of the button.
  final String? text;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text ?? 'Reply',
        style: TextStyle(color: color ?? Colors.white),
      ),
    );
  }
}
