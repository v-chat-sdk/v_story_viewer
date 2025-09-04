import 'package:flutter/widgets.dart';
import 'story_type.dart';
import 'v_base_story.dart';

/// A story that displays text content with customizable styling.
final class VTextStory extends VBaseStory {
  /// The main text content to display
  final String text;
  
  /// Text style for the content
  final TextStyle? textStyle;
  
  /// Background color for the text story
  final Color backgroundColor;
  
  /// Text alignment
  final TextAlign textAlign;
  
  /// Maximum lines before truncation
  final int? maxLines;
  
  /// How text overflow should be handled
  final TextOverflow overflow;
  
  /// Padding around the text
  final EdgeInsets padding;
  
  /// Background gradient (overrides backgroundColor if provided)
  final Gradient? backgroundGradient;
  
  /// Gets the text color from textStyle or defaults to white
  Color get textColor => textStyle?.color ?? const Color(0xFFFFFFFF);
  
  /// Creates a text story with the specified content and styling
  const VTextStory({
    required super.id,
    required this.text,
    required super.duration,
    this.textStyle,
    this.backgroundColor = const Color(0xFF1B1B1B),
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.padding = const EdgeInsets.all(24.0),
    this.backgroundGradient,
    super.viewedAt,
    required super.createdAt,
    super.reactedAt,
    super.metadata,
  }) : super(storyType: StoryType.text);
  
  /// Factory constructor for creating a simple text story
  factory VTextStory.simple({
    required String id,
    required String text,
    Duration? duration,
    TextStyle? textStyle,
    Color backgroundColor = const Color(0xFF1B1B1B),
    DateTime? viewedAt,
    required DateTime createdAt,
    DateTime? reactedAt,
    Map<String, dynamic>? metadata,
  }) {
    // Calculate duration based on text length if not provided
    final calculatedDuration = duration ?? _calculateDuration(text);
    
    return VTextStory(
      id: id,
      text: text,
      duration: calculatedDuration,
      textStyle: textStyle,
      backgroundColor: backgroundColor,
      viewedAt: viewedAt,
      createdAt: createdAt,
      reactedAt: reactedAt,
      metadata: metadata,
    );
  }
  
  /// Factory constructor for creating a gradient text story
  factory VTextStory.gradient({
    required String id,
    required String text,
    Duration? duration,
    required Gradient gradient,
    TextStyle? textStyle,
    TextAlign textAlign = TextAlign.center,
    EdgeInsets padding = const EdgeInsets.all(24.0),
    DateTime? viewedAt,
    required DateTime createdAt,
    DateTime? reactedAt,
    Map<String, dynamic>? metadata,
  }) {
    final calculatedDuration = duration ?? _calculateDuration(text);
    
    return VTextStory(
      id: id,
      text: text,
      duration: calculatedDuration,
      textStyle: textStyle,
      backgroundGradient: gradient,
      textAlign: textAlign,
      padding: padding,
      viewedAt: viewedAt,
      createdAt: createdAt,
      reactedAt: reactedAt,
      metadata: metadata,
    );
  }
  
  /// Whether this story has a gradient background
  bool get hasGradient => backgroundGradient != null;
  
  /// Gets the effective background (gradient or solid color)
  dynamic get effectiveBackground => backgroundGradient ?? backgroundColor;
  
  /// Calculate duration based on text length (words per minute heuristic)
  static Duration _calculateDuration(String text) {
    // Assume average reading speed of 200 words per minute
    const wordsPerMinute = 200;
    const minDuration = 3; // Minimum 3 seconds
    const maxDuration = 15; // Maximum 15 seconds
    
    final wordCount = text.split(' ').length;
    final seconds = ((wordCount / wordsPerMinute) * 60).clamp(
      minDuration,
      maxDuration,
    );
    
    return Duration(seconds: seconds.toInt());
  }
  
  @override
  VTextStory copyWith({
    String? id,
    String? text,
    Duration? duration,
    TextStyle? textStyle,
    Color? backgroundColor,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    EdgeInsets? padding,
    Gradient? backgroundGradient,
    DateTime? viewedAt,
    DateTime? createdAt,
    DateTime? reactedAt,
    Map<String, dynamic>? metadata,
    StoryType? storyType,
  }) {
    return VTextStory(
      id: id ?? this.id,
      text: text ?? this.text,
      duration: duration ?? this.duration,
      textStyle: textStyle ?? this.textStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textAlign: textAlign ?? this.textAlign,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      padding: padding ?? this.padding,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      viewedAt: viewedAt ?? this.viewedAt,
      createdAt: createdAt ?? this.createdAt,
      reactedAt: reactedAt ?? this.reactedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}