import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/v_story_error.dart';

/// Error logger for debugging and monitoring
class VErrorLogger {
  /// Whether to enable logging
  static bool _enabled = kDebugMode;
  
  /// Log level
  static VLogLevel _logLevel = VLogLevel.info;
  
  /// Custom log handler
  static void Function(VLogEntry entry)? _customHandler;
  
  /// Error event listeners
  static final List<void Function(VStoryError)> _errorListeners = [];
  
  /// Enable or disable logging
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }
  
  /// Set minimum log level
  static void setLogLevel(VLogLevel level) {
    _logLevel = level;
  }
  
  /// Set custom log handler
  static void setCustomHandler(void Function(VLogEntry entry)? handler) {
    _customHandler = handler;
  }
  
  /// Add error listener
  static void addErrorListener(void Function(VStoryError) listener) {
    _errorListeners.add(listener);
  }
  
  /// Remove error listener
  static void removeErrorListener(void Function(VStoryError) listener) {
    _errorListeners.remove(listener);
  }
  
  /// Log error
  static void logError(
    VStoryError error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    if (!_enabled) return;
    
    final entry = VLogEntry(
      level: VLogLevel.error,
      message: error.message,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
      timestamp: DateTime.now(),
    );
    
    _log(entry);
    
    // Notify error listeners
    for (final listener in _errorListeners) {
      try {
        listener(error);
      } catch (e) {
        // Prevent listener errors from breaking logging
        if (kDebugMode) {
          print('Error in error listener: $e');
        }
      }
    }
  }
  
  /// Log warning
  static void logWarning(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    if (!_enabled) return;
    
    final entry = VLogEntry(
      level: VLogLevel.warning,
      message: message,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
      timestamp: DateTime.now(),
    );
    
    _log(entry);
  }
  
  /// Log info
  static void logInfo(
    String message, {
    Map<String, dynamic>? extra,
  }) {
    if (!_enabled) return;
    
    final entry = VLogEntry(
      level: VLogLevel.info,
      message: message,
      extra: extra,
      timestamp: DateTime.now(),
    );
    
    _log(entry);
  }
  
  /// Log debug
  static void logDebug(
    String message, {
    Map<String, dynamic>? extra,
  }) {
    if (!_enabled || !kDebugMode) return;
    
    final entry = VLogEntry(
      level: VLogLevel.debug,
      message: message,
      extra: extra,
      timestamp: DateTime.now(),
    );
    
    _log(entry);
  }
  
  /// Log network operation
  static void logNetwork({
    required String operation,
    required String url,
    int? statusCode,
    Duration? duration,
    dynamic error,
    Map<String, dynamic>? extra,
  }) {
    if (!_enabled) return;
    
    final level = error != null ? VLogLevel.error : VLogLevel.debug;
    final message = _formatNetworkMessage(
      operation: operation,
      url: url,
      statusCode: statusCode,
      duration: duration,
      error: error,
    );
    
    final entry = VLogEntry(
      level: level,
      message: message,
      error: error,
      extra: {
        'operation': operation,
        'url': url,
        if (statusCode != null) 'statusCode': statusCode,
        if (duration != null) 'duration': duration.inMilliseconds,
        ...?extra,
      },
      timestamp: DateTime.now(),
    );
    
    _log(entry);
  }
  
  /// Log performance metric
  static void logPerformance({
    required String metric,
    required double value,
    String? unit,
    Map<String, dynamic>? extra,
  }) {
    if (!_enabled) return;
    
    final message = 'Performance: $metric = $value${unit != null ? ' $unit' : ''}';
    
    final entry = VLogEntry(
      level: VLogLevel.debug,
      message: message,
      extra: {
        'metric': metric,
        'value': value,
        if (unit != null) 'unit': unit,
        ...?extra,
      },
      timestamp: DateTime.now(),
    );
    
    _log(entry);
  }
  
  /// Internal log method
  static void _log(VLogEntry entry) {
    // Check log level
    if (entry.level.index < _logLevel.index) {
      return;
    }
    
    // Use custom handler if available
    if (_customHandler != null) {
      _customHandler!(entry);
      return;
    }
    
    // Default logging
    final formattedMessage = _formatLogMessage(entry);
    
    if (kDebugMode) {
      // Use developer.log for better IDE integration
      developer.log(
        formattedMessage,
        name: 'VStoryViewer',
        time: entry.timestamp,
        level: _mapLogLevel(entry.level),
        error: entry.error,
        stackTrace: entry.stackTrace,
      );
    } else {
      // Use debugPrint for release mode if enabled
      debugPrint(formattedMessage);
    }
  }
  
  /// Format log message
  static String _formatLogMessage(VLogEntry entry) {
    final buffer = StringBuffer();
    
    // Add timestamp
    buffer.write('[${entry.timestamp.toIso8601String()}] ');
    
    // Add level
    buffer.write('[${entry.level.name.toUpperCase()}] ');
    
    // Add message
    buffer.write(entry.message);
    
    // Add extra data
    if (entry.extra != null && entry.extra!.isNotEmpty) {
      buffer.write(' | ');
      buffer.write(entry.extra!.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', '));
    }
    
    // Add error details
    if (entry.error != null) {
      buffer.write('\n  Error: ${entry.error}');
      if (entry.error is VStoryError) {
        final storyError = entry.error as VStoryError;
        buffer.write(' (Code: ${storyError.code})');
      }
    }
    
    // Add stack trace for errors
    if (entry.stackTrace != null && entry.level == VLogLevel.error) {
      buffer.write('\n  Stack trace:\n${entry.stackTrace}');
    }
    
    return buffer.toString();
  }
  
  /// Format network message
  static String _formatNetworkMessage({
    required String operation,
    required String url,
    int? statusCode,
    Duration? duration,
    dynamic error,
  }) {
    final buffer = StringBuffer();
    buffer.write('$operation: $url');
    
    if (statusCode != null) {
      buffer.write(' [Status: $statusCode]');
    }
    
    if (duration != null) {
      buffer.write(' [Duration: ${duration.inMilliseconds}ms]');
    }
    
    if (error != null) {
      buffer.write(' [Error: $error]');
    }
    
    return buffer.toString();
  }
  
  /// Map log level to developer.log level
  static int _mapLogLevel(VLogLevel level) {
    switch (level) {
      case VLogLevel.debug:
        return 500;
      case VLogLevel.info:
        return 800;
      case VLogLevel.warning:
        return 900;
      case VLogLevel.error:
        return 1000;
    }
  }
}

/// Log levels
enum VLogLevel {
  debug,
  info,
  warning,
  error,
}

/// Log entry
class VLogEntry {
  final VLogLevel level;
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? extra;
  final DateTime timestamp;
  
  const VLogEntry({
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
    this.extra,
    required this.timestamp,
  });
}