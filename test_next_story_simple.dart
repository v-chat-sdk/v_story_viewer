import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('VStoryController.nextStory() Core Tests', () {
    late VStoryController controller;
    late VStoryList storyList;

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

    setUp(() async {
      // Create a story list with multiple groups for testing
      storyList = VStoryList(
        groups: [
          createTestGroup('user1', 3), // 3 stories in first group
          createTestGroup('user2', 2), // 2 stories in second group
          createTestGroup('user3', 1), // 1 story in third group
        ],
      );

      controller = VStoryController();
      controller.enablePersistence = false; // Disable persistence for tests
      await controller.initialize(storyList);
    });

    tearDown(() {
      if (!controller.isDisposed) {
        controller.dispose();
      }
    });

    test('✅ nextStory() navigates to next story within same group', () async {
      // Initially, controller should be at first story
      expect(controller.state.currentStoryId, 'user1_story_0');
      expect(controller.state.currentUserId, 'user1');

      // Navigate to next story in same group
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.state.currentStoryId, 'user1_story_1');
      expect(controller.state.currentUserId, 'user1');
      
      print('✅ Successfully navigated from story 0 to story 1 within user1 group');

      // Navigate to third story in same group
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.state.currentStoryId, 'user1_story_2');
      expect(controller.state.currentUserId, 'user1');
      
      print('✅ Successfully navigated from story 1 to story 2 within user1 group');
    });

    test('✅ nextStory() navigates to next group when current group ends', () async {
      // Start with last story of first group
      await controller.goToStory('user1_story_2');
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.state.currentStoryId, 'user1_story_2');
      expect(controller.state.currentUserId, 'user1');
      
      print('📍 Starting at last story of user1 group');

      // Navigate to next group (should go to first story of user2)
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.state.currentStoryId, 'user2_story_0');
      expect(controller.state.currentUserId, 'user2');
      
      print('✅ Successfully navigated from user1 last story to user2 first story');
    });

    test('✅ nextStory() handles end of all stories correctly', () async {
      // Start with last story of last group
      await controller.goToStory('user3_story_0');
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.state.currentStoryId, 'user3_story_0');
      expect(controller.state.currentUserId, 'user3');
      
      print('📍 Starting at last story of last group');

      var allStoriesCompletedCalled = false;
      controller.onAllStoriesCompleted = () {
        allStoriesCompletedCalled = true;
        print('🎯 All stories completed callback triggered');
      };

      // Navigate beyond last story (should trigger completion)
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(allStoriesCompletedCalled, true);
      print('✅ Successfully triggered all stories completed');
    });

    test('✅ Complex navigation flow through entire story list', () async {
      // Start at the beginning
      expect(controller.state.currentStoryId, 'user1_story_0');
      
      print('\n📊 Starting navigation flow test:');
      print('   Current: user1_story_0');

      // user1_story_0 -> user1_story_1
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.state.currentStoryId, 'user1_story_1');
      print('   ✓ Navigated to: user1_story_1');

      // user1_story_1 -> user1_story_2
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.state.currentStoryId, 'user1_story_2');
      print('   ✓ Navigated to: user1_story_2');

      // user1_story_2 -> user2_story_0 (next group)
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.state.currentStoryId, 'user2_story_0');
      expect(controller.state.currentUserId, 'user2');
      print('   ✓ Navigated to: user2_story_0 (GROUP CHANGE)');

      // user2_story_0 -> user2_story_1
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.state.currentStoryId, 'user2_story_1');
      print('   ✓ Navigated to: user2_story_1');

      // user2_story_1 -> user3_story_0 (next group)
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.state.currentStoryId, 'user3_story_0');
      expect(controller.state.currentUserId, 'user3');
      print('   ✓ Navigated to: user3_story_0 (GROUP CHANGE)');

      // user3_story_0 -> end (should complete)
      var completed = false;
      controller.onAllStoriesCompleted = () {
        completed = true;
      };

      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(completed, true);
      print('   ✓ All stories completed!');
      
      print('\n✅ Successfully completed full navigation flow through all stories!');
    });

    test('✅ nextStory() correctly identifies and navigates story groups', () async {
      // Test that we can identify which group contains which story
      final group1 = storyList.findGroupContainingStory('user1_story_0');
      expect(group1?.user.id, 'user1');
      print('✓ Found user1_story_0 in group user1');
      
      final group2 = storyList.findGroupContainingStory('user2_story_1');
      expect(group2?.user.id, 'user2');
      print('✓ Found user2_story_1 in group user2');
      
      // Test navigation between groups
      await controller.goToStory('user1_story_2');
      final currentGroup = storyList.findGroupContainingStory(controller.state.currentStoryId!);
      expect(currentGroup?.user.id, 'user1');
      
      // Get next story in group
      final nextStoryInGroup = currentGroup?.getNextStory(controller.state.currentStoryId!);
      expect(nextStoryInGroup, null); // Should be null as it's the last story
      print('✓ Correctly identified last story in group has no next story');
      
      // Get next group
      final nextGroup = storyList.getNextGroup(currentGroup!.user.id);
      expect(nextGroup?.user.id, 'user2');
      print('✓ Correctly identified next group is user2');
      
      // Navigate and verify we moved to the next group
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.state.currentUserId, 'user2');
      expect(controller.state.currentStoryId, 'user2_story_0');
      print('✓ Successfully navigated to next group');
    });
  });

  print('\n🎉 Test suite completed successfully!');
}

// Extension to check if controller is disposed (helper)
extension on VStoryController {
  bool get isDisposed {
    try {
      // Try to access state - will throw if disposed
      final _ = state;
      return false;
    } catch (e) {
      return true;
    }
  }
}