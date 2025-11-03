import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../controllers/v_video_controller.dart';

/// Widget for displaying video stories
///
/// Displays video content using VideoPlayer with aspect ratio handling.
class VVideoViewer extends StatelessWidget {
  const VVideoViewer({required this.controller, super.key});

  final VVideoController controller;

  @override
  Widget build(BuildContext context) {
    final videoController = controller.videoPlayerController;

    // No video controller
    if (videoController == null) {
      return SizedBox();
    }

    // Video not initialized
    if (!videoController.value.isInitialized) {
      return SizedBox();
    }

    // Display video with full-screen gesture coverage
    return SizedBox.expand(
      child: AspectRatio(
        aspectRatio: videoController.value.aspectRatio,
        child: VideoPlayer(videoController),
      ),
    );
  }
}
