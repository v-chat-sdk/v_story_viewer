import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Multiple Empty Groups Navigation Tests', () {
    // Helper function to create test story groups
    VStoryGroup createTestGroup(String userId, int storyCount) {
      final stories = List.generate(
        storyCount,
        (index) => VImageStory.fromUrl(
          id: '${userId}_story_$index',
          url: 'https://example.com/$userId/image_$index.jpg',
          duration: const Duration(seconds: 3),
          createdAt: DateTime.now().subtract(Duration(hours: index)),
        ),
      );

      return VStoryGroup(
        user: VStoryUser.fromUrl(
          id: userId,
          name: 'User $userId',
          avatarUrl: 'https://example.com/$userId/profile.jpg',
        ),
        stories: stories,
      );
    }

    test('✅ nextStory() skips multiple consecutive empty groups', () async {
      print('\n📋 Testing multiple consecutive empty groups:');
      
      final storyList = VStoryList(
        groups: [
          createTestGroup('user1', 2),  // Has 2 stories
          VStoryGroup(                  // Empty
            user: VStoryUser.fromUrl(
              id: 'user2',
              name: 'User 2',
              avatarUrl: 'https://example.com/user2/profile.jpg',
            ),
            stories: [],
          ),
          VStoryGroup(                  // Empty
            user: VStoryUser.fromUrl(
              id: 'user3',
              name: 'User 3',
              avatarUrl: 'https://example.com/user3/profile.jpg',
            ),
            stories: [],
          ),
          VStoryGroup(                  // Empty
            user: VStoryUser.fromUrl(
              id: 'user4',
              name: 'User 4',
              avatarUrl: 'https://example.com/user4/profile.jpg',
            ),
            stories: [],
          ),
          createTestGroup('user5', 1),  // Has 1 story
        ],
      );

      final controller = VStoryController();
      controller.enablePersistence = false;
      await controller.initialize(storyList);

      // Navigate to last story of first group
      await controller.goToStory('user1_story_1');
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.state.currentStoryId, 'user1_story_1');
      print('   Starting at: user1_story_1 (last story of user1)');

      // Call nextStory - should skip all 3 empty groups and go to user5
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(controller.state.currentStoryId, 'user5_story_0');
      expect(controller.state.currentUserId, 'user5');
      print('   ✓ Successfully skipped 3 empty groups (user2, user3, user4)');
      print('   ✓ Navigated to user5_story_0');

      controller.dispose();
    });

    test('✅ previous() skips multiple consecutive empty groups', () async {
      print('\n📋 Testing previous() with multiple empty groups:');
      
      final storyList = VStoryList(
        groups: [
          createTestGroup('user1', 1),  // Has 1 story
          VStoryGroup(                  // Empty
            user: VStoryUser.fromUrl(
              id: 'user2',
              name: 'User 2',
              avatarUrl: 'https://example.com/user2/profile.jpg',
            ),
            stories: [],
          ),
          VStoryGroup(                  // Empty
            user: VStoryUser.fromUrl(
              id: 'user3',
              name: 'User 3',
              avatarUrl: 'https://example.com/user3/profile.jpg',
            ),
            stories: [],
          ),
          createTestGroup('user4', 2),  // Has 2 stories
        ],
      );

      final controller = VStoryController();
      controller.enablePersistence = false;
      await controller.initialize(storyList);

      // Navigate to first story of last group
      await controller.goToStory('user4_story_0');
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.state.currentStoryId, 'user4_story_0');
      print('   Starting at: user4_story_0 (first story of user4)');

      // Call previous - should skip 2 empty groups and go to user1's last story
      await controller.previous();
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(controller.state.currentStoryId, 'user1_story_0');
      expect(controller.state.currentUserId, 'user1');
      print('   ✓ Successfully skipped 2 empty groups (user2, user3) going backwards');
      print('   ✓ Navigated to user1_story_0');

      controller.dispose();
    });

    test('✅ All empty groups except first and last', () async {
      print('\n📋 Testing all middle groups empty:');
      
      final storyList = VStoryList(
        groups: [
          createTestGroup('user1', 1),  // Has 1 story
          VStoryGroup(                  // Empty
            user: VStoryUser.fromUrl(
              id: 'user2',
              name: 'User 2',
              avatarUrl: 'https://example.com/user2/profile.jpg',
            ),
            stories: [],
          ),
          VStoryGroup(                  // Empty
            user: VStoryUser.fromUrl(
              id: 'user3',
              name: 'User 3',
              avatarUrl: 'https://example.com/user3/profile.jpg',
            ),
            stories: [],
          ),
          VStoryGroup(                  // Empty
            user: VStoryUser.fromUrl(
              id: 'user4',
              name: 'User 4',
              avatarUrl: 'https://example.com/user4/profile.jpg',
            ),
            stories: [],
          ),
          VStoryGroup(                  // Empty
            user: VStoryUser.fromUrl(
              id: 'user5',
              name: 'User 5',
              avatarUrl: 'https://example.com/user5/profile.jpg',
            ),
            stories: [],
          ),
          createTestGroup('user6', 1),  // Has 1 story
        ],
      );

      final controller = VStoryController();
      controller.enablePersistence = false;
      await controller.initialize(storyList);

      expect(controller.state.currentStoryId, 'user1_story_0');
      print('   Starting at: user1_story_0');

      // Navigate forward - should skip all empty groups
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(controller.state.currentStoryId, 'user6_story_0');
      expect(controller.state.currentUserId, 'user6');
      print('   ✓ Skipped 4 empty groups to reach user6');

      // Navigate backward - should skip all empty groups
      await controller.previous();
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(controller.state.currentStoryId, 'user1_story_0');
      expect(controller.state.currentUserId, 'user1');
      print('   ✓ Skipped 4 empty groups going back to user1');

      controller.dispose();
    });

    test('✅ Only empty groups after current - should complete', () async {
      print('\n📋 Testing completion when only empty groups remain:');
      
      final storyList = VStoryList(
        groups: [
          createTestGroup('user1', 1),  // Has 1 story
          VStoryGroup(                  // Empty
            user: VStoryUser.fromUrl(
              id: 'user2',
              name: 'User 2',
              avatarUrl: 'https://example.com/user2/profile.jpg',
            ),
            stories: [],
          ),
          VStoryGroup(                  // Empty
            user: VStoryUser.fromUrl(
              id: 'user3',
              name: 'User 3',
              avatarUrl: 'https://example.com/user3/profile.jpg',
            ),
            stories: [],
          ),
        ],
      );

      final controller = VStoryController();
      controller.enablePersistence = false;
      await controller.initialize(storyList);

      var completedCalled = false;
      controller.onAllStoriesCompleted = () {
        completedCalled = true;
        print('   🎯 All stories completed callback triggered');
      };

      expect(controller.state.currentStoryId, 'user1_story_0');
      print('   Starting at: user1_story_0 (only non-empty group)');

      // Navigate forward - should complete since only empty groups remain
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(completedCalled, true);
      print('   ✓ Correctly completed when only empty groups remain');

      controller.dispose();
    });
  });

  print('\n🎉 All multiple empty groups tests completed!');
}