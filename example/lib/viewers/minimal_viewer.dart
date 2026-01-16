import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

void openMinimalViewer(
  BuildContext context,
  List<VStoryGroup> stories,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => VStoryViewer(
        storyGroups: stories,
        initialGroupIndex: 0,
        config: const VStoryConfig(
          showHeader: false,
          showProgressBar: true,
          showReplyField: false,
          autoPauseOnBackground: false,
        ),
      ),
    ),
  );
}
