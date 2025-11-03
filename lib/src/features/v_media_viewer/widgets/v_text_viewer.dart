import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../v_story_models/models/v_text_story.dart';

/// Widget for displaying text stories
///
/// Renders text with customizable styling and optional background.
class VTextViewer extends StatelessWidget {
  const VTextViewer({required this.story, super.key});

  final VTextStory story;

  @override
  Widget build(BuildContext context) {
    // Use SizedBox.expand to ensure full-screen gesture coverage
    // while keeping text content constrained to 500px width
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: DecoratedBox(
        decoration: _buildDecoration(),
        child: Center(
          child: Padding(
            padding: story.padding,
            child: Text(
              story.text,
              style:
                  story.textStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: story.textAlign,
              maxLines: story.maxLines,
              overflow: story.maxLines != null ? TextOverflow.ellipsis : null,
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    // Background image
    if (story.backgroundImageUrl != null) {
      return BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(story.backgroundImageUrl!),
          fit: BoxFit.cover,
        ),
      );
    }

    // Gradient background
    if (story.backgroundGradient != null) {
      return BoxDecoration(gradient: story.backgroundGradient);
    }

    // Solid color background
    return BoxDecoration(color: story.backgroundColor);
  }
}
