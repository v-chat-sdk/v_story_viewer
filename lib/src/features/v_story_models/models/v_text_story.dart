import 'package:flutter/material.dart';

import 'story_type.dart';
import 'v_base_story.dart';

/// Text story model for displaying text content
@immutable
class VTextStory extends VBaseStory {
  const VTextStory({
    required super.id,
    required this.text,
    required super.createdAt,
    required super.groupId,
    this.backgroundColor = Colors.blue,
    super.duration = const Duration(seconds: 3),
    super.isViewed,
    super.isReacted,
    super.metadata,
    super.caption,
    super.source,
    this.textStyle,
    this.maxLines,
    this.textAlign = TextAlign.center,
    this.backgroundGradient,
    this.backgroundImageUrl,
    this.padding = const EdgeInsets.all(24),
  }): super(storyType: VStoryType.text) ;

  /// The main text content of the story
  final String text;

  /// Background color for the text story
  final Color backgroundColor;

  /// Text style for the story content
  final TextStyle? textStyle;

  /// Maximum lines before truncation
  final int? maxLines;

  /// Text alignment
  final TextAlign textAlign;

  /// Gradient background (if null, backgroundColor is used)
  final Gradient? backgroundGradient;

  /// Background image URL (displayed behind text)
  final String? backgroundImageUrl;

  /// Padding around the text
  final EdgeInsets padding;

  @override
  VTextStory copyWith({
    String? id,
    String? text,
    Color? backgroundColor,
    Duration? duration,
    DateTime? createdAt,
    bool? isViewed,
    String? groupId,
    int? maxLines,
    bool? isReacted,
    Map<String, dynamic>? metadata,
    TextStyle? textStyle,
    TextAlign? textAlign,
    Gradient? backgroundGradient,
    String? backgroundImageUrl,
    EdgeInsets? padding,
    String? caption,
    String? source,
  }) {
    return VTextStory(
      id: id ?? this.id,
      text: text ?? this.text,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      duration: duration ?? this.duration,
      groupId: groupId ?? this.groupId,
      createdAt: createdAt ?? this.createdAt,
      maxLines: maxLines ?? this.maxLines,
      isViewed: isViewed ?? this.isViewed,
      isReacted: isReacted ?? this.isReacted,
      metadata: metadata ?? this.metadata,
      caption: caption ?? this.caption,
      source: source ?? this.source,
      textStyle: textStyle ?? this.textStyle,
      textAlign: textAlign ?? this.textAlign,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      padding: padding ?? this.padding,
    );
  }

  /// Calculate duration based on text length using WPM heuristic
  Duration calculateReadingDuration({int wordsPerMinute = 180}) {
    final wordCount = text.split(' ').length;
    final seconds = (wordCount / wordsPerMinute * 60).ceil();
    final calculatedDuration = Duration(seconds: seconds.clamp(2, 10));
    return duration ?? calculatedDuration;
  }
}
