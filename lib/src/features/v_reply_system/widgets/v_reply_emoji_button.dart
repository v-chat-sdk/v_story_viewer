import 'package:flutter/material.dart';

/// A button for toggling the emoji picker in the reply system.
class VReplyEmojiButton extends StatelessWidget {
  /// Creates a new instance of [VReplyEmojiButton].
  const VReplyEmojiButton({
    required this.onPressed,
    required this.isEmojiPickerOpen,
    this.color,
    super.key,
  });

  /// Callback when the emoji button is pressed.
  final VoidCallback onPressed;

  /// Whether the emoji picker is currently open.
  final bool isEmojiPickerOpen;

  /// The color of the emoji button icon.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isEmojiPickerOpen ? Icons.keyboard : Icons.emoji_emotions_outlined,
        color: color ?? Colors.white.withValues(alpha: 0.7),
        size: 24,
      ),
      onPressed: onPressed,
      tooltip: isEmojiPickerOpen ? 'Show keyboard' : 'Show emoji picker',
      splashRadius: 24,
    );
  }
}
