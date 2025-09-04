import 'package:flutter/material.dart';
import '../models/v_story_state.dart';
import '../models/v_story_progress.dart';

/// Manages persistence of story states across widget rebuilds.
/// 
/// This class provides mechanisms to save and restore story states
/// to ensure continuity during widget tree rebuilds.
class VStatePersistence {
  /// Singleton instance
  static final VStatePersistence _instance = VStatePersistence._internal();
  
  /// Factory constructor returns singleton
  factory VStatePersistence() => _instance;
  
  /// Private constructor
  VStatePersistence._internal();
  
  /// In-memory storage for story progress
  final Map<String, VStoryProgress> _progressCache = {};
  
  /// In-memory storage for individual story states  
  final Map<String, VStoryState> _stateCache = {};
  
  /// Timestamp of last access for cleanup
  final Map<String, DateTime> _lastAccess = {};
  
  /// Maximum cache duration (30 minutes)
  static const Duration _maxCacheDuration = Duration(minutes: 30);
  
  /// Saves story progress for a session
  void saveProgress(String sessionId, VStoryProgress progress) {
    _progressCache[sessionId] = progress;
    _lastAccess[sessionId] = DateTime.now();
    _cleanupOldEntries();
  }
  
  /// Retrieves story progress for a session
  VStoryProgress? getProgress(String sessionId) {
    _lastAccess[sessionId] = DateTime.now();
    return _progressCache[sessionId];
  }
  
  /// Saves individual story state
  void saveState(String storyId, VStoryState state) {
    _stateCache[storyId] = state;
    _lastAccess['state_$storyId'] = DateTime.now();
  }
  
  /// Retrieves individual story state
  VStoryState? getState(String storyId) {
    _lastAccess['state_$storyId'] = DateTime.now();
    return _stateCache[storyId];
  }
  
  /// Clears progress for a session
  void clearProgress(String sessionId) {
    _progressCache.remove(sessionId);
    _lastAccess.remove(sessionId);
  }
  
  /// Clears state for a story
  void clearState(String storyId) {
    _stateCache.remove(storyId);
    _lastAccess.remove('state_$storyId');
  }
  
  /// Clears all cached data
  void clearAll() {
    _progressCache.clear();
    _stateCache.clear();
    _lastAccess.clear();
  }
  
  /// Cleans up old entries beyond max cache duration
  void _cleanupOldEntries() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    _lastAccess.forEach((key, time) {
      if (now.difference(time) > _maxCacheDuration) {
        keysToRemove.add(key);
      }
    });
    
    for (final key in keysToRemove) {
      _lastAccess.remove(key);
      
      // Remove from appropriate cache
      if (key.startsWith('state_')) {
        final storyId = key.substring(6);
        _stateCache.remove(storyId);
      } else {
        _progressCache.remove(key);
      }
    }
  }
  
  /// Gets cache statistics
  Map<String, dynamic> getCacheStatistics() {
    return {
      'progressEntries': _progressCache.length,
      'stateEntries': _stateCache.length,
      'totalEntries': _progressCache.length + _stateCache.length,
      'oldestEntry': _getOldestEntry(),
      'newestEntry': _getNewestEntry(),
    };
  }
  
  DateTime? _getOldestEntry() {
    if (_lastAccess.isEmpty) return null;
    return _lastAccess.values.reduce((a, b) => a.isBefore(b) ? a : b);
  }
  
  DateTime? _getNewestEntry() {
    if (_lastAccess.isEmpty) return null;
    return _lastAccess.values.reduce((a, b) => a.isAfter(b) ? a : b);
  }
}

/// Mixin for widgets that need state persistence
mixin VStatePersistenceMixin<T extends StatefulWidget> on State<T> {
  /// Unique session ID for this widget instance
  late final String _sessionId;
  
  /// The persistence manager
  final VStatePersistence _persistence = VStatePersistence();
  
  @override
  void initState() {
    super.initState();
    // Generate unique session ID
    _sessionId = '${widget.runtimeType}_${DateTime.now().millisecondsSinceEpoch}';
    _restoreState();
  }
  
  @override
  void dispose() {
    _saveState();
    super.dispose();
  }
  
  /// Override to provide the progress to save
  VStoryProgress? getProgressToSave() => null;
  
  /// Override to handle restored progress
  void onProgressRestored(VStoryProgress progress) {}
  
  /// Saves the current state
  void _saveState() {
    final progress = getProgressToSave();
    if (progress != null) {
      _persistence.saveProgress(_sessionId, progress);
    }
  }
  
  /// Restores previously saved state
  void _restoreState() {
    final progress = _persistence.getProgress(_sessionId);
    if (progress != null) {
      onProgressRestored(progress);
    }
  }
  
  /// Manually trigger state save
  void persistState() {
    _saveState();
  }
  
  /// Clear persisted state
  void clearPersistedState() {
    _persistence.clearProgress(_sessionId);
  }
}

/// Utility for creating state snapshots
class VStateSnapshot {
  /// Timestamp of the snapshot
  final DateTime timestamp;
  
  /// The story progress at snapshot time
  final VStoryProgress progress;
  
  /// Additional metadata
  final Map<String, dynamic> metadata;
  
  /// Creates a state snapshot
  const VStateSnapshot({
    required this.timestamp,
    required this.progress,
    this.metadata = const {},
  });
  
  /// Creates a snapshot from current progress
  factory VStateSnapshot.fromProgress(
    VStoryProgress progress, {
    Map<String, dynamic>? metadata,
  }) {
    return VStateSnapshot(
      timestamp: DateTime.now(),
      progress: progress,
      metadata: metadata ?? {},
    );
  }
  
  /// Converts snapshot to JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'totalStories': progress.totalStories,
      'viewedStories': progress.viewedStories,
      'currentStoryId': progress.currentStoryId,
      'currentUserId': progress.currentUserId,
      'metadata': metadata,
    };
  }
  
  @override
  String toString() {
    return 'VStateSnapshot(time: $timestamp, progress: ${progress.viewProgress})';
  }
}