import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';
import '../widgets/feature_card.dart';

class BasicTab extends StatelessWidget {
  final List<VStoryGroup> stories;
  final void Function(VStoryGroup group, int index) onUserTap;
  const BasicTab({
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
          child: Text('Basic Stories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        VStoryCircleList(
          storyGroups: stories,
          circleConfig: const VStoryCircleConfig(
            unseenColor: Colors.green,
            seenColor: Colors.grey,
            ringWidth: 4,
            segmentGap: 0.2,
          ),
          onUserTap: onUserTap,
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              FeatureCard(
                  icon: Icons.image,
                  title: 'Image Stories',
                  description:
                      'Sarah Photos - Multiple images with custom durations'),
              FeatureCard(
                  icon: Icons.videocam,
                  title: 'Video Stories',
                  description:
                      'Mike Videos - Auto-duration from video metadata'),
              FeatureCard(
                  icon: Icons.text_fields,
                  title: 'Text Stories',
                  description:
                      'Emma Quotes - Text with custom styles and colors'),
              FeatureCard(
                  icon: Icons.mic,
                  title: 'Voice Stories',
                  description: 'DJ Alex - Audio playback with seek slider'),
              FeatureCard(
                  icon: Icons.shuffle,
                  title: 'Mixed Content',
                  description:
                      'Chris Mix - Combined types, partial seen state'),
            ],
          ),
        ),
      ],
    );
  }
}
