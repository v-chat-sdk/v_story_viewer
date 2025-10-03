import 'package:flutter/material.dart';

/// Test screen for v_media_viewer feature
class MediaViewerTestScreen extends StatelessWidget {
  const MediaViewerTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Viewer Test'),
      ),
      body: const Center(
        child: Text('Media Viewer Test Screen - Coming Soon'),
      ),
    );
  }
}
