import 'package:flutter/material.dart';
import '../models/v_story_models.dart';
import 'v_story_content.dart';
import 'v_text_story_style.dart';

/// Widget for displaying text stories.
class VTextStoryContent extends VStoryContent {
  /// Text story style
  final VTextStoryStyle? style;
  
  /// Creates a text story content widget
  const VTextStoryContent({
    super.key,
    required VTextStory super.story,
    required super.controller,
    super.isVisible,
    this.style,
  });
  
  VTextStory get textStory => story as VTextStory;
  
  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }
    
    final effectiveStyle = style ?? VTextStoryStyle.defaultStyle();
    
    return Container(
      decoration: BoxDecoration(
        color: effectiveStyle.backgroundGradient == null 
            ? textStory.backgroundColor
            : null,
        gradient: effectiveStyle.backgroundGradient,
      ),
      padding: effectiveStyle.padding,
      child: Center(
        child: Text(
          textStory.text,
          style: effectiveStyle.textStyle ?? TextStyle(
            color: textStory.textColor,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          textAlign: effectiveStyle.textAlign,
        ),
      ),
    );
  }
}