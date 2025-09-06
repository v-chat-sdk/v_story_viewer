import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'v_error_logger.dart';

/// Performance monitoring for story viewer
class VPerformanceMonitor {
  /// Singleton instance
  static final VPerformanceMonitor _instance = VPerformanceMonitor._internal();
  
  /// Factory constructor
  factory VPerformanceMonitor() => _instance;
  
  /// Private constructor
  VPerformanceMonitor._internal() {
    if (kDebugMode) {
      _startMonitoring();
    }
  }
  
  /// Frame tracking variables
  int _frameCount = 0;
  DateTime _lastFrameTime = DateTime.now();
  double _currentFPS = 60.0;
  final List<double> _fpsHistory = [];
  static const int _maxHistorySize = 60;
  
  /// Memory tracking variables
  int _currentMemoryUsage = 0;
  int _peakMemoryUsage = 0;
  final List<int> _memoryHistory = [];
  
  /// Performance thresholds
  static const double _minAcceptableFPS = 55.0;
  static const int _maxMemoryUsageMB = 50;
  static const int _warningMemoryUsageMB = 40;
  
  /// Monitoring flags
  bool _isMonitoring = false;
  Timer? _memoryTimer;
  
  /// Performance listeners
  final List<void Function(VPerformanceMetrics)> _performanceListeners = [];
  final List<void Function(VPerformanceWarning)> _warningListeners = [];
  
  /// Current performance metrics
  VPerformanceMetrics get currentMetrics => VPerformanceMetrics(
    fps: _currentFPS,
    averageFPS: _calculateAverageFPS(),
    memoryUsageMB: _currentMemoryUsage,
    peakMemoryUsageMB: _peakMemoryUsage,
    timestamp: DateTime.now(),
  );
  
  /// Start monitoring
  void _startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    
    // Start FPS tracking
    SchedulerBinding.instance.addPostFrameCallback(_trackFrame);
    
    // Start memory monitoring
    _memoryTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _trackMemoryUsage(),
    );
  }
  
  /// Stop monitoring
  void stopMonitoring() {
    _isMonitoring = false;
    _memoryTimer?.cancel();
    _memoryTimer = null;
  }
  
  /// Track frame rendering
  void _trackFrame(Duration timestamp) {
    if (!_isMonitoring) return;
    
    _frameCount++;
    final now = DateTime.now();
    final elapsed = now.difference(_lastFrameTime).inMilliseconds;
    
    if (elapsed >= 1000) {
      // Calculate FPS
      _currentFPS = (_frameCount * 1000.0 / elapsed).clamp(0, 120);
      _frameCount = 0;
      _lastFrameTime = now;
      
      // Update history
      _fpsHistory.add(_currentFPS);
      if (_fpsHistory.length > _maxHistorySize) {
        _fpsHistory.removeAt(0);
      }
      
      // Check for performance issues
      if (_currentFPS < _minAcceptableFPS) {
        _handlePerformanceWarning(
          VPerformanceWarning(
            type: VPerformanceWarningType.lowFPS,
            message: 'FPS dropped to ${_currentFPS.toStringAsFixed(1)}',
            currentValue: _currentFPS,
            threshold: _minAcceptableFPS,
            severity: _currentFPS < 30 
                ? VPerformanceSeverity.critical 
                : VPerformanceSeverity.warning,
          ),
        );
      }
      
      // Notify listeners
      _notifyPerformanceListeners();
    }
    
    // Continue tracking
    if (_isMonitoring) {
      SchedulerBinding.instance.addPostFrameCallback(_trackFrame);
    }
  }
  
  /// Track memory usage
  void _trackMemoryUsage() {
    if (!_isMonitoring) return;
    
    // Get memory usage (simplified - in production use proper memory profiling)
    final memoryInfo = _getMemoryInfo();
    _currentMemoryUsage = memoryInfo;
    
    // Update peak memory
    if (_currentMemoryUsage > _peakMemoryUsage) {
      _peakMemoryUsage = _currentMemoryUsage;
    }
    
    // Update history
    _memoryHistory.add(_currentMemoryUsage);
    if (_memoryHistory.length > _maxHistorySize) {
      _memoryHistory.removeAt(0);
    }
    
    // Check for memory issues
    if (_currentMemoryUsage > _maxMemoryUsageMB) {
      _handlePerformanceWarning(
        VPerformanceWarning(
          type: VPerformanceWarningType.highMemory,
          message: 'Memory usage exceeded ${_maxMemoryUsageMB}MB',
          currentValue: _currentMemoryUsage.toDouble(),
          threshold: _maxMemoryUsageMB.toDouble(),
          severity: VPerformanceSeverity.critical,
        ),
      );
    } else if (_currentMemoryUsage > _warningMemoryUsageMB) {
      _handlePerformanceWarning(
        VPerformanceWarning(
          type: VPerformanceWarningType.highMemory,
          message: 'Memory usage is high: ${_currentMemoryUsage}MB',
          currentValue: _currentMemoryUsage.toDouble(),
          threshold: _warningMemoryUsageMB.toDouble(),
          severity: VPerformanceSeverity.warning,
        ),
      );
    }
  }
  
  /// Get memory info (simplified implementation)
  int _getMemoryInfo() {
    // In a real implementation, use platform channels to get actual memory usage
    // This is a placeholder that estimates based on widget count
    return 20 + (_frameCount ~/ 100); // Simplified calculation
  }
  
  /// Calculate average FPS
  double _calculateAverageFPS() {
    if (_fpsHistory.isEmpty) return _currentFPS;
    final sum = _fpsHistory.reduce((a, b) => a + b);
    return sum / _fpsHistory.length;
  }
  
  /// Handle performance warning
  void _handlePerformanceWarning(VPerformanceWarning warning) {
    // Log warning
    VErrorLogger.logWarning(
      warning.message,
      extra: {
        'type': warning.type.name,
        'severity': warning.severity.name,
        'value': warning.currentValue,
        'threshold': warning.threshold,
      },
    );
    
    // Notify warning listeners
    for (final listener in _warningListeners) {
      try {
        listener(warning);
      } catch (e) {
        if (kDebugMode) {
        }
      }
    }
  }
  
  /// Notify performance listeners
  void _notifyPerformanceListeners() {
    final metrics = currentMetrics;
    for (final listener in _performanceListeners) {
      try {
        listener(metrics);
      } catch (e) {
        if (kDebugMode) {
        }
      }
    }
  }
  
  /// Add performance listener
  void addPerformanceListener(void Function(VPerformanceMetrics) listener) {
    _performanceListeners.add(listener);
  }
  
  /// Remove performance listener
  void removePerformanceListener(void Function(VPerformanceMetrics) listener) {
    _performanceListeners.remove(listener);
  }
  
  /// Add warning listener
  void addWarningListener(void Function(VPerformanceWarning) listener) {
    _warningListeners.add(listener);
  }
  
  /// Remove warning listener
  void removeWarningListener(void Function(VPerformanceWarning) listener) {
    _warningListeners.remove(listener);
  }
  
  /// Get performance report
  VPerformanceReport getPerformanceReport() {
    return VPerformanceReport(
      currentMetrics: currentMetrics,
      fpsHistory: List.from(_fpsHistory),
      memoryHistory: List.from(_memoryHistory),
      recommendations: _generateRecommendations(),
    );
  }
  
  /// Generate performance recommendations
  List<String> _generateRecommendations() {
    final recommendations = <String>[];
    
    // FPS recommendations
    if (_currentFPS < _minAcceptableFPS) {
      recommendations.add('• Reduce animation complexity');
      recommendations.add('• Optimize widget rebuilds');
      recommendations.add('• Use RepaintBoundary for expensive widgets');
    }
    
    // Memory recommendations
    if (_currentMemoryUsage > _warningMemoryUsageMB) {
      recommendations.add('• Clear cached stories more frequently');
      recommendations.add('• Reduce video controller cache size');
      recommendations.add('• Optimize image sizes');
    }
    
    // General recommendations
    if (_fpsHistory.isNotEmpty) {
      final avgFPS = _calculateAverageFPS();
      if (avgFPS < 58) {
        recommendations.add('• Consider using const constructors');
        recommendations.add('• Extract complex widgets');
        recommendations.add('• Implement lazy loading');
      }
    }
    
    return recommendations;
  }
  
  /// Reset metrics
  void resetMetrics() {
    _frameCount = 0;
    _lastFrameTime = DateTime.now();
    _currentFPS = 60.0;
    _fpsHistory.clear();
    _currentMemoryUsage = 0;
    _peakMemoryUsage = 0;
    _memoryHistory.clear();
  }
  
  /// Dispose
  void dispose() {
    stopMonitoring();
    _performanceListeners.clear();
    _warningListeners.clear();
  }
}

/// Performance metrics data
class VPerformanceMetrics {
  final double fps;
  final double averageFPS;
  final int memoryUsageMB;
  final int peakMemoryUsageMB;
  final DateTime timestamp;
  
  const VPerformanceMetrics({
    required this.fps,
    required this.averageFPS,
    required this.memoryUsageMB,
    required this.peakMemoryUsageMB,
    required this.timestamp,
  });
  
  bool get isHealthy => 
      fps >= VPerformanceMonitor._minAcceptableFPS && 
      memoryUsageMB <= VPerformanceMonitor._maxMemoryUsageMB;
}

/// Performance warning
class VPerformanceWarning {
  final VPerformanceWarningType type;
  final String message;
  final double currentValue;
  final double threshold;
  final VPerformanceSeverity severity;
  
  const VPerformanceWarning({
    required this.type,
    required this.message,
    required this.currentValue,
    required this.threshold,
    required this.severity,
  });
}

/// Warning types
enum VPerformanceWarningType {
  lowFPS,
  highMemory,
  longTransition,
  slowLoading,
}

/// Warning severity
enum VPerformanceSeverity {
  info,
  warning,
  critical,
}

/// Performance report
class VPerformanceReport {
  final VPerformanceMetrics currentMetrics;
  final List<double> fpsHistory;
  final List<int> memoryHistory;
  final List<String> recommendations;
  
  const VPerformanceReport({
    required this.currentMetrics,
    required this.fpsHistory,
    required this.memoryHistory,
    required this.recommendations,
  });
  
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('=== Performance Report ===');
    buffer.writeln('Current FPS: ${currentMetrics.fps.toStringAsFixed(1)}');
    buffer.writeln('Average FPS: ${currentMetrics.averageFPS.toStringAsFixed(1)}');
    buffer.writeln('Memory Usage: ${currentMetrics.memoryUsageMB}MB');
    buffer.writeln('Peak Memory: ${currentMetrics.peakMemoryUsageMB}MB');
    
    if (recommendations.isNotEmpty) {
      buffer.writeln('\nRecommendations:');
      for (final rec in recommendations) {
        buffer.writeln(rec);
      }
    }
    
    return buffer.toString();
  }
}