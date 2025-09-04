import 'package:flutter/material.dart';

/// Styling configuration for story header.
class VStoryHeaderStyle {
  /// Text style for username
  final TextStyle usernameStyle;
  
  /// Text style for timestamp
  final TextStyle timestampStyle;
  
  /// Avatar size
  final double avatarSize;
  
  /// Avatar border radius
  final BorderRadius avatarBorderRadius;
  
  /// Spacing between avatar and text
  final double spacing;
  
  /// Padding for header
  final EdgeInsets padding;
  
  /// Background color
  final Color? backgroundColor;
  
  /// Creates a header style
  const VStoryHeaderStyle({
    required this.usernameStyle,
    required this.timestampStyle,
    this.avatarSize = 32.0,
    this.avatarBorderRadius = const BorderRadius.all(Radius.circular(16)),
    this.spacing = 12.0,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
  });
  
  factory VStoryHeaderStyle.light() {
    return const VStoryHeaderStyle(
      usernameStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      timestampStyle: TextStyle(
        color: Colors.white70,
        fontSize: 14,
      ),
    );
  }
  
  factory VStoryHeaderStyle.dark() {
    return const VStoryHeaderStyle(
      usernameStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      timestampStyle: TextStyle(
        color: Colors.white60,
        fontSize: 14,
      ),
    );
  }
  
  factory VStoryHeaderStyle.fromTextTheme(TextTheme textTheme, ColorScheme colorScheme) {
    return VStoryHeaderStyle(
      usernameStyle: textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ) ?? TextStyle(color: colorScheme.onSurface),
      timestampStyle: textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ) ?? TextStyle(color: colorScheme.onSurfaceVariant),
    );
  }
  
  factory VStoryHeaderStyle.cupertino() {
    return const VStoryHeaderStyle(
      usernameStyle: TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      timestampStyle: TextStyle(
        color: Colors.white70,
        fontSize: 15,
      ),
    );
  }
}