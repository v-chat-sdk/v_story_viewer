import 'package:flutter/material.dart';
import 'package:v_platform/v_platform.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

import 'cache_manager_test_screen.dart';
import 'progress_test_screen.dart';

/// Home screen with buttons to test each feature
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('V Story Viewer - Feature Tests'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFeatureCard(
            context,
            title: 'Progress Bar',
            description: 'Test segmented progress bar animations',
            icon: Icons.linear_scale,
            color: Colors.blue,
            onTap: () => _navigate(context, const ProgressTestScreen()),
          ),
          _buildFeatureCard(
            context,
            title: 'Cache Manager',
            description: 'Test media caching and preloading',
            icon: Icons.storage,
            color: Colors.orange,
            onTap: () => _navigate(context, const CacheManagerTestScreen()),
          ),

          _buildFeatureCard(
            context,
            title: 'Full Story Viewer',
            description: 'Test complete story viewing experience',
            icon: Icons.video_library,
            color: Colors.deepOrange,
            onTap: () => _openStoryViewer(context),
          ),
        ],
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
            groupSwipeDirection: Axis.horizontal,
          ),
          headerConfig: VHeaderConfig(
            showPlaybackControls: true,
            actions: [],
            controlButtonColor: Colors.white,
            actionButtonColor: Colors.white,
            closeButtonColor: Colors.white,
          ),
          callbacks: VStoryViewerCallbacks(
            onStoryChanged: (group, story, index) {
              debugPrint('Story changed: ${story.id} at index $index');
            },
            onGroupChanged: (group, index) {
              debugPrint(
                'Group changed: ${group.user.username} at index $index',
              );
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
          localization: VLocalization.ar(),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
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
            groupId: "user_1",
            text: 'story_1',
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 3),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),

          VTextStory(
            id: 'story_11',
            groupId: "user_1",
            text: 'Story number 2.',
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 3),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VVideoStory(
            id: 'story_2',
            groupId: "user_1",
            media: VPlatformFile.fromUrl(
              networkUrl:
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
            ),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VTextStory(
            id: 'story_112',
            text: 'Story number 4.',
            groupId: "user_1",
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 8),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VVideoStory(
            id: 'story_3',
            groupId: "user_1",
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
            groupId: "user_1",
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
            groupId: "user_2",
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
            groupId: "user_2",
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
            groupId: "user_2",
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
            groupId: "user_3",
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
            groupId: "user_3",
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
            groupId: "user_3",
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
            groupId: "user_4",
            text: 'Check out these cool videos! 🎥',
            backgroundColor: Colors.deepPurple,
            duration: const Duration(seconds: 3),
            createdAt: DateTime.now(),
            isViewed: false,
            isReacted: false,
          ),
          VVideoStory(
            id: 'story_11',
            groupId: "user_4",
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
            groupId: "user_4",
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
            groupId: "user_4",
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
            groupId: "user_4",
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
