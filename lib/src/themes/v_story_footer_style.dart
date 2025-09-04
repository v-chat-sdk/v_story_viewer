import 'package:flutter/material.dart';

/// Styling configuration for story footer.
class VStoryFooterStyle {
  /// Text style for footer text
  final TextStyle textStyle;
  
  /// Icon size for footer icons
  final double iconSize;
  
  /// Icon color
  final Color iconColor;
  
  /// Spacing between elements
  final double spacing;
  
  /// Padding for footer
  final EdgeInsets padding;
  
  /// Background color
  final Color? backgroundColor;
  
  /// Creates a footer style
  const VStoryFooterStyle({
    required this.textStyle,
    this.iconSize = 20.0,
    required this.iconColor,
    this.spacing = 8.0,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
  });
  
  factory VStoryFooterStyle.light() {
    return const VStoryFooterStyle(
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      iconColor: Colors.white,
    );
  }
  
  factory VStoryFooterStyle.dark() {
    return const VStoryFooterStyle(
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      iconColor: Colors.white70,
    );
  }
  
  factory VStoryFooterStyle.fromTextTheme(TextTheme textTheme, ColorScheme colorScheme) {
    return VStoryFooterStyle(
      textStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ) ?? TextStyle(color: colorScheme.onSurface),
      iconColor: colorScheme.onSurfaceVariant,
    );
  }
  
  factory VStoryFooterStyle.cupertino() {
    return const VStoryFooterStyle(
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
      iconColor: Colors.white,
      iconSize: 22.0,
    );
  }
}