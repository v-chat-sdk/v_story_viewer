import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../v_story_viewer.dart';
import '../utils/v_carousel_manager.dart';
import '../utils/v_controller_initializer.dart';
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

  VStoryState _state = VStoryState.initial();
  StreamSubscription<VDownloadProgress>? _progressSubscription;
  double _mediaLoadingProgress = 0;

  bool get _isCubePageMode =>
      _config.enableCarousel && widget.storyGroups.length > 1;

  @override
  void initState() {
    super.initState();
    _initializeConfiguration();
    _initializeManagers();
    _initializeControllers();
    _setupProgressListener();
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
      onBarComplete: _handleProgressComplete,
    );
    _reactionController = VControllerInitializer.createReactionController(
      onReactionSent: _handleReactionSent,
    );
    _initializeGestureHandler();
  }

  void _initMediaController(VBaseStory story) {
    _mediaController = VControllerInitializer.createMediaController(
      story: story,
      cacheController: _cacheController,
      onMediaReady: _handleMediaReady,
      onMediaError: _handleMediaError,
      onDurationKnown: _handleDurationKnown,
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
    _progressSubscription = _cacheController.progressStream.listen((progress) {
      if (!mounted) return;

      final currentStory = _navigationController.currentStory;

      // Match progress by story ID
      if (progress.storyId == currentStory.id) {
        setState(() {
          _mediaLoadingProgress = progress.progress;
        });
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

    setState(() {
      _mediaLoadingProgress = 0;
    });
    _mediaController?.dispose();
    _initMediaController(currentStory);

    // Set progress cursor and update state
    _progressController!.setCursorAt(currentStoryIndex + 1);
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

    // Load media
    await _mediaController!.loadStory(currentStory);

    // Notify callback
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
    _updateState(
      _state.copyWith(playbackState: VStoryPlaybackState.playing),
    );

    // Start progress animation
    _progressController!.startProgress(
      currentStoryIndex,
      currentStory.duration ?? const Duration(seconds: 5),
    );
  }

  void _handleMediaError(String error) {
    widget.callbacks?.onError?.call(error);
  }

  void _handleDurationKnown(Duration duration) {
    _progressController!.updateDuration(duration);
  }

  void _handleReactionSent(VBaseStory story, String reactionType) {
    debugPrint('Reaction: $reactionType for story ${story.id}');
  }

  void _handleCarouselScrollStateChanged(bool isScrolling) {
    setState(() {
      if (isScrolling) {
      } else {}
    });
  }

  void _handleTapPrevious() {
    final currentProgress = _progressController?.currentProgress ?? 0;
    final threshold = 0.1;
    if (currentProgress < threshold && _navigationController.hasPreviousStory) {
      _navigationController.previousStory();
      _loadCurrentStory();
    } else if (currentProgress < threshold &&
        _navigationController.hasPreviousGroup) {
      _handlePreviousGroup();
    } else {
      _progressController?.resetProgress();
      _mediaController?.loadStory(_navigationController.currentStory);
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
      onBarComplete: _handleProgressComplete,
    );
  }

  void _handleCarouselPageChanged(int index) {
    final jumpRes = _navigationController.jumpTo(
      groupIndex: index,
      storyIndex: 0,
    );
    if (jumpRes == false) {
      // this means he can not move to next group!
    }
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

    if (_isCubePageMode) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: CubePageView(
            controller: _cubePageManager.pageController!,
            itemCount: widget.storyGroups.length,
            onPageChanged: _handleCarouselPageChanged,
            itemBuilder: (context, index) {
              if (index == _navigationController.currentGroupIndex) {
                return storyContent;
              }
              return const ColoredBox(color: Colors.black);
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: storyContent),
    );
  }

  Widget _buildStoryContent() {
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
      state: _state,
      mediaLoadingProgress: _mediaLoadingProgress,
      progressController: _progressController!,
      currentGroup: _navigationController.currentGroup,
      reactionController: _reactionController,
      context: context,
      callbacks: widget.callbacks,
    );
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
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
}
