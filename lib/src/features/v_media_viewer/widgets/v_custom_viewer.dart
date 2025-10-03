import 'package:flutter/material.dart';

import '../../v_story_models/models/v_custom_story.dart';

/// Widget for displaying custom widget stories
///
/// Invokes user-provided builder function to render arbitrary widgets.
class VCustomViewer extends StatelessWidget {
  const VCustomViewer({
    required this.story,
    super.key,
  });

  final VCustomStory story;

  @override
  Widget build(BuildContext context) {
    try {
      // Invoke user-provided builder
      return story.builder(context);
    } catch (error) {
      // Use custom error builder if provided
      if (story.errorBuilder != null) {
        return story.errorBuilder!(context, error);
      }

      // Default error widget
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading custom story',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }
  }
}
