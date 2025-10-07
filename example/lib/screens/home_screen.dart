import 'package:example/screens/story_viewer_example_screen.dart';
import 'package:flutter/material.dart';
import 'cache_manager_test_screen.dart';
import 'gesture_detector_test_screen.dart';
import 'progress_test_screen.dart';

/// Home screen with buttons to test each feature
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('V Story Viewer - Feature Tests'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFeatureCard(
            context,
            title: 'Progress Bar',
            description: 'Test segmented progress bar animations',
            icon: Icons.linear_scale,
            color: Colors.blue,
            onTap: () => _navigate(context, const ProgressTestScreen()),
          ),
          _buildFeatureCard(
            context,
            title: 'Gesture Detector',
            description: 'Test tap zones and swipe gestures',
            icon: Icons.touch_app,
            color: Colors.green,
            onTap: () => _navigate(context, const GestureDetectorTestScreen()),
          ),
          _buildFeatureCard(
            context,
            title: 'Cache Manager',
            description: 'Test media caching and preloading',
            icon: Icons.storage,
            color: Colors.orange,
            onTap: () => _navigate(context, const CacheManagerTestScreen()),
          ),

          _buildFeatureCard(
            context,
            title: 'Full Story Viewer',
            description: 'Test complete story viewing experience',
            icon: Icons.video_library,
            color: Colors.deepOrange,
            onTap: () => _navigate(context, const StoryViewerExampleScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
