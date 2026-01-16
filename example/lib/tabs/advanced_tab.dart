import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';
import '../widgets/feature_card.dart';

class AdvancedTab extends StatelessWidget {
  final List<VStoryGroup> stories;
  final void Function(VStoryGroup group, int index) onUserTap;
  final VoidCallback onMinimalViewer;
  final VoidCallback onCustomHeaderViewer;
  const AdvancedTab({
    super.key,
    required this.stories,
    required this.onUserTap,
    required this.onMinimalViewer,
    required this.onCustomHeaderViewer,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Advanced Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        VStoryCircleList(
          storyGroups: stories,
          circleConfig: const VStoryCircleConfig(
            unseenColor: Colors.amber,
            seenColor: Colors.grey,
            ringWidth: 5,
            segmentGap: 0.15,
          ),
          onUserTap: onUserTap,
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const FeatureCard(
                icon: Icons.layers,
                title: 'Overlay Stories',
                description: 'Captions, watermarks, location tags, hashtags',
              ),
              const FeatureCard(
                icon: Icons.format_color_text,
                title: 'Rich Text',
                description: 'TextSpan with gradients, custom text builders',
              ),
              const FeatureCard(
                icon: Icons.check_circle,
                title: 'All Seen',
                description: 'Grey ring when all stories viewed',
              ),
              const SizedBox(height: 24),
              const Text('Quick Actions',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.visibility_off, size: 18),
                    label: const Text('Minimal UI'),
                    onPressed: onMinimalViewer,
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.dashboard_customize, size: 18),
                    label: const Text('Custom Header/Footer'),
                    onPressed: onCustomHeaderViewer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
