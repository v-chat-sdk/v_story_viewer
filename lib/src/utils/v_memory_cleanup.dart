import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../models/v_story_models.dart';
import 'v_error_logger.dart';

/// Memory cleanup manager for story viewer
class VMemoryCleanup {
  /// Singleton instance
  static final VMemoryCleanup _instance = VMemoryCleanup._internal();
  
  /// Factory constructor
  factory VMemoryCleanup() => _instance;
  
  /// Private constructor
  VMemoryCleanup._internal();
  
  /// Cleanup configuration
  static const int maxDismissedStories = 5;
  static const Duration cleanupDelay = Duration(seconds: 5);
  static const Duration cacheExpiration = Duration(hours: 24);
  
  /// Dismissed stories tracking
  final List<String> _dismissedStoryIds = [];
  final Map<String, Timer> _cleanupTimers = {};
  final Map<String, DateTime> _dismissalTimes = {};
  
  /// Cache manager reference
  CacheManager? _cacheManager;
  
  /// Cleanup listeners
  final List<void Function(String storyId)> _cleanupListeners = [];
  
  /// Initialize with cache manager
  void initialize(CacheManager cacheManager) {
    _cacheManager = cacheManager;
  }
  
  /// Mark story as dismissed
  void markStoryDismissed(VBaseStory story) {
    final storyId = story.id;
    
    // Track dismissal
    if (!_dismissedStoryIds.contains(storyId)) {
      _dismissedStoryIds.add(storyId);
      _dismissalTimes[storyId] = DateTime.now();
    }
    
    // Schedule cleanup
    _scheduleCleanup(story);
    
    // Check if we need immediate cleanup
    if (_dismissedStoryIds.length > maxDismissedStories) {
      _performImmediateCleanup();
    }
    
    // Log dismissal
    VErrorLogger.logDebug(
      'Story dismissed',
      extra: {
        'storyId': storyId,
        'dismissedCount': _dismissedStoryIds.length,
      },
    );
  }
  
  /// Mark story as active (cancel cleanup)
  void markStoryActive(String storyId) {
    // Cancel scheduled cleanup
    _cleanupTimers[storyId]?.cancel();
    _cleanupTimers.remove(storyId);
    
    // Remove from dismissed list
    _dismissedStoryIds.remove(storyId);
    _dismissalTimes.remove(storyId);
  }
  
  /// Schedule cleanup for a story
  void _scheduleCleanup(VBaseStory story) {
    final storyId = story.id;
    
    // Cancel existing timer
    _cleanupTimers[storyId]?.cancel();
    
    // Schedule new cleanup
    _cleanupTimers[storyId] = Timer(cleanupDelay, () {
      _cleanupStory(story);
      _cleanupTimers.remove(storyId);
    });
  }
  
  /// Cleanup a specific story
  Future<void> _cleanupStory(VBaseStory story) async {
    try {
      // Clean up based on story type
      if (story is VMediaStory) {
        await _cleanupMediaStory(story);
      }
      
      // Notify listeners
      for (final listener in _cleanupListeners) {
        try {
          listener(story.id);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error in cleanup listener: $e');
          }
        }
      }
      
      // Log cleanup
      VErrorLogger.logDebug(
        'Story cleaned up',
        extra: {'storyId': story.id},
      );
    } catch (e) {
      VErrorLogger.logWarning(
        'Failed to cleanup story',
        error: e,
        extra: {'storyId': story.id},
      );
    }
  }
  
  /// Clean up media story resources
  Future<void> _cleanupMediaStory(VMediaStory story) async {
    if (_cacheManager == null) return;
    
    // Get cache key for the media
    final cacheKey = story.media.getCachedUrlKey;
    if (cacheKey.isEmpty) return;
    
    // Remove from cache if expired
    final dismissalTime = _dismissalTimes[story.id];
    if (dismissalTime != null) {
      final age = DateTime.now().difference(dismissalTime);
      if (age > cacheExpiration) {
        await _cacheManager!.removeFile(cacheKey);
      }
    }
  }
  
  /// Perform immediate cleanup of oldest dismissed stories
  void _performImmediateCleanup() {
    // Sort by dismissal time
    final sortedIds = List<String>.from(_dismissedStoryIds)
      ..sort((a, b) {
        final timeA = _dismissalTimes[a] ?? DateTime.now();
        final timeB = _dismissalTimes[b] ?? DateTime.now();
        return timeA.compareTo(timeB);
      });
    
    // Clean up oldest stories
    final toCleanup = sortedIds.length - maxDismissedStories;
    for (int i = 0; i < toCleanup && i < sortedIds.length; i++) {
      final storyId = sortedIds[i];
      
      // Cancel timer
      _cleanupTimers[storyId]?.cancel();
      _cleanupTimers.remove(storyId);
      
      // Remove from tracking
      _dismissedStoryIds.remove(storyId);
      _dismissalTimes.remove(storyId);
      
      // Notify listeners
      for (final listener in _cleanupListeners) {
        try {
          listener(storyId);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error in cleanup listener: $e');
          }
        }
      }
    }
    
    VErrorLogger.logDebug(
      'Immediate cleanup performed',
      extra: {'cleanedCount': toCleanup},
    );
  }
  
  /// Clean up all expired cache entries
  Future<void> cleanupExpiredCache() async {
    if (_cacheManager == null) return;
    
    try {
      await _cacheManager!.emptyCache();
      
      VErrorLogger.logInfo(
        'Cache cleaned up',
        extra: {'timestamp': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      VErrorLogger.logWarning(
        'Failed to cleanup cache',
        error: e,
      );
    }
  }
  
  /// Force cleanup of all dismissed stories
  Future<void> forceCleanupAll() async {
    // Cancel all timers
    for (final timer in _cleanupTimers.values) {
      timer.cancel();
    }
    _cleanupTimers.clear();
    
    // Clear tracking
    _dismissedStoryIds.clear();
    _dismissalTimes.clear();
    
    // Clean cache if available
    if (_cacheManager != null) {
      await cleanupExpiredCache();
    }
    
    VErrorLogger.logInfo('Forced cleanup completed');
  }
  
  /// Add cleanup listener
  void addCleanupListener(void Function(String storyId) listener) {
    _cleanupListeners.add(listener);
  }
  
  /// Remove cleanup listener
  void removeCleanupListener(void Function(String storyId) listener) {
    _cleanupListeners.remove(listener);
  }
  
  /// Get cleanup statistics
  Map<String, dynamic> getCleanupStats() {
    return {
      'dismissedStories': _dismissedStoryIds.length,
      'pendingCleanups': _cleanupTimers.length,
      'maxDismissedStories': maxDismissedStories,
      'cleanupDelaySeconds': cleanupDelay.inSeconds,
      'cacheExpirationHours': cacheExpiration.inHours,
    };
  }
  
  /// Dispose
  void dispose() {
    // Cancel all timers
    for (final timer in _cleanupTimers.values) {
      timer.cancel();
    }
    _cleanupTimers.clear();
    
    // Clear listeners
    _cleanupListeners.clear();
    
    // Clear tracking
    _dismissedStoryIds.clear();
    _dismissalTimes.clear();
  }
}