import 'package:flutter/material.dart';
import '../models/v_story_models.dart';
import 'v_story_content.dart';

/// Widget for displaying custom stories.
class VCustomStoryContent extends VStoryContent {
  /// Creates a custom story content widget
  const VCustomStoryContent({
    super.key,
    required VCustomStory super.story,
    required super.controller,
    super.isVisible,
  });
  
  VCustomStory get customStory => story as VCustomStory;
  
  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }
    
    // Use the builder from the custom story
    return customStory.builder(context);
  }
}