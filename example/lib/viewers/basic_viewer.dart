import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

import '../dialogs/story_dialogs.dart';

void openBasicViewer(
  BuildContext context,
  List<VStoryGroup> stories,
  int index,
  void Function(String) onSeenStoryAdded,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => VStoryViewer(
        storyGroups: stories,
        initialGroupIndex: index,
        config: const VStoryConfig(),
        onComplete: (group, item) => debugPrint('All stories complete'),
        onClose: (group, item) => debugPrint('Viewer closed'),
        onStoryViewed: (group, item) {
          debugPrint('Viewed: ${group.user.name}');
          onSeenStoryAdded('${group.user.id}_${item.createdAt}');
        },
        onReply: (group, item, text) {
          debugPrint('Reply to ${group.user.name}: $text');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reply sent to ${group.user.name}: $text')),
          );
        },
        onUserTap: (group, item) async {
          await showUserProfile(context, group.user);
          return true;
        },
        onMenuTap: (group, item) async {
          return await showStoryMenu(context, group, item);
        },
        onSwipeUp: (group, item) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Swipe up detected!')),
          );
        },
        onError: (group, item, error) {
          debugPrint('Error: $error');
        },
      ),
    ),
  );
}
