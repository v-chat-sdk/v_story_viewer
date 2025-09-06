import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';
import 'debug_mock_data.dart';

/// Debug story viewer with comprehensive testing controls
class DebugStoryViewer extends StatefulWidget {
  const DebugStoryViewer({super.key});

  @override
  State<DebugStoryViewer> createState() => _DebugStoryViewerState();
}

class _DebugStoryViewerState extends State<DebugStoryViewer> {
  // Story controller reference
  VStoryController? _controller;
  
  // Debug state
  String _currentUserId = '';
  String _currentStoryId = '';
  String _currentStoryType = '';
  final double _currentProgress = 0.0;
  final String _playbackState = 'Initial';
  int _viewedCount = 0;
  String _lastError = 'None';
  
  // Test scenario selection
  TestScenario _selectedScenario = TestScenario.standard;
  
  // Story groups based on scenario
  List<VStoryGroup> _storyGroups = [];
  
  // Story list for viewer
  VStoryList? _storyList;
  
  @override
  void initState() {
    super.initState();
    _loadScenario(TestScenario.standard);
  }
  
  void _loadScenario(TestScenario scenario) {
    setState(() {
      _selectedScenario = scenario;
      switch (scenario) {
        case TestScenario.standard:
          _storyGroups = DebugMockData.createDebugStoryGroups(
            userCount: 5,
            storiesPerUser: 6,
          );
          break;
        case TestScenario.textOnly:
          _storyGroups = DebugMockData.createTextOnlyGroups(
            userCount: 3,
            storiesPerUser: 2,
          );
          break;
        case TestScenario.errorTest:
          _storyGroups = DebugMockData.createErrorTestGroups();
          break;
        case TestScenario.performance:
          _storyGroups = DebugMockData.createPerformanceTestGroups();
          break;
        case TestScenario.edgeCases:
          _storyGroups = DebugMockData.createEdgeCaseGroups();
          break;
      }
      
      // Create VStoryList from groups
      _storyList = VStoryList(
        groups: _storyGroups,
      );
    });
  }
  
  void _showStoryViewer(int startIndex) {
    if (_storyList == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SafeArea(
          child: VStoryViewer(
            storyList: _storyList!,
            initialGroupIndex: startIndex,
            onDismiss: () {
              Navigator.pop(context);
              _showDebugDialog('Story viewer dismissed');
            },
            onPageChanged: (index, group) {
              setState(() {
                _currentUserId = group.user.id;
                _viewedCount++;
              });
              debugPrint('👥 Page Changed: User=${group.user.name}, Index=$index');
            },
            onStoryViewed: (story) {
              setState(() {
                _currentStoryId = story.id;
                _currentStoryType = story.runtimeType.toString();
              });
              debugPrint('✅ Story Viewed: ${story.id}');
            },
            onGroupCompleted: (group) {
              debugPrint('🎉 Group Completed: ${group.user.name}');
            },
            errorBuilder: (context, error) {
              setState(() {
                _lastError = error.toString();
              });
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  void _showDebugDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Info'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Story Viewer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Debug Control Bar
          _buildDebugControlBar(),
          
          // Debug Status Display
          _buildDebugStatusDisplay(),
          
          // Story Groups List
          Expanded(
            child: _buildStoryGroupsList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDebugControlBar() {
    return Container(
      color: Colors.grey.shade900,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🧪 Test Scenarios',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TestScenario.values.map((scenario) {
              return ChoiceChip(
                label: Text(_getScenarioLabel(scenario)),
                selected: _selectedScenario == scenario,
                onSelected: (selected) {
                  if (selected) {
                    _loadScenario(scenario);
                  }
                },
                selectedColor: Colors.blue,
                backgroundColor: Colors.grey.shade700,
                labelStyle: TextStyle(
                  color: _selectedScenario == scenario ? Colors.white : Colors.white70,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _loadScenario(_selectedScenario),
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _controller != null ? () {
                  _controller!.pause();
                  _showDebugDialog('Story paused programmatically');
                } : null,
                icon: const Icon(Icons.pause),
                label: const Text('Pause'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _controller != null ? () {
                  _controller!.play();
                  _showDebugDialog('Story resumed programmatically');
                } : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDebugStatusDisplay() {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatusItem('Current User', _currentUserId.isEmpty ? 'None' : _currentUserId),
              ),
              Expanded(
                child: _buildStatusItem('Current Story', _currentStoryId.isEmpty ? 'None' : _currentStoryId),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatusItem('Story Type', _currentStoryType.isEmpty ? 'None' : _currentStoryType),
              ),
              Expanded(
                child: _buildStatusItem('State', _playbackState),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatusItem('Progress', '${(_currentProgress * 100).toStringAsFixed(1)}%'),
              ),
              Expanded(
                child: _buildStatusItem('Viewed', '$_viewedCount stories'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatusItem('Last Error', _lastError),
        ],
      ),
    );
  }
  
  Widget _buildStatusItem(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStoryGroupsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _storyGroups.length,
      itemBuilder: (context, index) {
        final group = _storyGroups[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(group.user.avatarUrl ?? ''),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            title: Text(
              group.user.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${group.user.id}'),
                Text('Stories: ${group.stories.length}'),
                Text('Status: ${group.hasUnviewed ? "Has Unviewed" : "All Viewed"}'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: group.stories.take(5).map((story) {
                    return Chip(
                      label: Text(
                        story.id.split('_').last,
                        style: const TextStyle(fontSize: 10),
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      backgroundColor: _getStoryTypeColor(story),
                    );
                  }).toList(),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.play_circle_filled),
              iconSize: 40,
              color: Theme.of(context).primaryColor,
              onPressed: () => _showStoryViewer(index),
            ),
            onTap: () => _showStoryViewer(index),
          ),
        );
      },
    );
  }
  
  Color _getStoryTypeColor(VBaseStory story) {
    if (story is VImageStory) return Colors.blue.shade200;
    if (story is VVideoStory) return Colors.green.shade200;
    if (story is VTextStory) return Colors.orange.shade200;
    if (story is VCustomStory) return Colors.purple.shade200;
    return Colors.grey.shade200;
  }
  
  String _getScenarioLabel(TestScenario scenario) {
    switch (scenario) {
      case TestScenario.standard:
        return '📱 Standard';
      case TestScenario.textOnly:
        return '📝 Text Only';
      case TestScenario.errorTest:
        return '❌ Errors';
      case TestScenario.performance:
        return '⚡ Performance';
      case TestScenario.edgeCases:
        return '🔧 Edge Cases';
    }
  }
}

enum TestScenario {
  standard,
  textOnly,
  errorTest,
  performance,
  edgeCases,
}