import 'package:flutter/material.dart';

import 'cache_manager_test_screen.dart';
import 'error_handling_test_screen.dart';
import 'gesture_detector_test_screen.dart';
import 'localization_test_screen.dart';
import 'media_viewer_test_screen.dart';
import 'progress_test_screen.dart';
import 'reactions_demo_screen.dart';
import 'reply_system_test_screen.dart';
import 'story_actions_test_screen.dart';
import 'story_footer_test_screen.dart';
import 'story_header_test_screen.dart';
import 'story_viewer_example_screen.dart';
import 'story_viewer_test_screen.dart';
import 'theme_system_test_screen.dart';

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
            title: 'Media Viewer',
            description: 'Test image, video, text, and custom stories',
            icon: Icons.photo_library,
            color: Colors.purple,
            onTap: () => _navigate(context, const MediaViewerTestScreen()),
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
            title: 'Reply System',
            description: 'Test reply input and keyboard handling',
            icon: Icons.reply,
            color: Colors.teal,
            onTap: () => _navigate(context, const ReplySystemTestScreen()),
          ),
          _buildFeatureCard(
            context,
            title: 'Story Actions',
            description: 'Test action buttons (share, save, etc.)',
            icon: Icons.more_vert,
            color: Colors.indigo,
            onTap: () => _navigate(context, const StoryActionsTestScreen()),
          ),
          _buildFeatureCard(
            context,
            title: 'Story Header',
            description: 'Test user info and timestamp display',
            icon: Icons.person,
            color: Colors.pink,
            onTap: () => _navigate(context, const StoryHeaderTestScreen()),
          ),
          _buildFeatureCard(
            context,
            title: 'Story Footer',
            description: 'Test caption and metadata display',
            icon: Icons.text_fields,
            color: Colors.amber,
            onTap: () => _navigate(context, const StoryFooterTestScreen()),
          ),
          _buildFeatureCard(
            context,
            title: 'Theme System',
            description: 'Test theme customization',
            icon: Icons.palette,
            color: Colors.deepPurple,
            onTap: () => _navigate(context, const ThemeSystemTestScreen()),
          ),
          _buildFeatureCard(
            context,
            title: 'Localization',
            description: 'Test internationalization support',
            icon: Icons.language,
            color: Colors.cyan,
            onTap: () => _navigate(context, const LocalizationTestScreen()),
          ),
          _buildFeatureCard(
            context,
            title: 'Error Handling',
            description: 'Test error states and recovery',
            icon: Icons.error_outline,
            color: Colors.red,
            onTap: () => _navigate(context, const ErrorHandlingTestScreen()),
          ),
          _buildFeatureCard(
            context,
            title: '🎯 Story Viewer (NEW)',
            description: 'NEW: Complete orchestrator with all features',
            icon: Icons.play_circle_filled,
            color: Colors.blue.shade700,
            onTap: () => _navigate(context, const StoryViewerExampleScreen()),
          ),
          _buildFeatureCard(
            context,
            title: '❤️ Reactions Demo (NEW)',
            description: 'NEW: Double-tap reactions with animation',
            icon: Icons.favorite,
            color: Colors.red,
            onTap: () => _navigate(context, const ReactionsDemoScreen()),
          ),
          _buildFeatureCard(
            context,
            title: 'Full Story Viewer',
            description: 'Test complete story viewing experience',
            icon: Icons.video_library,
            color: Colors.deepOrange,
            onTap: () => _navigate(context, const StoryViewerTestScreen()),
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
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
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
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
