import 'dart:async';
import 'package:flutter/widgets.dart';
import '../models/v_story_models.dart';
import '../services/v_cache_manager.dart';
import 'v_error_logger.dart';

/// Lazy loading manager for story content
class VLazyLoader {
  /// Maximum stories to preload
  static const int maxPreloadCount = 2;
  
  /// Maximum concurrent downloads
  static const int maxConcurrentDownloads = 3;
  
  /// Story list to manage
  final VStoryList storyList;
  
  /// Cache manager
  final VCacheManager cacheManager;
  
  /// Currently loaded stories
  final Map<String, bool> _loadedStories = {};
  
  /// Currently loading stories
  final Map<String, Completer<void>> _loadingStories = {};
  
  /// Active downloads count
  int _activeDownloads = 0;
  
  /// Preload queue
  final List<String> _preloadQueue = [];
  
  /// Create lazy loader
  VLazyLoader({
    required this.storyList,
    required this.cacheManager,
  });
  
  /// Preload stories around current index
  Future<void> preloadAroundStory(String currentStoryId) async {
    try {
      // Find current story index
      final currentIndex = _findStoryIndex(currentStoryId);
      if (currentIndex == -1) return;
      
      // Clear old preload queue
      _preloadQueue.clear();
      
      // Add stories to preload queue
      _addToPreloadQueue(currentIndex);
      
      // Process preload queue
      await _processPreloadQueue();
    } catch (e) {
      VErrorLogger.logWarning(
        'Failed to preload stories',
        error: e,
        extra: {'currentStoryId': currentStoryId},
      );
    }
  }
  
  /// Find story index in list
  int _findStoryIndex(String storyId) {
    for (int i = 0; i < storyList.groups.length; i++) {
      final group = storyList.groups[i];
      for (int j = 0; j < group.stories.length; j++) {
        if (group.stories[j].id == storyId) {
          return i * 100 + j; // Encode group and story index
        }
      }
    }
    return -1;
  }
  
  /// Add stories to preload queue
  void _addToPreloadQueue(int currentEncodedIndex) {
    final groupIndex = currentEncodedIndex ~/ 100;
    final storyIndex = currentEncodedIndex % 100;
    
    if (groupIndex >= storyList.groups.length) return;
    
    final currentGroup = storyList.groups[groupIndex];
    
    // Add next stories in current group
    for (int i = 1; i <= maxPreloadCount && storyIndex + i < currentGroup.stories.length; i++) {
      final story = currentGroup.stories[storyIndex + i];
      if (!_isLoaded(story.id)) {
        _preloadQueue.add(story.id);
      }
    }
    
    // Add stories from next group if at end of current group
    if (storyIndex == currentGroup.stories.length - 1 && groupIndex + 1 < storyList.groups.length) {
      final nextGroup = storyList.groups[groupIndex + 1];
      for (int i = 0; i < maxPreloadCount && i < nextGroup.stories.length; i++) {
        final story = nextGroup.stories[i];
        if (!_isLoaded(story.id)) {
          _preloadQueue.add(story.id);
        }
      }
    }
  }
  
  /// Process preload queue
  Future<void> _processPreloadQueue() async {
    final futures = <Future>[];
    
    for (final storyId in _preloadQueue) {
      if (_activeDownloads >= maxConcurrentDownloads) {
        // Wait for a slot to become available
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      final story = _findStoryById(storyId);
      if (story != null && story is VMediaStory) {
        futures.add(_preloadStory(story));
      }
    }
    
    // Wait for all preloads to complete or timeout
    if (futures.isNotEmpty) {
      await Future.wait(
        futures,
        eagerError: false,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => [],
      );
    }
  }
  
  /// Find story by ID
  VBaseStory? _findStoryById(String storyId) {
    for (final group in storyList.groups) {
      for (final story in group.stories) {
        if (story.id == storyId) {
          return story;
        }
      }
    }
    return null;
  }
  
  /// Preload a single story
  Future<void> _preloadStory(VMediaStory story) async {
    final storyId = story.id;
    
    // Check if already loaded or loading
    if (_isLoaded(storyId) || _isLoading(storyId)) {
      return;
    }
    
    // Create loading completer
    final completer = Completer<void>();
    _loadingStories[storyId] = completer;
    _activeDownloads++;
    
    try {
      // Download media
      if (story.media.networkUrl != null) {
        await cacheManager.getFile(story.media.networkUrl!);
      }
      
      // Mark as loaded
      _loadedStories[storyId] = true;
      completer.complete();
      
      VErrorLogger.logDebug(
        'Story preloaded',
        extra: {'storyId': storyId},
      );
    } catch (e) {
      completer.completeError(e);
      VErrorLogger.logWarning(
        'Failed to preload story',
        error: e,
        extra: {'storyId': storyId},
      );
    } finally {
      _loadingStories.remove(storyId);
      _activeDownloads--;
    }
  }
  
  /// Check if story is loaded
  bool _isLoaded(String storyId) {
    return _loadedStories[storyId] ?? false;
  }
  
  /// Check if story is currently loading
  bool _isLoading(String storyId) {
    return _loadingStories.containsKey(storyId);
  }
  
  /// Wait for story to load
  Future<void> waitForStory(String storyId) async {
    if (_isLoaded(storyId)) {
      return;
    }
    
    if (_isLoading(storyId)) {
      await _loadingStories[storyId]?.future;
      return;
    }
    
    // Load story if not already loading
    final story = _findStoryById(storyId);
    if (story != null && story is VMediaStory) {
      await _preloadStory(story);
    }
  }
  
  /// Clear loaded stories cache
  void clearCache() {
    _loadedStories.clear();
    _preloadQueue.clear();
  }
  
  /// Dispose
  void dispose() {
    _loadedStories.clear();
    _loadingStories.clear();
    _preloadQueue.clear();
  }
}

/// Widget recycler for optimal performance
class VWidgetRecycler extends StatefulWidget {
  /// Child widget to recycle
  final Widget child;
  
  /// Whether to enable recycling
  final bool enableRecycling;
  
  /// Cache key for this widget
  final String cacheKey;
  
  /// Creates a widget recycler
  const VWidgetRecycler({
    super.key,
    required this.child,
    required this.cacheKey,
    this.enableRecycling = true,
  });
  
  @override
  State<VWidgetRecycler> createState() => _VWidgetRecyclerState();
}

class _VWidgetRecyclerState extends State<VWidgetRecycler> 
    with AutomaticKeepAliveClientMixin {
  /// Widget cache
  static final Map<String, Widget> _widgetCache = {};
  static const int _maxCacheSize = 10;
  
  @override
  bool get wantKeepAlive => widget.enableRecycling;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (!widget.enableRecycling) {
      return widget.child;
    }
    
    // Check cache
    if (_widgetCache.containsKey(widget.cacheKey)) {
      return _widgetCache[widget.cacheKey]!;
    }
    
    // Clean cache if needed
    if (_widgetCache.length >= _maxCacheSize) {
      _cleanCache();
    }
    
    // Cache widget
    _widgetCache[widget.cacheKey] = widget.child;
    
    return widget.child;
  }
  
  /// Clean oldest cache entries
  void _cleanCache() {
    // Simple FIFO cleanup
    final keysToRemove = _widgetCache.keys
        .take(_widgetCache.length - _maxCacheSize + 1)
        .toList();
    
    for (final key in keysToRemove) {
      _widgetCache.remove(key);
    }
  }
  
  @override
  void dispose() {
    // Remove this widget from cache
    _widgetCache.remove(widget.cacheKey);
    super.dispose();
  }
}