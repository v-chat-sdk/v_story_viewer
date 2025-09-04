import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

/// Mock data for demonstrating story viewer
class MockStoryData {
  static List<VStoryGroup> getMockStoryGroups() {
    return [
      // User 1 - Multiple story types
      VStoryGroup(
        user: VStoryUser.fromUrl(
          id: 'user_1',
          name: 'John Doe',
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
          metadata: {'verified': true},
        ),
        stories: [
          // Image story with URL
          VImageStory(
            id: 'story_1_1',
            media: VPlatformFile.fromUrl(
              networkUrl: 'https://picsum.photos/1080/1920?random=1',
            ),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            caption: 'Beautiful sunset view 🌅',
          ),
          // Video story
          VVideoStory(
            id: 'story_1_2',
            media: VPlatformFile.fromUrl(
              networkUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            ),
            duration: const Duration(seconds: 10),
            createdAt: DateTime.now().subtract(const Duration(hours: 4)),
            muted: false,
          ),
          // Text story
          VTextStory(
            id: 'story_1_3',
            text: 'Sometimes the best moments are the ones we don\'t capture on camera, but keep in our hearts forever. 💝',
            backgroundColor: Colors.purple.shade700,
            textStyle: const TextStyle(color: Colors.white, fontSize: 18),
            duration: const Duration(seconds: 4),
            createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          ),
        ],
      ),
      
      // User 2 - Image stories with different styles
      VStoryGroup(
        user: VStoryUser.fromUrl(
          id: 'user_2',
          name: 'Jane Smith',
          avatarUrl: 'https://i.pravatar.cc/150?img=2',
          metadata: {'follower_count': 1500},
        ),
        stories: [
          VImageStory(
            id: 'story_2_1',
            media: VPlatformFile.fromUrl(
              networkUrl: 'https://picsum.photos/1080/1920?random=2',
            ),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            caption: 'Morning vibes ☕',
            fit: BoxFit.cover,
          ),
          VImageStory(
            id: 'story_2_2',
            media: VPlatformFile.fromUrl(
              networkUrl: 'https://picsum.photos/1080/1920?random=3',
            ),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now().subtract(const Duration(hours: 3)),
            caption: 'Nature is amazing 🌿',
          ),
        ],
      ),
      
      // User 3 - Text stories with gradients
      VStoryGroup(
        user: VStoryUser.fromUrl(
          id: 'user_3',
          name: 'Creative Studio',
          avatarUrl: 'https://i.pravatar.cc/150?img=3',
          metadata: {'type': 'business'},
        ),
        stories: [
          VTextStory(
            id: 'story_3_1',
            text: 'Design is not just what it looks like and feels like. Design is how it works.',
            backgroundColor: Colors.orange.shade600,
            textStyle: const TextStyle(color: Colors.white, fontSize: 18),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
          VTextStory(
            id: 'story_3_2',
            text: '🚀 New Product Launch!\n\nGet 30% off this week only!',
            backgroundColor: Colors.blue.shade800,
            textStyle: const TextStyle(color: Colors.white, fontSize: 24),
            duration: const Duration(seconds: 4),
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          // Custom story widget
          VCustomStory(
            id: 'story_3_3',
            duration: const Duration(seconds: 6),
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
            builder: (context) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.shade400,
                    Colors.pink.shade400,
                    Colors.orange.shade400,
                  ],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.celebration,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Custom Widget Story',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'You can display any Flutter widget!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      
      // User 4 - Video content creator
      VStoryGroup(
        user: VStoryUser.fromUrl(
          id: 'user_4',
          name: 'Video Creator',
          avatarUrl: 'https://i.pravatar.cc/150?img=4',
        ),
        stories: [
          VVideoStory(
            id: 'story_4_1',
            media: VPlatformFile.fromUrl(
              networkUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
            ),
            duration: const Duration(seconds: 15),
            createdAt: DateTime.now().subtract(const Duration(hours: 8)),
            muted: true,
          ),
        ],
      ),
      
      // User 5 - Mixed content
      VStoryGroup(
        user: VStoryUser.fromUrl(
          id: 'user_5',
          name: 'Travel Blogger',
          avatarUrl: 'https://i.pravatar.cc/150?img=5',
          metadata: {'location': 'Paris, France'},
        ),
        stories: [
          VImageStory(
            id: 'story_5_1',
            media: VPlatformFile.fromUrl(
              networkUrl: 'https://picsum.photos/1080/1920?random=4',
            ),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now().subtract(const Duration(hours: 10)),
            caption: 'Eiffel Tower at night 🗼',
          ),
          VTextStory(
            id: 'story_5_2',
            text: 'Travel Tip 💡\n\nAlways keep a portable charger with you when exploring new cities!',
            backgroundColor: Colors.teal.shade600,
            textStyle: const TextStyle(color: Colors.white, fontSize: 18),
            duration: const Duration(seconds: 4),
            createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          ),
          VImageStory(
            id: 'story_5_3',
            media: VPlatformFile.fromUrl(
              networkUrl: 'https://picsum.photos/1080/1920?random=5',
            ),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now().subtract(const Duration(hours: 14)),
            caption: 'French cuisine is amazing! 🥐',
          ),
        ],
      ),
    ];
  }
  static List<VStoryGroup> getMockTextStoryGroups() {
    return [
      VStoryGroup(
        user: VStoryUser.fromUrl(
          id: 'user_3',
          name: 'Creative Studio',
          avatarUrl: 'https://i.pravatar.cc/150?img=3',
          metadata: {'type': 'business'},
        ),
        stories: [
          VTextStory(
            id: 'story_3_1',
            text: 'Design is not just what it looks like and feels like. Design is how it works.',
            backgroundColor: Colors.orange.shade600,
            textStyle: const TextStyle(color: Colors.white, fontSize: 18),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
          VTextStory(
            id: 'story_3_2',
            text: '🚀 New Product Launch!\n\nGet 30% off this week only!',
            backgroundColor: Colors.blue.shade800,
            textStyle: const TextStyle(color: Colors.white, fontSize: 24),
            duration: const Duration(seconds: 4),
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          // Custom story widget
          VCustomStory(
            id: 'story_3_3',
            duration: const Duration(seconds: 6),
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
            builder: (context) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.shade400,
                    Colors.pink.shade400,
                    Colors.orange.shade400,
                  ],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.celebration,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Custom Widget Story',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'You can display any Flutter widget!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      VStoryGroup(
        user: VStoryUser.fromUrl(
          id: 'user_3',
          name: 'Creative Studio',
          avatarUrl: 'https://i.pravatar.cc/150?img=3',
          metadata: {'type': 'business'},
        ),
        stories: [
          VTextStory(
            id: 'story_3_1',
            text: 'Design is not just what it looks like and feels like. Design is how it works.',
            backgroundColor: Colors.orange.shade600,
            textStyle: const TextStyle(color: Colors.white, fontSize: 18),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ],
      ),
      VStoryGroup(
        user: VStoryUser.fromUrl(
          id: 'user_3',
          name: 'Creative Studio',
          avatarUrl: 'https://i.pravatar.cc/150?img=3',
          metadata: {'type': 'business'},
        ),
        stories: [
          VTextStory(
            id: 'story_3_1',
            text: 'Design is not just what it looks like and feels like. Design is how it works.',
            backgroundColor: Colors.orange.shade600,
            textStyle: const TextStyle(color: Colors.white, fontSize: 18),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
          VTextStory(
            id: 'story_3_2',
            text: '🚀 New Product Launch!\n\nGet 30% off this week only!',
            backgroundColor: Colors.blue.shade800,
            textStyle: const TextStyle(color: Colors.white, fontSize: 24),
            duration: const Duration(seconds: 4),
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      VStoryGroup(
        user: VStoryUser.fromUrl(
          id: 'user_3',
          name: 'Creative Studio',
          avatarUrl: 'https://i.pravatar.cc/150?img=3',
          metadata: {'type': 'business'},
        ),
        stories: [
          VImageStory(
            id: 'story_2_1',
            media: VPlatformFile.fromUrl(
              networkUrl: 'https://picsum.photos/1080/1920?random=2',
            ),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            caption: 'Morning vibes ☕',
            fit: BoxFit.cover,
          ),
          VImageStory(
            id: 'story_2_2',
            media: VPlatformFile.fromUrl(
              networkUrl: 'https://picsum.photos/1080/1920?random=3',
            ),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now().subtract(const Duration(hours: 3)),
            caption: 'Nature is amazing 🌿',
          ),
        ],
      ),
      VStoryGroup(
        user: VStoryUser.fromUrl(
          id: 'user_3',
          name: 'Creative Studio',
          avatarUrl: 'https://i.pravatar.cc/150?img=3',
          metadata: {'type': 'business'},
        ),
        stories: [
          VTextStory(
            id: 'story_3_1',
            text: 'Design is not just what it looks like and feels like. Design is how it works.',
            backgroundColor: Colors.orange.shade600,
            textStyle: const TextStyle(color: Colors.white, fontSize: 18),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
          VTextStory(
            id: 'story_3_2',
            text: '🚀 New Product Launch!\n\nGet 30% off this week only!',
            backgroundColor: Colors.blue.shade800,
            textStyle: const TextStyle(color: Colors.white, fontSize: 24),
            duration: const Duration(seconds: 4),
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          // Custom story widget
          VCustomStory(
            id: 'story_3_3',
            duration: const Duration(seconds: 6),
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
            builder: (context) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.shade400,
                    Colors.pink.shade400,
                    Colors.orange.shade400,
                  ],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.celebration,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Custom Widget Story',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'You can display any Flutter widget!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      VStoryGroup(
        user: VStoryUser.fromUrl(
          id: 'user_3',
          name: 'Creative Studio',
          avatarUrl: 'https://i.pravatar.cc/150?img=3',
          metadata: {'type': 'business'},
        ),
        stories: [
          VTextStory(
            id: 'story_3_1',
            text: 'Design is not just what it looks like and feels like. Design is how it works.',
            backgroundColor: Colors.orange.shade600,
            textStyle: const TextStyle(color: Colors.white, fontSize: 18),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
          VTextStory(
            id: 'story_3_2',
            text: '🚀 New Product Launch!\n\nGet 30% off this week only!',
            backgroundColor: Colors.blue.shade800,
            textStyle: const TextStyle(color: Colors.white, fontSize: 24),
            duration: const Duration(seconds: 4),
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          // Custom story widget
          VCustomStory(
            id: 'story_3_3',
            duration: const Duration(seconds: 6),
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
            builder: (context) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.shade400,
                    Colors.pink.shade400,
                    Colors.orange.shade400,
                  ],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.celebration,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Custom Widget Story',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'You can display any Flutter widget!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      VStoryGroup(
        user: VStoryUser.fromUrl(
          id: 'user_3',
          name: 'Creative Studio',
          avatarUrl: 'https://i.pravatar.cc/150?img=3',
          metadata: {'type': 'business'},
        ),
        stories: [
          VTextStory(
            id: 'story_3_1',
            text: 'Design is not just what it looks like and feels like. Design is how it works.',
            backgroundColor: Colors.orange.shade600,
            textStyle: const TextStyle(color: Colors.white, fontSize: 18),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
          VTextStory(
            id: 'story_3_2',
            text: '🚀 New Product Launch!\n\nGet 30% off this week only!',
            backgroundColor: Colors.blue.shade800,
            textStyle: const TextStyle(color: Colors.white, fontSize: 24),
            duration: const Duration(seconds: 4),
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          // Custom story widget
          VCustomStory(
            id: 'story_3_3',
            duration: const Duration(seconds: 6),
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
            builder: (context) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.shade400,
                    Colors.pink.shade400,
                    Colors.orange.shade400,
                  ],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.celebration,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Custom Widget Story',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'You can display any Flutter widget!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }
  
  /// Get demo story list
  static VStoryList getMockStoryList() {
    return VStoryList(
      groups: getMockStoryGroups(),
    );
  }
  
  /// Get sample URLs for testing
  static List<String> getSampleImageUrls() {
    return List.generate(
      10,
      (index) => 'https://picsum.photos/1080/1920?random=${index + 10}',
    );
  }
  
  /// Get sample video URLs
  static List<String> getSampleVideoUrls() {
    return [
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    ];
  }
  
  /// Get sample text content
  static List<Map<String, dynamic>> getSampleTextContent() {
    return [
      {
        'text': 'Life is 10% what happens to you and 90% how you react to it.',
        'color': Colors.blue.shade700,
      },
      {
        'text': 'The only way to do great work is to love what you do.',
        'color': Colors.green.shade700,
      },
      {
        'text': 'Innovation distinguishes between a leader and a follower.',
        'color': Colors.purple.shade700,
      },
      {
        'text': 'Stay hungry, stay foolish.',
        'color': Colors.orange.shade700,
      },
      {
        'text': 'Your time is limited, don\'t waste it living someone else\'s life.',
        'color': Colors.red.shade700,
      },
    ];
  }
}
