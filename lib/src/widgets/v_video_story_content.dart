import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/v_story_models.dart';
import 'v_story_content.dart';
import 'v_video_mute_button.dart';

/// Widget for displaying video stories.
class VVideoStoryContent extends VStoryContent {
  /// Creates a video story content widget
  const VVideoStoryContent({
    super.key,
    required VVideoStory super.story,
    required super.controller,
    super.isVisible,
    super.errorBuilder,
    super.loadingBuilder,
  });
  
  VVideoStory get videoStory => story as VVideoStory;
  
  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }
    
    // Get video controller from story controller
    final videoController = controller.getVideoController(videoStory.id);
    
    if (videoController == null || !videoController.value.isInitialized) {
      return buildDefaultLoading(context);
    }
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player
        Center(
          child: AspectRatio(
            aspectRatio: videoController.value.aspectRatio,
            // Wrap VideoPlayer with IgnorePointer to prevent it from consuming gestures
            // This allows our gesture coordinator to handle all gestures properly
            child: IgnorePointer(
              child: VideoPlayer(videoController),
            ),
          ),
        ),
        // Mute button
        Positioned(
          bottom: 100,
          right: 16,
          child: VVideoMuteButton(
            controller: controller,
            videoStory: videoStory,
          ),
        ),
      ],
    );
  }
}