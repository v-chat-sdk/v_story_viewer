import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../../v_story_viewer.dart';
import '../../v_cache_manager/controllers/v_cache_controller.dart';
import '../../v_gesture_detector/widgets/v_gesture_callbacks.dart';
import '../../v_gesture_detector/widgets/v_gesture_wrapper.dart';
import '../../v_media_viewer/controllers/v_base_media_controller.dart';
import '../../v_media_viewer/controllers/v_media_controller_factory.dart';
import '../../v_media_viewer/controllers/v_video_controller.dart';
import '../../v_media_viewer/models/v_media_callbacks.dart';
import '../../v_media_viewer/widgets/v_media_display.dart';
import '../../v_story_models/models/v_video_story.dart';
import '../../v_progress_bar/controllers/v_progress_controller.dart';
import '../../v_progress_bar/models/v_progress_callbacks.dart';
import '../../v_progress_bar/widgets/v_segmented_progress.dart';
import '../../v_reactions/controllers/v_reaction_controller.dart';
import '../../v_reactions/models/v_reaction_callbacks.dart';
import '../../v_reactions/models/v_reaction_config.dart';
import '../../v_reactions/widgets/v_reaction_animation.dart';
import '../../v_story_models/models/v_story_group.dart';
import '../controllers/v_story_navigation_controller.dart';
import '../models/v_story_viewer_callbacks.dart';
import '../models/v_story_viewer_config.dart';
import '../models/v_story_viewer_state.dart';

/// Main orchestrator widget for story viewing
///
/// Coordinates all feature controllers using callback-based mediator pattern.
/// This is the single entry point for displaying stories.
///
/// **Carousel Mode** (when multiple groups):
/// - Horizontal swipe navigation between groups
/// - Automatic pause/resume during swipe
/// - Edge handling (no infinite scroll)
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

  /// List of story groups to display
  final List<VStoryGroup> storyGroups;

  /// Initial group index to start from
  final int initialGroupIndex;

  /// Initial story index within group
  final int initialStoryIndex;

  /// Configuration options
  final VStoryViewerConfig? config;

  /// Callbacks for viewer events
  final VStoryViewerCallbacks? callbacks;

  /// Optional cache controller (creates default if not provided)
  final VCacheController? cacheController;

  @override
  State<VStoryViewer> createState() => _VStoryViewerState();
}

class _VStoryViewerState extends State<VStoryViewer> {
  late VStoryNavigationController _navigationController;
  late VProgressController _progressController;
  late VBaseMediaController _mediaController;
  late VCacheController _cacheController;
  late VReactionController _reactionController;
  late VStoryViewerConfig _config;
  late VStoryViewerState _state;

  /// Carousel controller for group navigation (only used in carousel mode)
  CarouselSliderController? _carouselController;

  /// Track media loading progress (0.0 to 1.0)
  double _mediaLoadingProgress = 0;

  /// Prevent concurrent navigation operations
  bool _isNavigating = false;

  /// Track carousel scroll state for pause/resume
  bool _isCarouselScrolling = false;

  /// Timer for syncing video progress with progress bar
  Timer? _videoProgressSyncTimer;

  /// Check if carousel mode is enabled
  bool get _isCarouselMode =>
      _config.enableCarousel && widget.storyGroups.length > 1;

  @override
  void initState() {
    super.initState();
    _config = widget.config ?? VStoryViewerConfig.defaultConfig;
    _state = VStoryViewerState.initial();
    _cacheController = widget.cacheController ?? VCacheController();

    // Initialize carousel controller if in carousel mode
    if (_isCarouselMode) {
      _carouselController = CarouselSliderController();
    }

    _initializeControllers();
    _loadCurrentStory();
  }

  /// Initialize all feature controllers with wired callbacks
  void _initializeControllers() {
    final currentGroup = widget.storyGroups[widget.initialGroupIndex];

    // Create navigation controller
    _navigationController = VStoryNavigationController(
      storyGroups: widget.storyGroups,
      initialGroupIndex: widget.initialGroupIndex,
      initialStoryIndex: widget.initialStoryIndex,
    );

    // Create progress controller with callbacks
    _progressController = VProgressController(
      barCount: currentGroup.stories.length,
      callbacks: VProgressCallbacks(onBarComplete: _handleProgressComplete),
    );

    // Create reaction controller with callbacks
    _reactionController = VReactionController(
      config: const VReactionConfig(),
      callbacks: VReactionCallbacks(onReactionSent: _handleReactionSent),
    );

    _initMediaController(_navigationController.currentStory);
  }

  /// Load current story
  Future<void> _loadCurrentStory() async {
    final currentStory = _navigationController.currentStory;
    final currentGroup = _navigationController.currentGroup;

    // CRITICAL: Stop progress timer IMMEDIATELY  and set cursor at next story
    _progressController.setCursorAt(_navigationController.currentStoryIndex);

    // Stop video progress sync
    _stopVideoProgressSync();

    // Reset loading progress
    _mediaLoadingProgress = 0.0;

    // Update reaction controller with current story
    _reactionController.setCurrentStory(currentStory);

    // Update state to loading
    setState(() {
      _state = _state.copyWith(
        playbackState: VStoryPlaybackState.loading,
        currentGroup: currentGroup,
        currentStory: currentStory,
        currentGroupIndex: _navigationController.currentGroupIndex,
        currentStoryIndex: _navigationController.currentStoryIndex,
      );
    });

    // Dispose old media controller
    _mediaController.dispose();

    // Create new media controller for current story
    _initMediaController(currentStory);

    // Load media (progress will be set when media is ready)
    await _mediaController.loadStory(currentStory);

    // Notify parent of story change
    widget.callbacks?.onStoryChanged?.call(
      currentGroup,
      currentStory,
      _navigationController.currentStoryIndex,
    );

    // Release navigation lock
    _isNavigating = false;
  }

  // ==================== Callback Handlers ====================

  /// Handle progress bar completion
  void _handleProgressComplete(int barIndex) {
    // Prevent concurrent navigation
    if (_isNavigating) return;

    _navigateToNextStory();
  }

  /// Handle media loading progress
  ///
  /// Called during media download with progress updates (0.0 to 1.0).
  /// Story remains in loading state and does NOT start until media is ready.
  void _handleLoadingProgress(double progress) {
    setState(() {
      _mediaLoadingProgress = progress;
    });
  }

  /// Handle media ready
  ///
  /// Called when media is fully loaded and ready to display.
  /// This is when we transition from loading to playing state
  /// and start the progress bar animation.
  void _handleMediaReady() {
    // Ensure we're at 100% before starting
    _mediaLoadingProgress = 1.0;

    // Update state to playing
    setState(() {
      _state = _state.copyWith(playbackState: VStoryPlaybackState.playing);
    });

    // Start progress animation ONLY after media is ready
    final currentStory = _navigationController.currentStory;
    _progressController.startProgress(
      _navigationController.currentStoryIndex,
      currentStory.duration ?? const Duration(seconds: 5),
    );

    // Start video progress sync if this is a video story
    if (currentStory is VVideoStory) {
      _startVideoProgressSync();
    }
  }

  /// Handle media error
  void _handleMediaError(String error) {
    widget.callbacks?.onError?.call(error);
  }

  /// Handle duration known (for videos)
  void _handleDurationKnown(Duration duration) {
    _progressController.updateDuration(duration);
  }

  /// Handle tap previous
  void _handleTapPrevious() {
    // Prevent concurrent navigation
    if (_isNavigating) return;
    _isNavigating = true;

    if (_navigationController.hasPreviousStory) {
      _navigationController.previousStory();
      _loadCurrentStory();
    } else if (_navigationController.hasPreviousGroup) {
      // In carousel mode, use carousel navigation
      if (_isCarouselMode) {
        _carouselController?.previousPage(
          duration: _config.carouselAnimationDuration,
          curve: Curves.easeInOut,
        );
        _isNavigating = false; // Carousel will handle navigation
      } else {
        _navigationController.previousGroup();
        _reinitializeProgressController();
        _loadCurrentStory();
        widget.callbacks?.onGroupChanged?.call(
          _navigationController.currentGroup,
          _navigationController.currentGroupIndex,
        );
      }
    } else {
      // No previous story, release lock
      _isNavigating = false;
    }
  }

  /// Handle tap next
  void _handleTapNext() {
    _navigateToNextStory();
  }

  /// Handle long press start (pause)
  void _handleLongPressStart() {
    if (!_config.pauseOnLongPress) return;

    _pauseStory();
  }

  /// Handle long press end (resume)
  void _handleLongPressEnd() {
    if (!_config.pauseOnLongPress) return;

    _resumeStory();
  }

  /// Handle swipe down (dismiss)
  void _handleSwipeDown() {
    if (!_config.dismissOnSwipeDown) return;

    widget.callbacks?.onDismiss?.call();
    Navigator.of(context).pop();
  }

  /// Handle double tap (reaction)
  void _handleDoubleTap() {
    _reactionController.triggerReaction();
  }

  /// Handle reaction sent
  void _handleReactionSent(story, String reactionType) {
    debugPrint('Reaction sent: $reactionType for story ${story.id}');
  }

  /// Handle carousel page changed (only called in carousel mode)
  void _handleCarouselPageChanged(int index, CarouselPageChangedReason reason) {
    // Prevent concurrent navigation
    if (_isNavigating) return;
    _isNavigating = true;

    // Update navigation controller to new group
    _navigationController.jumpTo(groupIndex: index, storyIndex: 0);

    // Reinitialize progress for new group
    _reinitializeProgressController();

    // Load first story of new group
    _loadCurrentStory();

    // Notify parent of group change
    widget.callbacks?.onGroupChanged?.call(
      _navigationController.currentGroup,
      _navigationController.currentGroupIndex,
    );
  }

  /// Handle carousel scroll events (only called in carousel mode)
  void _handleCarouselScrolled(double? value) {
    if (!_config.pauseOnCarouselScroll) return;

    final isScrolling = value != null && value > 0;

    // Only update if state changed
    if (_isCarouselScrolling == isScrolling) return;

    setState(() {
      _isCarouselScrolling = isScrolling;
    });

    if (isScrolling) {
      _pauseStory();
    } else {
      _resumeStory();
    }
  }

  /// Pause current story (progress and media)
  void _pauseStory() {
    _progressController.pauseProgress();
    _mediaController.pause();
    _stopVideoProgressSync();

    setState(() {
      _state = _state.copyWith(playbackState: VStoryPlaybackState.paused);
    });
  }

  /// Resume current story (progress and media)
  void _resumeStory() {
    // Only resume if media is ready (not loading)
    if (_mediaLoadingProgress < 1.0) return;

    _progressController.resumeProgress();
    _mediaController.resume();

    // Restart video progress sync if this is a video story
    if (_navigationController.currentStory is VVideoStory) {
      _startVideoProgressSync();
    }

    setState(() {
      _state = _state.copyWith(playbackState: VStoryPlaybackState.playing);
    });
  }

  // ==================== Navigation Helpers ====================

  /// Navigate to next story
  void _navigateToNextStory() {
    // Prevent concurrent navigation
    if (_isNavigating) return;
    _isNavigating = true;

    if (_navigationController.hasNextStory) {
      // Move to next story in current group
      _navigationController.nextStory();
      _loadCurrentStory();
    } else if (_navigationController.hasNextGroup &&
        _config.autoMoveToNextGroup) {
      // Move to next group
      if (_isCarouselMode) {
        // Use carousel navigation
        _carouselController?.nextPage(
          duration: _config.carouselAnimationDuration,
          curve: Curves.easeInOut,
        );
        _isNavigating = false; // Carousel will handle navigation
      } else {
        _navigationController.nextGroup();
        _reinitializeProgressController();
        _loadCurrentStory();
        widget.callbacks?.onGroupChanged?.call(
          _navigationController.currentGroup,
          _navigationController.currentGroupIndex,
        );
      }
    } else if (_config.restartGroupWhenAllViewed) {
      // Restart current group
      _navigationController.restartGroup();
      _loadCurrentStory();
    } else {
      // All stories completed
      _isNavigating = false; // Release lock before popping
      widget.callbacks?.onComplete?.call();
      Navigator.of(context).pop();
    }
  }

  /// Reinitialize progress controller when group changes
  void _reinitializeProgressController() {
    // CRITICAL: Stop timer BEFORE disposing to prevent callback race conditions
    _progressController
      ..pauseProgress()
      ..dispose();
    _progressController = VProgressController(
      barCount: _navigationController.currentGroup.stories.length,
      callbacks: VProgressCallbacks(onBarComplete: _handleProgressComplete),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storyContent = _buildStoryContent();

    // Wrap in carousel if carousel mode is enabled
    if (_isCarouselMode) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: widget.storyGroups.length,
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height,
              viewportFraction: 1,
              enableInfiniteScroll: false,
              initialPage: widget.initialGroupIndex,
              onPageChanged: _handleCarouselPageChanged,
              onScrolled: _handleCarouselScrolled,
            ),
            itemBuilder: (context, index, realIndex) {
              // Only build content for current group to avoid multiple controllers
              if (index == _navigationController.currentGroupIndex) {
                return storyContent;
              }
              // Return placeholder for other pages
              return const ColoredBox(color: Colors.black);
            },
          ),
        ),
      );
    }

    // Non-carousel mode (single group or carousel disabled)
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: storyContent),
    );
  }

  /// Build story content (used in both carousel and non-carousel modes)
  Widget _buildStoryContent() {
    return VGestureWrapper(
      callbacks: VGestureCallbacks(
        onTapPrevious: _handleTapPrevious,
        onTapNext: _handleTapNext,
        onLongPressStart: _mediaController.isLoading
            ? null
            : _handleLongPressStart,
        onLongPressEnd: _mediaController.isLoading ? null : _handleLongPressEnd,
        onSwipeDown: _handleSwipeDown,
        onDoubleTap: _mediaController.isLoading ? null : _handleDoubleTap,
      ),
      child: Stack(
        children: [
          // Media content
          VMediaDisplay(
            controller: _mediaController,
            story: _navigationController.currentStory,
          ),

          // Loading overlay (shown while media is downloading)
          if (_state.isLoading && _mediaLoadingProgress < 1.0)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _mediaLoadingProgress,
                      color: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 5),
                    Text(_mediaLoadingProgress.toString()),
                  ],
                ),
              ),
            ),

          // Progress bars at top
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: VSegmentedProgress(controller: _progressController),
          ),

          // Reaction animation overlay
          VReactionAnimation(controller: _reactionController),
        ],
      ),
    );
  }

  /// Start syncing video progress with progress bar
  ///
  /// This creates a periodic timer that updates the progress bar based on
  /// the actual video playback position.
  void _startVideoProgressSync() {
    _stopVideoProgressSync();

    if (_mediaController is! VVideoController) return;

    final videoController = _mediaController as VVideoController;
    final videoPlayer = videoController.videoPlayerController;

    if (videoPlayer == null) return;

    _videoProgressSyncTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        final position = videoPlayer.value.position;
        final duration = videoPlayer.value.duration;

        if (duration != Duration.zero) {
          final progress = position.inMilliseconds / duration.inMilliseconds;
          _progressController.updateCurrentProgress(progress.clamp(0.0, 1.0));
        }
      },
    );
  }

  /// Stop video progress sync timer
  void _stopVideoProgressSync() {
    _videoProgressSyncTimer?.cancel();
    _videoProgressSyncTimer = null;
  }

  @override
  void dispose() {
    _stopVideoProgressSync();
    _navigationController.dispose();
    _progressController.dispose();
    _mediaController.dispose();
    _reactionController.dispose();
    if (widget.cacheController == null) {
      _cacheController.dispose();
    }
    super.dispose();
  }

  void _initMediaController(VBaseStory currentStory) {
    _mediaController = VMediaControllerFactory.createController(
      story: currentStory,
      cacheController: _cacheController,
      callbacks: VMediaCallbacks(
        onLoadingProgress: _handleLoadingProgress,
        onMediaReady: _handleMediaReady,
        onMediaError: _handleMediaError,
        onDurationKnown: _handleDurationKnown,
      ),
    );
  }
}
