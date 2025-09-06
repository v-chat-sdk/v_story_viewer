import 'package:flutter/foundation.dart';
import 'package:v_platform/v_platform.dart' as v_platform;

/// Handles platform-specific behaviors for iOS, Android, and web.
/// 
/// This class provides utilities to handle platform differences
/// and ensure consistent behavior across all supported platforms.
class VPlatformHandler {
  /// Private constructor to prevent instantiation
  VPlatformHandler._();
  
  /// Whether the app is running on web
  static bool get isWeb => kIsWeb;
  
  /// Whether the app is running on mobile (iOS or Android)
  static bool get isMobile => !kIsWeb && (isIOS || isAndroid);
  
  /// Whether the app is running on iOS
  static bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  
  /// Whether the app is running on Android
  static bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  
  /// Whether the app is running on desktop
  static bool get isDesktop => !kIsWeb && !isMobile;
  
  /// Gets the current platform as a string
  static String get platformName {
    if (isWeb) return 'Web';
    if (isIOS) return 'iOS';
    if (isAndroid) return 'Android';
    if (defaultTargetPlatform == TargetPlatform.macOS) return 'macOS';
    if (defaultTargetPlatform == TargetPlatform.windows) return 'Windows';
    if (defaultTargetPlatform == TargetPlatform.linux) return 'Linux';
    return 'Unknown';
  }
  
  /// Gets the optimal image cache size based on platform
  static int getOptimalImageCacheSize() {
    if (isWeb) {
      // Web has different memory constraints
      return 50; // 50 MB
    } else if (isIOS) {
      // iOS has stricter memory management
      return 100; // 100 MB
    } else if (isAndroid) {
      // Android can typically handle more
      return 150; // 150 MB
    } else {
      // Desktop platforms
      return 200; // 200 MB
    }
  }
  
  /// Gets the optimal video cache count based on platform
  static int getOptimalVideoCacheCount() {
    if (isWeb) {
      // Limited video caching on web
      return 1;
    } else if (isMobile) {
      // Mobile devices have memory constraints
      return 3;
    } else {
      // Desktop can handle more
      return 5;
    }
  }
  
  /// Whether to use hardware acceleration for video
  static bool shouldUseHardwareAcceleration() {
    // Hardware acceleration is generally available on mobile
    // but may have issues on web
    return isMobile;
  }
  
  /// Whether to preload next stories
  static bool shouldPreloadStories() {
    // Preloading is beneficial on mobile with good network
    // but should be limited on web
    return isMobile;
  }
  
  /// Maximum number of stories to preload
  static int getMaxPreloadCount() {
    if (isWeb) return 1;
    if (isMobile) return 2;
    return 3; // Desktop
  }
  
  /// Whether to show download/save options
  static bool canDownloadMedia() {
    // Web has restrictions on downloading
    // Mobile platforms need permissions
    return !isWeb;
  }
  
  /// Whether to use native share functionality
  static bool canShareNatively() {
    // Native share is available on mobile
    // Web uses Web Share API (limited support)
    return isMobile || isWeb;
  }
  
  /// Gets the appropriate file source for the platform
  static v_platform.VPlatformFile adaptFileForPlatform(
    v_platform.VPlatformFile file,
  ) {
    // On web, we might need to handle files differently
    if (isWeb && file.fileLocalPath != null) {
      // Web can't access local file paths directly
      // This would need special handling in actual implementation
    }
    
    return file;
  }
  
  /// Whether haptic feedback is available
  static bool canUseHapticFeedback() {
    // Haptic feedback is primarily for mobile devices
    return isMobile;
  }
  
  /// Whether to use aggressive caching
  static bool shouldUseAggressiveCaching() {
    // Mobile benefits from aggressive caching
    // Web has different caching mechanisms
    return isMobile;
  }
  
  /// Gets memory warning threshold in MB
  static int getMemoryWarningThreshold() {
    if (isWeb) return 30;
    if (isIOS) return 40;
    if (isAndroid) return 50;
    return 100; // Desktop
  }
  
  /// Whether to enable performance monitoring
  static bool shouldEnablePerformanceMonitoring() {
    // Enable in debug mode or based on platform
    return kDebugMode || isWeb;
  }
  
  /// Gets the appropriate transition duration
  static Duration getTransitionDuration() {
    if (isWeb) {
      // Web might need slightly longer transitions
      return const Duration(milliseconds: 350);
    }
    return const Duration(milliseconds: 300);
  }
  
  /// Whether to use image compression
  static bool shouldCompressImages() {
    // Mobile benefits from image compression
    return isMobile;
  }
  
  /// Gets the image compression quality (0-100)
  static int getImageCompressionQuality() {
    if (isWeb) return 85;
    if (isMobile) return 80;
    return 90; // Desktop
  }
}