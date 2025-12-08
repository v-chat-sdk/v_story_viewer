import 'dart:async';

import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V Story Viewer Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<VStoryGroup> _basicStories;
  late List<VStoryGroup> _advancedStories;
  late List<VStoryGroup> _customStories;
  // Track seen state
  final Set<String> _seenStoryIds = {};
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _basicStories = _createBasicStories();
    _advancedStories = _createAdvancedStories();
    _customStories = _createCustomStories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // BASIC STORIES - Image, Video, Text, Voice
  // ═══════════════════════════════════════════════════════════════
  List<VStoryGroup> _createBasicStories() {
    final now = DateTime.now();
    return [
      // User 1: Multiple Image Stories
      VStoryGroup(
        user: const VStoryUser(
          id: 'user_images',
          name: 'Sarah Photos',
          imageUrl: 'https://i.pravatar.cc/150?u=sarah',
        ),
        stories: [
          VImageStory(
            url: 'https://picsum.photos/seed/nature1/1080/1920',
            createdAt: now.subtract(const Duration(hours: 2)),
            isSeen: false,
            duration: const Duration(seconds: 4),
            caption: 'This is a caption',
          ),
          VImageStory(
            url: 'https://picsum.photos/seed/nature2/1080/1920',
            createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
            isSeen: false,
          ),
          VImageStory(
            url: 'https://picsum.photos/seed/nature3/1080/1920',
            createdAt: now.subtract(const Duration(hours: 1)),
            isSeen: false,
            duration: const Duration(seconds: 7),
          ),
        ],
      ),
      // User 2: Video Stories
      VStoryGroup(
        user: const VStoryUser(
          id: 'user_videos',
          name: 'Mike Videos',
          imageUrl: 'https://i.pravatar.cc/150?u=mike',
        ),
        stories: [
          VVideoStory(
            url:
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
            createdAt: now.subtract(const Duration(hours: 4)),
            isSeen: false,
          ),
          VVideoStory(
            url:
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            createdAt: now.subtract(const Duration(hours: 3)),
            isSeen: false,
          ),
        ],
      ),
      // User 3: Text Stories with different styles
      VStoryGroup(
        user: const VStoryUser(
          id: 'user_text',
          name: 'Emma Quotes',
          imageUrl: 'https://i.pravatar.cc/150?u=emma',
        ),
        stories: [
          VTextStory(
            text: 'Good morning everyone! Hope you have an amazing day ahead.',
            backgroundColor: const Color(0xFF6366F1),
            createdAt: now.subtract(const Duration(hours: 6)),
            isSeen: false,
          ),
          VTextStory(
            text:
                'The only way to do great work is to love what you do. - Steve Jobs',
            backgroundColor: const Color(0xFFEC4899),
            textStyle: const TextStyle(
              fontSize: 28,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
            ),
            createdAt: now.subtract(const Duration(hours: 5)),
            isSeen: false,
          ),
          VTextStory(
            text: 'Flutter is awesome for building beautiful apps!',
            backgroundColor: const Color(0xFF10B981),
            createdAt: now.subtract(const Duration(hours: 4)),
            isSeen: false,
            duration: const Duration(seconds: 4),
          ),
        ],
      ),
      // User 4: Voice/Audio Stories
      VStoryGroup(
        user: const VStoryUser(
          id: 'user_voice',
          name: 'DJ Alex',
          imageUrl: 'https://i.pravatar.cc/150?u=alex',
        ),
        stories: [
          VVoiceStory(
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
            backgroundColor: const Color(0xFF8B5CF6),
            createdAt: now.subtract(const Duration(hours: 8)),
            isSeen: false,
          ),
          VVoiceStory(
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
            backgroundColor: const Color(0xFFF59E0B),
            createdAt: now.subtract(const Duration(hours: 7)),
            isSeen: false,
          ),
        ],
      ),
      // User 5: Mixed content (partial seen)
      VStoryGroup(
        user: const VStoryUser(
          id: 'user_mixed',
          name: 'Chris Mix',
          imageUrl: 'https://i.pravatar.cc/150?u=chris',
        ),
        stories: [
          VImageStory(
            url: 'https://picsum.photos/seed/mix1/1080/1920',
            createdAt: now.subtract(const Duration(hours: 10)),
            isSeen: true,
          ),
          VTextStory(
            text: 'Check out my latest video below!',
            backgroundColor: Colors.deepOrange,
            createdAt: now.subtract(const Duration(hours: 9)),
            isSeen: true,
          ),
          VVideoStory(
            url:
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
            createdAt: now.subtract(const Duration(hours: 8)),
            isSeen: false,
          ),
          VImageStory(
            url: 'https://picsum.photos/seed/mix2/1080/1920',
            createdAt: now.subtract(const Duration(hours: 7)),
            isSeen: false,
          ),
        ],
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════
  // ADVANCED STORIES - Overlays, RichText, Custom Builders
  // ═══════════════════════════════════════════════════════════════
  List<VStoryGroup> _createAdvancedStories() {
    final now = DateTime.now();
    return [
      // User 1: Stories with Overlays (captions, watermarks)
      VStoryGroup(
        user: const VStoryUser(
          id: 'user_overlay',
          name: 'Overlay Demo',
          imageUrl: 'https://i.pravatar.cc/150?u=overlay',
        ),
        stories: [
          // Image with caption overlay
          VImageStory(
            url: 'https://picsum.photos/seed/overlay1/1080/1920',
            createdAt: now.subtract(const Duration(hours: 2)),
            isSeen: false,
            overlayBuilder: (context) => Positioned(
              bottom: 120,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Beautiful sunset at the beach!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Image with watermark overlay
          VImageStory(
            url: 'https://picsum.photos/seed/overlay2/1080/1920',
            createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
            isSeen: false,
            overlayBuilder: (context) => Positioned(
              top: 100,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: Colors.blue.shade600, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '@photographer',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Image with multiple overlay elements
          VImageStory(
            url: 'https://picsum.photos/seed/overlay3/1080/1920',
            createdAt: now.subtract(const Duration(hours: 1)),
            isSeen: false,
            overlayBuilder: (context) => Stack(
              children: [
                // Location tag
                Positioned(
                  top: 100,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 16),
                        SizedBox(width: 4),
                        Text('New York City',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                // Hashtag
                Positioned(
                  bottom: 140,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '#travel #adventure',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // User 2: Rich Text Stories
      VStoryGroup(
        user: const VStoryUser(
          id: 'user_richtext',
          name: 'Rich Text',
          imageUrl: 'https://i.pravatar.cc/150?u=richtext',
        ),
        stories: [
          // RichText with TextSpan
          VTextStory(
            text: 'Rich text story',
            backgroundColor: const Color(0xFF1F2937),
            createdAt: now.subtract(const Duration(hours: 3)),
            isSeen: false,
            richText: TextSpan(
              children: [
                const TextSpan(
                  text: 'Welcome to ',
                  style: TextStyle(fontSize: 28, color: Colors.white),
                ),
                TextSpan(
                  text: 'V Story Viewer',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                  ),
                ),
                const TextSpan(
                  text: '\n\nThe most powerful story viewer for Flutter!',
                  style: TextStyle(fontSize: 20, color: Colors.white70),
                ),
              ],
            ),
          ),
          // Custom text builder
          VTextStory(
            text: 'Custom builder story',
            backgroundColor: const Color(0xFF0F172A),
            createdAt: now.subtract(const Duration(hours: 2)),
            isSeen: false,
            textBuilder: (context, text) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rocket_launch, size: 80, color: Colors.amber),
                const SizedBox(height: 24),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.purple, Colors.blue, Colors.cyan],
                  ).createShader(bounds),
                  child: const Text(
                    'LAUNCH DAY!',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Our new app is now live',
                  style: TextStyle(fontSize: 20, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
      // User 3: All seen stories (grey ring)
      VStoryGroup(
        user: const VStoryUser(
          id: 'user_allseen',
          name: 'All Seen',
          imageUrl: 'https://i.pravatar.cc/150?u=allseen',
        ),
        stories: [
          VImageStory(
            url: 'https://picsum.photos/seed/seen1/1080/1920',
            createdAt: now.subtract(const Duration(hours: 12)),
            isSeen: true,
          ),
          VImageStory(
            url: 'https://picsum.photos/seed/seen2/1080/1920',
            createdAt: now.subtract(const Duration(hours: 11)),
            isSeen: true,
          ),
          VTextStory(
            text: 'All stories viewed!',
            backgroundColor: Colors.grey,
            createdAt: now.subtract(const Duration(hours: 10)),
            isSeen: true,
          ),
        ],
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════
  // CUSTOM STORIES - VCustomStory with interactive content
  // ═══════════════════════════════════════════════════════════════
  List<VStoryGroup> _createCustomStories() {
    final now = DateTime.now();
    return [
      // User 1: Interactive Poll/Quiz
      VStoryGroup(
        user: const VStoryUser(
          id: 'user_poll',
          name: 'Poll Demo',
          imageUrl: 'https://i.pravatar.cc/150?u=poll',
        ),
        stories: [
          VCustomStory(
            createdAt: now.subtract(const Duration(hours: 1)),
            isSeen: false,
            duration: const Duration(seconds: 15),
            contentBuilder: (context, isPaused, isMuted, onLoaded, onError) {
              // Call onLoaded immediately since content is ready
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onLoaded(const Duration(seconds: 15));
              });
              return const _PollStoryContent();
            },
          ),
        ],
      ),
      // User 2: Countdown Timer
      VStoryGroup(
        user: const VStoryUser(
          id: 'user_countdown',
          name: 'Countdown',
          imageUrl: 'https://i.pravatar.cc/150?u=countdown',
        ),
        stories: [
          VCustomStory(
            createdAt: now.subtract(const Duration(hours: 2)),
            isSeen: false,
            contentBuilder: (context, isPaused, isMuted, onLoaded, onError) {
              return _CountdownStoryContent(
                isPaused: isPaused,
                onLoaded: onLoaded,
              );
            },
          ),
        ],
      ),
      // User 3: Gradient Animation
      VStoryGroup(
        user: const VStoryUser(
          id: 'user_gradient',
          name: 'Animated BG',
          imageUrl: 'https://i.pravatar.cc/150?u=gradient',
        ),
        stories: [
          VCustomStory(
            createdAt: now.subtract(const Duration(hours: 3)),
            isSeen: false,
            duration: const Duration(seconds: 8),
            contentBuilder: (context, isPaused, isMuted, onLoaded, onError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onLoaded(const Duration(seconds: 8));
              });
              return _AnimatedGradientContent(isPaused: isPaused);
            },
          ),
        ],
      ),
      // User 4: Product Showcase
      VStoryGroup(
        user: const VStoryUser(
          id: 'user_product',
          name: 'Shop Now',
          imageUrl: 'https://i.pravatar.cc/150?u=shop',
        ),
        stories: [
          VCustomStory(
            createdAt: now.subtract(const Duration(hours: 4)),
            isSeen: false,
            duration: const Duration(seconds: 10),
            contentBuilder: (context, isPaused, isMuted, onLoaded, onError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onLoaded(const Duration(seconds: 10));
              });
              return const _ProductShowcaseContent();
            },
            overlayBuilder: (context) => Positioned(
              bottom: 120,
              left: 16,
              right: 16,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shop Now tapped!')),
                  );
                },
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Shop Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════
  // STORY VIEWER OPENERS
  // ═══════════════════════════════════════════════════════════════
  void _openBasicViewer(VStoryGroup group, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VStoryViewer(
          storyGroups: _basicStories,
          initialGroupIndex: index,
          config: const VStoryConfig(),
          onComplete: (group, item) => debugPrint('All stories complete'),
          onClose: (group, item) => debugPrint('Viewer closed'),
          onStoryViewed: (group, item) {
            debugPrint('Viewed: ${group.user.name}');
            setState(
                () => _seenStoryIds.add('${group.user.id}_${item.createdAt}'));
          },
          onReply: (group, item, text) {
            debugPrint('Reply to ${group.user.name}: $text');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Reply sent to ${group.user.name}: $text')),
            );
          },
          onUserTap: (group, item) async {
            await _showUserProfile(group.user);
            return true;
          },
          onMenuTap: (group, item) async {
            return await _showStoryMenu(group, item);
          },
          onSwipeUp: (group, item) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Swipe up detected!')),
            );
          },
          onError: (group, item, error) {
            debugPrint('Error: $error');
          },
        ),
      ),
    );
  }

  void _openAdvancedViewer(VStoryGroup group, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VStoryViewer(
          storyGroups: _advancedStories,
          initialGroupIndex: index,
          config: VStoryConfig(
            // Custom colors
            progressColor: Colors.amber,
            progressBackgroundColor: Colors.amber.withValues(alpha: 0.3),
            // Custom loading builder
            loadingBuilder: (context) => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.amber),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Custom error builder
            errorBuilder: (context, error, retry) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Oops! Something went wrong',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
            // i18n texts
            texts: const VStoryTexts(
              replyHint: 'Write a reply...',
              errorLoadingMedia: 'Could not load content',
              tapToRetry: 'Tap here to retry',
            ),
          ),
          onStoryViewed: (group, item) => debugPrint('Advanced viewed'),
          onReply: (group, item, text) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Reply: $text')),
            );
          },
          onMenuTap: (group, item) async => await _showStoryMenu(group, item),
        ),
      ),
    );
  }

  void _openCustomViewer(VStoryGroup group, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VStoryViewer(
          storyGroups: _customStories,
          initialGroupIndex: index,
          config: const VStoryConfig(
            showReplyField: false, // Hide reply for custom stories
            showEmojiButton: false,
          ),
          onStoryViewed: (group, item) => debugPrint('Custom story viewed'),
          onSwipeUp: (group, item) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Swipe up on custom story!')),
            );
          },
        ),
      ),
    );
  }

  void _openMinimalViewer() {
    // Minimal config - hide most UI elements
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VStoryViewer(
          storyGroups: _basicStories,
          initialGroupIndex: 0,
          config: const VStoryConfig(
            showHeader: false,
            showProgressBar: true,
            showReplyField: false,
            autoPauseOnBackground: false,
          ),
        ),
      ),
    );
  }

  void _openCustomHeaderViewer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VStoryViewer(
          storyGroups: _basicStories,
          initialGroupIndex: 0,
          config: VStoryConfig(
            headerBuilder: (context, user, item, onClose) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.imageUrl),
                      radius: 24,
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
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            TimeFormatter.formatRelativeTime(item.createdAt),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),
            ),
            footerBuilder: (context, group, item) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'Custom footer!',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.favorite_border,
                          color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Liked!')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPER DIALOGS
  // ═══════════════════════════════════════════════════════════════
  Future<void> _showUserProfile(VStoryUser user) async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.imageUrl),
              radius: 50,
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('User ID: ${user.id}'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProfileStat('Posts', '42'),
                _buildProfileStat('Followers', '1.2K'),
                _buildProfileStat('Following', '180'),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('View Full Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Future<bool> _showStoryMenu(VStoryGroup group, VStoryItem item) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report'),
              onTap: () => Navigator.pop(ctx, 'report'),
            ),
            ListTile(
              leading: const Icon(Icons.volume_off_outlined),
              title: Text('Mute ${group.user.name}'),
              onTap: () => Navigator.pop(ctx, 'mute'),
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: Text('Block ${group.user.name}'),
              onTap: () => Navigator.pop(ctx, 'block'),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () => Navigator.pop(ctx, 'share'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (action != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action: $action for ${group.user.name}')),
      );
    }
    return true;
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD UI
  // ═══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('V Story Viewer Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Basic', icon: Icon(Icons.auto_stories)),
            Tab(text: 'Advanced', icon: Icon(Icons.auto_awesome)),
            Tab(text: 'Custom', icon: Icon(Icons.widgets)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicTab(),
          _buildAdvancedTab(),
          _buildCustomTab(),
        ],
      ),
    );
  }

  Widget _buildBasicTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Basic Stories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        VStoryCircleList(
          storyGroups: _basicStories,
          circleConfig: const VStoryCircleConfig(
            unseenColor: Colors.green,
            seenColor: Colors.grey,
            ringWidth: 4,
            segmentGap: 0.2,
          ),
          onUserTap: _openBasicViewer,
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              _FeatureCard(
                  icon: Icons.image,
                  title: 'Image Stories',
                  description:
                      'Sarah Photos - Multiple images with custom durations'),
              _FeatureCard(
                  icon: Icons.videocam,
                  title: 'Video Stories',
                  description:
                      'Mike Videos - Auto-duration from video metadata'),
              _FeatureCard(
                  icon: Icons.text_fields,
                  title: 'Text Stories',
                  description:
                      'Emma Quotes - Text with custom styles and colors'),
              _FeatureCard(
                  icon: Icons.mic,
                  title: 'Voice Stories',
                  description: 'DJ Alex - Audio playback with seek slider'),
              _FeatureCard(
                  icon: Icons.shuffle,
                  title: 'Mixed Content',
                  description:
                      'Chris Mix - Combined types, partial seen state'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Advanced Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        VStoryCircleList(
          storyGroups: _advancedStories,
          circleConfig: const VStoryCircleConfig(
            unseenColor: Colors.amber,
            seenColor: Colors.grey,
            ringWidth: 5,
            segmentGap: 0.15,
          ),
          onUserTap: _openAdvancedViewer,
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _FeatureCard(
                icon: Icons.layers,
                title: 'Overlay Stories',
                description: 'Captions, watermarks, location tags, hashtags',
              ),
              const _FeatureCard(
                icon: Icons.format_color_text,
                title: 'Rich Text',
                description: 'TextSpan with gradients, custom text builders',
              ),
              const _FeatureCard(
                icon: Icons.check_circle,
                title: 'All Seen',
                description: 'Grey ring when all stories viewed',
              ),
              const SizedBox(height: 24),
              const Text('Quick Actions',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.visibility_off, size: 18),
                    label: const Text('Minimal UI'),
                    onPressed: _openMinimalViewer,
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.dashboard_customize, size: 18),
                    label: const Text('Custom Header/Footer'),
                    onPressed: _openCustomHeaderViewer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Custom Stories (VCustomStory)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        VStoryCircleList(
          storyGroups: _customStories,
          circleConfig: const VStoryCircleConfig(
            unseenColor: Colors.purple,
            seenColor: Colors.grey,
            ringWidth: 4,
            segmentGap: 0.25,
          ),
          onUserTap: _openCustomViewer,
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _FeatureCard(
                icon: Icons.poll,
                title: 'Interactive Poll',
                description: 'Poll Demo - Tap options to vote, see results',
              ),
              const _FeatureCard(
                icon: Icons.timer,
                title: 'Countdown Timer',
                description: 'Countdown - Live countdown with pause support',
              ),
              const _FeatureCard(
                icon: Icons.gradient,
                title: 'Animated Background',
                description: 'Animated BG - Smooth gradient animation',
              ),
              const _FeatureCard(
                icon: Icons.shopping_bag,
                title: 'Product Showcase',
                description: 'Shop Now - E-commerce story with CTA button',
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.purple.withAlpha(25),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('VCustomStory',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                        'Use VCustomStory for:\n'
                        '• Interactive polls/quizzes\n'
                        '• Countdown timers\n'
                        '• Lottie animations\n'
                        '• 3D models\n'
                        '• Live data\n'
                        '• Any custom widget!',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CUSTOM STORY CONTENT WIDGETS
// ═══════════════════════════════════════════════════════════════
class _PollStoryContent extends StatefulWidget {
  const _PollStoryContent();
  @override
  State<_PollStoryContent> createState() => _PollStoryContentState();
}

class _PollStoryContentState extends State<_PollStoryContent> {
  int? _selectedOption;
  final _votes = [42, 28, 15, 10];
  @override
  Widget build(BuildContext context) {
    final totalVotes = _votes.reduce((a, b) => a + b);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'What\'s your favorite Flutter feature?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ..._buildPollOptions(totalVotes),
              if (_selectedOption != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Total votes: $totalVotes',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPollOptions(int totalVotes) {
    final options = [
      'Hot Reload',
      'Widget System',
      'Cross-Platform',
      'Performance'
    ];
    return List.generate(options.length, (index) {
      final isSelected = _selectedOption == index;
      final hasVoted = _selectedOption != null;
      final percentage =
          hasVoted ? (_votes[index] / totalVotes * 100).round() : 0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: _selectedOption == null
              ? () => setState(() => _selectedOption = index)
              : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isSelected ? 0.3 : 0.15),
              borderRadius: BorderRadius.circular(12),
              border:
                  isSelected ? Border.all(color: Colors.white, width: 2) : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    options[index],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                if (hasVoted)
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _CountdownStoryContent extends StatefulWidget {
  final bool isPaused;
  final void Function(Duration? duration) onLoaded;
  const _CountdownStoryContent(
      {required this.isPaused, required this.onLoaded});
  @override
  State<_CountdownStoryContent> createState() => _CountdownStoryContentState();
}

class _CountdownStoryContentState extends State<_CountdownStoryContent> {
  late Timer _timer;
  int _secondsRemaining = 10;
  bool _loaded = false;
  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loaded) {
        _loaded = true;
        widget.onLoaded(Duration(seconds: _secondsRemaining));
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!widget.isPaused && _secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'COMING SOON',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 4),
              ),
              child: Center(
                child: Text(
                  '$_secondsRemaining',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'New Feature Launch',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isPaused ? 'PAUSED' : 'Get ready!',
              style: TextStyle(
                color: widget.isPaused ? Colors.amber : Colors.white54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedGradientContent extends StatefulWidget {
  final bool isPaused;
  const _AnimatedGradientContent({required this.isPaused});
  @override
  State<_AnimatedGradientContent> createState() =>
      _AnimatedGradientContentState();
}

class _AnimatedGradientContentState extends State<_AnimatedGradientContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _AnimatedGradientContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused) {
      _controller.stop();
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(const Color(0xFFEC4899), const Color(0xFF6366F1),
                    _controller.value)!,
                Color.lerp(const Color(0xFF6366F1), const Color(0xFF10B981),
                    _controller.value)!,
                Color.lerp(const Color(0xFF10B981), const Color(0xFFF59E0B),
                    _controller.value)!,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 64, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  'Animated Background',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isPaused
                      ? 'Animation Paused'
                      : 'Smooth gradient transitions',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProductShowcaseContent extends StatelessWidget {
  const _ProductShowcaseContent();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1F2937), Color(0xFF111827)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.headphones,
                    size: 100, color: Colors.purple),
              ),
              const SizedBox(height: 32),
              const Text(
                'Premium Headphones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Wireless • Noise Cancelling • 40h Battery',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '\$299',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 18,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '\$199',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'LIMITED TIME OFFER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FEATURE CARD WIDGET
// ═══════════════════════════════════════════════════════════════
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}
