import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

import 'data/advanced_stories.dart';
import 'data/basic_stories.dart';
import 'data/custom_stories.dart';
import 'data/music_stories.dart';
import 'tabs/advanced_tab.dart';
import 'tabs/basic_tab.dart';
import 'tabs/custom_tab.dart';
import 'tabs/music_tab.dart';
import 'tabs/vertical_tab.dart';
import 'viewers/advanced_viewer.dart';
import 'viewers/basic_viewer.dart';
import 'viewers/custom_header_viewer.dart';
import 'viewers/custom_viewer.dart';
import 'viewers/minimal_viewer.dart';
import 'viewers/music_viewer.dart';
import 'viewers/vertical_viewer.dart';

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
  late List<VStoryGroup> _musicStories;
  final Set<String> _seenStoryIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _basicStories = createBasicStories();
    _advancedStories = createAdvancedStories();
    _customStories = createCustomStories();
    _musicStories = createMusicStories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onBasicUserTap(VStoryGroup group, int index) {
    openBasicViewer(
      context,
      _basicStories,
      index,
      (id) => setState(() => _seenStoryIds.add(id)),
    );
  }

  void _onAdvancedUserTap(VStoryGroup group, int index) {
    openAdvancedViewer(context, _advancedStories, index);
  }

  void _onVerticalUserTap(VStoryGroup group, int index) {
    openVerticalViewer(
      context,
      _basicStories,
      index,
      (id) => setState(() => _seenStoryIds.add(id)),
    );
  }

  void _onCustomUserTap(VStoryGroup group, int index) {
    openCustomViewer(context, _customStories, index);
  }

  void _onMusicUserTap(VStoryGroup group, int index) {
    openMusicViewer(context, _musicStories, index);
  }

  void _openMusicTimingDemo() {
    openMusicViewer(context, _musicStories, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('V Story Viewer Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Basic', icon: Icon(Icons.auto_stories)),
            Tab(text: 'Advanced', icon: Icon(Icons.auto_awesome)),
            Tab(text: 'Vertical', icon: Icon(Icons.swap_vert)),
            Tab(text: 'Custom', icon: Icon(Icons.widgets)),
            Tab(text: 'Music', icon: Icon(Icons.music_note)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BasicTab(
            stories: _basicStories,
            onUserTap: _onBasicUserTap,
          ),
          AdvancedTab(
            stories: _advancedStories,
            onUserTap: _onAdvancedUserTap,
            onMinimalViewer: () => openMinimalViewer(context, _basicStories),
            onCustomHeaderViewer: () =>
                openCustomHeaderViewer(context, _basicStories),
          ),
          VerticalTab(
            stories: _basicStories,
            onUserTap: _onVerticalUserTap,
          ),
          CustomTab(
            stories: _customStories,
            onUserTap: _onCustomUserTap,
          ),
          MusicTab(
            stories: _musicStories,
            onUserTap: _onMusicUserTap,
            onStartDemo: _openMusicTimingDemo,
          ),
        ],
      ),
    );
  }
}
