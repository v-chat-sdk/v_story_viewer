import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../v_story_viewer.dart';
import '../../../core/models/v_story_events.dart';
import '../../v_theme_system/models/v_responsive_utils.dart';
import '../utils/v_carousel_manager.dart';
import '../utils/v_controller_initializer.dart';
import '../utils/v_story_event_manager.dart';
import '../utils/v_story_gesture_handler.dart';
import 'builders/v_story_content_builder.dart';
import 'cube_page_view.dart' show CubePageView;

/// Main orchestrator widget for story viewing (Refactored)
///
/// Coordinates all feature controllers using callback-based mediator pattern.
/// Responsibilities are delegated to specialized managers.
class VStoryViewer extends StatefulWidget {
  const VStoryViewer({
    required this.storyGroups,
    this.initialGroupIndex = 0,
    this.initialStoryIndex = 0,
    this.config,
    this.callbacks,
    this.cacheController,
    super.key,
  }) : assert(storyGroups.length > 0, 'Story groups cannot be empty');

  final List<VStoryGroup> storyGroups;
  final int initialGroupIndex;
  final int initialStoryIndex;
  final VStoryViewerConfig? config;
  final VStoryViewerCallbacks? callbacks;
  final VCacheController? cacheController;

  @override
  State<VStoryViewer> createState() => _VStoryViewerState();
}

class _VStoryViewerState extends State<VStoryViewer> {
  late VStoryNavigationController _navigationController;
  VProgressController? _progressController;
  VBaseMediaController? _mediaController;
  late VCacheController _cacheController;
  late VReactionController _reactionController;
  late VStoryViewerConfig _config;
  late VCubePageManager _cubePageManager;
  late VStoryGestureHandler _gestureHandler;
  final _keyboardFocusNode = FocusNode();
  final _replyTextFieldFocusNode = FocusNode();

  VStoryState _state = VStoryState.initial();
  StreamSubscription<VDownloadProgress>? _progressSubscription;
  StreamSubscription<VStoryEvent>? _eventSubscription;
  double _mediaLoadingProgress = 0;

  bool get _isCubePageMode =>
      _config.enableCarousel && widget.storyGroups.length > 1;

  /// Calculate responsive maxContentWidth based on screen size
  /// Mobile: full width minus padding
  /// Tablet: 600px (default)
  /// Desktop: 700px
  double _getResponsiveMaxContentWidth(BuildContext context) {
    return VResponsiveUtils.getMaxContentWidth(context);
  }

  @override
  void initState() {
    super.initState();
    _initializeConfiguration();
    _initializeManagers();
    _initializeControllers();
    _setupProgressListener();
    _setupEventListener();
    _loadCurrentStory();
  }

  void _initializeConfiguration() {
    _config = widget.config ?? VStoryViewerConfig.defaultConfig;
    _cacheController = widget.cacheController ?? VCacheController();
  }

  void _initializeManagers() {
    _cubePageManager = VCubePageManager(
      config: _config,
      onScrollStateChanged: _handleCarouselScrollStateChanged,
    );

    if (_isCubePageMode) {
      _cubePageManager.initializePageController(widget.initialGroupIndex);
    }
  }

  void _initializeControllers() {
    final currentGroup = widget.storyGroups[widget.initialGroupIndex];

    _navigationController = VControllerInitializer.createNavigationController(
      storyGroups: widget.storyGroups,
      initialGroupIndex: widget.initialGroupIndex,
      initialStoryIndex: widget.initialStoryIndex,
    );

    _progressController = VControllerInitializer.createProgressController(
      barCount: currentGroup.stories.length,
      currentBar: widget.initialStoryIndex,
      callbacks: VProgressCallbacks(onBarComplete: _handleProgressComplete),
    );
    _reactionController = VControllerInitializer.createReactionController();
    _initializeGestureHandler();
  }

  void _initMediaController(VBaseStory story) {
    _mediaController = VControllerInitializer.createMediaController(
      story: story,
      cacheController: _cacheController,
    );
  }

  void _initializeGestureHandler() {
    _gestureHandler = VStoryGestureHandler(
      config: _config,
      reactionController: _reactionController,
      onTapPrevious: _handleTapPrevious,
      onTapNext: _handleTapNext,
      onPauseStory: _handlePause,
      onResumeStory: _handleResume,
      callbacks: widget.callbacks,
    );
  }

  void _setupProgressListener() {
    _progressSubscription = _cacheController.mediaDownloadProgressStream.listen(
      (progress) {
        if (!mounted) return;
        final currentStory = _navigationController.currentStory;
        if (progress.storyId == currentStory.id) {
          if (mounted) {
            setState(() {
              _mediaLoadingProgress = progress.progress;
            });
          }
        }
      },
    );
  }

  void _setupEventListener() {
    _eventSubscription = VStoryEventManager.instance.on<VStoryEvent>((event) {
      if (!mounted) return;

      switch (event) {
        case VMediaReadyEvent():
          _handleMediaReady();
        case VMediaErrorEvent():
          widget.callbacks?.onError?.call(event.error);
        case VDurationKnownEvent():
          _progressController?.updateDuration(event.duration);
        case VReactionSentEvent():
          debugPrint(
            'Reaction: ${event.reactionType} for story ${event.story.id}',
          );
        case VReplyFocusChangedEvent():
          if (event.hasFocus) {
            _handlePause();
          } else {
            _handleResume();
          }
        case VStoryPauseStateChangedEvent():
          // Handled by media controller itself
          break;
        default:
          break;
      }
    });
  }

  void _updateState(VStoryState newState) {
    if (!mounted) return;
    setState(() {
      _state = newState;
    });
  }

  Future<void> _loadCurrentStory() async {
    final currentStory = _navigationController.currentStory;
    final currentStoryIndex = _navigationController.currentStoryIndex;
    final currentGroup = _navigationController.currentGroup;
    final currentGroupIndex = _navigationController.currentGroupIndex;
    if (!mounted) return;
    setState(() {
      _mediaLoadingProgress = 0;
    });
    final oldController = _mediaController;
    _mediaController = null;
    oldController?.dispose();
    if (!mounted) return;
    _initMediaController(currentStory);
    _progressController!.setCursorAt(currentStoryIndex);
    _reactionController.setCurrentStory(currentStory);
    _updateState(
      _state.copyWith(
        playbackState: VStoryPlaybackState.loading,
        currentGroup: currentGroup,
        currentStory: currentStory,
        currentGroupIndex: currentGroupIndex,
        currentStoryIndex: currentStoryIndex,
      ),
    );
    if (!mounted || _mediaController == null) return;
    try {
      await _mediaController!.loadStory(currentStory);
    } catch (e) {
      // Ignore errors from disposed controller or other race conditions
      if (!mounted) return;
      rethrow;
    }
    if (!mounted || _mediaController == null) return;
    widget.callbacks?.onStoryChanged?.call(
      currentGroup,
      currentStory,
      currentStoryIndex,
    );
  }

  void _handleProgressComplete(int barIndex) {
    _handleTapNext();
  }

  void _handleMediaReady() {
    final currentStory = _navigationController.currentStory;
    final currentStoryIndex = _navigationController.currentStoryIndex;

    // Update state to playing
    _updateState(_state.copyWith(playbackState: VStoryPlaybackState.playing));

    // Start progress animation
    _progressController!.startProgress(
      currentStoryIndex,
      currentStory.duration ?? const Duration(seconds: 5),
    );
  }

  void _handleCarouselScrollStateChanged(bool isScrolling) {
    if (isScrolling) {
      _handlePause();
    } else {
      _handleResume();
    }
  }

  void _handleTapPrevious() {
    if (_navigationController.hasPreviousStory) {
      _navigationController.previousStory();
      _loadCurrentStory();
    } else if (_navigationController.hasPreviousGroup) {
      _handlePreviousGroup();
    }
  }

  void _handlePreviousGroup() {
    if (_isCubePageMode) {
      _cubePageManager.previousPage();
    } else {
      _navigationController.previousGroup();
      _reinitializeProgressController();
      _loadCurrentStory();
      widget.callbacks?.onGroupChanged?.call(
        _navigationController.currentGroup,
        _navigationController.currentGroupIndex,
      );
    }
  }

  void _handleTapNext() {
    if (_navigationController.hasNextStory) {
      _navigationController.nextStory();
      _loadCurrentStory();
    } else if (_navigationController.hasNextGroup &&
        _config.autoMoveToNextGroup) {
      _handleNextGroup();
    } else if (_config.restartGroupWhenAllViewed) {
      _navigationController.restartGroup();
      _loadCurrentStory();
    } else {
      _completeViewing();
    }
  }

  void _handleNextGroup() {
    if (_isCubePageMode) {
      _cubePageManager.nextPage();
    } else {
      _navigationController.nextGroup();
      _reinitializeProgressController();
      _loadCurrentStory();
      widget.callbacks?.onGroupChanged?.call(
        _navigationController.currentGroup,
        _navigationController.currentGroupIndex,
      );
    }
  }

  void _completeViewing() {
    widget.callbacks?.onComplete?.call();
    Navigator.of(context).pop();
  }

  void _handlePlayPausePressed() {
    if (_state.isPlaying) {
      _handlePause();
    } else if (_state.isPaused) {
      _handleResume();
    }
  }

  Future<void> _handleMutePressed() async {
    final controller = _mediaController;
    if (controller is VVideoController) {
      await controller.toggleMute();
    }
  }

  void _handlePause() {
    if (!_state.isPaused && _state.isPlaying) {
      _progressController?.pauseProgress();
      _mediaController?.pause();
      _updateState(_state.copyWith(playbackState: VStoryPlaybackState.paused));
    }
  }

  void _handleResume() {
    if (_state.isPaused) {
      _progressController?.resumeProgress();
      _mediaController?.resume();
      _updateState(_state.copyWith(playbackState: VStoryPlaybackState.playing));
    }
  }

  void _reinitializeProgressController() {
    _progressController!
      ..pauseProgress()
      ..dispose();

    _progressController = VControllerInitializer.createProgressController(
      barCount: _navigationController.currentGroup.stories.length,
      currentBar: widget.initialStoryIndex,
      callbacks: VProgressCallbacks(onBarComplete: _handleProgressComplete),
    );
  }

  void _handleCarouselPageChanged(int index) {
    _navigationController.jumpTo(
      groupIndex: index,
      storyIndex: 0,
    );
    _reinitializeProgressController();
    _loadCurrentStory();

    widget.callbacks?.onGroupChanged?.call(
      _navigationController.currentGroup,
      _navigationController.currentGroupIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final storyContent = _buildStoryContent();
    final isWebPlatform = kIsWeb;

    Widget body;
    if (_isCubePageMode) {
      body = CubePageView(
        controller: _cubePageManager.pageController!,
        itemCount: widget.storyGroups.length,
        onPageChanged: _handleCarouselPageChanged,
        itemBuilder: (context, index) {
          if (index == _navigationController.currentGroupIndex) {
            return storyContent;
          }
          return const ColoredBox(color: Colors.black);
        },
      );
    } else {
      body = storyContent;
    }

    // Check if we should show navigation arrows
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopWide = screenWidth >= 1000;
    final hasMultipleGroups = widget.storyGroups.length > 1;
    final hasMultipleStories =
        _navigationController.currentGroup.stories.length > 1;
    // Show arrows if there are multiple stories in current group OR multiple groups
    final shouldShowArrows =
        isWebPlatform && isDesktopWide && (hasMultipleStories || hasMultipleGroups);

    // Add navigation arrows overlay for web/desktop
    if (shouldShowArrows) {
      body = Stack(
        children: [
          body,
          _buildNavigationArrowsOverlay(),
        ],
      );
    }

    final scaffoldBackgroundColor = _getScaffoldBackgroundColor();
    if (isWebPlatform) {
      return Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        body: KeyboardListener(
          focusNode: _keyboardFocusNode,
          autofocus: true,
          onKeyEvent: (KeyEvent event) {
            if (_isTextFieldFocused()) return;
            if (event is KeyDownEvent) {
              // Space: Pause/Resume
              if (event.logicalKey == LogicalKeyboardKey.space) {
                _handlePlayPausePressed();
                return;
              }
              // Arrow Right / D: Next story
              if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                  event.logicalKey == LogicalKeyboardKey.keyD) {
                _handleTapNext();
                return;
              }
              // Arrow Left / A: Previous story
              if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                  event.logicalKey == LogicalKeyboardKey.keyA) {
                _handleTapPrevious();
                return;
              }
              // Escape: Exit viewer
              if (event.logicalKey == LogicalKeyboardKey.escape) {
                _completeViewing();
                return;
              }
              // R: Focus reply input
              if (event.logicalKey == LogicalKeyboardKey.keyR) {
                _replyTextFieldFocusNode.requestFocus();
                return;
              }
              // M: Mute/Unmute (for videos)
              if (event.logicalKey == LogicalKeyboardKey.keyM) {
                _handleMutePressed();
                return;
              }
            }
          },

          child: body,
        ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: body,
    );
  }

  Widget _buildNavigationArrowsOverlay() {
    return Stack(
      children: [
        // Left arrow - Navigate to previous story or group
        Positioned(
          left: 24,
          top: 0,
          bottom: 0,
          child: Center(
            child: _buildNavigationButton(
              icon: Icons.arrow_back_ios_new,
              onPressed: (_navigationController.hasPreviousStory ||
                      _navigationController.hasPreviousGroup)
                  ? _handleTapPrevious
                  : null,
            ),
          ),
        ),
        // Right arrow - Navigate to next story or next group
        Positioned(
          right: 24,
          top: 0,
          bottom: 0,
          child: Center(
            child: _buildNavigationButton(
              icon: Icons.arrow_forward_ios,
              onPressed: (_navigationController.hasNextStory ||
                      (_navigationController.hasNextGroup && _config.autoMoveToNextGroup))
                  ? _handleTapNext
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return MouseRegion(
      cursor: onPressed != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.4),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: onPressed != null
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildStoryContent() {
    // Use responsive maxContentWidth based on screen size
    final responsiveMaxWidth = _getResponsiveMaxContentWidth(context);

    return VStoryContentBuilder.build(
      gestureCallbacks: VGestureCallbacks(
        onTapPrevious: _gestureHandler.handleTapPrevious,
        onTapNext: _gestureHandler.handleTapNext,
        onLongPressStart: _gestureHandler.handleLongPressStart,
        onLongPressEnd: _gestureHandler.handleLongPressEnd,
        onSwipeDown: () => _gestureHandler.handleSwipeDown(context),
        onDoubleTap: _gestureHandler.handleDoubleTap,
      ),
      mediaController: _mediaController!,
      currentStory: _navigationController.currentStory,
      isLoading: _state.isLoading,
      mediaLoadingProgress: _mediaLoadingProgress,
      progressController: _progressController!,
      currentGroup: _navigationController.currentGroup,
      reactionController: _reactionController,
      context: context,
      callbacks: widget.callbacks,
      replyTextFieldFocusNode: _replyTextFieldFocusNode,
      maxContentWidth: responsiveMaxWidth,
      isPaused: _state.isPaused,
      onPlayPausePressed: _handlePlayPausePressed,
      onMutePressed: _handleMutePressed,
      loadingSpinnerColor: _config.loadingSpinnerColor,
      transitionConfig: _config.transitionConfig,
    );
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    _replyTextFieldFocusNode.dispose();
    _progressSubscription?.cancel();
    _eventSubscription?.cancel();
    VStoryEventManager.instance.clear();
    _navigationController.dispose();
    _progressController?.dispose();
    _mediaController?.dispose();
    _reactionController.dispose();
    _cubePageManager.dispose();
    if (widget.cacheController == null) {
      _cacheController.dispose();
    }
    super.dispose();
  }

  bool _isTextFieldFocused() {
    // Check if the currently focused widget is a text input
    final focusNode = FocusManager.instance.primaryFocus;
    if (focusNode != null && focusNode.context != null) {
      final Widget? widget = focusNode.context!.widget;
      // Check if it's an EditableText (base class for TextField)
      if (widget is EditableText) {
        return true;
      }
      // Also check the context for TextField or TextFormField
      return focusNode.context!.findAncestorWidgetOfExactType<TextField>() != null ||
          focusNode.context!.findAncestorWidgetOfExactType<TextFormField>() != null;
    }
    return false;
  }

  Color _getScaffoldBackgroundColor() {
    final currentStory = _navigationController.currentStory;
    if (currentStory is VTextStory) {
      return currentStory.backgroundColor;
    }
    return Colors.black;
  }
}
