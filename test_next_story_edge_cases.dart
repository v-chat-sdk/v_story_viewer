import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('VStoryController.nextStory() Edge Cases', () {
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

    test('✅ Test exact nextStory() logic - within group navigation', () async {
      print('\n📋 Testing nextStory() within group navigation logic:');
      
      final storyList = VStoryList(
        groups: [
          createTestGroup('user1', 3),
          createTestGroup('user2', 2),
        ],
      );

      final controller = VStoryController();
      controller.enablePersistence = false;
      await controller.initialize(storyList);

      // Verify initial state
      expect(controller.state.currentStoryId, 'user1_story_0');
      print('   Initial story: user1_story_0');

      // Test the exact logic from nextStory():
      // 1. Find current group
      final currentGroup = storyList.findGroupContainingStory(controller.state.currentStoryId!);
      expect(currentGroup?.user.id, 'user1');
      print('   Current group found: user1');

      // 2. Try next story in current group
      final nextStoryInGroup = currentGroup?.getNextStory(controller.state.currentStoryId!);
      expect(nextStoryInGroup?.id, 'user1_story_1');
      print('   Next story in group: user1_story_1');

      // 3. Execute nextStory and verify
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.state.currentStoryId, 'user1_story_1');
      print('   ✓ Successfully navigated to user1_story_1');

      controller.dispose();
    });

    test('✅ Test exact nextStory() logic - group transition', () async {
      print('\n📋 Testing nextStory() group transition logic:');
      
      final storyList = VStoryList(
        groups: [
          createTestGroup('user1', 2),
          createTestGroup('user2', 2),
        ],
      );

      final controller = VStoryController();
      controller.enablePersistence = false;
      await controller.initialize(storyList);

      // Go to last story of first group
      await controller.goToStory('user1_story_1');
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.state.currentStoryId, 'user1_story_1');
      print('   Starting at: user1_story_1 (last story of group)');

      // Test the exact logic from nextStory():
      // 1. Find current group
      final currentGroup = storyList.findGroupContainingStory(controller.state.currentStoryId!);
      expect(currentGroup?.user.id, 'user1');
      print('   Current group: user1');

      // 2. Try next story in current group (should be null)
      final nextStoryInGroup = currentGroup?.getNextStory(controller.state.currentStoryId!);
      expect(nextStoryInGroup, null);
      print('   Next story in group: null (end of group)');

      // 3. Get next group
      final nextGroup = storyList.getNextGroup(currentGroup!.user.id);
      expect(nextGroup?.user.id, 'user2');
      print('   Next group found: user2');

      // 4. Verify next group has stories
      expect(nextGroup?.stories.isEmpty, false);
      print('   Next group has ${nextGroup?.stories.length} stories');

      // 5. Find first story to show (without persistence, should be first story)
      final firstStory = nextGroup?.firstUnviewed ?? nextGroup?.stories.first;
      expect(firstStory?.id, 'user2_story_0');
      print('   First story to show: user2_story_0');

      // 6. Execute nextStory and verify
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.state.currentStoryId, 'user2_story_0');
      expect(controller.state.currentUserId, 'user2');
      print('   ✓ Successfully navigated to user2_story_0');

      controller.dispose();
    });

    test('✅ Test exact nextStory() logic - end of all stories', () async {
      print('\n📋 Testing nextStory() end of all stories logic:');
      
      final storyList = VStoryList(
        groups: [
          createTestGroup('user1', 1),
          createTestGroup('user2', 1),
        ],
      );

      final controller = VStoryController();
      controller.enablePersistence = false;
      await controller.initialize(storyList);

      // Go to last story of last group
      await controller.goToStory('user2_story_0');
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.state.currentStoryId, 'user2_story_0');
      print('   Starting at: user2_story_0 (last story of last group)');

      // Set up completion callback
      var completedCalled = false;
      controller.onAllStoriesCompleted = () {
        completedCalled = true;
        print('   🎯 All stories completed callback triggered');
      };

      // Test the exact logic from nextStory():
      // 1. Find current group
      final currentGroup = storyList.findGroupContainingStory(controller.state.currentStoryId!);
      expect(currentGroup?.user.id, 'user2');
      print('   Current group: user2');

      // 2. Try next story in current group (should be null)
      final nextStoryInGroup = currentGroup?.getNextStory(controller.state.currentStoryId!);
      expect(nextStoryInGroup, null);
      print('   Next story in group: null');

      // 3. Get next group (should be null)
      final nextGroup = storyList.getNextGroup(currentGroup!.user.id);
      expect(nextGroup, null);
      print('   Next group: null (end of all groups)');

      // 4. Execute nextStory (should trigger completion)
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(completedCalled, true);
      print('   ✓ Successfully triggered completion');

      controller.dispose();
    });

    test('✅ Test empty group handling - should skip to next non-empty group', () async {
      print('\n📋 Testing empty group handling:');
      
      final storyList = VStoryList(
        groups: [
          createTestGroup('user1', 1),
          VStoryGroup(
            user: VStoryUser.fromUrl(
              id: 'user2',
              name: 'User 2',
              avatarUrl: 'https://example.com/user2/profile.jpg',
            ),
            stories: [], // Empty group
          ),
          createTestGroup('user3', 1),
        ],
      );

      final controller = VStoryController();
      controller.enablePersistence = false;
      await controller.initialize(storyList);

      // Go to last story of first group
      await controller.goToStory('user1_story_0');
      await Future.delayed(const Duration(milliseconds: 50));
      print('   Starting at: user1_story_0');

      // Test navigation
      final currentGroup = storyList.findGroupContainingStory(controller.state.currentStoryId!);
      final nextGroup = storyList.getNextGroup(currentGroup!.user.id);
      expect(nextGroup?.user.id, 'user2');
      expect(nextGroup?.stories.isEmpty, true);
      print('   Next group (user2) is empty - should skip to user3');

      // Execute nextStory - should skip empty group and go to user3
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 50));
      
      // After fix, it should skip the empty group and navigate to user3
      expect(controller.state.currentStoryId, 'user3_story_0');
      expect(controller.state.currentUserId, 'user3');
      print('   ✓ Successfully skipped empty group and navigated to user3_story_0');

      controller.dispose();
    });

    test('✅ Test rapid successive nextStory calls', () async {
      print('\n📋 Testing rapid successive nextStory calls:');
      
      final storyList = VStoryList(
        groups: [
          createTestGroup('user1', 5),
        ],
      );

      final controller = VStoryController();
      controller.enablePersistence = false;
      await controller.initialize(storyList);

      expect(controller.state.currentStoryId, 'user1_story_0');
      print('   Starting at: user1_story_0');

      // Make multiple rapid calls
      print('   Making 3 rapid nextStory calls...');
      await controller.nextStory();
      await controller.nextStory();
      await controller.nextStory();
      
      // Wait for all to complete
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Should have moved 3 stories forward
      expect(controller.state.currentStoryId, 'user1_story_3');
      print('   ✓ Successfully moved to user1_story_3');

      controller.dispose();
    });
  });

  print('\n🎉 All edge case tests completed!');
}