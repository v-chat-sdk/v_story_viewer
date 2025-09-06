import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

/// Basic story viewer page with horizontal swipe navigation between users
class StoryViewerPage extends StatefulWidget {
  final VStoryList storyList;
  final int initialGroupIndex;

  const StoryViewerPage({
    super.key,
    required this.storyList,
    this.initialGroupIndex = 0,
  });

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> {
  @override
  Widget build(BuildContext context) {
    // Set system UI for immersive experience
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildPageViewer(), // Use horizontal swipe navigation
    );
  }

  /// Builds story viewer with horizontal swipe navigation between users
  Widget _buildPageViewer() {
    return SafeArea(
      child: VStoryViewer(
        storyList: widget.storyList,
        initialGroupIndex: widget.initialGroupIndex,
        config: const VStoryViewerConfig(
          gestureConfig: VGestureConfig(
            tapEnabled: true,
            swipeEnabled: true,
            longPressEnabled: true,
          ),
        ),
        onPageChanged: (index, group) {
          debugPrint('Switched to user: ${group.user.name} (index: $index)');
        },
        onStoryViewed: (story) {
          debugPrint('Story viewed: ${story.id}');
        },
        onGroupCompleted: (group) {
          debugPrint('All stories completed for user: ${group.user.name}');
        },
        onDismiss: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// Themed story viewer page with custom styles
class ThemedStoryViewerPage extends StatefulWidget {
  final VStoryList storyList;

  const ThemedStoryViewerPage({super.key, required this.storyList});

  @override
  State<ThemedStoryViewerPage> createState() => _ThemedStoryViewerPageState();
}

class _ThemedStoryViewerPageState extends State<ThemedStoryViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: VStoryViewer(
          storyList: widget.storyList,
          onDismiss: () => Navigator.pop(context),
          config: VStoryViewerConfig(
            progressStyle: VStoryProgressStyle(
              activeColor: Colors.pink,
              inactiveColor: Colors.pink.withValues(alpha: 0.3),
              height: 3,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            ),
            textStoryStyle: const VTextStoryStyle(
              textStyle: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          headerBuilder: (context, user, story) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      user.avatarUrl ?? 'https://i.pravatar.cc/150',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatTime(story.createdAt),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Story viewer with all callbacks demonstrated
class CallbackStoryViewerPage extends StatefulWidget {
  final VStoryList storyList;

  const CallbackStoryViewerPage({super.key, required this.storyList});

  @override
  State<CallbackStoryViewerPage> createState() =>
      _CallbackStoryViewerPageState();
}

class _CallbackStoryViewerPageState extends State<CallbackStoryViewerPage> {
  final List<String> events = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: VStoryViewer(
              storyList: widget.storyList,
              onDismiss: () {
                debugPrint('Viewer dismissed');
                Navigator.pop(context);
              },
              onStoryViewed: (story) {
                setState(() {
                  events.add('Viewed: ${story.id}');
                });
                debugPrint('Story viewed: ${story.id}');
              },
              onGroupCompleted: (group) {
                debugPrint('All stories completed for group: ${group.user.name}');
                Navigator.pop(context);
              },
            ),
          ),
          // Event log overlay
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              height: 100,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return Text(
                    events[index],
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Story viewer with reply system
class ReplyStoryViewerPage extends StatefulWidget {
  final VStoryList storyList;

  const ReplyStoryViewerPage({super.key, required this.storyList});

  @override
  State<ReplyStoryViewerPage> createState() => _ReplyStoryViewerPageState();
}

class _ReplyStoryViewerPageState extends State<ReplyStoryViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: VStoryViewer(
          storyList: widget.storyList,
          onDismiss: () => Navigator.pop(context),
          footerBuilder: (context, story) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Send a message...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      // Handle reply send
                      debugPrint('Reply sent for story ${story.id}');
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Story viewer with reaction system
class ReactionStoryViewerPage extends StatefulWidget {
  final VStoryList storyList;

  const ReactionStoryViewerPage({super.key, required this.storyList});

  @override
  State<ReactionStoryViewerPage> createState() =>
      _ReactionStoryViewerPageState();
}

class _ReactionStoryViewerPageState extends State<ReactionStoryViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onDoubleTap: () {
          // Show reaction animation
          debugPrint('Reaction sent');
          _showReactionAnimation(context);
        },
        child: Stack(
          children: [
            SafeArea(
              child: VStoryViewer(
                storyList: widget.storyList,
                onDismiss: () => Navigator.pop(context),
                config: const VStoryViewerConfig(
                  gestureConfig: VGestureConfig(enableDoubleTap: true),
                ),
              ),
            ),
            // Instructions overlay
            const Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Text(
                'Double tap to react ❤️',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReactionAnimation(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          onEnd: () => entry.remove(),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value < 0.5 ? value * 2 : 2 - value * 2,
              child: Opacity(
                opacity: 1 - value,
                child: const Icon(Icons.favorite, color: Colors.red, size: 100),
              ),
            );
          },
        ),
      ),
    );

    overlay.insert(entry);
  }
}
