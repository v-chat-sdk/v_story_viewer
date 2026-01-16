import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';
import '../dialogs/story_dialogs.dart';

void openAdvancedViewer(
  BuildContext context,
  List<VStoryGroup> stories,
  int index,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => VStoryViewer(
        storyGroups: stories,
        initialGroupIndex: index,
        config: VStoryConfig(
          // Custom colors
          progressColor: Colors.amber,
          progressBackgroundColor: Colors.amber.withValues(alpha: 0.3),
          // Custom loading builder
          loadingBuilder: (context) => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.amber),
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          // Custom error builder
          errorBuilder: (context, error, retry) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Oops! Something went wrong',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
          // i18n texts
          texts: const VStoryTexts(
            replyHint: 'Write a reply...',
            errorLoadingMedia: 'Could not load content',
            tapToRetry: 'Tap here to retry',
          ),
        ),
        onStoryViewed: (group, item) => debugPrint('Advanced viewed'),
        onReply: (group, item, text) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reply: $text')),
          );
        },
        onMenuTap: (group, item) async =>
            await showStoryMenu(context, group, item),
      ),
    ),
  );
}
