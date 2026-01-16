import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';
import '../custom_content/poll_content.dart';
import '../custom_content/countdown_content.dart';
import '../custom_content/gradient_content.dart';
import '../custom_content/product_content.dart';

List<VStoryGroup> createCustomStories() {
  final now = DateTime.now();
  return [
    // User 1: Interactive Poll/Quiz
    VStoryGroup(
      user: const VStoryUser(
        id: 'user_poll',
        name: 'Poll Demo',
        imageUrl: 'https://i.pravatar.cc/150?u=poll',
      ),
      stories: [
        VCustomStory(
          createdAt: now.subtract(const Duration(hours: 1)),
          isSeen: false,
          duration: const Duration(seconds: 15),
          contentBuilder: (context, isPaused, isMuted, onLoaded, onError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onLoaded(const Duration(seconds: 15));
            });
            return const PollStoryContent();
          },
        ),
      ],
    ),
    // User 2: Countdown Timer
    VStoryGroup(
      user: const VStoryUser(
        id: 'user_countdown',
        name: 'Countdown',
        imageUrl: 'https://i.pravatar.cc/150?u=countdown',
      ),
      stories: [
        VCustomStory(
          createdAt: now.subtract(const Duration(hours: 2)),
          isSeen: false,
          contentBuilder: (context, isPaused, isMuted, onLoaded, onError) {
            return CountdownStoryContent(
              isPaused: isPaused,
              onLoaded: onLoaded,
            );
          },
        ),
      ],
    ),
    // User 3: Gradient Animation
    VStoryGroup(
      user: const VStoryUser(
        id: 'user_gradient',
        name: 'Animated BG',
        imageUrl: 'https://i.pravatar.cc/150?u=gradient',
      ),
      stories: [
        VCustomStory(
          createdAt: now.subtract(const Duration(hours: 3)),
          isSeen: false,
          duration: const Duration(seconds: 8),
          contentBuilder: (context, isPaused, isMuted, onLoaded, onError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onLoaded(const Duration(seconds: 8));
            });
            return AnimatedGradientContent(isPaused: isPaused);
          },
        ),
      ],
    ),
    // User 4: Product Showcase
    VStoryGroup(
      user: const VStoryUser(
        id: 'user_product',
        name: 'Shop Now',
        imageUrl: 'https://i.pravatar.cc/150?u=shop',
      ),
      stories: [
        VCustomStory(
          createdAt: now.subtract(const Duration(hours: 4)),
          isSeen: false,
          duration: const Duration(seconds: 10),
          contentBuilder: (context, isPaused, isMuted, onLoaded, onError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onLoaded(const Duration(seconds: 10));
            });
            return const ProductShowcaseContent();
          },
          overlayBuilder: (context) => Positioned(
            bottom: 120,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Shop Now tapped!')),
                );
              },
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Shop Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ],
    ),
  ];
}
