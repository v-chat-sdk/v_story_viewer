import 'package:flutter/material.dart';
import 'debug_story_viewer.dart';

/// Main debug example application
void main() {
  // Enable debug mode for detailed logging
  debugPrint('🚀 Starting Debug Story Viewer Example');
  
  runApp(const DebugExampleApp());
}

class DebugExampleApp extends StatelessWidget {
  const DebugExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story Viewer Debug',
      debugShowCheckedModeBanner: false, // Show debug banner for clarity
      theme: ThemeData.dark(),
      home: const DebugHomePage(),
    );
  }
}

class DebugHomePage extends StatelessWidget {
  const DebugHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Viewer Debug Tools'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bug_report,
              size: 80,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 20),
            Text(
              'Debug Story Viewer',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Test various story scenarios with numbered users and stories',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DebugStoryViewer(),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Launch Debug Viewer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 Debug Features:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem('✅ Numbered users (user_1, user_2, etc.)'),
                    _buildFeatureItem('✅ Numbered stories (story_1, story_2, etc.)'),
                    _buildFeatureItem('✅ Text-only story testing mode'),
                    _buildFeatureItem('✅ Real-time progress monitoring'),
                    _buildFeatureItem('✅ Playback state tracking'),
                    _buildFeatureItem('✅ Error simulation scenarios'),
                    _buildFeatureItem('✅ Performance testing with many stories'),
                    _buildFeatureItem('✅ Edge case testing'),
                    _buildFeatureItem('✅ Programmatic control buttons'),
                    _buildFeatureItem('✅ Detailed console logging'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}