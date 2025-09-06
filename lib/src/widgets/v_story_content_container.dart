import 'package:flutter/material.dart';
import '../models/v_story_models.dart';
import '../controllers/v_story_controller.dart';
import 'v_story_content.dart';
import 'v_story_loading_indicator.dart';
import 'v_text_story_style.dart';

/// Container widget that combines all story elements.
class VStoryContentContainer extends StatelessWidget {
  /// The story to display
  final VBaseStory story;
  
  /// The story controller
  final VStoryController controller;
  
  /// Whether to show loading indicator
  final bool showLoading;
  
  /// Text story style
  final VTextStoryStyle? textStyle;
  
  /// Error widget builder
  final Widget Function(BuildContext, Object?)? errorBuilder;
  
  /// Loading widget builder
  final Widget Function(BuildContext)? loadingBuilder;
  
  /// Creates a story content container
  const VStoryContentContainer({
    super.key,
    required this.story,
    required this.controller,
    this.showLoading = true,
    this.textStyle,
    this.errorBuilder,
    this.loadingBuilder,
  });
  
  @override
  Widget build(BuildContext context) {

    if (showLoading && controller.state.storyState.isLoading) {
      return const VStoryLoadingIndicator();
    }
   return VStoryContent.fromStory(
      story: story,
      controller: controller,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      textStyle: textStyle,
    );
  }
}