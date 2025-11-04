import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const VStoryViewerExampleApp());
}

class VStoryViewerExampleApp extends StatelessWidget {
  const VStoryViewerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V Story Viewer - Feature Tests',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
