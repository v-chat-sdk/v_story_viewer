import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

/// Debug mock data generator with numbered users and stories for testing
class DebugMockData {
  /// Creates debug story groups with clear numbering for testing
  static List<VStoryGroup> createDebugStoryGroups({
    int userCount = 5,
    int storiesPerUser = 6,
    bool includeAllTypes = true,
  }) {
    final List<VStoryGroup> groups = [];

    for (int userIndex = 1; userIndex <= userCount; userIndex++) {
      final stories = _createDebugStories(
        userId: userIndex,
        storyCount: storiesPerUser,
        includeAllTypes: includeAllTypes,
      );

      groups.add(
        VStoryGroup(
          user: VStoryUser.fromUrl(
            id: 'user_$userIndex',
            name: 'User $userIndex',
            avatarUrl: 'https://i.pravatar.cc/150?img=$userIndex',
          ),
          stories: stories,
        ),
      );
    }

    return groups;
  }

  /// Creates text-only story groups for focused testing
  static List<VStoryGroup> createTextOnlyGroups({
    int userCount = 3,
    int storiesPerUser = 3,
  }) {
    final List<VStoryGroup> groups = [];
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    for (int userIndex = 1; userIndex <= userCount; userIndex++) {
      final List<VBaseStory> stories = [];

      for (int storyIndex = 1; storyIndex <= storiesPerUser; storyIndex++) {
        final colorIndex = (userIndex * storyIndex - 1) % colors.length;
        
        stories.add(
          VTextStory(
            id: 'user_${userIndex}_text_story_$storyIndex',
            text: 'User $userIndex\nText Story $storyIndex',
            backgroundColor: colors[colorIndex],
            textStyle: TextStyle(
              fontSize: storyIndex == 1 ? 20 : 24,
              fontWeight: storyIndex % 2 == 0 ? FontWeight.bold : FontWeight.normal,
              color: Colors.white,
            ),
            duration: Duration(seconds: 3 + storyIndex),
            createdAt: DateTime.now().subtract(Duration(hours: storyIndex)),
          ),
        );
      }

      groups.add(
        VStoryGroup(
          user: VStoryUser.fromUrl(
            id: 'text_user_$userIndex',
            name: 'Text User $userIndex',
            avatarUrl: 'https://i.pravatar.cc/150?img=${userIndex + 10}',
          ),
          stories: stories,
        ),
      );
    }

    return groups;
  }

  /// Creates mixed story types for comprehensive testing
  static List<VBaseStory> _createDebugStories({
    required int userId,
    required int storyCount,
    required bool includeAllTypes,
  }) {
    final List<VBaseStory> stories = [];
    
    for (int storyIndex = 1; storyIndex <= storyCount; storyIndex++) {
      final storyType = includeAllTypes 
        ? storyIndex % 4 
        : 0; // 0 = image, 1 = video, 2 = text, 3 = custom

      switch (storyType) {
        case 0: // Image story
          stories.add(
            VImageStory.fromUrl(
              id: 'user_${userId}_image_story_$storyIndex',
              url: 'https://picsum.photos/720/1280?random=$userId$storyIndex',
              duration: const Duration(seconds: 5),
              caption: 'User $userId - Image Story $storyIndex\nID: u${userId}s$storyIndex',
              createdAt: DateTime.now().subtract(Duration(hours: storyIndex * 2)),
            ),
          );
          break;

        case 1: // Video story
          stories.add(
            VVideoStory.fromUrl(
              id: 'user_${userId}_video_story_$storyIndex',
              url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
              createdAt: DateTime.now().subtract(Duration(hours: storyIndex * 3)),
            ),
          );
          break;

        case 2: // Text story
          final colors = [Colors.blue, Colors.green, Colors.purple, Colors.orange];
          stories.add(
            VTextStory(
              id: 'user_${userId}_text_story_$storyIndex',
              text: 'User $userId Story $storyIndex\n\nThis is text story number $storyIndex for user $userId.\n\nStory ID: u${userId}s$storyIndex\n\nTest Duration: ${3 + storyIndex}s',
              backgroundColor: colors[storyIndex % colors.length],
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              duration: Duration(seconds: 3 + storyIndex),
              createdAt: DateTime.now().subtract(Duration(hours: storyIndex * 4)),
            ),
          );
          break;

        case 3: // Custom story
          stories.add(
            VCustomStory(
              id: 'user_${userId}_custom_story_$storyIndex',
              duration: const Duration(seconds: 7),
              builder: (context) => _buildCustomStory(context, userId, storyIndex),
              createdAt: DateTime.now().subtract(Duration(hours: storyIndex * 5)),
            ),
          );
          break;
      }
    }

    return stories;
  }

  /// Builds custom story widget
  static Widget _buildCustomStory(BuildContext context, int userId, int storyIndex) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade400,
            Colors.pink.shade400,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'Custom Story',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'User $userId - Story $storyIndex',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ID: u${userId}s$storyIndex',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates error test scenarios
  static List<VStoryGroup> createErrorTestGroups() {
    return [
      VStoryGroup(
        user: VStoryUser.fromUrl(
          id: 'error_test_user',
          name: 'Error Test User',
          avatarUrl: 'https://invalid-url-that-will-fail.com/image.jpg',
        ),
        stories: [
          VImageStory.fromUrl(
            id: 'invalid_image',
            url: 'https://invalid-image-url.com/404.jpg',
            duration: const Duration(seconds: 5),
            caption: 'This image should fail to load',
            createdAt: DateTime.now(),
          ),
          VVideoStory.fromUrl(
            id: 'invalid_video',
            url: 'https://invalid-video-url.com/404.mp4',
            createdAt: DateTime.now(),
          ),
          VTextStory(
            id: 'valid_text',
            text: 'This text story should work fine after the errors',
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            createdAt: DateTime.now(),
          ),
        ],
      ),
    ];
  }

  /// Creates performance test scenarios with many stories
  static List<VStoryGroup> createPerformanceTestGroups() {
    return createDebugStoryGroups(
      userCount: 10,
      storiesPerUser: 20,
      includeAllTypes: true,
    );
  }

  /// Creates edge case test scenarios
  static List<VStoryGroup> createEdgeCaseGroups() {
    return [
      // User with single story
      VStoryGroup(
        user: VStoryUser.fromUrl(
          id: 'single_story_user',
          name: 'Single Story User',
          avatarUrl: 'https://i.pravatar.cc/150?img=100',
        ),
        stories: [
          VTextStory(
            id: 'single_story',
            text: 'This user has only one story',
            backgroundColor: Colors.indigo,
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now(),
          ),
        ],
      ),
      // User with very long username
      VStoryGroup(
        user: VStoryUser.fromUrl(
          id: 'long_name_user',
          name: 'User With Very Long Username That Should Be Truncated',
          avatarUrl: 'https://i.pravatar.cc/150?img=101',
        ),
        stories: [
          VTextStory(
            id: 'long_name_story',
            text: 'Testing long username display',
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            createdAt: DateTime.now(),
          ),
        ],
      ),
      // User with emoji in content
      VStoryGroup(
        user: VStoryUser.fromUrl(
          id: 'emoji_user',
          name: 'Emoji User 🎉',
          avatarUrl: 'https://i.pravatar.cc/150?img=102',
        ),
        stories: [
          VTextStory(
            id: 'emoji_story',
            text: '🎉 Party Time! 🎊\n\n🚀 Testing emojis 🌟\n\n😀😃😄😁😆',
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 4),
            createdAt: DateTime.now(),
          ),
        ],
      ),
    ];
  }
}