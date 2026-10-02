import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

class _SynchronouslyLoadedImage extends StatefulWidget {
  final VoidCallback onLoaded;

  const _SynchronouslyLoadedImage({required this.onLoaded});

  @override
  State<_SynchronouslyLoadedImage> createState() =>
      _SynchronouslyLoadedImageState();
}

class _SynchronouslyLoadedImageState extends State<_SynchronouslyLoadedImage> {
  var _isLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isLoaded = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      widget.onLoaded();
    }
    return const ColoredBox(color: Colors.black);
  }
}

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

  testWidgets('custom image builder can report a cached load during build',
      (tester) async {
    var loadCount = 0;
    final group = VStoryGroup(
      user: const VStoryUser(
        id: 'user',
        name: 'User',
        imageUrl: 'https://example.com/avatar.jpg',
      ),
      stories: [
        VImageStory(
          url: 'https://example.com/story.jpg',
          duration: const Duration(seconds: 30),
          createdAt: DateTime.now(),
          isSeen: false,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: VStoryViewer(
          storyGroups: [group],
          config: VStoryConfig(
            hideStatusBar: false,
            showHeader: false,
            showReplyField: false,
            enableCaching: false,
            imageBuilder: (context, story, onLoaded, onError) {
              return _SynchronouslyLoadedImage(onLoaded: onLoaded);
            },
          ),
          onLoad: (_, __) => loadCount++,
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(loadCount, 1);
  });
}
