import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

import '../widgets/feature_card.dart';

class VerticalTab extends StatelessWidget {
  final List<VStoryGroup> stories;
  final void Function(VStoryGroup group, int index) onUserTap;
  const VerticalTab({
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
          child: Text(
            'Vertical Stories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        VStoryCircleList(
          storyGroups: stories,
          circleConfig: const VStoryCircleConfig(
            unseenColor: Colors.teal,
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
                icon: Icons.swap_vert,
                title: 'Vertical Group Paging',
                description:
                    'Swipe up/down to move between story groups (users).',
              ),
              FeatureCard(
                icon: Icons.touch_app,
                title: 'Tap Navigation',
                description: 'Tap left/right to change stories in a group.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
