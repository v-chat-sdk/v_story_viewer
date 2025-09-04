import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'v_performance_monitor.dart';
import 'v_error_logger.dart';

/// Performance optimizer for story viewer
class VPerformanceOptimizer {
  /// Singleton instance
  static final VPerformanceOptimizer _instance = VPerformanceOptimizer._internal();
  
  /// Factory constructor
  factory VPerformanceOptimizer() => _instance;
  
  /// Private constructor
  VPerformanceOptimizer._internal() {
    _performanceMonitor.addPerformanceListener(_onPerformanceUpdate);
    _performanceMonitor.addWarningListener(_onPerformanceWarning);
  }
  
  /// Performance monitor reference
  final VPerformanceMonitor _performanceMonitor = VPerformanceMonitor();
  
  /// Optimization settings
  bool _autoOptimizeEnabled = true;
  bool _reducedAnimations = false;
  bool _lowQualityMode = false;
  int _targetFPS = 60;
  
  /// Performance thresholds
  static const double _criticalFPS = 30.0;
  static const double _warningFPS = 45.0;
  static const int _criticalMemoryMB = 60;
  static const int _warningMemoryMB = 40;
  
  /// Optimization listeners
  final List<void Function(VOptimizationSettings)> _optimizationListeners = [];
  
  /// Current optimization settings
  VOptimizationSettings get currentSettings => VOptimizationSettings(
    autoOptimizeEnabled: _autoOptimizeEnabled,
    reducedAnimations: _reducedAnimations,
    lowQualityMode: _lowQualityMode,
    targetFPS: _targetFPS,
  );
  
  /// Enable auto optimization
  void enableAutoOptimization() {
    _autoOptimizeEnabled = true;
    VErrorLogger.logInfo('Auto optimization enabled');
  }
  
  /// Disable auto optimization
  void disableAutoOptimization() {
    _autoOptimizeEnabled = false;
    _resetOptimizations();
    VErrorLogger.logInfo('Auto optimization disabled');
  }
  
  /// Handle performance update
  void _onPerformanceUpdate(VPerformanceMetrics metrics) {
    if (!_autoOptimizeEnabled) return;
    
    // Check if we need to optimize
    if (metrics.fps < _warningFPS || metrics.memoryUsageMB > _warningMemoryMB) {
      _applyOptimizations(metrics);
    } else if (metrics.fps > _warningFPS + 10 && metrics.memoryUsageMB < _warningMemoryMB - 10) {
      // Performance is good, consider removing optimizations
      _relaxOptimizations(metrics);
    }
  }
  
  /// Handle performance warning
  void _onPerformanceWarning(VPerformanceWarning warning) {
    if (!_autoOptimizeEnabled) return;
    
    switch (warning.severity) {
      case VPerformanceSeverity.critical:
        _applyCriticalOptimizations();
        break;
      case VPerformanceSeverity.warning:
        _applyWarningOptimizations();
        break;
      case VPerformanceSeverity.info:
        // No action needed
        break;
    }
  }
  
  /// Apply optimizations based on metrics
  void _applyOptimizations(VPerformanceMetrics metrics) {
    bool changed = false;
    
    // FPS optimizations
    if (metrics.fps < _criticalFPS) {
      if (!_reducedAnimations) {
        _reducedAnimations = true;
        changed = true;
        VErrorLogger.logInfo('Reduced animations enabled due to low FPS');
      }
      if (!_lowQualityMode) {
        _lowQualityMode = true;
        changed = true;
        VErrorLogger.logInfo('Low quality mode enabled due to critical FPS');
      }
    } else if (metrics.fps < _warningFPS) {
      if (!_reducedAnimations) {
        _reducedAnimations = true;
        changed = true;
        VErrorLogger.logInfo('Reduced animations enabled');
      }
    }
    
    // Memory optimizations
    if (metrics.memoryUsageMB > _criticalMemoryMB) {
      if (!_lowQualityMode) {
        _lowQualityMode = true;
        changed = true;
        VErrorLogger.logInfo('Low quality mode enabled due to high memory');
      }
    }
    
    if (changed) {
      _notifyOptimizationListeners();
    }
  }
  
  /// Relax optimizations when performance improves
  void _relaxOptimizations(VPerformanceMetrics metrics) {
    bool changed = false;
    
    if (_lowQualityMode && metrics.fps > _warningFPS + 10 && metrics.memoryUsageMB < _warningMemoryMB) {
      _lowQualityMode = false;
      changed = true;
      VErrorLogger.logInfo('Low quality mode disabled - performance improved');
    }
    
    if (_reducedAnimations && metrics.fps > _targetFPS - 5) {
      _reducedAnimations = false;
      changed = true;
      VErrorLogger.logInfo('Animations re-enabled - FPS stable');
    }
    
    if (changed) {
      _notifyOptimizationListeners();
    }
  }
  
  /// Apply critical optimizations
  void _applyCriticalOptimizations() {
    _reducedAnimations = true;
    _lowQualityMode = true;
    _targetFPS = 30;
    _notifyOptimizationListeners();
    
    VErrorLogger.logWarning('Critical optimizations applied');
  }
  
  /// Apply warning optimizations
  void _applyWarningOptimizations() {
    _reducedAnimations = true;
    _targetFPS = 45;
    _notifyOptimizationListeners();
    
    VErrorLogger.logInfo('Warning optimizations applied');
  }
  
  /// Reset optimizations
  void _resetOptimizations() {
    _reducedAnimations = false;
    _lowQualityMode = false;
    _targetFPS = 60;
    _notifyOptimizationListeners();
    
    VErrorLogger.logInfo('Optimizations reset');
  }
  
  /// Notify optimization listeners
  void _notifyOptimizationListeners() {
    final settings = currentSettings;
    for (final listener in _optimizationListeners) {
      try {
        listener(settings);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error in optimization listener: $e');
        }
      }
    }
  }
  
  /// Add optimization listener
  void addOptimizationListener(void Function(VOptimizationSettings) listener) {
    _optimizationListeners.add(listener);
  }
  
  /// Remove optimization listener
  void removeOptimizationListener(void Function(VOptimizationSettings) listener) {
    _optimizationListeners.remove(listener);
  }
  
  /// Get optimization suggestions
  List<VOptimizationSuggestion> getOptimizationSuggestions() {
    final suggestions = <VOptimizationSuggestion>[];
    final report = _performanceMonitor.getPerformanceReport();
    final metrics = report.currentMetrics;
    
    // FPS suggestions
    if (metrics.fps < _warningFPS) {
      suggestions.add(
        VOptimizationSuggestion(
          title: 'Improve Animation Performance',
          description: 'Current FPS: ${metrics.fps.toStringAsFixed(1)}',
          actions: [
            'Use const constructors for widgets',
            'Implement RepaintBoundary for expensive widgets',
            'Reduce animation complexity',
            'Use widget keys for better diffing',
          ],
          severity: metrics.fps < _criticalFPS 
              ? VOptimizationSeverity.high 
              : VOptimizationSeverity.medium,
        ),
      );
    }
    
    // Memory suggestions
    if (metrics.memoryUsageMB > _warningMemoryMB) {
      suggestions.add(
        VOptimizationSuggestion(
          title: 'Reduce Memory Usage',
          description: 'Current usage: ${metrics.memoryUsageMB}MB',
          actions: [
            'Dispose controllers properly',
            'Reduce cache size for videos',
            'Optimize image sizes',
            'Clear dismissed stories more aggressively',
          ],
          severity: metrics.memoryUsageMB > _criticalMemoryMB 
              ? VOptimizationSeverity.high 
              : VOptimizationSeverity.medium,
        ),
      );
    }
    
    // General suggestions
    if (metrics.averageFPS < _targetFPS - 5) {
      suggestions.add(
        VOptimizationSuggestion(
          title: 'General Performance Tips',
          description: 'Average FPS below target',
          actions: [
            'Enable lazy loading for stories',
            'Preload only next 2 stories',
            'Use widget recycling',
            'Implement pagination for large lists',
          ],
          severity: VOptimizationSeverity.low,
        ),
      );
    }
    
    return suggestions;
  }
  
  /// Apply manual optimization settings
  void applyManualSettings({
    bool? reducedAnimations,
    bool? lowQualityMode,
    int? targetFPS,
  }) {
    bool changed = false;
    
    if (reducedAnimations != null && reducedAnimations != _reducedAnimations) {
      _reducedAnimations = reducedAnimations;
      changed = true;
    }
    
    if (lowQualityMode != null && lowQualityMode != _lowQualityMode) {
      _lowQualityMode = lowQualityMode;
      changed = true;
    }
    
    if (targetFPS != null && targetFPS != _targetFPS) {
      _targetFPS = targetFPS.clamp(30, 120);
      changed = true;
    }
    
    if (changed) {
      _notifyOptimizationListeners();
      VErrorLogger.logInfo(
        'Manual optimization settings applied',
        extra: currentSettings.toJson(),
      );
    }
  }
  
  /// Dispose
  void dispose() {
    _performanceMonitor.removePerformanceListener(_onPerformanceUpdate);
    _performanceMonitor.removeWarningListener(_onPerformanceWarning);
    _optimizationListeners.clear();
  }
}

/// Optimization settings
class VOptimizationSettings {
  final bool autoOptimizeEnabled;
  final bool reducedAnimations;
  final bool lowQualityMode;
  final int targetFPS;
  
  const VOptimizationSettings({
    required this.autoOptimizeEnabled,
    required this.reducedAnimations,
    required this.lowQualityMode,
    required this.targetFPS,
  });
  
  Map<String, dynamic> toJson() => {
    'autoOptimizeEnabled': autoOptimizeEnabled,
    'reducedAnimations': reducedAnimations,
    'lowQualityMode': lowQualityMode,
    'targetFPS': targetFPS,
  };
}

/// Optimization suggestion
class VOptimizationSuggestion {
  final String title;
  final String description;
  final List<String> actions;
  final VOptimizationSeverity severity;
  
  const VOptimizationSuggestion({
    required this.title,
    required this.description,
    required this.actions,
    required this.severity,
  });
}

/// Optimization severity
enum VOptimizationSeverity {
  low,
  medium,
  high,
}

/// Performance optimized widget wrapper
class VOptimizedWidget extends StatelessWidget {
  /// Child widget
  final Widget child;
  
  /// Whether to use repaint boundary
  final bool useRepaintBoundary;
  
  /// Whether to apply optimizations
  final bool applyOptimizations;
  
  /// Creates an optimized widget
  const VOptimizedWidget({
    super.key,
    required this.child,
    this.useRepaintBoundary = true,
    this.applyOptimizations = true,
  });
  
  @override
  Widget build(BuildContext context) {
    if (!applyOptimizations) {
      return child;
    }
    
    Widget result = child;
    
    // Apply repaint boundary for expensive widgets
    if (useRepaintBoundary) {
      result = RepaintBoundary(child: result);
    }
    
    return result;
  }
}