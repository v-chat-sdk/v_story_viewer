import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../controllers/v_video_controller.dart';

/// Widget for displaying video stories
///
/// Displays video content using VideoPlayer with aspect ratio handling.
class VVideoViewer extends StatelessWidget {
  const VVideoViewer({
    required this.controller,
    super.key,
  });

  final VVideoController controller;

  @override
  Widget build(BuildContext context) {
    final videoController = controller.videoPlayerController;

    // No video controller
    if (videoController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Video not initialized
    if (!videoController.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Display video
    return Center(
      child: AspectRatio(
        aspectRatio: videoController.value.aspectRatio,
        child: VideoPlayer(videoController),
      ),
    );
  }
}
