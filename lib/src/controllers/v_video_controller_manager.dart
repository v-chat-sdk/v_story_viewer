import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import '../models/v_story_models.dart';
import '../services/v_memory_manager.dart';

/// Configuration for video controller management
class VVideoControllerConfig {
  /// Maximum number of cached video controllers
  final int maxCachedControllers;
  
  /// Whether to preload next video
  final bool preloadNext;
  
  /// Whether to preload previous video
  final bool preloadPrevious;
  
  /// Auto play videos
  final bool autoPlay;
  
  /// Default volume
  final double defaultVolume;
  
  /// Whether to loop videos
  final bool loopVideos;
  
  /// Buffer size for preloading
  final Duration bufferDuration;
  
  /// Creates a video controller configuration
  const VVideoControllerConfig({
    this.maxCachedControllers = 3,
    this.preloadNext = true,
    this.preloadPrevious = false,
    this.autoPlay = true,
    this.defaultVolume = 1.0,
    this.loopVideos = false,
    this.bufferDuration = const Duration(seconds: 2),
  });
}

/// Manages video controllers with resource optimization
class VVideoControllerManager extends ChangeNotifier {
  /// Configuration for video management
  final VVideoControllerConfig config;
  
  /// Memory manager for resource tracking
  final VMemoryManager _memoryManager;
  
  /// Cache of video controllers
  final Map<String, VideoPlayerController> _controllers = {};
  
  /// Currently active controller
  VideoPlayerController? _activeController;
  
  /// Preloading controllers
  final Set<String> _preloadingControllers = {};
  
  /// Error states for videos
  final Map<String, String> _errorStates = {};
  
  /// Video durations cache
  final Map<String, Duration> _durations = {};
  
  /// Initialization completers
  final Map<String, Completer<void>> _initCompleters = {};
  
  /// Current volume level
  double _volume;
  
  /// Whether videos are muted
  bool _isMuted = false;
  
  /// Disposal flag
  bool _disposed = false;
  
  /// Gets the current volume
  double get volume => _volume;
  
  /// Gets whether videos are muted
  bool get isMuted => _isMuted;
  
  /// Gets the active controller
  VideoPlayerController? get activeController => _activeController;
  
  /// Creates a video controller manager
  VVideoControllerManager({
    this.config = const VVideoControllerConfig(),
    VMemoryManager? memoryManager,
  }) : _memoryManager = memoryManager ?? VMemoryManager(),
       _volume = config.defaultVolume;
  
  /// Loads a video controller for a story
  Future<VideoPlayerController?> loadVideo(VVideoStory story) async {
    if (_disposed) return null;
    
    final storyId = story.id;
    
    // Check if already loaded
    if (_controllers.containsKey(storyId)) {
      final controller = _controllers[storyId]!;
      if (controller.value.isInitialized) {
        return controller;
      }
    }
    
    // Check for errors
    if (_errorStates.containsKey(storyId)) {
      return null;
    }
    
    // Create and initialize controller
    try {
      final controller = await _createController(story);
      if (controller != null) {
        await _initializeController(controller, storyId);
        _controllers[storyId] = controller;
        _manageCacheSize();
        notifyListeners();
        return controller;
      }
    } catch (e) {
      _errorStates[storyId] = e.toString();
    }
    
    return null;
  }
  
  /// Creates a video controller for a story
  Future<VideoPlayerController?> _createController(VVideoStory story) async {
    final media = story.media;
    
    VideoPlayerController? controller;
    
    if (media.networkUrl != null) {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(media.networkUrl!),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
      );
    } else if (media.fileLocalPath != null) {
      controller = VideoPlayerController.file(
        File(media.fileLocalPath!),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
      );
    } else if (media.assetsPath != null) {
      controller = VideoPlayerController.asset(
        media.assetsPath!,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
      );
    }
    
    return controller;
  }
  
  /// Initializes a video controller
  Future<void> _initializeController(
    VideoPlayerController controller,
    String storyId,
  ) async {
    // Check if already initializing
    if (_initCompleters.containsKey(storyId)) {
      await _initCompleters[storyId]!.future;
      return;
    }
    
    // Create completer for initialization
    final completer = Completer<void>();
    _initCompleters[storyId] = completer;
    
    try {
      // Initialize controller
      await controller.initialize();
      
      // Set volume
      await controller.setVolume(_isMuted ? 0.0 : _volume);
      
      // Set looping
      await controller.setLooping(config.loopVideos);
      
      // Cache duration
      _durations[storyId] = controller.value.duration;
      
      // Track in memory manager
      _memoryManager.trackVideoController(storyId, controller);
      
      completer.complete();
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _initCompleters.remove(storyId);
    }
  }
  
  /// Plays a video
  Future<void> playVideo(String storyId) async {
    if (_disposed) return;
    
    final controller = _controllers[storyId];
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    
    // Pause previous active controller
    if (_activeController != null && _activeController != controller) {
      await _activeController!.pause();
    }
    
    // Set as active and play
    _activeController = controller;
    await controller.play();
    notifyListeners();
  }
  
  /// Pauses a video
  Future<void> pauseVideo(String storyId) async {
    if (_disposed) return;
    
    final controller = _controllers[storyId];
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    
    await controller.pause();
    notifyListeners();
  }
  
  /// Seeks to a position in the video
  Future<void> seekTo(String storyId, Duration position) async {
    if (_disposed) return;
    
    final controller = _controllers[storyId];
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    
    await controller.seekTo(position);
    notifyListeners();
  }
  
  /// Preloads videos for smooth playback
  Future<void> preloadVideos(
    List<VVideoStory> stories,
    int currentIndex,
  ) async {
    if (_disposed || !config.preloadNext) return;
    
    // Preload next video
    if (config.preloadNext && currentIndex < stories.length - 1) {
      final nextStory = stories[currentIndex + 1];
      if (!_controllers.containsKey(nextStory.id) &&
          !_preloadingControllers.contains(nextStory.id)) {
        _preloadingControllers.add(nextStory.id);
        loadVideo(nextStory).then((_) {
          _preloadingControllers.remove(nextStory.id);
        });
      }
    }
    
    // Preload previous video
    if (config.preloadPrevious && currentIndex > 0) {
      final prevStory = stories[currentIndex - 1];
      if (!_controllers.containsKey(prevStory.id) &&
          !_preloadingControllers.contains(prevStory.id)) {
        _preloadingControllers.add(prevStory.id);
        loadVideo(prevStory).then((_) {
          _preloadingControllers.remove(prevStory.id);
        });
      }
    }
  }
  
  /// Manages cache size to prevent memory issues
  void _manageCacheSize() {
    if (_controllers.length <= config.maxCachedControllers) {
      return;
    }
    
    // Find controllers to remove (not active, not preloading)
    final toRemove = <String>[];
    for (final entry in _controllers.entries) {
      if (entry.value != _activeController &&
          !_preloadingControllers.contains(entry.key)) {
        toRemove.add(entry.key);
        if (_controllers.length - toRemove.length <= config.maxCachedControllers) {
          break;
        }
      }
    }
    
    // Remove excess controllers
    for (final storyId in toRemove) {
      disposeController(storyId);
    }
  }
  
  /// Sets the volume for all videos
  Future<void> setVolume(double volume) async {
    if (_disposed) return;
    
    _volume = volume.clamp(0.0, 1.0);
    _isMuted = false;
    
    // Update all controllers
    for (final controller in _controllers.values) {
      if (controller.value.isInitialized) {
        await controller.setVolume(_volume);
      }
    }
    
    notifyListeners();
  }
  
  /// Mutes/unmutes all videos
  Future<void> setMuted(bool muted) async {
    if (_disposed) return;
    
    _isMuted = muted;
    
    // Update all controllers
    for (final controller in _controllers.values) {
      if (controller.value.isInitialized) {
        await controller.setVolume(muted ? 0.0 : _volume);
      }
    }
    
    // Sync with memory manager
    await _memoryManager.setMutedAll(muted);
    
    notifyListeners();
  }
  
  /// Gets the duration of a video
  Duration? getVideoDuration(String storyId) {
    if (_durations.containsKey(storyId)) {
      return _durations[storyId];
    }
    
    final controller = _controllers[storyId];
    if (controller != null && controller.value.isInitialized) {
      _durations[storyId] = controller.value.duration;
      return controller.value.duration;
    }
    
    return null;
  }
  
  /// Gets the current position of a video
  Duration? getVideoPosition(String storyId) {
    final controller = _controllers[storyId];
    if (controller != null && controller.value.isInitialized) {
      return controller.value.position;
    }
    return null;
  }
  
  /// Gets the buffered position of a video
  Duration? getBufferedPosition(String storyId) {
    final controller = _controllers[storyId];
    if (controller != null && controller.value.isInitialized) {
      final buffered = controller.value.buffered;
      if (buffered.isNotEmpty) {
        return buffered.last.end;
      }
    }
    return null;
  }
  
  /// Checks if a video is playing
  bool isPlaying(String storyId) {
    final controller = _controllers[storyId];
    return controller != null &&
        controller.value.isInitialized &&
        controller.value.isPlaying;
  }
  
  /// Checks if a video is buffering
  bool isBuffering(String storyId) {
    final controller = _controllers[storyId];
    return controller != null &&
        controller.value.isInitialized &&
        controller.value.isBuffering;
  }
  
  /// Checks if a video has an error
  bool hasError(String storyId) {
    return _errorStates.containsKey(storyId);
  }
  
  /// Gets the error message for a video
  String? getError(String storyId) {
    return _errorStates[storyId];
  }
  
  /// Clears error state for a video
  void clearError(String storyId) {
    _errorStates.remove(storyId);
    notifyListeners();
  }
  
  /// Disposes a specific controller
  void disposeController(String storyId) {
    final controller = _controllers.remove(storyId);
    if (controller != null) {
      if (controller == _activeController) {
        _activeController = null;
      }
      controller.dispose();
      _memoryManager.releaseVideoController(storyId);
    }
    
    _durations.remove(storyId);
    _errorStates.remove(storyId);
    _preloadingControllers.remove(storyId);
    _initCompleters.remove(storyId);
  }
  
  /// Disposes all controllers
  void disposeAll() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _activeController = null;
    _durations.clear();
    _errorStates.clear();
    _preloadingControllers.clear();
    _initCompleters.clear();
    _memoryManager.releaseAllVideoControllers();
  }
  
  /// Pauses all videos
  Future<void> pauseAll() async {
    if (_disposed) return;
    
    for (final controller in _controllers.values) {
      if (controller.value.isInitialized && controller.value.isPlaying) {
        await controller.pause();
      }
    }
    notifyListeners();
  }
  
  /// Resumes the active video
  Future<void> resumeActive() async {
    if (_disposed || _activeController == null) return;
    
    if (_activeController!.value.isInitialized &&
        !_activeController!.value.isPlaying) {
      await _activeController!.play();
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    
    disposeAll();
    super.dispose();
  }
}