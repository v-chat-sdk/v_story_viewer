import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';
import 'mock_data.dart';
import 'story_viewer_page.dart';
import 'integration_test.dart';
import 'horizontal_swipe_example.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V Story Viewer Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<VStoryGroup> storyGroups = MockStoryData.getMockStoryGroups();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('V Story Viewer Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Story circles preview
            _buildStoryCircles(),
            
            const Divider(),
            
            // Feature demos
            _buildFeatureDemos(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStoryCircles() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: storyGroups.length,
        itemBuilder: (context, index) {
          final group = storyGroups[index];
          final hasUnviewed = group.stories.any((s) => s.viewedAt == null);
          
          return GestureDetector(
            onTap: () => _openStoryViewer(context, index),
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  // Avatar with ring
                  Container(
                    width: 70,
                    height: 70,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: hasUnviewed
                          ? const LinearGradient(
                              colors: [Colors.purple, Colors.orange],
                            )
                          : null,
                      border: !hasUnviewed
                          ? Border.all(color: Colors.grey.shade300, width: 2)
                          : null,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          group.user.avatarUrl ?? 'https://i.pravatar.cc/150',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Username
                  Text(
                    group.user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildFeatureDemos() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feature Demonstrations',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildDemoCard(
            title: 'Horizontal Swipe Navigation',
            description: 'Swipe left/right between users\' stories',
            icon: Icons.swipe,
            isNew: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HorizontalSwipeExample(),
              ),
            ),
          ),
          
          _buildDemoCard(
            title: 'Text Story Viewer',
            description: 'Open stories with default settings',
            onTap: () => _openTextStoryViewer(context),
          ),
          // Basic story viewer
          _buildDemoCard(
            title: 'Basic Story Viewer',
            description: 'Open stories with default settings',
            onTap: () => _openBasicStoryViewer(context),
          ),
          
          // Custom themed viewer
          _buildDemoCard(
            title: 'Custom Themed Viewer',
            description: 'Story viewer with custom colors and styles',
            onTap: () => _openThemedStoryViewer(context),
          ),
          
          // With callbacks
          _buildDemoCard(
            title: 'With Callbacks',
            description: 'Demonstrates all callback events',
            onTap: () => _openCallbackStoryViewer(context),
          ),
          
          // With replies enabled
          _buildDemoCard(
            title: 'Reply System',
            description: 'Stories with reply functionality',
            onTap: () => _openReplyStoryViewer(context),
          ),
          
          // With reactions
          _buildDemoCard(
            title: 'Reaction System',
            description: 'Double tap to send reactions',
            onTap: () => _openReactionStoryViewer(context),
          ),
          
          // Performance test
          _buildDemoCard(
            title: 'Performance Test',
            description: 'Test with many stories for performance',
            onTap: () => _openPerformanceTest(context),
          ),
          
          // RTL support
          _buildDemoCard(
            title: 'RTL Support',
            description: 'Right-to-left language support',
            onTap: () => _openRTLStoryViewer(context),
          ),
          
          // Custom widgets
          _buildDemoCard(
            title: 'Custom Story Widgets',
            description: 'Display any Flutter widget as a story',
            onTap: () => _openCustomWidgetDemo(context),
          ),
          
          // Integration test
          _buildDemoCard(
            title: 'Integration Test',
            description: 'Run comprehensive integration tests',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IntegrationTest(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildDemoCard({
    required String title,
    required String description,
    required VoidCallback onTap,
    IconData? icon,
    bool isNew = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: icon != null 
          ? Icon(icon, color: Theme.of(context).colorScheme.primary)
          : null,
        title: Row(
          children: [
            Expanded(child: Text(title)),
            if (isNew)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
  
  void _openStoryViewer(BuildContext context, int startIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewerPage(
          storyList: VStoryList(groups: storyGroups),
          initialGroupIndex: startIndex,
        ),
      ),
    );
  }


  void _openTextStoryViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewerPage(
          storyList: VStoryList(groups: MockStoryData.getMockTextStoryGroups()),
          initialGroupIndex: 0,
        ),
      ),
    );
  }




  void _openBasicStoryViewer(BuildContext context) {
    _openStoryViewer(context, 0);
  }
  
  void _openThemedStoryViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThemedStoryViewerPage(
          storyList: VStoryList(groups: storyGroups),
        ),
      ),
    );
  }
  
  void _openCallbackStoryViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallbackStoryViewerPage(
          storyList: VStoryList(groups: storyGroups),
        ),
      ),
    );
  }
  
  void _openReplyStoryViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReplyStoryViewerPage(
          storyList: VStoryList(groups: storyGroups),
        ),
      ),
    );
  }
  
  void _openReactionStoryViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReactionStoryViewerPage(
          storyList: VStoryList(groups: storyGroups),
        ),
      ),
    );
  }
  
  void _openPerformanceTest(BuildContext context) {
    // Create large dataset for performance testing
    final largeStoryList = _createLargeStoryList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewerPage(
          storyList: largeStoryList,
          initialGroupIndex: 0,
        ),
      ),
    );
  }
  
  void _openRTLStoryViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: StoryViewerPage(
            storyList: VStoryList(groups: storyGroups),
            initialGroupIndex: 0,
          ),
        ),
      ),
    );
  }
  
  void _openCustomWidgetDemo(BuildContext context) {
    final customStoryGroup = VStoryGroup(
      user: VStoryUser.fromUrl(
        id: 'custom_demo',
        name: 'Custom Widgets',
        avatarUrl: 'https://i.pravatar.cc/150?img=10',
      ),
      stories: [
        VCustomStory(
          id: 'custom_1',
          duration: const Duration(seconds: 5),
          createdAt: DateTime.now(),
          builder: (context) => Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.blue, Colors.purple],
              ),
            ),
            child: const Center(
              child: FlutterLogo(size: 200),
            ),
          ),
        ),
        VCustomStory(
          id: 'custom_2',
          duration: const Duration(seconds: 6),
          createdAt: DateTime.now(),
          builder: (context) => Container(
            color: Colors.teal,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.widgets, size: 100, color: Colors.white),
                  const SizedBox(height: 20),
                  Text(
                    'Any Widget Works!',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewerPage(
          storyList: VStoryList(groups: [customStoryGroup]),
          initialGroupIndex: 0,
        ),
      ),
    );
  }
  
  VStoryList _createLargeStoryList() {
    final groups = <VStoryGroup>[];
    for (int i = 0; i < 20; i++) {
      final stories = <VBaseStory>[];
      for (int j = 0; j < 5; j++) {
        stories.add(
          VImageStory(
            id: 'perf_${i}_$j',
            media: VPlatformFile.fromUrl(
              networkUrl: 'https://picsum.photos/1080/1920?random=${i * 10 + j}',
            ),
            duration: const Duration(seconds: 5),
            createdAt: DateTime.now(),
          ),
        );
      }
      
      groups.add(
        VStoryGroup(
          user: VStoryUser.fromUrl(
            id: 'perf_user_$i',
            name: 'User $i',
            avatarUrl: 'https://i.pravatar.cc/150?img=${i + 20}',
          ),
          stories: stories,
        ),
      );
    }
    
    return VStoryList(groups: groups);
  }
}
