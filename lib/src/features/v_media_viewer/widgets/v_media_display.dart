import 'package:flutter/material.dart';

import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_custom_story.dart';
import '../../v_story_models/models/v_image_story.dart';
import '../../v_story_models/models/v_text_story.dart';
import '../../v_story_models/models/v_video_story.dart';
import '../controllers/v_base_media_controller.dart';
import '../controllers/v_video_controller.dart';
import 'v_custom_viewer.dart';
import 'v_image_viewer.dart';
import 'v_text_viewer.dart';
import 'v_video_viewer.dart';

/// Main widget for displaying story content
///
/// Switches between different viewer widgets based on story type.
class VMediaDisplay extends StatelessWidget {
  const VMediaDisplay({
    required this.controller,
    required this.story,
    super.key,
  });

  final VBaseMediaController controller;
  final VBaseStory story;

  @override
  Widget build(BuildContext context) {
    // Show loading indicator
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show error
    if (controller.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage ?? 'Failed to load story',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Display appropriate viewer based on story type
    return switch (story) {
      VImageStory() => VImageViewer(story: story as VImageStory),
      VVideoStory() => VVideoViewer(
          controller: controller as VVideoController,
        ),
      VTextStory() => VTextViewer(story: story as VTextStory),
      VCustomStory() => VCustomViewer(story: story as VCustomStory),
      _ => const Center(
          child: Text(
            'Unknown story type',
            style: TextStyle(color: Colors.white),
          ),
        ),
    };
  }
}
