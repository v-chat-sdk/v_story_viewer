import 'package:flutter/material.dart';

/// Style configuration for text stories.
class VTextStoryStyle {
  /// Background color
  final Color backgroundColor;
  
  /// Text color
  final Color textColor;
  
  /// Text style
  final TextStyle? textStyle;
  
  /// Text alignment
  final TextAlign textAlign;
  
  /// Padding around text
  final EdgeInsets padding;
  
  /// Background gradient
  final Gradient? backgroundGradient;
  
  /// Creates a text story style
  const VTextStoryStyle({
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.textStyle,
    this.textAlign = TextAlign.center,
    this.padding = const EdgeInsets.all(24),
    this.backgroundGradient,
  });
  
  /// Creates a default style
  factory VTextStoryStyle.defaultStyle() => const VTextStoryStyle();
  
  /// Creates a gradient style
  factory VTextStoryStyle.gradient({
    required List<Color> colors,
    Color textColor = Colors.white,
    TextStyle? textStyle,
  }) {
    return VTextStoryStyle(
      textColor: textColor,
      textStyle: textStyle,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
    );
  }
}