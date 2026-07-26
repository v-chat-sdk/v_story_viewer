import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

void main() {
  VStoryGroup createGroup(int storyCount) {
    final now = DateTime.now();
    return VStoryGroup(
      user: const VStoryUser(
        id: 'user',
        name: 'User',
        imageUrl: 'https://example.com/avatar.jpg',
      ),
      stories: List.generate(
        storyCount,
        (index) => VTextStory(
          text: 'Story $index',
          duration: const Duration(seconds: 30),
          createdAt: now.add(Duration(milliseconds: index)),
          isSeen: false,
        ),
      ),
    );
  }

  Widget createViewer({
    required VStoryGroup group,
    VoidCallback? onPause,
    VoidCallback? onResume,
  }) {
    return MaterialApp(
      home: VStoryViewer(
        storyGroups: [group],
        config: const VStoryConfig(
          hideStatusBar: false,
          showHeader: false,
          showReplyField: false,
        ),
        onPause: (_, __) => onPause?.call(),
        onResume: (_, __) => onResume?.call(),
      ),
    );
  }

  testWidgets('overlapping pause reasons do not resume each other',
      (tester) async {
    var pauseCount = 0;
    var resumeCount = 0;
    await tester.pumpWidget(
      createViewer(
        group: createGroup(1),
        onPause: () => pauseCount++,
        onResume: () => resumeCount++,
      ),
    );
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.inactive,
    );
    tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.hidden,
    );
    tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.paused,
    );
    await tester.pump();
    expect(pauseCount, 1);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(VStoryViewer)),
    );
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(resumeCount, 0);

    tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.hidden,
    );
    tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.inactive,
    );
    tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
    await tester.pump();
    expect(resumeCount, 1);
  });

  testWidgets('quick next tap does not resume the outgoing story',
      (tester) async {
    var pauseCount = 0;
    var resumeCount = 0;
    await tester.pumpWidget(
      createViewer(
        group: createGroup(2),
        onPause: () => pauseCount++,
        onResume: () => resumeCount++,
      ),
    );
    await tester.pump();

    final size = tester.getSize(find.byType(VStoryViewer));
    await tester.tapAt(Offset(size.width * 0.8, size.height * 0.5));
    await tester.pump();
    await tester.pump();

    expect(find.text('Story 1'), findsOneWidget);
    expect(pauseCount, 1);
    expect(resumeCount, 0);
  });
}
