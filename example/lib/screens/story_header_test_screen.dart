import 'package:flutter/material.dart';

/// Test screen for v_story_header feature
class StoryHeaderTestScreen extends StatelessWidget {
  const StoryHeaderTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Header Test'),
      ),
      body: const Center(
        child: Text('Story Header Test Screen - Coming Soon'),
      ),
    );
  }
}
