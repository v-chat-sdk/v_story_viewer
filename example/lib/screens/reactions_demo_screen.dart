import 'package:flutter/material.dart';
import 'package:v_platform/v_platform.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

/// Demo screen showcasing reaction feature
class ReactionsDemoScreen extends StatelessWidget {
  const ReactionsDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reactions Demo'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              'Double Tap Reaction Demo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Double tap on any story to send a ❤️ reaction with animated feedback',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _openStoriesWithReactions(context),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('View Stories'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openStoriesWithReactions(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VStoryViewer(
          storyGroups: _createReactionDemoStories(),
          config: const VStoryViewerConfig(
            enableHapticFeedback: true,
            pauseOnLongPress: true,
            dismissOnSwipeDown: true,
            autoMoveToNextGroup: true,
          ),
          callbacks: VStoryViewerCallbacks(
            onStoryChanged: (group, story, index) {
              debugPrint('📖 Story changed: ${story.id}');
            },
            onComplete: () {
              debugPrint('✅ All stories completed');
            },
            onDismiss: () {
              debugPrint('👋 Dismissed');
            },
          ),
        ),
      ),
    );
  }

  List<VStoryGroup> _createReactionDemoStories() {
    final durationController = VDurationController();

    return [
      VStoryGroup(
        user: VStoryUser(
          id: 'demo_user_1',
          username: 'Sarah',
          profilePicture: 'https://i.pravatar.cc/150?img=5',
        ),
        stories: [
          VTextStory(
            id: 'text_1',
            text: '❤️ Double tap me!\n\nTry double tapping this story to send a reaction',
            backgroundColor: Colors.deepPurple,
            duration: durationController.calculateDuration(
              VTextStory(
                id: 'temp',
                text: '❤️ Double tap me!\n\nTry double tapping this story to send a reaction',
                createdAt: DateTime.now(),
                isViewed: false,
                isReacted: false,
              ),
            ),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VImageStory(
            id: 'image_1',
            media: VPlatformFile.fromUrl(
              networkUrl: 'https://picsum.photos/1080/1920?random=1',
            ),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VTextStory(
            id: 'text_2',
            text: 'You can also react to image and video stories!\n\nJust double tap anywhere ❤️',
            backgroundColor: Colors.pink,
            duration: durationController.calculateDuration(
              VTextStory(
                id: 'temp',
                text: 'You can also react to image and video stories!\n\nJust double tap anywhere ❤️',
                createdAt: DateTime.now(),
                isViewed: false,
                isReacted: false,
              ),
            ),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
        ],
      ),
      VStoryGroup(
        user: VStoryUser(
          id: 'demo_user_2',
          username: 'Alex',
          profilePicture: 'https://i.pravatar.cc/150?img=12',
        ),
        stories: [
          VImageStory(
            id: 'image_2',
            media: VPlatformFile.fromUrl(
              networkUrl: 'https://picsum.photos/1080/1920?random=2',
            ),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VTextStory(
            id: 'text_3',
            text: 'Reactions work seamlessly with all story types!\n\n❤️ ❤️ ❤️',
            backgroundColor: Colors.orange,
            duration: durationController.calculateDuration(
              VTextStory(
                id: 'temp',
                text: 'Reactions work seamlessly with all story types!\n\n❤️ ❤️ ❤️',
                createdAt: DateTime.now(),
                isViewed: false,
                isReacted: false,
              ),
            ),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
        ],
      ),
    ];
  }
}
