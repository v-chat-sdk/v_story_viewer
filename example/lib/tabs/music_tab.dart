import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

import '../widgets/feature_card.dart';

class MusicTab extends StatelessWidget {
  final List<VStoryGroup> stories;
  final void Function(VStoryGroup group, int index) onUserTap;
  final VoidCallback onStartDemo;

  const MusicTab({
    super.key,
    required this.stories,
    required this.onUserTap,
    required this.onStartDemo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Background Music Lab',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Use the stories below to verify timing, navigation, pause/resume, '
            'and original-audio mixing.',
          ),
        ),
        const SizedBox(height: 12),
        VStoryCircleList(
          storyGroups: stories,
          circleConfig: const VStoryCircleConfig(
            unseenColor: Colors.deepPurple,
            seenColor: Colors.grey,
            ringWidth: 4,
            segmentGap: 0.2,
          ),
          onUserTap: onUserTap,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStartDemo,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Open Music Timing Demo'),
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              FeatureCard(
                icon: Icons.volume_up,
                title: 'Web Audio',
                description:
                    'Browsers start the viewer muted. Tap the speaker icon '
                    'once after opening the demo.',
              ),
              FeatureCard(
                icon: Icons.touch_app,
                title: 'Pause and Resume',
                description:
                    'Press and hold a story. Music and progress should stop '
                    'and resume together.',
              ),
              FeatureCard(
                icon: Icons.skip_next,
                title: 'Story Navigation',
                description:
                    'Tap left or right. The old track must stop before the '
                    'new story begins.',
              ),
              FeatureCard(
                icon: Icons.timer,
                title: 'Duration Policies',
                description:
                    'Compare looping story time, music-clip time, and the '
                    'shortest-duration policy.',
              ),
              FeatureCard(
                icon: Icons.graphic_eq,
                title: 'Audio Mixing',
                description:
                    'Open Music Mixing to compare duck, replace, and mix '
                    'policies with video or voice audio.',
              ),
              FeatureCard(
                icon: Icons.phone_android,
                title: 'App Lifecycle',
                description:
                    'Send the app to the background and return. Playback '
                    'should remain synchronized.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
