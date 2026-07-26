import 'package:flutter_test/flutter_test.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

void main() {
  group('VStoryUser', () {
    test('creates user with required fields', () {
      final user = VStoryUser(
        id: '1',
        name: 'Test User',
        imageUrl: 'https://example.com/avatar.jpg',
      );
      expect(user.id, '1');
      expect(user.name, 'Test User');
      expect(user.imageUrl, 'https://example.com/avatar.jpg');
    });
    test('equality uses id, name, and image URL', () {
      const user1 = VStoryUser(id: '1', name: 'User', imageUrl: 'url');
      const user2 = VStoryUser(id: '1', name: 'User', imageUrl: 'url');
      const updatedProfile =
          VStoryUser(id: '1', name: 'Updated User', imageUrl: 'new-url');

      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
      expect(user1, isNot(equals(updatedProfile)));
    });
  });
  group('VStoryItem', () {
    test('image story is not expired when created now', () {
      final story = VImageStory(
        url: 'https://example.com/image.jpg',
        createdAt: DateTime.now(),
        isSeen: false,
      );
      expect(story.isExpired, false);
    });
    test('image story is expired after 24 hours', () {
      final story = VImageStory(
        url: 'https://example.com/image.jpg',
        createdAt: DateTime.now().subtract(const Duration(hours: 25)),
        isSeen: false,
      );
      expect(story.isExpired, true);
    });
    test('isSeen property works correctly', () {
      final unseenStory = VImageStory(
        url: 'url',
        createdAt: DateTime.now(),
        isSeen: false,
      );
      final seenStory = VImageStory(
        url: 'url',
        createdAt: DateTime.now(),
        isSeen: true,
      );
      expect(unseenStory.isSeen, false);
      expect(seenStory.isSeen, true);
    });
  });
  group('VStoryGroup', () {
    test('hasValidStories returns true for non-expired stories', () {
      final user = VStoryUser(id: '1', name: 'User', imageUrl: 'url');
      final group = VStoryGroup(
        user: user,
        stories: [
          VImageStory(url: 'url', createdAt: DateTime.now(), isSeen: false),
        ],
      );
      expect(group.hasValidStories, true);
    });
    test('hasValidStories returns false for all expired stories', () {
      final user = VStoryUser(id: '1', name: 'User', imageUrl: 'url');
      final group = VStoryGroup(
        user: user,
        stories: [
          VImageStory(
            url: 'url',
            createdAt: DateTime.now().subtract(const Duration(hours: 25)),
            isSeen: false,
          ),
        ],
      );
      expect(group.hasValidStories, false);
    });
    test('hasUnseenStories returns true when any story is unseen', () {
      final user = VStoryUser(id: '1', name: 'User', imageUrl: 'url');
      final group = VStoryGroup(
        user: user,
        stories: [
          VImageStory(url: 'url1', createdAt: DateTime.now(), isSeen: true),
          VImageStory(url: 'url2', createdAt: DateTime.now(), isSeen: false),
        ],
      );
      expect(group.hasUnseenStories, true);
    });
    test('sortedStories puts unseen first', () {
      final user = VStoryUser(id: '1', name: 'User', imageUrl: 'url');
      final group = VStoryGroup(
        user: user,
        stories: [
          VImageStory(url: 'seen1', createdAt: DateTime.now(), isSeen: true),
          VImageStory(url: 'unseen', createdAt: DateTime.now(), isSeen: false),
          VImageStory(url: 'seen2', createdAt: DateTime.now(), isSeen: true),
        ],
      );
      final sorted = group.sortedStories;
      expect(sorted[0].isSeen, false);
      expect(sorted[1].isSeen, true);
      expect(sorted[2].isSeen, true);
    });
  });
}
