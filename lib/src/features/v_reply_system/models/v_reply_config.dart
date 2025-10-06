import 'package:flutter/material.dart';

/// Configuration for the reply system.
class VReplyConfig {
  /// Creates a new instance of [VReplyConfig].
  const VReplyConfig({
    this.textStyle,
    this.inputDecoration,
    this.sendButtonColor,
    this.replyButtonColor,
    this.placeholderText,
  });

  /// The text style for the reply input field.
  final TextStyle? textStyle;

  /// The decoration for the reply input field.
  final InputDecoration? inputDecoration;

  /// The color of the send button.
  final Color? sendButtonColor;

  /// The color of the reply button.
  final Color? replyButtonColor;

  /// The placeholder text for the reply input field.
  final String? placeholderText;
}
