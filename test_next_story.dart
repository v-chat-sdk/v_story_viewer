import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('VStoryController.nextStory() Tests', () {
    late VStoryController controller;
    late VStoryList storyList;

    // Helper function to create test story groups
    VStoryGroup createTestGroup(String userId, int storyCount, {int viewedCount = 0}) {
      final stories = List.generate(
        storyCount,
        (index) => VImageStory.fromUrl(
          id: '${userId}_story_$index',
          url: 'https://example.com/$userId/image_$index.jpg',
          duration: const Duration(seconds: 3),
          createdAt: DateTime.now().subtract(Duration(hours: index)),
          viewedAt: index < viewedCount ? DateTime.now() : null,
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
      controller.enablePersistence = false;
      await controller.initialize(storyList);
    });

    tearDown(() {
      controller.dispose();
    });

    test('nextStory() navigates to next story within same group', () async {
      // Start with first story of first group
      await controller.goToStory('user1_story_0');
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.state.currentStoryId, 'user1_story_0');
      expect(controller.state.currentUserId, 'user1');

      // Navigate to next story in same group
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.state.currentStoryId, 'user1_story_1');
      expect(controller.state.currentUserId, 'user1');

      // Navigate to third story in same group
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.state.currentStoryId, 'user1_story_2');
      expect(controller.state.currentUserId, 'user1');
    });

    test('nextStory() navigates to next group when current group ends', () async {
      // Start with last story of first group
      await controller.goToStory('user1_story_2');
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.state.currentStoryId, 'user1_story_2');
      expect(controller.state.currentUserId, 'user1');

      // Navigate to next group (should go to first story of user2)
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.state.currentStoryId, 'user2_story_0');
      expect(controller.state.currentUserId, 'user2');
    });

    test('nextStory() handles end of all stories correctly', () async {
      // Start with last story of last group
      await controller.goToStory('user3_story_0');
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.state.currentStoryId, 'user3_story_0');
      expect(controller.state.currentUserId, 'user3');

      var allStoriesCompletedCalled = false;
      controller.onAllStoriesCompleted = () {
        allStoriesCompletedCalled = true;
      };

      // Navigate beyond last story (should trigger completion)
      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(allStoriesCompletedCalled, true);
    });

    test('nextStory() works correctly with persistence enabled', () async {
      // Create controller with persistence enabled
      final persistenceController = VStoryController();
      persistenceController.enablePersistence = true;
      
      await persistenceController.initialize(
        VStoryList(
          groups: [
            createTestGroup('user1', 3, viewedCount: 1), // First story viewed
            createTestGroup('user2', 2),
          ],
        ),
      );

      // Jump to first story
      await persistenceController.goToStory('user1_story_0');
      await Future.delayed(const Duration(milliseconds: 100));

      // Navigate to next story
      await persistenceController.nextStory();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(persistenceController.state.currentStoryId, 'user1_story_1');

      persistenceController.dispose();
    });

    test('nextStory() handles empty groups correctly', () async {
      // Create story list with empty group in the middle
      final emptyGroupList = VStoryList(
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

      final emptyController = VStoryController();
      emptyController.enablePersistence = false;
      await emptyController.initialize(emptyGroupList);

      // Start with last story of first group
      await emptyController.goToStory('user1_story_0');
      await Future.delayed(const Duration(milliseconds: 100));

      // Navigate - should skip empty group and go to user3
      await emptyController.nextStory();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(emptyController.state.currentStoryId, 'user3_story_0');
      expect(emptyController.state.currentUserId, 'user3');

      emptyController.dispose();
    });

    test('nextStory() does nothing when controller is disposed', () async {
      await controller.goToStory('user1_story_0');
      await Future.delayed(const Duration(milliseconds: 100));

      final storyIdBeforeDispose = controller.state.currentStoryId;
      expect(storyIdBeforeDispose, 'user1_story_0');

      // Dispose the controller
      controller.dispose();

      // Try to navigate after disposal (should do nothing)
      await controller.nextStory();
      
      // No error should be thrown, method should just return early
      // We can't check the state after disposal as it's not safe
    });

    test('nextStory() maintains correct state throughout navigation', () async {
      // Track state changes
      final stateChanges = <VStoryPlaybackState>[];
      controller.addListener(() {
        stateChanges.add(controller.state.storyState.playbackState);
      });

      // Start navigation
      await controller.goToStory('user1_story_0');
      await Future.delayed(const Duration(milliseconds: 100));

      // Navigate through multiple stories
      await controller.nextStory(); // To user1_story_1
      await Future.delayed(const Duration(milliseconds: 50));
      
      await controller.nextStory(); // To user1_story_2
      await Future.delayed(const Duration(milliseconds: 50));
      
      await controller.nextStory(); // To user2_story_0 (next group)
      await Future.delayed(const Duration(milliseconds: 50));

      // Verify we ended up in the right place
      expect(controller.state.currentStoryId, 'user2_story_0');
      expect(controller.state.currentUserId, 'user2');

      // Verify state transitions were proper
      expect(stateChanges.contains(VStoryPlaybackState.playing), true);
    });

    test('nextStory() handles rapid successive calls correctly', () async {
      await controller.goToStory('user1_story_0');
      await Future.delayed(const Duration(milliseconds: 100));

      // Make rapid successive calls
      final futures = [
        controller.nextStory(),
        controller.nextStory(),
      ];

      await Future.wait(futures);
      await Future.delayed(const Duration(milliseconds: 100));

      // Should have moved two stories forward
      expect(controller.state.currentStoryId, 'user1_story_2');
      expect(controller.state.currentUserId, 'user1');
    });

    test('Complex navigation flow through entire story list', () async {
      // Navigate through entire story list
      await controller.goToStory('user1_story_0');
      await Future.delayed(const Duration(milliseconds: 100));

      // user1_story_0 -> user1_story_1
      await controller.nextStory();
      expect(controller.state.currentStoryId, 'user1_story_1');

      // user1_story_1 -> user1_story_2
      await controller.nextStory();
      expect(controller.state.currentStoryId, 'user1_story_2');

      // user1_story_2 -> user2_story_0 (next group)
      await controller.nextStory();
      expect(controller.state.currentStoryId, 'user2_story_0');
      expect(controller.state.currentUserId, 'user2');

      // user2_story_0 -> user2_story_1
      await controller.nextStory();
      expect(controller.state.currentStoryId, 'user2_story_1');

      // user2_story_1 -> user3_story_0 (next group)
      await controller.nextStory();
      expect(controller.state.currentStoryId, 'user3_story_0');
      expect(controller.state.currentUserId, 'user3');

      // user3_story_0 -> end (should complete)
      var completed = false;
      controller.onAllStoriesCompleted = () {
        completed = true;
      };

      await controller.nextStory();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(completed, true);
    });
  });

  print('✅ All nextStory() tests defined successfully!');
}