import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

void openCustomViewer(
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
          showEmojiButton: false,
          footerBuilder: (context, group, item, onReplyFocusChanged) =>
              SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Focus(
                      onFocusChange: onReplyFocusChanged,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Reply to ${group.user.name}...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.2),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (value) {
                          if (value.trim().isEmpty) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Reply: $value')),
                          );
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        onStoryViewed: (group, item) => debugPrint('Custom story viewed'),
        onSwipeUp: (group, item) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Swipe up on custom story!')),
          );
        },
      ),
    ),
  );
}
