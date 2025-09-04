import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';
import 'mock_data.dart';

/// Example demonstrating horizontal swipe navigation between users' stories
class HorizontalSwipeExample extends StatelessWidget {
  const HorizontalSwipeExample({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Create story list from mock data
    final storyGroups = MockStoryData.getMockStoryGroups();
    final storyList = VStoryList(
      groups: storyGroups,
      config: const VStoryListConfig(),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horizontal Swipe Navigation'),
        backgroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Horizontal Swipe Between Users',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Swipe left/right to navigate between different users\' stories.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // User avatars to show available story groups
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: storyList.groups.length,
                itemBuilder: (context, index) {
                  final group = storyList.groups[index];
                  return GestureDetector(
                    onTap: () => _openStoryViewer(context, index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: group.hasUnviewed 
                                    ? Colors.blue 
                                    : Colors.grey,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                group.user.avatarUrl ?? 'https://i.pravatar.cc/150',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            group.user.name,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to Use:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInstruction(
                      Icons.touch_app,
                      'Tap on any user avatar to open stories',
                    ),
                    _buildInstruction(
                      Icons.swipe,
                      'Swipe left/right to navigate between users',
                    ),
                    _buildInstruction(
                      Icons.touch_app,
                      'Tap left/right sides to navigate stories',
                    ),
                    _buildInstruction(
                      Icons.pause_circle,
                      'Long press to pause current story',
                    ),
                    _buildInstruction(
                      Icons.swipe_down,
                      'Swipe down to dismiss viewer',
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Full-width button to open story viewer
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _openStoryViewer(context, 0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Open Story Viewer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInstruction(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  
  void _openStoryViewer(BuildContext context, int initialIndex) {
    // Get the story list
    final storyGroups = MockStoryData.getMockStoryGroups();
    final storyList = VStoryList(
      groups: storyGroups,
      config: const VStoryListConfig(),
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HorizontalSwipeStoryViewer(
          storyList: storyList,
          initialGroupIndex: initialIndex,
        ),
      ),
    );
  }
}

/// Story viewer with horizontal swipe navigation
class HorizontalSwipeStoryViewer extends StatelessWidget {
  final VStoryList storyList;
  final int initialGroupIndex;
  
  const HorizontalSwipeStoryViewer({
    super.key,
    required this.storyList,
    this.initialGroupIndex = 0,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: VStoryPageViewer(
        storyList: storyList,
        initialGroupIndex: initialGroupIndex,
        preloadPages: true, // Preload adjacent pages for smooth transitions
        config: VStoryViewerConfig(
          showProgressBars: true,
          showHeader: true,
          showFooter: false,
          enableGestures: true,
          useSafeArea: true,
          backgroundColor: Colors.black,
          progressStyle: const VStoryProgressStyle(
            activeColor: Colors.white,
            inactiveColor: Color(0x4DFFFFFF),
            height: 3,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          gestureConfig: const VGestureConfig(
            tapEnabled: true,
            swipeEnabled: true,
            longPressEnabled: true,
            swipeVelocityThreshold: 300,
          ),
        ),
        onPageChanged: (index, group) {
          debugPrint('📱 Navigated to user: ${group.user.name} (Page $index)');
        },
        onStoryViewed: (story) {
          debugPrint('👁️ Story viewed: ${story.id}');
        },
        onGroupCompleted: (group) {
          debugPrint('✅ Completed all stories for: ${group.user.name}');
        },
        onDismiss: () {
          Navigator.pop(context);
        },
        headerBuilder: (context, user, story) {
          // Custom header with user info and close button
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // User avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      user.avatarUrl ?? 'https://i.pravatar.cc/150',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // User name and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        _getTimeAgo(story.createdAt),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Close button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Just now';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}