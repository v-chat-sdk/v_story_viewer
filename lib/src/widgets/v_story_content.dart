import 'package:flutter/material.dart';
import '../models/v_story_models.dart';
import '../controllers/v_story_controller.dart';
import '../utils/v_error_recovery.dart';
import '../utils/v_error_logger.dart';
import 'v_story_loading_indicator.dart';
import 'v_image_story_content.dart';
import 'v_video_story_content.dart';
import 'v_text_story_content.dart';
import 'v_custom_story_content.dart';
import 'v_text_story_style.dart';

/// Base widget for displaying story content.
abstract class VStoryContent extends StatelessWidget {
  /// The story to display
  final VBaseStory story;
  
  /// The story controller
  final VStoryController controller;
  
  /// Whether the story is currently visible
  final bool isVisible;
  
  /// Error widget builder
  final Widget Function(BuildContext, Object?)? errorBuilder;
  
  /// Loading widget builder
  final Widget Function(BuildContext)? loadingBuilder;
  
  /// Creates a story content widget
  const VStoryContent({
    super.key,
    required this.story,
    required this.controller,
    this.isVisible = true,
    this.errorBuilder,
    this.loadingBuilder,
  });
  
  /// Factory constructor to create appropriate content widget
  factory VStoryContent.fromStory({
    Key? key,
    required VBaseStory story,
    required VStoryController controller,
    bool isVisible = true,
    Widget Function(BuildContext, Object?)? errorBuilder,
    Widget Function(BuildContext)? loadingBuilder,
    VTextStoryStyle? textStyle,
  }) {
    switch (story) {
      case VImageStory():
        return VImageStoryContent(
          key: key,
          story: story,
          controller: controller,
          isVisible: isVisible,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
        );
      case VVideoStory():
        return VVideoStoryContent(
          key: key,
          story: story,
          controller: controller,
          isVisible: isVisible,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
        );
      case VTextStory():
        return VTextStoryContent(
          key: key,
          story: story,
          controller: controller,
          isVisible: isVisible,
          style: textStyle,
        );
      case VCustomStory():
        return VCustomStoryContent(
          key: key,
          story: story,
          controller: controller,
          isVisible: isVisible,
        );
      default:
        throw UnsupportedError('Unknown story type: ${story.runtimeType}');
    }
  }
  
  /// Default loading widget
  Widget buildDefaultLoading(BuildContext context) {
    return loadingBuilder?.call(context) ??
        const VStoryLoadingIndicator();
  }
  
  /// Default error widget
  Widget buildDefaultError(BuildContext context, Object? error) {
    // Convert to VStoryError if needed
    final storyError = error is VStoryError 
        ? error 
        : VGenericError('Failed to load content', error);
    
    // Log the error
    VErrorLogger.logError(storyError);
    
    return errorBuilder?.call(context, error) ??
        VErrorRecovery.buildErrorPlaceholder(
          error: storyError,
          onRetry: storyError.isRetryable ? () {
            // Trigger reload through controller
            controller.reload();
          } : null,
        );
  }
}

