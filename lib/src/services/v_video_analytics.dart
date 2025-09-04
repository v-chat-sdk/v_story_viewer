import 'dart:async';
import 'package:flutter/foundation.dart';

/// Video playback analytics event
class VVideoAnalyticsEvent {
  /// Event type
  final VVideoAnalyticsType type;
  
  /// Story ID
  final String storyId;
  
  /// Timestamp of event
  final DateTime timestamp;
  
  /// Additional data
  final Map<String, dynamic> data;
  
  /// Creates an analytics event
  const VVideoAnalyticsEvent({
    required this.type,
    required this.storyId,
    required this.timestamp,
    this.data = const {},
  });
  
  /// Creates a view start event
  factory VVideoAnalyticsEvent.viewStart(String storyId) {
    return VVideoAnalyticsEvent(
      type: VVideoAnalyticsType.viewStart,
      storyId: storyId,
      timestamp: DateTime.now(),
    );
  }
  
  /// Creates a view complete event
  factory VVideoAnalyticsEvent.viewComplete(String storyId, Duration watchTime) {
    return VVideoAnalyticsEvent(
      type: VVideoAnalyticsType.viewComplete,
      storyId: storyId,
      timestamp: DateTime.now(),
      data: {'watchTime': watchTime.inSeconds},
    );
  }
  
  /// Creates a buffer event
  factory VVideoAnalyticsEvent.buffer(String storyId, Duration bufferTime) {
    return VVideoAnalyticsEvent(
      type: VVideoAnalyticsType.buffer,
      storyId: storyId,
      timestamp: DateTime.now(),
      data: {'bufferTime': bufferTime.inMilliseconds},
    );
  }
  
  /// Creates an error event
  factory VVideoAnalyticsEvent.error(String storyId, String error) {
    return VVideoAnalyticsEvent(
      type: VVideoAnalyticsType.error,
      storyId: storyId,
      timestamp: DateTime.now(),
      data: {'error': error},
    );
  }
  
  /// Creates a quality change event
  factory VVideoAnalyticsEvent.qualityChange(String storyId, String quality) {
    return VVideoAnalyticsEvent(
      type: VVideoAnalyticsType.qualityChange,
      storyId: storyId,
      timestamp: DateTime.now(),
      data: {'quality': quality},
    );
  }
}

/// Types of video analytics events
enum VVideoAnalyticsType {
  /// Video view started
  viewStart,
  
  /// Video view completed
  viewComplete,
  
  /// Video paused
  pause,
  
  /// Video resumed
  resume,
  
  /// Video buffering
  buffer,
  
  /// Video error
  error,
  
  /// Video quality changed
  qualityChange,
  
  /// Video seek
  seek,
  
  /// Video muted
  mute,
  
  /// Video unmuted
  unmute,
}

/// Video performance metrics
class VVideoMetrics {
  /// Total watch time
  final Duration totalWatchTime;
  
  /// Total buffer time
  final Duration totalBufferTime;
  
  /// Number of buffer events
  final int bufferCount;
  
  /// Number of errors
  final int errorCount;
  
  /// Average watch percentage
  final double averageWatchPercentage;
  
  /// Completion rate
  final double completionRate;
  
  /// Quality changes count
  final int qualityChanges;
  
  /// Creates video metrics
  const VVideoMetrics({
    required this.totalWatchTime,
    required this.totalBufferTime,
    required this.bufferCount,
    required this.errorCount,
    required this.averageWatchPercentage,
    required this.completionRate,
    required this.qualityChanges,
  });
  
  /// Creates empty metrics
  factory VVideoMetrics.empty() => const VVideoMetrics(
    totalWatchTime: Duration.zero,
    totalBufferTime: Duration.zero,
    bufferCount: 0,
    errorCount: 0,
    averageWatchPercentage: 0.0,
    completionRate: 0.0,
    qualityChanges: 0,
  );
}

/// Service for tracking video analytics
class VVideoAnalytics extends ChangeNotifier {
  /// Stream controller for analytics events
  final StreamController<VVideoAnalyticsEvent> _eventController =
      StreamController<VVideoAnalyticsEvent>.broadcast();
  
  /// All analytics events
  final List<VVideoAnalyticsEvent> _events = [];
  
  /// Video start times
  final Map<String, DateTime> _startTimes = {};
  
  /// Video watch times
  final Map<String, Duration> _watchTimes = {};
  
  /// Buffer start times
  final Map<String, DateTime> _bufferStartTimes = {};
  
  /// Total buffer times
  final Map<String, Duration> _bufferTimes = {};
  
  /// Video durations
  final Map<String, Duration> _videoDurations = {};
  
  /// View counts
  final Map<String, int> _viewCounts = {};
  
  /// Completion counts
  final Map<String, int> _completionCounts = {};
  
  /// Error counts
  final Map<String, int> _errorCounts = {};
  
  /// Whether analytics is enabled
  bool _enabled = true;
  
  /// Gets the event stream
  Stream<VVideoAnalyticsEvent> get eventStream => _eventController.stream;
  
  /// Gets all events
  List<VVideoAnalyticsEvent> get events => List.unmodifiable(_events);
  
  /// Gets whether analytics is enabled
  bool get enabled => _enabled;
  
  /// Enables/disables analytics
  set enabled(bool value) {
    _enabled = value;
    notifyListeners();
  }
  
  /// Tracks video start
  void trackVideoStart(String storyId, Duration videoDuration) {
    if (!_enabled) return;
    
    _startTimes[storyId] = DateTime.now();
    _videoDurations[storyId] = videoDuration;
    _viewCounts[storyId] = (_viewCounts[storyId] ?? 0) + 1;
    
    final event = VVideoAnalyticsEvent.viewStart(storyId);
    _addEvent(event);
  }
  
  /// Tracks video completion
  void trackVideoComplete(String storyId) {
    if (!_enabled) return;
    
    final startTime = _startTimes[storyId];
    if (startTime != null) {
      final watchTime = DateTime.now().difference(startTime);
      _watchTimes[storyId] = (_watchTimes[storyId] ?? Duration.zero) + watchTime;
      _completionCounts[storyId] = (_completionCounts[storyId] ?? 0) + 1;
      
      final event = VVideoAnalyticsEvent.viewComplete(storyId, watchTime);
      _addEvent(event);
    }
    
    _startTimes.remove(storyId);
  }
  
  /// Tracks video pause
  void trackVideoPause(String storyId) {
    if (!_enabled) return;
    
    final event = VVideoAnalyticsEvent(
      type: VVideoAnalyticsType.pause,
      storyId: storyId,
      timestamp: DateTime.now(),
    );
    _addEvent(event);
  }
  
  /// Tracks video resume
  void trackVideoResume(String storyId) {
    if (!_enabled) return;
    
    final event = VVideoAnalyticsEvent(
      type: VVideoAnalyticsType.resume,
      storyId: storyId,
      timestamp: DateTime.now(),
    );
    _addEvent(event);
  }
  
  /// Tracks buffer start
  void trackBufferStart(String storyId) {
    if (!_enabled) return;
    
    _bufferStartTimes[storyId] = DateTime.now();
  }
  
  /// Tracks buffer end
  void trackBufferEnd(String storyId) {
    if (!_enabled) return;
    
    final startTime = _bufferStartTimes[storyId];
    if (startTime != null) {
      final bufferTime = DateTime.now().difference(startTime);
      _bufferTimes[storyId] = (_bufferTimes[storyId] ?? Duration.zero) + bufferTime;
      
      final event = VVideoAnalyticsEvent.buffer(storyId, bufferTime);
      _addEvent(event);
    }
    
    _bufferStartTimes.remove(storyId);
  }
  
  /// Tracks video error
  void trackVideoError(String storyId, String error) {
    if (!_enabled) return;
    
    _errorCounts[storyId] = (_errorCounts[storyId] ?? 0) + 1;
    
    final event = VVideoAnalyticsEvent.error(storyId, error);
    _addEvent(event);
  }
  
  /// Tracks video seek
  void trackVideoSeek(String storyId, Duration from, Duration to) {
    if (!_enabled) return;
    
    final event = VVideoAnalyticsEvent(
      type: VVideoAnalyticsType.seek,
      storyId: storyId,
      timestamp: DateTime.now(),
      data: {
        'from': from.inSeconds,
        'to': to.inSeconds,
      },
    );
    _addEvent(event);
  }
  
  /// Tracks mute state change
  void trackMuteChange(String storyId, bool isMuted) {
    if (!_enabled) return;
    
    final event = VVideoAnalyticsEvent(
      type: isMuted ? VVideoAnalyticsType.mute : VVideoAnalyticsType.unmute,
      storyId: storyId,
      timestamp: DateTime.now(),
    );
    _addEvent(event);
  }
  
  /// Tracks quality change
  void trackQualityChange(String storyId, String quality) {
    if (!_enabled) return;
    
    final event = VVideoAnalyticsEvent.qualityChange(storyId, quality);
    _addEvent(event);
  }
  
  /// Adds an event to the analytics
  void _addEvent(VVideoAnalyticsEvent event) {
    _events.add(event);
    _eventController.add(event);
    notifyListeners();
  }
  
  /// Gets metrics for a specific video
  VVideoMetrics getMetricsForVideo(String storyId) {
    final watchTime = _watchTimes[storyId] ?? Duration.zero;
    final bufferTime = _bufferTimes[storyId] ?? Duration.zero;
    final duration = _videoDurations[storyId] ?? Duration(seconds: 1);
    final views = _viewCounts[storyId] ?? 0;
    final completions = _completionCounts[storyId] ?? 0;
    final errors = _errorCounts[storyId] ?? 0;
    
    final bufferEvents = _events
        .where((e) => e.storyId == storyId && e.type == VVideoAnalyticsType.buffer)
        .length;
    
    final qualityEvents = _events
        .where((e) => e.storyId == storyId && e.type == VVideoAnalyticsType.qualityChange)
        .length;
    
    final watchPercentage = duration.inSeconds > 0
        ? (watchTime.inSeconds / duration.inSeconds * 100).clamp(0.0, 100.0)
        : 0.0;
    
    final completionRate = views > 0 ? completions / views : 0.0;
    
    return VVideoMetrics(
      totalWatchTime: watchTime,
      totalBufferTime: bufferTime,
      bufferCount: bufferEvents,
      errorCount: errors,
      averageWatchPercentage: watchPercentage,
      completionRate: completionRate,
      qualityChanges: qualityEvents,
    );
  }
  
  /// Gets overall metrics
  VVideoMetrics getOverallMetrics() {
    Duration totalWatch = Duration.zero;
    Duration totalBuffer = Duration.zero;
    int totalBufferEvents = 0;
    int totalErrors = 0;
    int totalQualityChanges = 0;
    double totalWatchPercentage = 0.0;
    int videoCount = 0;
    
    for (final storyId in _watchTimes.keys) {
      final metrics = getMetricsForVideo(storyId);
      totalWatch += metrics.totalWatchTime;
      totalBuffer += metrics.totalBufferTime;
      totalBufferEvents += metrics.bufferCount;
      totalErrors += metrics.errorCount;
      totalQualityChanges += metrics.qualityChanges;
      totalWatchPercentage += metrics.averageWatchPercentage;
      videoCount++;
    }
    
    final avgWatchPercentage = videoCount > 0 
        ? totalWatchPercentage / videoCount 
        : 0.0;
    
    final totalViews = _viewCounts.values.fold(0, (sum, count) => sum + count);
    final totalCompletions = _completionCounts.values.fold(0, (sum, count) => sum + count);
    final completionRate = totalViews > 0 ? totalCompletions / totalViews : 0.0;
    
    return VVideoMetrics(
      totalWatchTime: totalWatch,
      totalBufferTime: totalBuffer,
      bufferCount: totalBufferEvents,
      errorCount: totalErrors,
      averageWatchPercentage: avgWatchPercentage,
      completionRate: completionRate,
      qualityChanges: totalQualityChanges,
    );
  }
  
  /// Clears all analytics data
  void clearAnalytics() {
    _events.clear();
    _startTimes.clear();
    _watchTimes.clear();
    _bufferStartTimes.clear();
    _bufferTimes.clear();
    _videoDurations.clear();
    _viewCounts.clear();
    _completionCounts.clear();
    _errorCounts.clear();
    notifyListeners();
  }
  
  /// Exports analytics data
  Map<String, dynamic> exportAnalytics() {
    return {
      'events': _events.map((e) => {
        'type': e.type.toString(),
        'storyId': e.storyId,
        'timestamp': e.timestamp.toIso8601String(),
        'data': e.data,
      }).toList(),
      'metrics': {
        'overall': _metricsToMap(getOverallMetrics()),
        'byVideo': Map.fromEntries(
          _watchTimes.keys.map((id) => MapEntry(id, _metricsToMap(getMetricsForVideo(id)))),
        ),
      },
    };
  }
  
  /// Converts metrics to map
  Map<String, dynamic> _metricsToMap(VVideoMetrics metrics) {
    return {
      'totalWatchTime': metrics.totalWatchTime.inSeconds,
      'totalBufferTime': metrics.totalBufferTime.inSeconds,
      'bufferCount': metrics.bufferCount,
      'errorCount': metrics.errorCount,
      'averageWatchPercentage': metrics.averageWatchPercentage,
      'completionRate': metrics.completionRate,
      'qualityChanges': metrics.qualityChanges,
    };
  }
  
  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}