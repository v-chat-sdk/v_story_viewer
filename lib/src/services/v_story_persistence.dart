import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages persistence of story view states across app sessions.
/// 
/// This service handles saving and loading story view states,
/// tracking which stories have been viewed, and maintaining
/// progress information across app restarts.
class VStoryPersistence {
  /// Singleton instance
  static final VStoryPersistence _instance = VStoryPersistence._internal();
  
  /// Factory constructor returns singleton
  factory VStoryPersistence() => _instance;
  
  /// Private constructor
  VStoryPersistence._internal();
  
  /// SharedPreferences instance
  SharedPreferences? _prefs;
  
  /// Key prefix for storage
  static const String _keyPrefix = 'v_story_viewer_';
  
  /// Key for viewed stories set
  static const String _viewedStoriesKey = '${_keyPrefix}viewed_stories';
  
  /// Key for story progress map
  static const String _progressKey = '${_keyPrefix}progress';
  
  /// Key for last viewed timestamp
  static const String _lastViewedKey = '${_keyPrefix}last_viewed';
  
  /// Key for user-specific view states
  static const String _userViewStatesKey = '${_keyPrefix}user_states';
  
  /// Initialize persistence service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _cleanExpiredData();
  }
  
  /// Check if story has been viewed
  Future<bool> isStoryViewed(String storyId) async {
    await _ensureInitialized();
    final viewedStories = _prefs!.getStringList(_viewedStoriesKey) ?? [];
    return viewedStories.contains(storyId);
  }
  
  /// Mark story as viewed
  Future<void> markStoryAsViewed(String storyId, {String? userId}) async {
    await _ensureInitialized();
    
    // Add to viewed stories set
    final viewedStories = _prefs!.getStringList(_viewedStoriesKey) ?? [];
    if (!viewedStories.contains(storyId)) {
      viewedStories.add(storyId);
      await _prefs!.setStringList(_viewedStoriesKey, viewedStories);
    }
    
    // Update timestamp
    final timestampKey = '${_keyPrefix}viewed_$storyId';
    await _prefs!.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    
    // Update user-specific view state if userId provided
    if (userId != null) {
      await _updateUserViewState(userId, storyId);
    }
  }
  
  /// Get viewed timestamp for a story
  Future<DateTime?> getViewedTimestamp(String storyId) async {
    await _ensureInitialized();
    final timestampKey = '${_keyPrefix}viewed_$storyId';
    final timestamp = _prefs!.getInt(timestampKey);
    
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }
  
  /// Save partial progress for a story
  Future<void> saveProgress(String storyId, double progress) async {
    await _ensureInitialized();
    
    final progressMap = _loadProgressMap();
    progressMap[storyId] = progress;
    
    final jsonString = jsonEncode(progressMap);
    await _prefs!.setString(_progressKey, jsonString);
  }
  
  /// Get saved progress for a story
  Future<double> getProgress(String storyId) async {
    await _ensureInitialized();
    
    final progressMap = _loadProgressMap();
    return progressMap[storyId] ?? 0.0;
  }
  
  /// Clear progress for a story
  Future<void> clearProgress(String storyId) async {
    await _ensureInitialized();
    
    final progressMap = _loadProgressMap();
    progressMap.remove(storyId);
    
    final jsonString = jsonEncode(progressMap);
    await _prefs!.setString(_progressKey, jsonString);
  }
  
  /// Get all viewed story IDs
  Future<Set<String>> getViewedStoryIds() async {
    await _ensureInitialized();
    final viewedStories = _prefs!.getStringList(_viewedStoriesKey) ?? [];
    return viewedStories.toSet();
  }
  
  /// Get count of unviewed stories for a user
  Future<int> getUnviewedCount(String userId, List<String> storyIds) async {
    await _ensureInitialized();
    final viewedStories = await getViewedStoryIds();
    
    int unviewedCount = 0;
    for (final storyId in storyIds) {
      if (!viewedStories.contains(storyId)) {
        unviewedCount++;
      }
    }
    
    return unviewedCount;
  }
  
  /// Get the first unviewed story ID for a list
  Future<String?> getFirstUnviewedStoryId(List<String> storyIds) async {
    await _ensureInitialized();
    final viewedStories = await getViewedStoryIds();
    
    for (final storyId in storyIds) {
      if (!viewedStories.contains(storyId)) {
        return storyId;
      }
    }
    
    return null; // All stories viewed
  }
  
  /// Clear all viewed stories
  Future<void> clearAllViewedStories() async {
    await _ensureInitialized();
    
    // Clear viewed stories list
    await _prefs!.remove(_viewedStoriesKey);
    
    // Clear progress map
    await _prefs!.remove(_progressKey);
    
    // Clear user states
    await _prefs!.remove(_userViewStatesKey);
    
    // Clear all timestamp keys
    final keys = _prefs!.getKeys();
    for (final key in keys) {
      if (key.startsWith('${_keyPrefix}viewed_')) {
        await _prefs!.remove(key);
      }
    }
  }
  
  /// Clear viewed stories for a specific user
  Future<void> clearUserViewedStories(String userId) async {
    await _ensureInitialized();
    
    final userStates = _loadUserViewStates();
    userStates.remove(userId);
    
    final jsonString = jsonEncode(userStates);
    await _prefs!.setString(_userViewStatesKey, jsonString);
  }
  
  /// Update the last viewed timestamp
  Future<void> updateLastViewed() async {
    await _ensureInitialized();
    await _prefs!.setInt(
      _lastViewedKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
  
  /// Get the last viewed timestamp
  Future<DateTime?> getLastViewed() async {
    await _ensureInitialized();
    final timestamp = _prefs!.getInt(_lastViewedKey);
    
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }
  
  /// Save story list metadata for quick loading
  Future<void> saveStoryMetadata(
    String storyId,
    Map<String, dynamic> metadata,
  ) async {
    await _ensureInitialized();
    
    final metadataKey = '${_keyPrefix}metadata_$storyId';
    final jsonString = jsonEncode(metadata);
    await _prefs!.setString(metadataKey, jsonString);
  }
  
  /// Load story metadata
  Future<Map<String, dynamic>?> loadStoryMetadata(String storyId) async {
    await _ensureInitialized();
    
    final metadataKey = '${_keyPrefix}metadata_$storyId';
    final jsonString = _prefs!.getString(metadataKey);
    
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (_) {
        // Ignore decode errors for corrupt data
      }
    }
    return null;
  }
  
  /// Private helper methods
  
  /// Ensure service is initialized
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }
  
  /// Load progress map from storage
  Map<String, double> _loadProgressMap() {
    final jsonString = _prefs!.getString(_progressKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(jsonString);
        return map.map((key, value) => MapEntry(key, value.toDouble()));
      } catch (_) {
        // Ignore decode errors for corrupt data
      }
    }
    return {};
  }
  
  /// Load user view states from storage
  Map<String, List<String>> _loadUserViewStates() {
    final jsonString = _prefs!.getString(_userViewStatesKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(jsonString);
        return map.map((key, value) => MapEntry(key, List<String>.from(value)));
      } catch (_) {
        // Ignore decode errors for corrupt data
      }
    }
    return {};
  }
  
  /// Update user-specific view state
  Future<void> _updateUserViewState(String userId, String storyId) async {
    final userStates = _loadUserViewStates();
    
    if (!userStates.containsKey(userId)) {
      userStates[userId] = [];
    }
    
    if (!userStates[userId]!.contains(storyId)) {
      userStates[userId]!.add(storyId);
    }
    
    final jsonString = jsonEncode(userStates);
    await _prefs!.setString(_userViewStatesKey, jsonString);
  }
  
  /// Clean expired data (older than 7 days)
  Future<void> _cleanExpiredData() async {
    final now = DateTime.now();
    final expirationDays = 7;
    final keys = _prefs!.getKeys();
    
    for (final key in keys) {
      // Skip the viewed_stories key which stores a StringList, not an int timestamp
      if (key == _viewedStoriesKey) {
        continue;
      }
      
      // Check for individual story timestamp keys
      if (key.startsWith('${_keyPrefix}viewed_')) {
        try {
          final timestamp = _prefs!.getInt(key);
          if (timestamp != null) {
            final viewedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
            if (now.difference(viewedDate).inDays > expirationDays) {
              await _prefs!.remove(key);
            }
          }
        } catch (e) {
          // If the key doesn't store an int, skip it
        }
      }
    }
  }
  
  /// Export view state data for debugging
  Future<Map<String, dynamic>> exportViewState() async {
    await _ensureInitialized();
    
    return {
      'viewed_stories': _prefs!.getStringList(_viewedStoriesKey) ?? [],
      'progress_map': _loadProgressMap(),
      'user_states': _loadUserViewStates(),
      'last_viewed': getLastViewed(),
    };
  }
  
  /// Import view state data (for testing/migration)
  Future<void> importViewState(Map<String, dynamic> data) async {
    await _ensureInitialized();
    
    if (data.containsKey('viewed_stories')) {
      await _prefs!.setStringList(
        _viewedStoriesKey,
        List<String>.from(data['viewed_stories']),
      );
    }
    
    if (data.containsKey('progress_map')) {
      await _prefs!.setString(
        _progressKey,
        jsonEncode(data['progress_map']),
      );
    }
    
    if (data.containsKey('user_states')) {
      await _prefs!.setString(
        _userViewStatesKey,
        jsonEncode(data['user_states']),
      );
    }
  }
}