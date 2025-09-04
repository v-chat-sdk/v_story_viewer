import 'package:flutter/material.dart';

/// Styling configuration for text stories.
class VStoryTextStyle {
  /// Text style for story content
  final TextStyle contentStyle;
  
  /// Background color for text stories
  final Color backgroundColor;
  
  /// Gradient colors for background
  final List<Color>? gradientColors;
  
  /// Text alignment
  final TextAlign textAlign;
  
  /// Padding for text content
  final EdgeInsets padding;
  
  /// Maximum font size
  final double maxFontSize;
  
  /// Minimum font size
  final double minFontSize;
  
  /// Creates a text story style
  const VStoryTextStyle({
    required this.contentStyle,
    required this.backgroundColor,
    this.gradientColors,
    this.textAlign = TextAlign.center,
    this.padding = const EdgeInsets.all(32),
    this.maxFontSize = 32.0,
    this.minFontSize = 16.0,
  });
  
  factory VStoryTextStyle.light() {
    return const VStoryTextStyle(
      contentStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: Colors.blueGrey,
    );
  }
  
  factory VStoryTextStyle.dark() {
    return const VStoryTextStyle(
      contentStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: Color(0xFF1E1E1E),
    );
  }
  
  factory VStoryTextStyle.fromTextTheme(TextTheme textTheme, ColorScheme colorScheme) {
    return VStoryTextStyle(
      contentStyle: textTheme.headlineSmall?.copyWith(
        color: Colors.white,
      ) ?? const TextStyle(color: Colors.white),
      backgroundColor: colorScheme.primary,
    );
  }
  
  factory VStoryTextStyle.cupertino() {
    return const VStoryTextStyle(
      contentStyle: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: Colors.blueGrey,
    );
  }
}