import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

void openMusicViewer(
  BuildContext context,
  List<VStoryGroup> stories,
  int index,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (viewerContext) => VStoryViewer(
        storyGroups: stories,
        initialGroupIndex: index,
        config: const VStoryConfig(),
        onMusicError: (group, item, error) {
          debugPrint('Background music failed for ${group.user.name}: $error');
          ScaffoldMessenger.maybeOf(viewerContext)?.showSnackBar(
            SnackBar(
              content: Text(
                'Music could not play. The story will continue: $error',
              ),
            ),
          );
        },
        onError: (group, item, error) {
          debugPrint('Story failed for ${group.user.name}: $error');
        },
        onPause: (group, item) => debugPrint(
          'Paused story and music for ${group.user.name}',
        ),
        onResume: (group, item) => debugPrint(
          'Resumed story and music for ${group.user.name}',
        ),
        onSkip: (group, item) => debugPrint(
          'Skipped story from ${group.user.name}',
        ),
      ),
    ),
  );
}
