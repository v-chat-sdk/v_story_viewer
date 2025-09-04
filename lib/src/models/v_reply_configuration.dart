import 'package:flutter/widgets.dart';
import 'v_story_models.dart';

/// Configuration for story replies
class VReplyConfiguration {
  /// The hint text for the reply input
  final String hintText;
  
  /// Callback when a reply is sent
  /// Returns true if the reply was successfully sent
  final Future<bool> Function(String message, VBaseStory story) onReplySend;
  
  /// Whether to show the reply UI
  final bool enabled;
  
  /// Custom reply widget builder
  final Widget Function(BuildContext context, VBaseStory story)? customReplyBuilder;
  
  /// Maximum length of reply message
  final int? maxLength;
  
  /// Whether to allow attachments
  final bool allowAttachments;
  
  /// Text style for the input field
  final TextStyle? textStyle;
  
  /// Text style for the hint
  final TextStyle? hintStyle;
  
  /// Background color of reply field
  final Color? backgroundColor;
  
  /// Creates a reply configuration
  const VReplyConfiguration({
    this.hintText = 'Send a reply...',
    required this.onReplySend,
    this.enabled = true,
    this.customReplyBuilder,
    this.maxLength,
    this.allowAttachments = false,
    this.textStyle,
    this.hintStyle,
    this.backgroundColor,
  });
}