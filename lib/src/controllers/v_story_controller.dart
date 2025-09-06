import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/v_story_models.dart';
import '../utils/v_state_transitions.dart';
import '../utils/v_error_logger.dart';
import '../services/v_view_state_manager.dart';
import '../services/v_story_persistence.dart';
import '../services/v_cache_manager.dart';
import 'v_story_controller_state.dart';

/// Callback for when a story is viewed
typedef VStoryViewedCallback = void Function(VBaseStory story, String userId);

/// Callback for story navigation events
typedef VStoryNavigationCallback =
    void Function(String? fromStoryId, String toStoryId);

/// Callback for story errors
typedef VStoryErrorCallback = void Function(String error, VBaseStory? story);

/// Main controller for managing story playback and navigation.
///
/// This controller handles story lifecycle, navigation, video management,
/// and app lifecycle integration using WidgetsBindingObserver.
class VStoryController extends ChangeNotifier with WidgetsBindingObserver {
  /// Internal state of the controller
  VStoryControllerState _state = VStoryControllerState.initial();

  /// Timer for story progress updates
  Timer? _progressTimer;

  /// Track if controller has been disposed
  bool _isDisposed = false;

  /// Video controllers cache (limited to 10 instances)
  final Map<String, VideoPlayerController> _videoControllers = {};

  /// Maximum number of cached video controllers
  static const int _maxVideoCacheCount = 10;

  /// View state manager for persistence
  final VViewStateManager _viewStateManager = VViewStateManager();

  /// Persistence service
  final VStoryPersistence _persistence = VStoryPersistence();

  /// Story viewed callback
  VStoryViewedCallback? onStoryViewed;

  /// Story navigation callback
  VStoryNavigationCallback? onStoryNavigation;

  /// Error callback
  VStoryErrorCallback? onError;

  /// All stories completed callback
  VoidCallback? onAllStoriesCompleted;

  /// Enable persistence
  bool enablePersistence = true;

  /// Gets the current controller state
  VStoryControllerState get state => _state;

  /// Gets the current story
  VBaseStory? get currentStory => _state.currentStory;

  /// Gets the current story state
  VStoryState get storyState => _state.storyState;

  /// Gets the current progress (0.0 to 1.0)
  double get progress => _state.storyState.progress;

  /// Whether the controller is playing
  bool get isPlaying => _state.isPlaying;

  /// Whether the controller is paused
  bool get isPaused => _state.isPaused;


  /// Creates a story controller
  VStoryController() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Initializes the controller with a story list
  Future<void> initialize(VStoryList storyList) async {
    if (_isDisposed) return;
    if (_state.isInitialized) {
      // Already initialized, skip re-initialization
      return;
    }

    // Initialize persistence if enabled
    if (enablePersistence) {
      await _viewStateManager.initialize();
      await _persistence.initialize();
    }

    // Find first unviewed story based on persistence
    VStoryGroup? firstGroup;
    VBaseStory? firstStory;

    if (enablePersistence) {
      firstGroup = _viewStateManager.findFirstUnviewedGroup(storyList);
      if (firstGroup != null) {
        firstStory = _viewStateManager.findFirstUnviewed(firstGroup);
      }
    }

    // Fallback to default logic if no persistence or all viewed
    firstGroup ??= storyList.firstUnviewedGroup ?? storyList.groups.first;
    firstStory ??= firstGroup.firstUnviewed ?? firstGroup.stories.first;

    _state = _state.copyWith(
      storyList: storyList,
      currentStory: firstStory,
      currentStoryId: firstStory.id,
      currentUserId: firstGroup.user.id,
      isInitialized: true,
      progress: VStoryProgress(
        storyStates: {},
        currentStoryId: firstStory.id,
        currentUserId: firstGroup.user.id,
        totalStories: storyList.totalStoryCount,
        viewedStories: storyList.totalStoryCount - storyList.totalUnviewedCount,
      ),
    );

    notifyListeners();

    // Start playing the first story
    await play();
  }

  /// Loads a story list (alias for initialize for backward compatibility)
  Future<void> loadStoryList(VStoryList storyList) async {
    if (_isDisposed) return;
    await initialize(storyList);
  }

  /// Plays the current story
  Future<void> play() async {
    if (_isDisposed) return;
    if (!_state.isReady || _state.isPlaying) return;

    final currentState = _state.storyState;

    // Check valid transition
    if (!VStateTransitions.canStartPlayback(currentState.playbackState)) {
      return;
    }

    try {
      // Transition to loading if needed
      if (currentState.playbackState == VStoryPlaybackState.initial) {
        _updateState(_state.updateStoryState(VStoryState.loading()));
        await _loadCurrentStory();
      }

      // Start playback
      _updateState(
        _state.updateStoryState(
          _state.storyState.toPlaying(duration: _state.currentStory?.duration),
        ),
      );

      // Start progress timer
      _startProgressTimer();

      // Resume video if applicable
      await _resumeVideo();
    } catch (e) {
      _handleError('Failed to play story: $e');
    }
  }

  /// Pauses the current story
  void pause() {
    if (_isDisposed) return;
    if (!_state.isReady || !_state.isPlaying) return;

    _updateState(_state.updateStoryState(_state.storyState.toPaused()));
    _stopProgressTimer();
    _pauseVideo();
  }

  /// Stops the current story
  void stop() {
    if (_isDisposed) return;
    if (!_state.isReady) return;

    _stopProgressTimer();
    _stopVideo();
    _updateState(_state.updateStoryState(VStoryState.initial()));
  }

  /// Resets the current story to the beginning
  void reset() {
    if (_isDisposed) return;
    if (!_state.isReady) return;

    _stopProgressTimer();
    _resetVideo();
    _updateState(_state.updateStoryState(VStoryState.initial()));

    // Restart playback
    play();
  }

  /// Reloads the current story (for error recovery)
  Future<void> reload() async {
    if (_isDisposed) return;
    if (!_state.isReady || _state.currentStory == null) return;

    try {
      // Reset to loading state
      _updateState(_state.updateStoryState(VStoryState.loading()));

      // Clear any cached error state for video stories
      if (_state.currentStory is VVideoStory) {
        final videoController = _videoControllers[_state.currentStory!.id];
        if (videoController != null) {
          videoController.dispose();
          _videoControllers.remove(_state.currentStory!.id);
        }
      }

      // Reload the story
      await _loadCurrentStory();

      // Resume playback if it was playing before
      await play();
    } catch (e) {
      _handleError('Failed to reload story: $e');
    }
  }

  /// Navigates to the next story
  Future<void> nextStory() async {
    print('🔵 nextStory() called');
    print('  └─ isDisposed: $_isDisposed');
    
    if (_isDisposed) {
      print('  ⚠️ Controller is disposed, returning early');
      return;
    }
    
    final storyList = _state.storyList;
    print('  └─ Total groups in storyList: ${storyList.groups.length}');
    print('  └─ Current story ID: ${_state.currentStoryId}');
    
    final currentGroup = storyList.findGroupContainingStory(_state.currentStoryId!)!;
    print('  └─ Current group: ${currentGroup.user.id}');
    print('  └─ Stories in current group: ${currentGroup.stories.length}');
    print('  └─ Current story index in group: ${currentGroup.stories.indexWhere((s) => s.id == _state.currentStoryId)}');


    // Try next story in current group first
    final nextStoryInGroup = currentGroup.getNextStory(_state.currentStoryId!);
    print('  └─ Next story in current group: ${nextStoryInGroup?.id ?? "null"}');
    
    if (nextStoryInGroup != null) {
      print('  ✅ Found next story in same group: ${nextStoryInGroup.id}');
      print('  └─ Navigating to story within group...');
      await _navigateToStory(nextStoryInGroup, currentGroup.user.id);
      print('  └─ Navigation complete');
      return;
    }
    
    print('  └─ No more stories in current group, checking for next group...');
    
    // No more stories in current group, try next group
    var nextGroup = storyList.getNextGroup(currentGroup.user.id);
    print('  └─ Next group found: ${nextGroup?.user.id ?? "null"}');
    
    // Skip empty groups
    int skippedGroups = 0;
    while (nextGroup != null && nextGroup.stories.isEmpty) {
      skippedGroups++;
      print('  └─ Skipping empty group: ${nextGroup.user.id}');
      nextGroup = storyList.getNextGroup(nextGroup.user.id);
    }
    
    if (skippedGroups > 0) {
      print('  └─ Skipped $skippedGroups empty groups');
    }
    
    // Check if we've reached the end of all stories
    if (nextGroup == null) {
      print('  🏁 Reached end of all stories - calling _handleAllStoriesCompleted()');
      _handleAllStoriesCompleted();
      return;
    }
    
    print('  └─ Found next non-empty group: ${nextGroup.user.id}');
    print('  └─ Stories in next group: ${nextGroup.stories.length}');
    
    // Find first story to show in next group
    VBaseStory? firstStory;
    if (enablePersistence) {
      print('  └─ Persistence enabled, finding first unviewed story...');
      firstStory = _viewStateManager.findFirstUnviewed(nextGroup);
      print('  └─ First unviewed from persistence: ${firstStory?.id ?? "null"}');
    }
    
    if (firstStory == null) {
      firstStory = nextGroup.firstUnviewed ?? nextGroup.stories.first;
      print('  └─ Using fallback: ${nextGroup.firstUnviewed != null ? "firstUnviewed" : "first story"}');
    }
    
    print('  ✅ Selected story to navigate to: ${firstStory.id}');
    print('  └─ Starting navigation to new group...');
    
    await _navigateToStory(firstStory, nextGroup.user.id);
    
    print('  └─ Navigation to next group complete');
    print('🔵 nextStory() finished');
  }

  /// Navigates to the previous story
  Future<void> previous() async {
    if (_isDisposed || !_state.isReady) return;
    
    final storyList = _state.storyList;
    final currentGroup = storyList.findGroupContainingStory(_state.currentStoryId!);
    
    // Early return if current group not found
    if (currentGroup == null) return;
    
    // Try previous story in current group first
    final previousStoryInGroup = currentGroup.getPreviousStory(_state.currentStoryId!);
    if (previousStoryInGroup != null) {
      await _navigateToStory(previousStoryInGroup, currentGroup.user.id);
      return;
    }
    
    // No previous story in current group, try previous group
    var previousGroup = storyList.getPreviousGroup(currentGroup.user.id);
    
    // Skip empty groups when going backwards
    while (previousGroup != null && previousGroup.stories.isEmpty) {
      previousGroup = storyList.getPreviousGroup(previousGroup.user.id);
    }
    
    // If no previous group with stories found, return
    if (previousGroup == null) return;
    
    await _navigateToStory(previousGroup.stories.last, previousGroup.user.id);
  }

  /// Navigates to a specific story by ID
  Future<void> goToStory(String storyId) async {
    if (_isDisposed || !_state.isReady) return;
    
    final storyList = _state.storyList;
    final story = storyList.findStoryById(storyId);
    final group = storyList.findGroupContainingStory(storyId);
    
    // Early return if story or group not found
    if (story == null || group == null) return;
    
    await _navigateToStory(story, group.user.id);
  }

  /// Navigates to a specific story by index in current group
  void goToStoryByIndex(int index) {
    if (!_state.isReady) return;

    final storyList = _state.storyList;
    final currentGroup = storyList.findGroupContainingStory(
      _state.currentStoryId!,
    );

    if (currentGroup != null &&
        index >= 0 &&
        index < currentGroup.stories.length) {
      final story = currentGroup.stories[index];
      goToStory(story.id);
    }
  }

  /// Mutes/unmutes video stories
  void setMuted(bool muted) {
    _updateState(
      _state.copyWith(storyState: _state.storyState.copyWith(isMuted: muted)),
    );

    // Apply to current video if playing
    _videoControllers.forEach((_, controller) {
      controller.setVolume(muted ? 0.0 : 1.0);
    });
  }

  /// Gets a video controller for a story ID
  VideoPlayerController? getVideoController(String storyId) {
    return _videoControllers[storyId];
  }

  /// Internal navigation to a story
  Future<void> _navigateToStory(VBaseStory story, String userId) async {
    // Mark current story as viewed if it was playing
    if (_state.currentStory != null && _state.storyState.progress > 0.5) {
      _markCurrentAsViewed();
    }

    // Stop current story
    stop();

    // Clean up old video controllers
    await _cleanupVideoControllers();

    // Update state with new story
    final fromStoryId = _state.currentStoryId;
    _updateState(_state.updateCurrentStory(story, userId: userId));

    // Notify persistence about starting new story
    if (enablePersistence) {
      await _viewStateManager.startViewing(story);
      _viewStateManager.setCurrentUser(userId);
    }

    // Notify navigation
    onStoryNavigation?.call(fromStoryId, story.id);

    // Start playing new story
    await play();
  }

  /// Loads the current story
  Future<void> _loadCurrentStory() async {
    final story = _state.currentStory;
    if (story == null) return;

    // Load video controller if video story
    if (story is VVideoStory) {
      await _loadVideoController(story);
    }

    // No artificial delay needed for non-video stories
  }

  /// Cache manager instance for video caching
  final VCacheManager _cacheManager = VCacheManager();

  /// Loads a video controller for a video story
  Future<void> _loadVideoController(VVideoStory story) async {
    final key = story.id;

    // Check if already cached
    if (_videoControllers.containsKey(key)) {
      return;
    }

    // Create new controller
    VideoPlayerController controller;

    if (story.media.networkUrl != null) {
      try {
        // Try to get cached file first for network videos
        final cachedFile = await _cacheManager.getFile(story.media.networkUrl!);

        // Use cached file if available
        controller = VideoPlayerController.file(cachedFile);
      } catch (e) {
        // Fallback to network URL if caching fails
        controller = VideoPlayerController.networkUrl(
          Uri.parse(story.media.networkUrl!),
        );
      }
    } else if (story.media.fileLocalPath != null) {
      controller = VideoPlayerController.file(File(story.media.fileLocalPath!));
    } else if (story.media.assetsPath != null) {
      controller = VideoPlayerController.asset(story.media.assetsPath!);
    } else {
      throw UnsupportedError('Unsupported video source');
    }

    // Initialize controller
    await controller.initialize();
    controller.setLooping(story.loop);
    controller.setVolume(_state.storyState.isMuted ? 0.0 : 1.0);

    // Cache controller
    _videoControllers[key] = controller;

    // Cleanup old controllers if cache is full
    if (_videoControllers.length > _maxVideoCacheCount) {
      await _cleanupOldestVideoController();
    }
  }

  /// Starts the progress timer
  void _startProgressTimer() {
    _stopProgressTimer();

    final duration =
        _state.currentStory?.duration ?? const Duration(seconds: 10);
    final updateInterval = const Duration(milliseconds: 50);

    _progressTimer = Timer.periodic(updateInterval, (timer) {
      // Check if disposed
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      final elapsed = _state.storyState.elapsed + updateInterval;

      if (elapsed >= duration) {
        // Story completed
        _handleStoryCompleted();
        timer.cancel();
      } else {
        // Update progress
        final newState = _state.storyState.updateProgress(elapsed);
        _updateState(_state.updateStoryState(newState));

        // Save partial progress to persistence
        if (enablePersistence && _state.currentStory != null) {
          _viewStateManager.updateProgress(
            _state.currentStory!.id,
            newState.progress,
          );
        }
      }
    });
  }

  /// Stops the progress timer
  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  /// Handles story completion
  void _handleStoryCompleted() {
    _stopProgressTimer();
    _markCurrentAsViewed();
    _updateState(_state.updateStoryState(_state.storyState.toCompleted()));

    // Auto-advance to next story immediately
    if (!_isDisposed) {
      nextStory();
    }
  }

  /// Marks current story as viewed
  void _markCurrentAsViewed() {
    final story = _state.currentStory;
    if (story != null) {
      // Check persistence state
      final wasViewed = enablePersistence
          ? _viewStateManager.isStoryViewed(story.id)
          : story.isViewed;

      if (!wasViewed) {
        // Mark as viewed in persistence
        if (enablePersistence) {
          _viewStateManager.markAsViewed(story);
        }

        // Call callback
        onStoryViewed?.call(story, _state.currentUserId ?? '');
      }
    }
  }

  /// Handles all stories completed
  void _handleAllStoriesCompleted() {
    _stopProgressTimer();
    stop();
    onAllStoriesCompleted?.call();
  }

  /// Handles errors
  void _handleError(dynamic error, [StackTrace? stackTrace]) {
    // Convert to VStoryError if needed
    final storyError = error is VStoryError
        ? error
        : VGenericError(error.toString(), error);

    // Log the error with stack trace
    VErrorLogger.logError(storyError, stackTrace: stackTrace);

    // Update state with error message
    _updateState(
      _state.updateStoryState(VStoryState.error(storyError.userMessage)),
    );

    // Notify error callback
    onError?.call(storyError.userMessage, _state.currentStory);
  }

  /// Updates internal state and notifies listeners
  void _updateState(VStoryControllerState newState) {
    if (_isDisposed) return;
    _state = newState;
    notifyListeners();
  }

  // Video control methods

  VideoPlayerController? _getCurrentVideoController() {
    final story = _state.currentStory;
    if (story is VVideoStory) {
      return _videoControllers[story.id];
    }
    return null;
  }

  Future<void> _resumeVideo() async {
    final controller = _getCurrentVideoController();
    await controller?.play();
  }

  void _pauseVideo() {
    final controller = _getCurrentVideoController();
    controller?.pause();
  }

  void _stopVideo() {
    final controller = _getCurrentVideoController();
    controller?.pause();
    controller?.seekTo(Duration.zero);
  }

  void _resetVideo() {
    final controller = _getCurrentVideoController();
    controller?.seekTo(Duration.zero);
  }

  Future<void> _cleanupVideoControllers() async {
    // Keep only current video controller
    final currentStoryId = _state.currentStoryId;
    final controllersToRemove = <String>[];

    _videoControllers.forEach((key, controller) {
      if (key != currentStoryId) {
        controllersToRemove.add(key);
      }
    });

    for (final key in controllersToRemove) {
      await _videoControllers[key]?.dispose();
      _videoControllers.remove(key);
    }
  }

  Future<void> _cleanupOldestVideoController() async {
    if (_videoControllers.isEmpty) return;

    // Remove the first (oldest) controller that's not current
    final currentStoryId = _state.currentStoryId;
    String? keyToRemove;

    for (final key in _videoControllers.keys) {
      if (key != currentStoryId) {
        keyToRemove = key;
        break;
      }
    }

    if (keyToRemove != null) {
      await _videoControllers[keyToRemove]?.dispose();
      _videoControllers.remove(keyToRemove);
    }
  }

  // WidgetsBindingObserver implementation

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Pause when app goes to background
        if (_state.isPlaying) {
          pause();
          _updateState(_state.updateAppActive(false));
        }
        break;

      case AppLifecycleState.resumed:
        // Resume when app comes to foreground
        if (!_state.isAppActive && _state.isPaused) {
          _updateState(_state.updateAppActive(true));
          play();
        }
        break;

      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Stop everything when app is detached
        stop();
        break;
    }
  }

  // Persistence methods

  /// Clear all viewed stories from persistence
  Future<void> clearAllViewedStories() async {
    if (enablePersistence) {
      await _viewStateManager.clearAllViewStates();
    }
  }

  /// Clear viewed stories for a specific user
  Future<void> clearUserViewedStories(String userId) async {
    if (enablePersistence) {
      await _viewStateManager.clearUserViewStates(userId);
    }
  }

  /// Get view statistics for current story list
  ViewStatistics? getViewStatistics() {
    if (!enablePersistence) {
      return null;
    }
    return _viewStateManager.getStatistics(_state.storyList);
  }

  /// Get unviewed count for current user's stories
  int getUnviewedCount() {
    if (!enablePersistence) {
      return _state.storyList.totalUnviewedCount;
    }

    final currentGroup = _state.storyList.findGroupContainingStory(
      _state.currentStoryId ?? '',
    );

    if (currentGroup != null) {
      return _viewStateManager.getUnviewedCount(currentGroup);
    }

    return 0;
  }

  /// Check if a specific story has been viewed
  bool isStoryViewed(String storyId) {
    if (!enablePersistence) {
      final story = _state.storyList.findStoryById(storyId);
      return story?.isViewed ?? false;
    }

    return _viewStateManager.isStoryViewed(storyId);
  }

  /// Export view state data for debugging or migration
  Future<Map<String, dynamic>> exportViewState() async {
    if (!enablePersistence) {
      return {};
    }

    return await _viewStateManager.exportViewStates();
  }

  /// Import view state data
  Future<void> importViewState(Map<String, dynamic> data) async {
    if (enablePersistence) {
      await _viewStateManager.importViewStates(data);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _stopProgressTimer();

    // Dispose all video controllers
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();

    // Dispose view state manager resources
    if (enablePersistence) {
      _viewStateManager.dispose();
    }

    super.dispose();
  }
}
