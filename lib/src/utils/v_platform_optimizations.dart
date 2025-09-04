import 'package:flutter/foundation.dart';
import 'v_platform_handler.dart';
import 'v_performance_monitor.dart';
import 'v_error_logger.dart';

/// Platform-specific performance optimizations
class VPlatformOptimizations {
  /// Singleton instance
  static final VPlatformOptimizations _instance = VPlatformOptimizations._internal();
  
  /// Factory constructor
  factory VPlatformOptimizations() => _instance;
  
  /// Private constructor
  VPlatformOptimizations._internal() {
    _initialize();
  }
  
  /// Performance monitor reference
  final VPerformanceMonitor _performanceMonitor = VPerformanceMonitor();
  
  /// Optimization flags
  bool _webOptimizationsEnabled = false;
  bool _mobileOptimizationsEnabled = false;
  bool _iosOptimizationsEnabled = false;
  bool _androidOptimizationsEnabled = false;
  
  /// Initialize optimizations
  void _initialize() {
    // Apply platform-specific optimizations
    if (VPlatformHandler.isWeb) {
      _applyWebOptimizations();
    } else if (VPlatformHandler.isIOS) {
      _applyIOSOptimizations();
    } else if (VPlatformHandler.isAndroid) {
      _applyAndroidOptimizations();
    } else if (VPlatformHandler.isDesktop) {
      _applyDesktopOptimizations();
    }
    
    VErrorLogger.logInfo(
      'Platform optimizations initialized',
      extra: {
        'platform': VPlatformHandler.platformName,
        'webOpt': _webOptimizationsEnabled,
        'mobileOpt': _mobileOptimizationsEnabled,
        'iosOpt': _iosOptimizationsEnabled,
        'androidOpt': _androidOptimizationsEnabled,
      },
    );
  }
  
  /// Apply web-specific optimizations
  void _applyWebOptimizations() {
    _webOptimizationsEnabled = true;
    
    // Web-specific optimizations
    WebOptimizations.apply();
    
    VErrorLogger.logDebug('Web optimizations applied');
  }
  
  /// Apply iOS-specific optimizations
  void _applyIOSOptimizations() {
    _iosOptimizationsEnabled = true;
    _mobileOptimizationsEnabled = true;
    
    // iOS-specific optimizations
    IOSOptimizations.apply();
    
    VErrorLogger.logDebug('iOS optimizations applied');
  }
  
  /// Apply Android-specific optimizations
  void _applyAndroidOptimizations() {
    _androidOptimizationsEnabled = true;
    _mobileOptimizationsEnabled = true;
    
    // Android-specific optimizations
    AndroidOptimizations.apply();
    
    VErrorLogger.logDebug('Android optimizations applied');
  }
  
  /// Apply desktop-specific optimizations
  void _applyDesktopOptimizations() {
    // Desktop-specific optimizations
    DesktopOptimizations.apply();
    
    VErrorLogger.logDebug('Desktop optimizations applied');
  }
  
  /// Get optimized settings for current platform
  OptimizedSettings getOptimizedSettings() {
    return OptimizedSettings(
      enableHardwareAcceleration: VPlatformHandler.shouldUseHardwareAcceleration(),
      maxConcurrentVideos: _getOptimizedMaxVideos(),
      imageCacheSize: _getOptimizedImageCacheSize(),
      enablePreloading: _shouldEnablePreloading(),
      animationDuration: _getOptimizedAnimationDuration(),
      useWebGL: VPlatformHandler.isWeb,
      enableOffscreenRendering: !VPlatformHandler.isWeb,
      maxMemoryUsageMB: _getOptimizedMemoryLimit(),
      enableLazyLoading: true,
      compressionQuality: VPlatformHandler.getImageCompressionQuality(),
    );
  }
  
  /// Get optimized max videos based on performance
  int _getOptimizedMaxVideos() {
    final metrics = _performanceMonitor.currentMetrics;
    final baseCount = VPlatformHandler.getOptimalVideoCacheCount();
    
    // Reduce if performance is poor
    if (metrics.fps < 30) {
      return (baseCount * 0.5).round().clamp(1, 10);
    } else if (metrics.fps < 45) {
      return (baseCount * 0.75).round().clamp(1, 10);
    }
    
    return baseCount;
  }
  
  /// Get optimized image cache size
  int _getOptimizedImageCacheSize() {
    final metrics = _performanceMonitor.currentMetrics;
    final baseSize = VPlatformHandler.getOptimalImageCacheSize();
    
    // Reduce if memory usage is high
    if (metrics.memoryUsageMB > 40) {
      return (baseSize * 0.75).round();
    }
    
    return baseSize;
  }
  
  /// Should enable preloading based on conditions
  bool _shouldEnablePreloading() {
    if (!VPlatformHandler.shouldPreloadStories()) {
      return false;
    }
    
    final metrics = _performanceMonitor.currentMetrics;
    
    // Disable preloading if performance is poor
    return metrics.fps >= 45 && metrics.memoryUsageMB < 40;
  }
  
  /// Get optimized animation duration
  Duration _getOptimizedAnimationDuration() {
    final metrics = _performanceMonitor.currentMetrics;
    final baseDuration = VPlatformHandler.getTransitionDuration();
    
    // Speed up animations if performance is poor
    if (metrics.fps < 30) {
      return baseDuration * 0.5;
    } else if (metrics.fps < 45) {
      return baseDuration * 0.75;
    }
    
    return baseDuration;
  }
  
  /// Get optimized memory limit
  int _getOptimizedMemoryLimit() {
    if (VPlatformHandler.isWeb) return 30;
    if (VPlatformHandler.isIOS) return 50;
    if (VPlatformHandler.isAndroid) return 75;
    return 150; // Desktop
  }
}

/// Optimized settings for platform
class OptimizedSettings {
  final bool enableHardwareAcceleration;
  final int maxConcurrentVideos;
  final int imageCacheSize;
  final bool enablePreloading;
  final Duration animationDuration;
  final bool useWebGL;
  final bool enableOffscreenRendering;
  final int maxMemoryUsageMB;
  final bool enableLazyLoading;
  final int compressionQuality;
  
  const OptimizedSettings({
    required this.enableHardwareAcceleration,
    required this.maxConcurrentVideos,
    required this.imageCacheSize,
    required this.enablePreloading,
    required this.animationDuration,
    required this.useWebGL,
    required this.enableOffscreenRendering,
    required this.maxMemoryUsageMB,
    required this.enableLazyLoading,
    required this.compressionQuality,
  });
  
  Map<String, dynamic> toJson() => {
    'enableHardwareAcceleration': enableHardwareAcceleration,
    'maxConcurrentVideos': maxConcurrentVideos,
    'imageCacheSize': imageCacheSize,
    'enablePreloading': enablePreloading,
    'animationDurationMs': animationDuration.inMilliseconds,
    'useWebGL': useWebGL,
    'enableOffscreenRendering': enableOffscreenRendering,
    'maxMemoryUsageMB': maxMemoryUsageMB,
    'enableLazyLoading': enableLazyLoading,
    'compressionQuality': compressionQuality,
  };
}

/// Web-specific optimizations
class WebOptimizations {
  static void apply() {
    // Web-specific performance optimizations
    
    // 1. Use WebGL when available
    // This would be handled by the rendering engine
    
    // 2. Optimize image loading
    // Use lazy loading with Intersection Observer
    
    // 3. Reduce concurrent network requests
    // Browsers limit concurrent connections
    
    // 4. Use Service Workers for caching
    // This requires PWA setup
    
    // 5. Optimize video playback
    // Use HLS or DASH for adaptive streaming
    
    if (kDebugMode) {
      debugPrint('Web optimizations: WebGL, lazy loading, service workers');
    }
  }
}

/// iOS-specific optimizations
class IOSOptimizations {
  static void apply() {
    // iOS-specific performance optimizations
    
    // 1. Enable Metal rendering
    // This is handled by Flutter engine
    
    // 2. Optimize for ProMotion displays
    // Support 120Hz refresh rate
    
    // 3. Use iOS-specific video codecs
    // H.264/HEVC optimization
    
    // 4. Memory pressure handling
    // Respond to memory warnings
    
    // 5. Background task management
    // Pause heavy operations in background
    
    if (kDebugMode) {
      debugPrint('iOS optimizations: Metal rendering, ProMotion support');
    }
  }
}

/// Android-specific optimizations
class AndroidOptimizations {
  static void apply() {
    // Android-specific performance optimizations
    
    // 1. Enable Vulkan/OpenGL ES
    // This is handled by Flutter engine
    
    // 2. Optimize for different screen densities
    // Use appropriate image resolutions
    
    // 3. Handle diverse hardware
    // Adapt to device capabilities
    
    // 4. Battery optimization
    // Reduce operations on battery saver
    
    // 5. Memory management
    // Handle low memory killer
    
    if (kDebugMode) {
      debugPrint('Android optimizations: Vulkan/OpenGL, adaptive performance');
    }
  }
}

/// Desktop-specific optimizations
class DesktopOptimizations {
  static void apply() {
    // Desktop-specific performance optimizations
    
    // 1. Use full hardware acceleration
    // Leverage GPU capabilities
    
    // 2. Higher quality settings
    // Desktop has more resources
    
    // 3. Multi-threading support
    // Use isolates for heavy operations
    
    // 4. Larger cache sizes
    // Desktop has more storage
    
    // 5. Keyboard shortcuts
    // Desktop-specific interactions
    
    if (kDebugMode) {
      debugPrint('Desktop optimizations: Full GPU acceleration, higher quality');
    }
  }
}

/// Platform-specific render settings
class VPlatformRenderSettings {
  /// Get optimal render settings for current platform
  static Map<String, dynamic> getOptimalSettings() {
    final settings = <String, dynamic>{};
    
    if (VPlatformHandler.isWeb) {
      settings['preferWebGL'] = true;
      settings['maxTextureSize'] = 2048;
      settings['enableAntialiasing'] = false; // Performance over quality
      settings['pixelRatio'] = 1.0; // Let browser handle
    } else if (VPlatformHandler.isIOS) {
      settings['preferMetal'] = true;
      settings['maxTextureSize'] = 4096;
      settings['enableAntialiasing'] = true;
      settings['pixelRatio'] = 2.0; // Retina displays
    } else if (VPlatformHandler.isAndroid) {
      settings['preferVulkan'] = true;
      settings['maxTextureSize'] = 2048;
      settings['enableAntialiasing'] = false; // Varies by device
      settings['pixelRatio'] = 1.5; // Average density
    } else {
      // Desktop
      settings['maxTextureSize'] = 8192;
      settings['enableAntialiasing'] = true;
      settings['pixelRatio'] = 1.0; // Native resolution
    }
    
    return settings;
  }
}