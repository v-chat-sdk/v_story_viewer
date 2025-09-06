import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

/// Simple example demonstrating v_story_viewer
class SimpleExample extends StatefulWidget {
  const SimpleExample({super.key});

  @override
  State<SimpleExample> createState() => _SimpleExampleState();
}

class _SimpleExampleState extends State<SimpleExample> {
  late VStoryController controller;

  @override
  void initState() {
    super.initState();
    controller = VStoryController();

    // Initialize with sample stories
    final storyList = VStoryList(
      groups: [
        VStoryGroup(
          user: VStoryUser(id: 'user_1', name: 'Sample User'),
          stories: [
            // Text story example
            VTextStory(
              id: 'text_story_1',
              text:
                  'Welcome to V Story Viewer!\n\nThis is a text story example.',
              backgroundColor: Colors.blue.shade700,
              duration: const Duration(seconds: 5),
              createdAt: DateTime.now(),
            ),
            // Image story from URL
            VImageStory(
              id: 'image_story_1',
              media: VPlatformFile.fromUrl(
                networkUrl: 'https://picsum.photos/1080/1920?random=1',
              ),
              duration: const Duration(seconds: 5),
              createdAt: DateTime.now(),
            ),
            // Another text story
            VTextStory(
              id: 'text_story_2',
              text: 'You can customize colors, fonts, and more!',
              backgroundColor: Colors.purple.shade700,
              duration: const Duration(seconds: 4),
              createdAt: DateTime.now(),
            ),
            // Custom widget story
            VCustomStory(
              id: 'custom_story_1',
              duration: const Duration(seconds: 6),
              createdAt: DateTime.now(),
              builder: (context) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.pink.shade400, Colors.orange.shade400],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlutterLogo(size: 120),
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
                        'Display any Flutter widget!',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    controller.initialize(storyList);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: VStoryViewer(
        storyList: controller.state.storyList,
        config: VStoryViewerConfig(
          progressStyle: VStoryProgressStyle(
            activeColor: Colors.white,
            inactiveColor: Colors.white.withValues(alpha: 0.3),
            height: 2.5,
          ),
          gestureConfig: const VGestureConfig(
            tapEnabled: true,
            swipeEnabled: true,
            longPressEnabled: true,
            enableDoubleTap: true,
          ),
          enableReply: true,
          enableReactions: true,
          replyConfig: VReplyConfiguration(
            hintText: 'Send a message...',
            onReplySend: (message, story) async {
              debugPrint('Reply: $message for story ${story.id}');
              return true;
            },
          ),
          reactionConfig: VReactionConfiguration(
            onReaction: (story) {
              debugPrint('Reaction sent for story ${story.id}');
            },
          ),
          theme: VStoryTheme.withProgressBar(
            progressBarTheme: VStoryProgressStyle(
              activeColor: Colors.white,
              inactiveColor: Colors.white.withValues(alpha: 0.3),
              height: 2.5,
            ),
          ),
        ),
        onDismiss: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// Main app to launch the example
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V Story Viewer Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

/// Home page with button to launch story viewer
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('V Story Viewer Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'V Story Viewer Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'A comprehensive story viewer for Flutter',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SimpleExample(),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('View Stories'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
