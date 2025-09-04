import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/v_story_models.dart';
import 'v_cache_manager.dart';

/// Manages video controller lifecycle and memory.
class VMemoryManager {
  /// Singleton instance
  static final VMemoryManager _instance = VMemoryManager._internal();
  
  /// Factory constructor
  factory VMemoryManager() => _instance;
  
  /// Private constructor
  VMemoryManager._internal();
  
  /// Maximum number of cached video controllers
  static const int maxCachedControllers = 3;
  
  /// Active video controllers
  final Map<String, VideoPlayerController> _controllers = {};
  
  /// Controller initialization status
  final Map<String, bool> _initializationStatus = {};
  
  /// Controller access order for LRU cache
  final List<String> _accessOrder = [];
  
  /// Cache manager instance
  final VCacheManager _cacheManager = VCacheManager();
  
  /// Stream controller for video events
  final StreamController<VVideoEvent> _eventController = 
      StreamController<VVideoEvent>.broadcast();
  
  /// Stream of video events
  Stream<VVideoEvent> get eventStream => _eventController.stream;
  
  /// Gets or creates a video controller for a story
  Future<VideoPlayerController?> getVideoController(VVideoStory story) async {
    // Check if controller already exists
    if (_controllers.containsKey(story.id)) {
      _updateAccessOrder(story.id);
      return _controllers[story.id];
    }
    
    // Clean up old controllers if needed
    await _enforceMemoryLimit();
    
    try {
      // Create new controller based on source
      VideoPlayerController? controller;
      
      if (story.url != null) {
        // Network video - use cache manager
        final file = await _cacheManager.getCachedFile(story.url!);
        controller = VideoPlayerController.file(file);
      } else if (story.assetPath != null) {
        // Asset video
        controller = VideoPlayerController.asset(story.assetPath!);
      } else if (story.file != null) {
        // Local file video
        controller = VideoPlayerController.file(File(story.file!));
      }
      
      if (controller != null) {
        // Initialize controller
        await _initializeController(controller, story.id);
        
        // Store controller
        _controllers[story.id] = controller;
        _updateAccessOrder(story.id);
        
        // Emit event
        _eventController.add(VVideoEvent.initialized(story.id, controller));
        
        return controller;
      }
    } catch (error) {
      debugPrint('Failed to create video controller for ${story.id}: $error');
      _eventController.add(VVideoEvent.error(story.id, error));
    }
    
    return null;
  }
  
  /// Initializes a video controller
  Future<void> _initializeController(
    VideoPlayerController controller,
    String storyId,
  ) async {
    _initializationStatus[storyId] = false;
    
    try {
      await controller.initialize();
      _initializationStatus[storyId] = true;
      
      // Set looping to false for stories
      await controller.setLooping(false);
      
      // Prepare video for playback
      await controller.setVolume(1.0);
    } catch (error) {
      debugPrint('Failed to initialize video controller: $error');
      rethrow;
    }
  }
  
  /// Updates access order for LRU cache
  void _updateAccessOrder(String storyId) {
    _accessOrder.remove(storyId);
    _accessOrder.add(storyId);
  }
  
  /// Enforces memory limit by removing least recently used controllers
  Future<void> _enforceMemoryLimit() async {
    while (_controllers.length >= maxCachedControllers && _accessOrder.isNotEmpty) {
      final oldestId = _accessOrder.first;
      await disposeController(oldestId);
    }
  }
  
  /// Plays a video
  Future<void> playVideo(String storyId) async {
    final controller = _controllers[storyId];
    if (controller != null && _initializationStatus[storyId] == true) {
      await controller.play();
      _eventController.add(VVideoEvent.playing(storyId));
    }
  }
  
  /// Pauses a video
  Future<void> pauseVideo(String storyId) async {
    final controller = _controllers[storyId];
    if (controller != null) {
      await controller.pause();
      _eventController.add(VVideoEvent.paused(storyId));
    }
  }
  
  /// Stops a video
  Future<void> stopVideo(String storyId) async {
    final controller = _controllers[storyId];
    if (controller != null) {
      await controller.pause();
      await controller.seekTo(Duration.zero);
      _eventController.add(VVideoEvent.stopped(storyId));
    }
  }
  
  /// Sets video volume
  Future<void> setVolume(String storyId, double volume) async {
    final controller = _controllers[storyId];
    if (controller != null) {
      await controller.setVolume(volume.clamp(0.0, 1.0));
    }
  }
  
  /// Mutes/unmutes all videos
  Future<void> setMutedAll(bool muted) async {
    final volume = muted ? 0.0 : 1.0;
    for (final controller in _controllers.values) {
      await controller.setVolume(volume);
    }
    _eventController.add(VVideoEvent.muteChanged(muted));
  }
  
  /// Gets video duration
  Duration? getVideoDuration(String storyId) {
    final controller = _controllers[storyId];
    if (controller != null && controller.value.isInitialized) {
      return controller.value.duration;
    }
    return null;
  }
  
  /// Gets video position
  Duration? getVideoPosition(String storyId) {
    final controller = _controllers[storyId];
    if (controller != null && controller.value.isInitialized) {
      return controller.value.position;
    }
    return null;
  }
  
  /// Disposes a specific video controller
  Future<void> disposeController(String storyId) async {
    final controller = _controllers[storyId];
    if (controller != null) {
      await controller.dispose();
      _controllers.remove(storyId);
      _initializationStatus.remove(storyId);
      _accessOrder.remove(storyId);
      _eventController.add(VVideoEvent.disposed(storyId));
    }
  }
  
  /// Tracks a video controller (for external management)
  void trackVideoController(String id, VideoPlayerController controller) {
    _controllers[id] = controller;
    _initializationStatus[id] = controller.value.isInitialized;
    _accessOrder.add(id);
  }
  
  /// Releases a specific video controller
  void releaseVideoController(String id) {
    disposeController(id);
  }
  
  /// Releases all video controllers
  void releaseAllVideoControllers() {
    disposeAll();
  }
  
  /// Disposes all video controllers
  Future<void> disposeAll() async {
    for (final storyId in _controllers.keys.toList()) {
      await disposeController(storyId);
    }
  }
  
  /// Preloads video controllers for upcoming stories
  Future<void> preloadVideos(List<VVideoStory> stories) async {
    // Preload up to 2 upcoming videos
    final toPreload = stories.take(2);
    
    for (final story in toPreload) {
      if (!_controllers.containsKey(story.id)) {
        // Preload in background
        getVideoController(story).then((_) {
          debugPrint('Preloaded video for story ${story.id}');
        }).catchError((error) {
          debugPrint('Failed to preload video: $error');
        });
      }
    }
  }
  
  /// Cleans up resources
  void dispose() {
    disposeAll();
    _eventController.close();
  }
}

/// Video event types
enum VVideoEventType {
  initialized,
  playing,
  paused,
  stopped,
  disposed,
  error,
  muteChanged,
}

/// Video event data
class VVideoEvent {
  /// Event type
  final VVideoEventType type;
  
  /// Story ID
  final String? storyId;
  
  /// Video controller (for initialized event)
  final VideoPlayerController? controller;
  
  /// Error (for error event)
  final Object? error;
  
  /// Mute state (for muteChanged event)
  final bool? isMuted;
  
  /// Creates a video event
  const VVideoEvent({
    required this.type,
    this.storyId,
    this.controller,
    this.error,
    this.isMuted,
  });
  
  /// Creates an initialized event
  factory VVideoEvent.initialized(String storyId, VideoPlayerController controller) {
    return VVideoEvent(
      type: VVideoEventType.initialized,
      storyId: storyId,
      controller: controller,
    );
  }
  
  /// Creates a playing event
  factory VVideoEvent.playing(String storyId) {
    return VVideoEvent(
      type: VVideoEventType.playing,
      storyId: storyId,
    );
  }
  
  /// Creates a paused event
  factory VVideoEvent.paused(String storyId) {
    return VVideoEvent(
      type: VVideoEventType.paused,
      storyId: storyId,
    );
  }
  
  /// Creates a stopped event
  factory VVideoEvent.stopped(String storyId) {
    return VVideoEvent(
      type: VVideoEventType.stopped,
      storyId: storyId,
    );
  }
  
  /// Creates a disposed event
  factory VVideoEvent.disposed(String storyId) {
    return VVideoEvent(
      type: VVideoEventType.disposed,
      storyId: storyId,
    );
  }
  
  /// Creates an error event
  factory VVideoEvent.error(String storyId, Object error) {
    return VVideoEvent(
      type: VVideoEventType.error,
      storyId: storyId,
      error: error,
    );
  }
  
  /// Creates a mute changed event
  factory VVideoEvent.muteChanged(bool isMuted) {
    return VVideoEvent(
      type: VVideoEventType.muteChanged,
      isMuted: isMuted,
    );
  }
}

/// Video controller synchronization with story state
class VVideoSync {
  /// Memory manager instance
  final VMemoryManager _memoryManager = VMemoryManager();
  
  /// Synchronizes video with story play state
  Future<void> syncPlay(String storyId) async {
    await _memoryManager.playVideo(storyId);
  }
  
  /// Synchronizes video with story pause state
  Future<void> syncPause(String storyId) async {
    await _memoryManager.pauseVideo(storyId);
  }
  
  /// Synchronizes video with story stop state
  Future<void> syncStop(String storyId) async {
    await _memoryManager.stopVideo(storyId);
  }
  
  /// Synchronizes mute state
  Future<void> syncMute(bool muted) async {
    await _memoryManager.setMutedAll(muted);
  }
  
  /// Gets video duration for story
  Duration? getStoryDuration(VVideoStory story) {
    // Use max duration from model if available
    if (story.maxDuration != null) {
      return story.maxDuration;
    }
    
    // Use story duration if available
    if (story.duration != Duration.zero) {
      return story.duration;
    }
    
    // Try to get duration from controller
    return _memoryManager.getVideoDuration(story.id);
  }
  
  /// Cleans up resources
  void dispose() {
    _memoryManager.disposeAll();
  }
}