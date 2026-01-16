import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';
import '../widgets/feature_card.dart';

class CustomTab extends StatelessWidget {
  final List<VStoryGroup> stories;
  final void Function(VStoryGroup group, int index) onUserTap;
  const CustomTab({
    super.key,
    required this.stories,
    required this.onUserTap,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Custom Stories (VCustomStory)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        VStoryCircleList(
          storyGroups: stories,
          circleConfig: const VStoryCircleConfig(
            unseenColor: Colors.purple,
            seenColor: Colors.grey,
            ringWidth: 4,
            segmentGap: 0.25,
          ),
          onUserTap: onUserTap,
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const FeatureCard(
                icon: Icons.poll,
                title: 'Interactive Poll',
                description: 'Poll Demo - Tap options to vote, see results',
              ),
              const FeatureCard(
                icon: Icons.timer,
                title: 'Countdown Timer',
                description: 'Countdown - Live countdown with pause support',
              ),
              const FeatureCard(
                icon: Icons.gradient,
                title: 'Animated Background',
                description: 'Animated BG - Smooth gradient animation',
              ),
              const FeatureCard(
                icon: Icons.shopping_bag,
                title: 'Product Showcase',
                description: 'Shop Now - E-commerce story with CTA button',
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.purple.withAlpha(25),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('VCustomStory',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                        'Use VCustomStory for:\n'
                        '• Interactive polls/quizzes\n'
                        '• Countdown timers\n'
                        '• Lottie animations\n'
                        '• 3D models\n'
                        '• Live data\n'
                        '• Any custom widget!',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
