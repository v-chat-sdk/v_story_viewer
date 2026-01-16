import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

List<VStoryGroup> createAdvancedStories() {
  final now = DateTime.now();
  return [
    // User 1: Stories with Overlays (captions, watermarks)
    VStoryGroup(
      user: const VStoryUser(
        id: 'user_overlay',
        name: 'Overlay Demo',
        imageUrl: 'https://i.pravatar.cc/150?u=overlay',
      ),
      stories: [
        // Image with caption overlay
        VImageStory(
          url: 'https://picsum.photos/seed/overlay1/1080/1920',
          createdAt: now.subtract(const Duration(hours: 2)),
          isSeen: false,
          overlayBuilder: (context) => Positioned(
            bottom: 120,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Beautiful sunset at the beach!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        // Image with watermark overlay
        VImageStory(
          url: 'https://picsum.photos/seed/overlay2/1080/1920',
          createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
          isSeen: false,
          overlayBuilder: (context) => Positioned(
            top: 100,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.blue.shade600, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '@photographer',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Image with multiple overlay elements
        VImageStory(
          url: 'https://picsum.photos/seed/overlay3/1080/1920',
          createdAt: now.subtract(const Duration(hours: 1)),
          isSeen: false,
          overlayBuilder: (context) => Stack(
            children: [
              // Location tag
              Positioned(
                top: 100,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 16),
                      SizedBox(width: 4),
                      Text('New York City',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              // Hashtag
              Positioned(
                bottom: 140,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '#travel #adventure',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    // User 2: Rich Text Stories
    VStoryGroup(
      user: const VStoryUser(
        id: 'user_richtext',
        name: 'Rich Text',
        imageUrl: 'https://i.pravatar.cc/150?u=richtext',
      ),
      stories: [
        // RichText with TextSpan
        VTextStory(
          text: 'Rich text story',
          backgroundColor: const Color(0xFF1F2937),
          createdAt: now.subtract(const Duration(hours: 3)),
          isSeen: false,
          richText: TextSpan(
            children: [
              const TextSpan(
                text: 'Welcome to ',
                style: TextStyle(fontSize: 28, color: Colors.white),
              ),
              TextSpan(
                text: 'V Story Viewer',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
              const TextSpan(
                text: '\n\nThe most powerful story viewer for Flutter!',
                style: TextStyle(fontSize: 20, color: Colors.white70),
              ),
            ],
          ),
        ),
        // Custom text builder
        VTextStory(
          text: 'Custom builder story',
          backgroundColor: const Color(0xFF0F172A),
          createdAt: now.subtract(const Duration(hours: 2)),
          isSeen: false,
          textBuilder: (context, text) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.rocket_launch, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.purple, Colors.blue, Colors.cyan],
                ).createShader(bounds),
                child: const Text(
                  'LAUNCH DAY!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Our new app is now live',
                style: TextStyle(fontSize: 20, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    ),
    // User 3: All seen stories (grey ring)
    VStoryGroup(
      user: const VStoryUser(
        id: 'user_allseen',
        name: 'All Seen',
        imageUrl: 'https://i.pravatar.cc/150?u=allseen',
      ),
      stories: [
        VImageStory(
          url: 'https://picsum.photos/seed/seen1/1080/1920',
          createdAt: now.subtract(const Duration(hours: 12)),
          isSeen: true,
        ),
        VImageStory(
          url: 'https://picsum.photos/seed/seen2/1080/1920',
          createdAt: now.subtract(const Duration(hours: 11)),
          isSeen: true,
        ),
        VTextStory(
          text: 'All stories viewed!',
          backgroundColor: Colors.grey,
          createdAt: now.subtract(const Duration(hours: 10)),
          isSeen: true,
        ),
      ],
    ),
  ];
}
