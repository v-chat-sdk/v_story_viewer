import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../v_story_viewer.dart';

/// Main story viewer widget providing full-screen immersive experience with horizontal swipe navigation.
class VStoryViewer extends StatefulWidget {
  /// The story list to display
  final VStoryList storyList;

  /// Viewer configuration
  final VStoryViewerConfig config;

  /// Initial story group index
  final int initialGroupIndex;

  /// Initial story ID within the initial group
  final String? initialStoryId;

  /// Called when page changes to a new user
  final void Function(int index, VStoryGroup group)? onPageChanged;

  /// Called when viewer is dismissed
  final VoidCallback? onDismiss;

  /// Called when a story is viewed
  final void Function(VBaseStory story)? onStoryViewed;

  /// Called when all stories complete for a user
  final void Function(VStoryGroup group)? onGroupCompleted;

  /// Custom header builder
  final Widget Function(BuildContext, VStoryUser, VBaseStory)? headerBuilder;

  /// Custom footer builder
  final Widget Function(BuildContext, VBaseStory)? footerBuilder;

  /// Error widget builder
  final Widget Function(BuildContext, Object?)? errorBuilder;

  /// Loading widget builder
  final Widget Function(BuildContext)? loadingBuilder;

  /// Whether to preload adjacent pages for smoother transitions
  final bool preloadPages;

  /// Creates a story viewer
  const VStoryViewer({
    super.key,
    required this.storyList,
    this.config = const VStoryViewerConfig(),
    this.initialGroupIndex = 0,
    this.initialStoryId,
    this.onPageChanged,
    this.onDismiss,
    this.onStoryViewed,
    this.onGroupCompleted,
    this.headerBuilder,
    this.footerBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.preloadPages = true,
  });

  @override
  State<VStoryViewer> createState() => _VStoryViewerState();
}

class _VStoryViewerState extends State<VStoryViewer> {
  /// Page controller for horizontal navigation
  late PageController _pageController;

  /// Current page index
  int _currentIndex = 0;

  /// Single story controller for all groups
  late VStoryController _controller;

  @override
  void initState() {
    super.initState();

    // Set system UI overlay style
    if (widget.config.systemUiOverlayStyle != null) {
      SystemChrome.setSystemUIOverlayStyle(widget.config.systemUiOverlayStyle!);
    }

    _currentIndex = widget.initialGroupIndex;
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 1.0,
      keepPage: false,
    );

    // Initialize the single controller with all groups
    _initializeController();
  }

  @override
  void dispose() {
    // Restore system UI
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    // Dispose the single controller
    _controller.dispose();

    // Dispose page controller
    _pageController.dispose();

    super.dispose();
  }

  /// Initializes the single controller with all groups
  void _initializeController() {
    _controller = VStoryController();

    // Set callbacks
    _controller.onStoryViewed = widget.onStoryViewed != null
        ? (story, userId) => widget.onStoryViewed!(story)
        : null;

    _controller.onAllStoriesCompleted = () {
      // Handle group completion for current group
      final currentGroup = widget.storyList.groups[_currentIndex];
      widget.onGroupCompleted?.call(currentGroup);

      // Auto-navigate to next group if available
      if (_currentIndex < widget.storyList.groups.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    };

    // Load the full story list
    _controller.loadStoryList(widget.storyList);

    // Navigate to specific story if provided
    if (widget.initialStoryId != null) {
      _controller.goToStory(widget.initialStoryId!);
    } else if (widget.initialGroupIndex > 0) {
      // Navigate to the first story of the initial group
      final initialGroup = widget.storyList.groups[widget.initialGroupIndex];
      if (initialGroup.stories.isNotEmpty) {
        _controller.goToStory(initialGroup.stories.first.id);
      }
    }
  }

  /// Handles page change events
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate to the first story of the new group
    final newGroup = widget.storyList.groups[index];
    if (newGroup.stories.isNotEmpty) {
      _controller.goToStory(newGroup.stories.first.id);
    }

    // Call the callback
    widget.onPageChanged?.call(index, newGroup);
  }

  /// Handles dismissal of the viewer
  void _handleDismiss() {
    // Pause the controller
    _controller.pause();

    // Call dismiss callback
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.config.backgroundColor,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.storyList.groups.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final group = widget.storyList.groups[index];

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final state = _controller.state;
              // Show loading if not ready
              if (!state.isReady || state.currentStory == null) {
                return _buildLoading(context);
              }
              // Get current story
              final story = state.currentStory!;

              // Get the actual group containing the current story
              // This ensures the header updates when navigating between groups
              final currentGroup =
                  widget.storyList.findGroupContainingStory(story.id) ?? group;

              // Build main content
              return VStoryContainer(
                story: story,
                controller: _controller,
                group: currentGroup,
                config: widget.config,
                headerBuilder: widget.headerBuilder,
                footerBuilder: widget.footerBuilder,
                errorBuilder: widget.errorBuilder,
                loadingBuilder: widget.loadingBuilder,
                onDismiss: _handleDismiss,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context);
    }

    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }
}
