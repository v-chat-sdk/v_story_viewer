import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../v_story_viewer.dart';

/// Configuration for the story viewer.
class VStoryViewerConfig {
  /// Whether to show progress bars
  final bool showProgressBars;
  
  /// Whether to show header
  final bool showHeader;
  
  /// Whether to show footer
  final bool showFooter;
  
  /// Whether to enable gestures
  final bool enableGestures;
  
  /// Whether to use safe area
  final bool useSafeArea;
  
  /// Background color
  final Color backgroundColor;
  
  /// System UI overlay style
  final SystemUiOverlayStyle? systemUiOverlayStyle;
  
  /// Progress bar style
  final VStoryProgressStyle progressStyle;
  
  /// Text story style
  final VTextStoryStyle? textStoryStyle;
  
  /// Duration configuration
  final VDurationConfig durationConfig;
  
  /// Gesture configuration
  final VGestureConfig gestureConfig;
  
  /// Whether replies are enabled
  final bool enableReply;
  
  /// Whether reactions are enabled  
  final bool enableReactions;
  
  /// Reply configuration
  final VReplyConfiguration? replyConfig;
  
  /// Reaction configuration
  final VReactionConfiguration? reactionConfig;
  
  /// Overall theme configuration
  final VStoryTheme? theme;
  
  /// Creates a viewer configuration
  const VStoryViewerConfig({
    this.showProgressBars = true,
    this.showHeader = true,
    this.showFooter = false,
    this.enableGestures = true,
    this.useSafeArea = true,
    this.backgroundColor = Colors.black,
    this.systemUiOverlayStyle,
    this.progressStyle = const VStoryProgressStyle(
      activeColor: Colors.white,
      inactiveColor: Color(0x4DFFFFFF),
    ),
    this.textStoryStyle,
    this.durationConfig = const VDurationConfig(),
    this.gestureConfig = const VGestureConfig(),
    this.enableReply = false,
    this.enableReactions = false,
    this.replyConfig,
    this.reactionConfig,
    this.theme,
  });
  
  /// Creates a default configuration
  factory VStoryViewerConfig.defaultConfig() => const VStoryViewerConfig();
  
  /// Creates a minimal configuration
  factory VStoryViewerConfig.minimal() => const VStoryViewerConfig(
    showHeader: false,
    showFooter: false,
    showProgressBars: true,
  );
  
  /// Creates an immersive configuration
  factory VStoryViewerConfig.immersive() => VStoryViewerConfig(
    useSafeArea: false,
    systemUiOverlayStyle: SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  
  /// Creates a configuration with reply system enabled
  factory VStoryViewerConfig.withReply({
    required VReplyConfiguration replyConfig,
    VStoryTheme? theme,
    bool enableReactions = false,
    VReactionConfiguration? reactionConfig,
  }) => VStoryViewerConfig(
    showFooter: true,  // Required for reply system
    enableReply: true,
    enableReactions: enableReactions,
    replyConfig: replyConfig,
    reactionConfig: reactionConfig,
    theme: theme,
  );
}

/// Main story viewer widget providing full-screen immersive experience.
class VStoryViewer extends StatefulWidget {
  /// The story list to display
  final VStoryList storyList;
  
  /// The story controller
  final VStoryController? controller;
  
  /// Viewer configuration
  final VStoryViewerConfig config;
  
  /// Initial story group index
  final int initialGroupIndex;
  
  /// Initial story ID (overrides group index)
  final String? initialStoryId;
  
  /// Called when viewer is dismissed
  final VoidCallback? onDismiss;
  
  /// Called when a story is viewed
  final void Function(VBaseStory story)? onStoryViewed;
  
  /// Called when all stories complete
  final VoidCallback? onAllStoriesCompleted;
  
  /// Custom header builder
  final Widget Function(BuildContext, VStoryUser, VBaseStory)? headerBuilder;
  
  /// Custom footer builder
  final Widget Function(BuildContext, VBaseStory)? footerBuilder;
  
  /// Error widget builder
  final Widget Function(BuildContext, Object?)? errorBuilder;
  
  /// Loading widget builder
  final Widget Function(BuildContext)? loadingBuilder;
  
  /// Creates a story viewer
  const VStoryViewer({
    super.key,
    required this.storyList,
    this.controller,
    this.config = const VStoryViewerConfig(),
    this.initialGroupIndex = 0,
    this.initialStoryId,
    this.onDismiss,
    this.onStoryViewed,
    this.onAllStoriesCompleted,
    this.headerBuilder,
    this.footerBuilder,
    this.errorBuilder,
    this.loadingBuilder,
  });
  
  @override
  State<VStoryViewer> createState() => _VStoryViewerState();
}

class _VStoryViewerState extends State<VStoryViewer> {
  /// Story controller
  late VStoryController _controller;
  
  /// Memory manager for video handling
  final VMemoryManager _memoryManager = VMemoryManager();
  
  
  /// Whether we created the controller internally
  bool _internalController = false;
  
  @override
  void initState() {
    super.initState();
    
    // Set system UI overlay style
    if (widget.config.systemUiOverlayStyle != null) {
      SystemChrome.setSystemUIOverlayStyle(widget.config.systemUiOverlayStyle!);
    }
    
    // Create or use provided controller
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = VStoryController();
      _internalController = true;
    }
    
    // Duration calculation is handled by the controller
    
    // Set callbacks
    _controller.onStoryViewed = widget.onStoryViewed != null 
        ? (story, userId) => widget.onStoryViewed!(story)
        : null;
    _controller.onAllStoriesCompleted = widget.onAllStoriesCompleted;
    
    // Initialize controller with story list
    _initializeController();
  }
  
  @override
  void dispose() {
    // Restore system UI
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    
    // Dispose controller if we created it
    if (_internalController) {
      _controller.dispose();
    }
    
    // Clean up memory manager
    _memoryManager.dispose();
    
    super.dispose();
  }
  
  void _initializeController() {
    // Load story list
    _controller.loadStoryList(widget.storyList);
    
    // Navigate to initial story
    if (widget.initialStoryId != null) {
      _controller.goToStory(widget.initialStoryId!);
    } else if (widget.initialGroupIndex < widget.storyList.groups.length) {
      final group = widget.storyList.groups[widget.initialGroupIndex];
      final firstStory = group.firstUnviewed ?? group.stories.first;
      _controller.goToStory(firstStory.id);
    }
    
    // Start playback
    _controller.play();
  }
  
  void _handleDismiss() {
    // Stop playback
    _controller.stop();
    
    // Call dismiss callback
    widget.onDismiss?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.config.backgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final state = _controller.state;
          
          // Show loading if not ready
          if (!state.isReady || state.currentStory == null) {
            return _buildLoading(context);
          }
          
          // Get current story and group
          final story = state.currentStory!;
          final group = state.storyList!.findGroupContainingStory(story.id);
          
          if (group == null) {
            return _buildError(context, 'Story group not found');
          }
          
          // Build main content
          Widget content = VStoryContainer(
            story: story,
            controller: _controller,
            group: group,
            config: widget.config,
            headerBuilder: widget.headerBuilder,
            footerBuilder: widget.footerBuilder,
            errorBuilder: widget.errorBuilder,
            loadingBuilder: widget.loadingBuilder,
            onDismiss: _handleDismiss,
          );
          
          // Apply safe area if configured
          if (widget.config.useSafeArea) {
            content = SafeArea(child: content);
          }
          
          return content;
        },
      ),
    );
  }
  
  Widget _buildLoading(BuildContext context) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context);
    }
    
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  }
  
  Widget _buildError(BuildContext context, Object? error) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, error);
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: ${error.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Page-based story viewer for swipe navigation between user groups.
/// 
/// This widget provides Instagram/WhatsApp-style horizontal swipe navigation
/// between different users' stories. Each page contains one user's stories,
/// and users can swipe left/right to navigate between different users.
class VStoryPageViewer extends StatefulWidget {
  /// The story list to display
  final VStoryList storyList;
  
  /// Viewer configuration
  final VStoryViewerConfig config;
  
  /// Initial group index
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
  
  /// Creates a page-based story viewer
  const VStoryPageViewer({
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
  State<VStoryPageViewer> createState() => _VStoryPageViewerState();
}

class _VStoryPageViewerState extends State<VStoryPageViewer> {
  /// Page controller for horizontal navigation
  late PageController _pageController;
  
  /// Current page index
  int _currentIndex = 0;
  
  /// Story controllers for each page (user group)
  final Map<int, VStoryController> _controllers = {};
  
  /// Track which pages have been initialized
  final Set<int> _initializedPages = {};
  
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
    );
    
    // Initialize the current page controller
    _initializeController(_currentIndex);
    
    // Preload adjacent pages if enabled
    if (widget.preloadPages) {
      _preloadAdjacentPages(_currentIndex);
    }
  }
  
  @override
  void dispose() {
    // Restore system UI
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    
    // Dispose all controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    
    // Dispose page controller
    _pageController.dispose();
    
    super.dispose();
  }
  
  /// Initializes a controller for the given page index
  void _initializeController(int index) {
    if (_initializedPages.contains(index) || index >= widget.storyList.groups.length) {
      return;
    }
    
    final controller = VStoryController();
    final group = widget.storyList.groups[index];
    
    // Set callbacks
    controller.onStoryViewed = widget.onStoryViewed != null 
        ? (story, userId) => widget.onStoryViewed!(story)
        : null;
    
    controller.onAllStoriesCompleted = () {
      // Handle group completion
      widget.onGroupCompleted?.call(group);
      
      // Auto-navigate to next group if available
      if (index < widget.storyList.groups.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    };
    
    // Initialize with single group
    final singleGroupList = VStoryList(
      groups: [group],
      config: widget.storyList.config,
    );
    
    controller.loadStoryList(singleGroupList);
    
    // Navigate to specific story if provided and this is the initial group
    if (index == widget.initialGroupIndex && widget.initialStoryId != null) {
      controller.goToStory(widget.initialStoryId!);
    }
    
    _controllers[index] = controller;
    _initializedPages.add(index);
  }
  
  /// Preloads adjacent pages for smoother transitions
  void _preloadAdjacentPages(int currentIndex) {
    // Preload previous page
    if (currentIndex > 0) {
      _initializeController(currentIndex - 1);
    }
    
    // Preload next page
    if (currentIndex < widget.storyList.groups.length - 1) {
      _initializeController(currentIndex + 1);
    }
  }
  
  /// Handles page change events
  void _onPageChanged(int index) {
    // Pause the previous page's controller
    if (_controllers.containsKey(_currentIndex)) {
      _controllers[_currentIndex]!.pause();
    }
    
    setState(() {
      _currentIndex = index;
    });
    
    // Initialize the new page if needed
    if (!_initializedPages.contains(index)) {
      _initializeController(index);
    }
    
    // Resume the new page's controller
    if (_controllers.containsKey(index)) {
      _controllers[index]!.play();
    }
    
    // Preload adjacent pages
    if (widget.preloadPages) {
      _preloadAdjacentPages(index);
    }
    
    // Call the callback
    widget.onPageChanged?.call(index, widget.storyList.groups[index]);
    
    // Clean up distant pages to manage memory
    _cleanupDistantPages(index);
  }
  
  /// Cleans up controllers for pages that are far from the current page
  void _cleanupDistantPages(int currentIndex) {
    const int keepDistance = 2; // Keep controllers within 2 pages
    
    final keysToRemove = <int>[];
    for (final key in _controllers.keys) {
      if ((key - currentIndex).abs() > keepDistance) {
        keysToRemove.add(key);
      }
    }
    
    for (final key in keysToRemove) {
      _controllers[key]?.dispose();
      _controllers.remove(key);
      _initializedPages.remove(key);
    }
  }
  
  /// Handles dismissal of the viewer
  void _handleDismiss() {
    // Pause all controllers
    for (final controller in _controllers.values) {
      controller.pause();
    }
    
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
          
          // Get or create controller for this page
          if (!_controllers.containsKey(index)) {
            _initializeController(index);
          }
          
          final controller = _controllers[index];
          
          // Return an empty container if controller is not ready
          if (controller == null) {
            return Container(color: widget.config.backgroundColor);
          }
          
          return VStoryViewer(
            storyList: VStoryList(
              groups: [group],
              config: widget.storyList.config,
            ),
            controller: controller,
            config: widget.config,
            onDismiss: _handleDismiss,
            onStoryViewed: widget.onStoryViewed,
            headerBuilder: widget.headerBuilder,
            footerBuilder: widget.footerBuilder,
            errorBuilder: widget.errorBuilder,
            loadingBuilder: widget.loadingBuilder,
          );
        },
      ),
    );
  }
}