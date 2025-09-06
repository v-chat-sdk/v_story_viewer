import '../models/v_story_models.dart';
import 'v_cache_manager.dart';

/// Handles preloading of story media for optimal performance.
class VCachePreloader {
  /// The cache manager instance
  final VCacheManager _cacheManager = VCacheManager();
  
  /// Currently preloading URLs
  final Set<String> _preloadingUrls = {};
  
  /// Preloads stories from a story list
  Future<void> preloadStoryList(
    VStoryList storyList, {
    int maxStories = 5,
  }) async {
    final urls = <String>[];
    int count = 0;
    
    // Collect URLs from unviewed stories first
    for (final group in storyList.groups) {
      for (final story in group.stories) {
        if (count >= maxStories) break;
        
        final url = _getStoryUrl(story);
        if (url != null && !story.isViewed) {
          urls.add(url);
          count++;
        }
      }
      if (count >= maxStories) break;
    }
    
    // Preload the URLs
    if (urls.isNotEmpty) {
      await _preloadUrls(urls);
    }
  }
  
  /// Preloads stories from a specific group
  Future<void> preloadGroup(
    VStoryGroup group, {
    int maxStories = 3,
  }) async {
    final urls = <String>[];
    int count = 0;
    
    for (final story in group.stories) {
      if (count >= maxStories) break;
      
      final url = _getStoryUrl(story);
      if (url != null && !story.isViewed) {
        urls.add(url);
        count++;
      }
    }
    
    if (urls.isNotEmpty) {
      await _preloadUrls(urls);
    }
  }
  
  /// Preloads the next stories after the current one
  Future<void> preloadNextStories(
    VStoryList storyList,
    String currentStoryId, {
    int count = 2,
  }) async {
    final urls = <String>[];
    final currentGroup = storyList.findGroupContainingStory(currentStoryId);
    
    if (currentGroup == null) return;
    
    // Find current story index
    final currentIndex = currentGroup.getStoryIndex(currentStoryId);
    if (currentIndex < 0) return;
    
    // Preload next stories in current group
    for (int i = currentIndex + 1; 
         i < currentGroup.stories.length && urls.length < count; 
         i++) {
      final url = _getStoryUrl(currentGroup.stories[i]);
      if (url != null) {
        urls.add(url);
      }
    }
    
    // If we need more, get from next group
    if (urls.length < count) {
      final nextGroup = storyList.getNextGroup(currentGroup.user.id);
      if (nextGroup != null) {
        for (final story in nextGroup.stories) {
          if (urls.length >= count) break;
          
          final url = _getStoryUrl(story);
          if (url != null) {
            urls.add(url);
          }
        }
      }
    }
    
    if (urls.isNotEmpty) {
      await _preloadUrls(urls);
    }
  }
  
  /// Preloads a single story
  Future<void> preloadStory(VBaseStory story) async {
    final url = _getStoryUrl(story);
    if (url != null) {
      await _preloadUrls([url]);
    }
  }
  
  /// Gets the URL from a story for caching
  String? _getStoryUrl(VBaseStory story) {
    if (story is VImageStory) {
      return story.media.networkUrl;
    } else if (story is VVideoStory) {
      return story.media.networkUrl;
    }
    // Text and custom stories don't need preloading
    return null;
  }
  
  /// Preloads a list of URLs
  Future<void> _preloadUrls(List<String> urls) async {
    // Filter out already preloading URLs
    final urlsToPreload = urls.where((url) => !_preloadingUrls.contains(url)).toList();
    
    if (urlsToPreload.isEmpty) return;
    
    // Mark as preloading
    _preloadingUrls.addAll(urlsToPreload);
    
    try {
      // Use the cache manager to preload
      await _cacheManager.preloadUrls(urlsToPreload);
    } catch (_) {
      // Preload errors are non-critical
    } finally {
      // Remove from preloading set
      _preloadingUrls.removeAll(urlsToPreload);
    }
  }
  
  /// Cancels all preloading operations
  void cancelPreloading() {
    _preloadingUrls.clear();
    // The cache manager will handle cancelling downloads
  }
  
  /// Checks if a story is cached
  Future<bool> isStoryCached(VBaseStory story) async {
    final url = _getStoryUrl(story);
    if (url == null) return true; // Non-media stories are always "cached"
    
    return await _cacheManager.isCached(url);
  }
  
  /// Gets cache status for a story list
  Future<Map<String, bool>> getCacheStatus(VStoryList storyList) async {
    final status = <String, bool>{};
    
    for (final group in storyList.groups) {
      for (final story in group.stories) {
        status[story.id] = await isStoryCached(story);
      }
    }
    
    return status;
  }
}