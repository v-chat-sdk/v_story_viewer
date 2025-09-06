import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

void main() {
  runApp(const WebTestApp());
}

class WebTestApp extends StatelessWidget {
  const WebTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V Story Viewer Web Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WebTestPage(),
    );
  }
}

class WebTestPage extends StatefulWidget {
  const WebTestPage({super.key});

  @override
  State<WebTestPage> createState() => _WebTestPageState();
}

class _WebTestPageState extends State<WebTestPage> {
  @override
  Widget build(BuildContext context) {
    // Create sample stories with publicly available images
    final now = DateTime.now();
    
    final storyList = VStoryList(
      groups: [
        VStoryGroup(
          user: VStoryUser.fromUrl(
            id: 'web_test_user',
            name: 'Web Test User',
            avatarUrl: 'https://picsum.photos/200',
          ),
          stories: [
            VImageStory.fromUrl(
              id: 'story_1',
              url: 'https://picsum.photos/400/600?random=1',
              duration: const Duration(seconds: 5),
              caption: 'Test Image 1 - Web Platform',
              createdAt: now,
            ),
            VImageStory.fromUrl(
              id: 'story_2',
              url: 'https://picsum.photos/400/600?random=2',
              duration: const Duration(seconds: 5),
              caption: 'Test Image 2 - Web Platform',
              createdAt: now,
            ),
            VTextStory(
              id: 'story_3',
              text: 'This is a text story running on the web platform!',
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 3),
              createdAt: now,
            ),
            VImageStory.fromUrl(
              id: 'story_4',
              url: 'https://picsum.photos/400/600?random=3',
              duration: const Duration(seconds: 5),
              caption: 'Test Image 3 - Web Platform',
              createdAt: now,
            ),
          ],
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('V Story Viewer - Web Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Click to view stories on Web',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VStoryViewer(
                      storyList: storyList,
                      onDismiss: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('View Stories'),
            ),
            const SizedBox(height: 20),
            const Text(
              'This test verifies that the story viewer works on web platform\n'
              'without path_provider issues.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}