import 'package:flutter/material.dart';
import 'package:v_platform/v_platform.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

/// Example screen demonstrating VStoryViewer with all story types
class StoryViewerExampleScreen extends StatelessWidget {
  const StoryViewerExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Viewer with Carousel'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.swipe,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Story Viewer with Carousel',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Swipe horizontally to navigate between story groups!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _openStoryViewer(context),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('View Stories with Carousel'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                '✨ Features:\n'
                '• Horizontal swipe between groups\n'
                '• Auto-pause during swipe\n'
                '• All story types supported\n'
                '• Reactions, gestures, and more!',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openStoryViewer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VStoryViewer(
          storyGroups: _createMockStoryGroups(),
          config: const VStoryViewerConfig(
            enableHapticFeedback: true,
            pauseOnLongPress: true,
            dismissOnSwipeDown: true,
            autoMoveToNextGroup: true,
          ),
          callbacks: VStoryViewerCallbacks(
            onStoryChanged: (group, story, index) {
              debugPrint('Story changed: ${story.id} at index $index');
            },
            onGroupChanged: (group, index) {
              debugPrint('Group changed: ${group.user.username} at index $index');
            },
            onComplete: () {
              debugPrint('All stories completed');
            },
            onDismiss: () {
              debugPrint('Story viewer dismissed');
            },
            onError: (error) {
              debugPrint('Error: $error');
            },
          ),
        ),
      ),
    );
  }

  List<VStoryGroup> _createMockStoryGroups() {
    return [
      // Group 1: User 1 with text, image, and video stories
      VStoryGroup(
        user: VStoryUser(
          id: 'user_1',
          username: 'Alice',
          profilePicture: 'https://i.pravatar.cc/150?img=1',
        ),
        stories: [
          VTextStory(
            id: 'story_1',
            text: 'story_1',
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 3),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),


          VTextStory(
            id: 'story_11',
            text: 'Story number 2.',
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 3),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VVideoStory(
            id: 'story_2',
            media: VPlatformFile.fromUrl(
              networkUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
            ),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VTextStory(
            id: 'story_112',
            text: 'Story number 4.',
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 8),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VVideoStory(
            id: 'story_3',
            media: VPlatformFile.fromUrl(
              networkUrl:
                  'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
            ),
            duration: const Duration(seconds: 15),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VTextStory(
            id: 'story_1121',
            text: 'Story number 5 END.',
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 13),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
        ],
      ),

      // Group 2: User 2 with custom, text, and video stories
      VStoryGroup(
        user: VStoryUser(
          id: 'user_2',
          username: 'Bob',
          profilePicture: 'https://i.pravatar.cc/150?img=2',
        ),
        stories: [
          VCustomStory(
            id: 'story_4',
            builder: (context) => Container(
              color: Colors.orange,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.code, size: 80, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Custom Widget Story',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            duration: const Duration(seconds: 4),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VVideoStory(
            id: 'story_5',
            media: VPlatformFile.fromUrl(
              networkUrl:
                  'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
            ),
            duration: const Duration(seconds: 15),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VTextStory(
            id: 'story_6',
            text: 'This is Bob\'s story\n\nSwipe left to see more! 👉',
            backgroundColor: Colors.teal,
            duration: const Duration(seconds: 3),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
        ],
      ),

      // Group 3: User 3 with multiple images
      VStoryGroup(
        user: VStoryUser(
          id: 'user_3',
          username: 'Charlie',
          profilePicture: 'https://i.pravatar.cc/150?img=3',
        ),
        stories: [
          VImageStory(
            id: 'story_7',
            media: VPlatformFile.fromUrl(
              networkUrl: 'https://picsum.photos/400/600?random=2',
            ),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VImageStory(
            id: 'story_8',
            media: VPlatformFile.fromUrl(
              networkUrl: 'https://picsum.photos/400/600?random=3',
            ),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VTextStory(
            id: 'story_9',
            text: 'Thanks for watching! 🎉',
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
        ],
      ),

      // Group 4: User 4 with multiple video stories
      VStoryGroup(
        user: VStoryUser(
          id: 'user_4',
          username: 'Diana',
          profilePicture: 'https://i.pravatar.cc/150?img=4',
        ),
        stories: [
          VTextStory(
            id: 'story_10',
            text: 'Check out these cool videos! 🎥',
            backgroundColor: Colors.deepPurple,
            duration: const Duration(seconds: 3),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VVideoStory(
            id: 'story_11',
            media: VPlatformFile.fromUrl(
              networkUrl:
                  'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            ),
            duration: const Duration(seconds: 15),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VVideoStory(
            id: 'story_12',
            media: VPlatformFile.fromUrl(
              networkUrl:
                  'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
            ),
            duration: const Duration(seconds: 15),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VVideoStory(
            id: 'story_13',
            media: VPlatformFile.fromUrl(
              networkUrl:
                  'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
            ),
            duration: const Duration(seconds: 15),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VTextStory(
            id: 'story_14',
            text: 'Hope you enjoyed! 🌟',
            backgroundColor: Colors.indigo,
            duration: const Duration(seconds: 3),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
        ],
      ),
    ];
  }
}
