import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Styling configuration for story reply system.
/// 
/// Defines the appearance of reply input field, send button,
/// and related UI elements.
class VStoryReplyStyle {
  /// Background color for reply input
  final Color backgroundColor;
  
  /// Text color for reply input
  final Color textColor;
  
  /// Hint text color
  final Color hintTextColor;
  
  /// Send button color
  final Color sendButtonColor;
  
  /// Border radius for reply input
  final BorderRadius borderRadius;
  
  /// Padding for reply input
  final EdgeInsets padding;
  
  /// Text style for input
  final TextStyle? textStyle;
  
  /// Hint text style
  final TextStyle? hintTextStyle;
  
  /// Border color for reply input
  final Color? borderColor;
  
  /// Border width
  final double borderWidth;
  
  /// Cursor color
  final Color? cursorColor;
  
  /// Selection color
  final Color? selectionColor;
  
  /// Send button icon
  final IconData sendIcon;
  
  /// Send button size
  final double sendButtonSize;
  
  /// Elevation for reply input
  final double elevation;
  
  /// Shadows for reply input
  final List<BoxShadow>? shadows;
  
  /// Maximum lines for input
  final int maxLines;
  
  /// Minimum lines for input
  final int minLines;
  
  /// Keyboard type
  final TextInputType keyboardType;
  
  /// Text input action
  final TextInputAction textInputAction;
  
  /// Whether to show emoji button
  final bool showEmojiButton;
  
  /// Emoji button color
  final Color? emojiButtonColor;
  
  /// Animation duration
  final Duration animationDuration;
  
  /// Creates a reply style configuration
  const VStoryReplyStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.hintTextColor,
    required this.sendButtonColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.textStyle,
    this.hintTextStyle,
    this.borderColor,
    this.borderWidth = 1.0,
    this.cursorColor,
    this.selectionColor,
    this.sendIcon = Icons.send,
    this.sendButtonSize = 24.0,
    this.elevation = 0,
    this.shadows,
    this.maxLines = 4,
    this.minLines = 1,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.send,
    this.showEmojiButton = false,
    this.emojiButtonColor,
    this.animationDuration = const Duration(milliseconds: 200),
  });
  
  /// Creates a light theme reply style
  factory VStoryReplyStyle.light() {
    return const VStoryReplyStyle(
      backgroundColor: Colors.white,
      textColor: Colors.black,
      hintTextColor: Colors.black54,
      sendButtonColor: Colors.blue,
      borderRadius: BorderRadius.all(Radius.circular(24)),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
  
  /// Creates a dark theme reply style
  factory VStoryReplyStyle.dark() {
    return const VStoryReplyStyle(
      backgroundColor: Color(0xFF1E1E1E),
      textColor: Colors.white,
      hintTextColor: Colors.white54,
      sendButtonColor: Colors.blueAccent,
      borderRadius: BorderRadius.all(Radius.circular(24)),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderColor: Colors.white24,
    );
  }
  
  /// Creates a reply style from Material 3 color scheme
  factory VStoryReplyStyle.fromColorScheme(ColorScheme colorScheme) {
    return VStoryReplyStyle(
      backgroundColor: colorScheme.surfaceContainerHighest,
      textColor: colorScheme.onSurface,
      hintTextColor: colorScheme.onSurfaceVariant,
      sendButtonColor: colorScheme.primary,
      borderRadius: const BorderRadius.all(Radius.circular(28)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      cursorColor: colorScheme.primary,
      selectionColor: colorScheme.primary.withValues(alpha: 0.3),
      textStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 16,
      ),
      hintTextStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 16,
      ),
    );
  }
  
  /// Creates a Cupertino-style reply style
  factory VStoryReplyStyle.cupertino() {
    return const VStoryReplyStyle(
      backgroundColor: CupertinoColors.systemGrey6,
      textColor: CupertinoColors.label,
      hintTextColor: CupertinoColors.placeholderText,
      sendButtonColor: CupertinoColors.activeBlue,
      borderRadius: BorderRadius.all(Radius.circular(20)),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sendIcon: CupertinoIcons.arrow_up_circle_fill,
      sendButtonSize: 28.0,
    );
  }
  
  /// Creates a minimal reply style
  factory VStoryReplyStyle.minimal() {
    return const VStoryReplyStyle(
      backgroundColor: Colors.transparent,
      textColor: Colors.white,
      hintTextColor: Colors.white54,
      sendButtonColor: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(0)),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderColor: Colors.white,
      borderWidth: 1.0,
      elevation: 0,
    );
  }
  
  /// Creates an outlined reply style
  factory VStoryReplyStyle.outlined({
    Color borderColor = Colors.white,
    Color textColor = Colors.white,
  }) {
    return VStoryReplyStyle(
      backgroundColor: Colors.transparent,
      textColor: textColor,
      hintTextColor: textColor.withValues(alpha: 0.54),
      sendButtonColor: textColor,
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderColor: borderColor,
      borderWidth: 2.0,
    );
  }
  
  /// Creates a filled reply style
  factory VStoryReplyStyle.filled({
    required Color backgroundColor,
    required Color textColor,
    required Color sendButtonColor,
  }) {
    return VStoryReplyStyle(
      backgroundColor: backgroundColor,
      textColor: textColor,
      hintTextColor: textColor.withValues(alpha: 0.54),
      sendButtonColor: sendButtonColor,
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadows: [
        BoxShadow(
          color: backgroundColor.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  /// Creates a copy with modified fields
  VStoryReplyStyle copyWith({
    Color? backgroundColor,
    Color? textColor,
    Color? hintTextColor,
    Color? sendButtonColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
    TextStyle? hintTextStyle,
    Color? borderColor,
    double? borderWidth,
    Color? cursorColor,
    Color? selectionColor,
    IconData? sendIcon,
    double? sendButtonSize,
    double? elevation,
    List<BoxShadow>? shadows,
    int? maxLines,
    int? minLines,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool? showEmojiButton,
    Color? emojiButtonColor,
    Duration? animationDuration,
  }) {
    return VStoryReplyStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      hintTextColor: hintTextColor ?? this.hintTextColor,
      sendButtonColor: sendButtonColor ?? this.sendButtonColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      cursorColor: cursorColor ?? this.cursorColor,
      selectionColor: selectionColor ?? this.selectionColor,
      sendIcon: sendIcon ?? this.sendIcon,
      sendButtonSize: sendButtonSize ?? this.sendButtonSize,
      elevation: elevation ?? this.elevation,
      shadows: shadows ?? this.shadows,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
      keyboardType: keyboardType ?? this.keyboardType,
      textInputAction: textInputAction ?? this.textInputAction,
      showEmojiButton: showEmojiButton ?? this.showEmojiButton,
      emojiButtonColor: emojiButtonColor ?? this.emojiButtonColor,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
  
  /// Gets the input decoration
  InputDecoration getInputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: hintTextStyle ?? TextStyle(
        color: hintTextColor,
        fontSize: 16,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: backgroundColor,
      contentPadding: padding,
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: borderColor != null
          ? BorderSide(color: borderColor!, width: borderWidth)
          : BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: borderColor != null
          ? BorderSide(color: borderColor!, width: borderWidth)
          : BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: borderColor != null
          ? BorderSide(color: sendButtonColor, width: borderWidth)
          : BorderSide.none,
      ),
    );
  }
  
  /// Gets the container decoration
  BoxDecoration getContainerDecoration() {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius,
      border: borderColor != null
        ? Border.all(color: borderColor!, width: borderWidth)
        : null,
      boxShadow: shadows,
    );
  }
}