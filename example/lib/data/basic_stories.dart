import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

List<VStoryGroup> createBasicStories() {
  final now = DateTime.now();
  return [
    // User 1: Multiple Image Stories
    VStoryGroup(
      user: const VStoryUser(
        id: 'user_images',
        name: 'Sarah Photos',
        imageUrl: 'https://i.pravatar.cc/150?u=sarah',
      ),
      stories: [
        VImageStory(
          url: 'https://picsum.photos/seed/nature1/1080/1920',
          createdAt: now.subtract(const Duration(hours: 2)),
          isSeen: false,
          duration: const Duration(seconds: 4),
          caption: 'This is a caption',
        ),
        VImageStory(
          url: 'https://picsum.photos/seed/nature2/1080/1920',
          createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
          isSeen: false,
        ),
        VImageStory(
          url: 'https://picsum.photos/seed/nature3/1080/1920',
          createdAt: now.subtract(const Duration(hours: 1)),
          isSeen: false,
          duration: const Duration(seconds: 7),
        ),
      ],
    ),
    // User 2: Video Stories
    VStoryGroup(
      user: const VStoryUser(
        id: 'user_videos',
        name: 'Mike Videos',
        imageUrl: 'https://i.pravatar.cc/150?u=mike',
      ),
      stories: [
        VVideoStory(
          url:
              'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
          createdAt: now.subtract(const Duration(hours: 4)),
          isSeen: false,
        ),
        VVideoStory(
          url:
              'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          createdAt: now.subtract(const Duration(hours: 3)),
          isSeen: false,
        ),
      ],
    ),
    // User 3: Text Stories with different styles
    VStoryGroup(
      user: const VStoryUser(
        id: 'user_text',
        name: 'Emma Quotes',
        imageUrl: 'https://i.pravatar.cc/150?u=emma',
      ),
      stories: [
        VTextStory(
          text: 'Good morning everyone! Hope you have an amazing day ahead.',
          backgroundColor: const Color(0xFF6366F1),
          createdAt: now.subtract(const Duration(hours: 6)),
          isSeen: false,
        ),
        VTextStory(
          text:
              'The only way to do great work is to love what you do. - Steve Jobs',
          backgroundColor: const Color(0xFFEC4899),
          textStyle: const TextStyle(
            fontSize: 28,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w300,
          ),
          createdAt: now.subtract(const Duration(hours: 5)),
          isSeen: false,
        ),
        VTextStory(
          text: 'Flutter is awesome for building beautiful apps!',
          backgroundColor: const Color(0xFF10B981),
          createdAt: now.subtract(const Duration(hours: 4)),
          isSeen: false,
          duration: const Duration(seconds: 4),
        ),
      ],
    ),
    // User 4: Voice/Audio Stories
    VStoryGroup(
      user: const VStoryUser(
        id: 'user_voice',
        name: 'DJ Alex',
        imageUrl: 'https://i.pravatar.cc/150?u=alex',
      ),
      stories: [
        VVoiceStory(
          url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
          backgroundColor: const Color(0xFF8B5CF6),
          createdAt: now.subtract(const Duration(hours: 8)),
          isSeen: false,
        ),
        VVoiceStory(
          url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
          backgroundColor: const Color(0xFFF59E0B),
          createdAt: now.subtract(const Duration(hours: 7)),
          isSeen: false,
        ),
      ],
    ),
    // User 5: Mixed content (partial seen)
    VStoryGroup(
      user: const VStoryUser(
        id: 'user_mixed',
        name: 'Chris Mix',
        imageUrl: 'https://i.pravatar.cc/150?u=chris',
      ),
      stories: [
        VImageStory(
          url: 'https://picsum.photos/seed/mix1/1080/1920',
          createdAt: now.subtract(const Duration(hours: 10)),
          isSeen: true,
        ),
        VTextStory(
          text: 'Check out my latest video below!',
          backgroundColor: Colors.deepOrange,
          createdAt: now.subtract(const Duration(hours: 9)),
          isSeen: true,
        ),
        VVideoStory(
          url:
              'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
          createdAt: now.subtract(const Duration(hours: 8)),
          isSeen: false,
        ),
        VImageStory(
          url: 'https://picsum.photos/seed/mix2/1080/1920',
          createdAt: now.subtract(const Duration(hours: 7)),
          isSeen: false,
        ),
      ],
    ),
  ];
}
