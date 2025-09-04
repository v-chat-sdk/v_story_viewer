import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/v_story_models.dart';
import '../controllers/v_video_controller_manager.dart';

/// Preloading strategy for videos
enum VPreloadStrategy {
  /// Preload next video only
  next,
  
  /// Preload next and previous videos
  adjacent,
  
  /// Preload multiple videos ahead
  aggressive,
  
  /// No preloading
  none,
}

/// Configuration for video preloading
class VPreloadConfig {
  /// Preloading strategy
  final VPreloadStrategy strategy;
  
  /// Number of videos to preload ahead
  final int preloadAhead;
  
  /// Number of videos to preload behind
  final int preloadBehind;
  
  /// Whether to preload in background
  final bool backgroundPreload;
  
  /// Minimum buffer before preloading
  final Duration minBufferBeforePreload;
  
  /// Maximum concurrent preloads
  final int maxConcurrentPreloads;
  
  /// Creates a preload configuration
  const VPreloadConfig({
    this.strategy = VPreloadStrategy.next,
    this.preloadAhead = 1,
    this.preloadBehind = 0,
    this.backgroundPreload = true,
    this.minBufferBeforePreload = const Duration(seconds: 2),
    this.maxConcurrentPreloads = 2,
  });
  
  /// Creates an aggressive preload configuration
  factory VPreloadConfig.aggressive() => const VPreloadConfig(
    strategy: VPreloadStrategy.aggressive,
    preloadAhead: 3,
    preloadBehind: 1,
    backgroundPreload: true,
    maxConcurrentPreloads: 3,
  );
  
  /// Creates a conservative preload configuration
  factory VPreloadConfig.conservative() => const VPreloadConfig(
    strategy: VPreloadStrategy.next,
    preloadAhead: 1,
    preloadBehind: 0,
    backgroundPreload: false,
    maxConcurrentPreloads: 1,
  );
  
  /// Creates a no-preload configuration
  factory VPreloadConfig.none() => const VPreloadConfig(
    strategy: VPreloadStrategy.none,
    preloadAhead: 0,
    preloadBehind: 0,
    backgroundPreload: false,
    maxConcurrentPreloads: 0,
  );
}

/// Service for managing video preloading
class VVideoPreloader extends ChangeNotifier {
  /// Configuration for preloading
  final VPreloadConfig config;
  
  /// Video controller manager
  final VVideoControllerManager _controllerManager;
  
  /// Current preloading queue
  final List<VVideoStory> _preloadQueue = [];
  
  /// Currently preloading stories
  final Set<String> _preloadingStories = {};
  
  /// Preload completion status
  final Map<String, bool> _preloadStatus = {};
  
  /// Preload timers
  final Map<String, Timer> _preloadTimers = {};
  
  /// Current story index
  int _currentIndex = 0;
  
  /// All stories
  List<VVideoStory> _stories = [];
  
  /// Whether preloader is active
  bool _isActive = false;
  
  /// Disposal flag
  bool _disposed = false;
  
  /// Gets whether preloader is active
  bool get isActive => _isActive;
  
  /// Gets current preload queue
  List<VVideoStory> get preloadQueue => List.unmodifiable(_preloadQueue);
  
  /// Gets preloading stories
  Set<String> get preloadingStories => Set.unmodifiable(_preloadingStories);
  
  /// Creates a video preloader
  VVideoPreloader({
    required VVideoControllerManager controllerManager,
    this.config = const VPreloadConfig(),
  }) : _controllerManager = controllerManager;
  
  /// Initializes preloader with stories
  void initialize(List<VVideoStory> stories, int currentIndex) {
    if (_disposed) return;
    
    _stories = stories;
    _currentIndex = currentIndex;
    _isActive = true;
    
    _updatePreloadQueue();
    _startPreloading();
    
    notifyListeners();
  }
  
  /// Updates current story index
  void updateCurrentIndex(int index) {
    if (_disposed || index == _currentIndex) return;
    
    _currentIndex = index;
    _updatePreloadQueue();
    _startPreloading();
    
    notifyListeners();
  }
  
  /// Updates the preload queue based on current index
  void _updatePreloadQueue() {
    _preloadQueue.clear();
    
    if (config.strategy == VPreloadStrategy.none) {
      return;
    }
    
    // Add stories to preload based on strategy
    switch (config.strategy) {
      case VPreloadStrategy.next:
        _addNextStories();
        break;
      case VPreloadStrategy.adjacent:
        _addAdjacentStories();
        break;
      case VPreloadStrategy.aggressive:
        _addAggressiveStories();
        break;
      case VPreloadStrategy.none:
        break;
    }
  }
  
  /// Adds next stories to preload queue
  void _addNextStories() {
    for (int i = 1; i <= config.preloadAhead; i++) {
      final index = _currentIndex + i;
      if (index < _stories.length) {
        _preloadQueue.add(_stories[index]);
      }
    }
  }
  
  /// Adds adjacent stories to preload queue
  void _addAdjacentStories() {
    // Add next stories
    _addNextStories();
    
    // Add previous stories
    for (int i = 1; i <= config.preloadBehind; i++) {
      final index = _currentIndex - i;
      if (index >= 0) {
        _preloadQueue.add(_stories[index]);
      }
    }
  }
  
  /// Adds stories for aggressive preloading
  void _addAggressiveStories() {
    // Add all stories within range
    for (int i = _currentIndex - config.preloadBehind;
         i <= _currentIndex + config.preloadAhead;
         i++) {
      if (i >= 0 && i < _stories.length && i != _currentIndex) {
        _preloadQueue.add(_stories[i]);
      }
    }
  }
  
  /// Starts preloading process
  void _startPreloading() {
    if (_disposed || !_isActive) return;
    
    // Cancel existing timers
    _cancelAllTimers();
    
    // Start preloading based on configuration
    if (config.backgroundPreload) {
      _startBackgroundPreloading();
    } else {
      _startImmediatePreloading();
    }
  }
  
  /// Starts immediate preloading
  void _startImmediatePreloading() {
    int concurrent = 0;
    
    for (final story in _preloadQueue) {
      if (concurrent >= config.maxConcurrentPreloads) break;
      if (_shouldPreload(story)) {
        _preloadStory(story);
        concurrent++;
      }
    }
  }
  
  /// Starts background preloading with delays
  void _startBackgroundPreloading() {
    int delay = 0;
    int concurrent = 0;
    
    for (final story in _preloadQueue) {
      if (concurrent >= config.maxConcurrentPreloads) break;
      if (_shouldPreload(story)) {
        final timer = Timer(
          Duration(milliseconds: delay),
          () => _preloadStory(story),
        );
        _preloadTimers[story.id] = timer;
        delay += 500; // Stagger preloads
        concurrent++;
      }
    }
  }
  
  /// Checks if a story should be preloaded
  bool _shouldPreload(VVideoStory story) {
    return !_preloadingStories.contains(story.id) &&
           !_preloadStatus.containsKey(story.id);
  }
  
  /// Preloads a single story
  Future<void> _preloadStory(VVideoStory story) async {
    if (_disposed || !_isActive) return;
    
    _preloadingStories.add(story.id);
    notifyListeners();
    
    try {
      await _controllerManager.loadVideo(story);
      _preloadStatus[story.id] = true;
    } catch (e) {
      _preloadStatus[story.id] = false;
      debugPrint('Error preloading video ${story.id}: $e');
    } finally {
      _preloadingStories.remove(story.id);
      _preloadTimers.remove(story.id);
      notifyListeners();
    }
  }
  
  /// Cancels all preload timers
  void _cancelAllTimers() {
    for (final timer in _preloadTimers.values) {
      timer.cancel();
    }
    _preloadTimers.clear();
  }
  
  /// Pauses preloading
  void pause() {
    if (_disposed) return;
    
    _isActive = false;
    _cancelAllTimers();
    notifyListeners();
  }
  
  /// Resumes preloading
  void resume() {
    if (_disposed) return;
    
    _isActive = true;
    _startPreloading();
    notifyListeners();
  }
  
  /// Clears preload queue
  void clearQueue() {
    if (_disposed) return;
    
    _preloadQueue.clear();
    _preloadingStories.clear();
    _cancelAllTimers();
    notifyListeners();
  }
  
  /// Gets preload status for a story
  bool? getPreloadStatus(String storyId) {
    return _preloadStatus[storyId];
  }
  
  /// Checks if a story is preloading
  bool isPreloading(String storyId) {
    return _preloadingStories.contains(storyId);
  }
  
  /// Gets preload progress
  double get preloadProgress {
    if (_preloadQueue.isEmpty) return 1.0;
    
    final completed = _preloadQueue
        .where((story) => _preloadStatus[story.id] == true)
        .length;
    
    return completed / _preloadQueue.length;
  }
  
  /// Disposes the preloader
  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    
    _cancelAllTimers();
    _preloadQueue.clear();
    _preloadingStories.clear();
    _preloadStatus.clear();
    _stories.clear();
    
    super.dispose();
  }
}