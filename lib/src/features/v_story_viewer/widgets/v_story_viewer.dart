import 'package:flutter/material.dart';

import '../../v_cache_manager/controllers/v_cache_controller.dart';
import '../../v_gesture_detector/widgets/v_gesture_callbacks.dart';
import '../../v_gesture_detector/widgets/v_gesture_wrapper.dart';
import '../../v_media_viewer/controllers/v_base_media_controller.dart';
import '../../v_media_viewer/controllers/v_media_controller_factory.dart';
import '../../v_media_viewer/models/v_media_callbacks.dart';
import '../../v_media_viewer/widgets/v_media_display.dart';
import '../../v_progress_bar/controllers/v_progress_controller.dart';
import '../../v_progress_bar/models/v_progress_callbacks.dart';
import '../../v_progress_bar/widgets/v_segmented_progress.dart';
import '../../v_story_models/models/v_story_group.dart';
import '../controllers/v_story_navigation_controller.dart';
import '../models/v_story_viewer_callbacks.dart';
import '../models/v_story_viewer_config.dart';
import '../models/v_story_viewer_state.dart';

/// Main orchestrator widget for story viewing
///
/// Coordinates all feature controllers using callback-based mediator pattern.
/// This is the single entry point for displaying stories.
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
  late VStoryViewerConfig _config;
  late VStoryViewerState _state;

  /// Track media loading progress (0.0 to 1.0)
  double _mediaLoadingProgress = 0;

  /// Prevent concurrent navigation operations
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _config = widget.config ?? VStoryViewerConfig.defaultConfig;
    _state = VStoryViewerState.initial();
    _cacheController = widget.cacheController ?? VCacheController();
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
      barDuration: const Duration(seconds: 5),
      callbacks: VProgressCallbacks(onBarComplete: _handleProgressComplete),
    );

    // Create media controller with callbacks
    _mediaController = VMediaControllerFactory.createController(
      story: _navigationController.currentStory,
      cacheController: _cacheController,
      callbacks: VMediaCallbacks(
        onLoadingProgress: _handleLoadingProgress,
        onMediaReady: _handleMediaReady,
        onMediaError: _handleMediaError,
        onDurationKnown: _handleDurationKnown,
      ),
    );
  }

  /// Load current story
  Future<void> _loadCurrentStory() async {
    final currentStory = _navigationController.currentStory;
    final currentGroup = _navigationController.currentGroup;

    // CRITICAL: Stop progress timer IMMEDIATELY to prevent race conditions
    _progressController.pauseProgress();

    // Reset loading progress
    _mediaLoadingProgress = 0.0;

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

    // CRITICAL: Set progress bar position AFTER media is ready, not before load
    // This prevents the old timer from interfering with the new story
    _progressController.jumpToBar(_navigationController.currentStoryIndex);

    // Start progress animation ONLY after media is ready
    _progressController.startProgress(_navigationController.currentStoryIndex);
  }

  /// Handle media error
  void _handleMediaError(String error) {
    widget.callbacks?.onError?.call(error);

    // Skip to next story on error
    _navigateToNextStory();
  }

  /// Handle duration known (for videos)
  void _handleDurationKnown(Duration duration) {
    // Could update progress duration if needed
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
      _navigationController.previousGroup();
      _reinitializeProgressController();
      _loadCurrentStory();
      widget.callbacks?.onGroupChanged?.call(
        _navigationController.currentGroup,
        _navigationController.currentGroupIndex,
      );
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

    _progressController.pauseProgress();
    _mediaController.pause();

    setState(() {
      _state = _state.copyWith(playbackState: VStoryPlaybackState.paused);
    });
  }

  /// Handle long press end (resume)
  void _handleLongPressEnd() {
    if (!_config.pauseOnLongPress) return;

    _progressController.resumeProgress();
    _mediaController.resume();

    setState(() {
      _state = _state.copyWith(playbackState: VStoryPlaybackState.playing);
    });
  }

  /// Handle swipe down (dismiss)
  void _handleSwipeDown() {
    if (!_config.dismissOnSwipeDown) return;

    widget.callbacks?.onDismiss?.call();
    Navigator.of(context).pop();
  }

  /// Handle double tap (reaction)
  void _handleDoubleTap() {
    // Reaction handling can be implemented here
    // For now, this is a placeholder
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
      _navigationController.nextGroup();
      _reinitializeProgressController();
      _loadCurrentStory();
      widget.callbacks?.onGroupChanged?.call(
        _navigationController.currentGroup,
        _navigationController.currentGroupIndex,
      );
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
    _progressController.pauseProgress();
    _progressController.dispose();
    _progressController = VProgressController(
      barCount: _navigationController.currentGroup.stories.length,
      barDuration: const Duration(seconds: 5),
      callbacks: VProgressCallbacks(onBarComplete: _handleProgressComplete),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: VGestureWrapper(
          callbacks: VGestureCallbacks(
            onTapPrevious: _handleTapPrevious,
            onTapNext: _handleTapNext,
            onLongPressStart: _handleLongPressStart,
            onLongPressEnd: _handleLongPressEnd,
            onSwipeDown: _handleSwipeDown,
            onDoubleTap: _handleDoubleTap,
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
                Container(
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
                        const SizedBox(height: 16),
                        Text(
                          'Loading ${(_mediaLoadingProgress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _navigationController.dispose();
    _progressController.dispose();
    _mediaController.dispose();
    if (widget.cacheController == null) {
      _cacheController.dispose();
    }
    super.dispose();
  }
}
