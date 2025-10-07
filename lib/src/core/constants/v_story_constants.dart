/// Constants used throughout the v_story_viewer package
///
/// This file centralizes all magic numbers and hardcoded values
/// to improve code readability and maintainability.
library v_story_constants;

/// Animation and timing constants
class VStoryAnimationConstants {
  VStoryAnimationConstants._();

  /// Frame interval for progress bar animation (60 FPS)
  static const Duration animationFrameInterval = Duration(milliseconds: 16);

  /// Legacy frame interval (kept for backward compatibility)
  static const Duration legacyFrameInterval = Duration(milliseconds: 60);

  /// Debounce delay for carousel scrolling
  static const Duration carouselDebounceDelay = Duration(milliseconds: 100);

  /// Default story transition duration
  static const Duration storyTransitionDuration = Duration(milliseconds: 300);

  /// Video progress sync interval
  static const Duration videoProgressSyncInterval = Duration(milliseconds: 100);

  /// Long press detection threshold
  static const Duration longPressThreshold = Duration(milliseconds: 500);

  /// Double tap detection window
  static const Duration doubleTapWindow = Duration(milliseconds: 300);
}

/// UI dimension constants
class VStoryDimensionConstants {
  VStoryDimensionConstants._();

  /// Default progress bar height
  static const double progressBarHeight = 2;

  /// Default progress bar spacing
  static const double progressBarSpacing = 2;

  /// Default tap zone width ratios
  static const double defaultLeftTapZoneWidth = 0.3;
  static const double defaultRightTapZoneWidth = 0.7;

  /// Header and footer heights
  static const double defaultHeaderHeight = 80;
  static const double defaultFooterHeight = 60;

  /// Loading indicator size
  static const double loadingIndicatorSize = 48;

  /// Reaction bubble size
  static const double reactionBubbleSize = 40;

  /// Border radius values
  static const double defaultBorderRadius = 8;
  static const double smallBorderRadius = 4;
  static const double largeBorderRadius = 16;
}

/// Color and opacity constants
class VStoryColorConstants {
  VStoryColorConstants._();

  /// Overlay background opacity
  static const double overlayBackgroundOpacity = 0.7;

  /// Loading progress indicator opacity
  static const double loadingProgressOpacity = 0.3;

  /// Inactive progress bar opacity
  static const double inactiveProgressOpacity = 0.3;

  /// Text shadow opacity
  static const double textShadowOpacity = 0.8;

  /// Gesture feedback opacity
  static const double gestureFeedbackOpacity = 0.1;
}

/// Story duration constants
class VStoryDurationConstants {
  VStoryDurationConstants._();

  /// Default image story duration
  static const Duration defaultImageDuration = Duration(seconds: 5);

  /// Default text story duration
  static const Duration defaultTextDuration = Duration(seconds: 3);

  /// Minimum story duration
  static const Duration minimumStoryDuration = Duration(seconds: 1);

  /// Maximum story duration
  static const Duration maximumStoryDuration = Duration(minutes: 1);

  /// Default words per minute for text duration calculation
  static const int defaultWordsPerMinute = 200;
}

/// Cache and storage constants
class VStoryCacheConstants {
  VStoryCacheConstants._();

  /// Default cache size in MB
  static const int defaultCacheSizeMB = 100;

  /// Maximum cache age in days
  static const int maxCacheAgeDays = 7;

  /// Maximum concurrent downloads
  static const int maxConcurrentDownloads = 3;

  /// Download retry attempts
  static const int maxRetryAttempts = 3;

  /// Download timeout duration
  static const Duration downloadTimeout = Duration(seconds: 30);
}

/// Gesture detection constants
class VStoryGestureConstants {
  VStoryGestureConstants._();

  /// Minimum swipe distance to trigger navigation
  static const double minSwipeDistance = 50;

  /// Minimum swipe velocity to trigger navigation
  static const double minSwipeVelocity = 300;

  /// Maximum tap duration to be considered a tap (not long press)
  static const Duration maxTapDuration = Duration(milliseconds: 100);

  /// Swipe down dismiss threshold (as fraction of screen height)
  static const double swipeDownDismissThreshold = 0.15;
}

/// Text and content constants
class VStoryTextConstants {
  VStoryTextConstants._();

  /// Default loading message
  static const String defaultLoadingMessage = 'Loading...';

  /// Default error message
  static const String defaultErrorMessage = 'Something went wrong';

  /// Default retry message
  static const String defaultRetryMessage = 'Tap to retry';

  /// Default reply placeholder
  static const String defaultReplyPlaceholder = 'Reply to story...';

  /// Maximum caption length
  static const int maxCaptionLength = 500;

  /// Maximum reply length
  static const int maxReplyLength = 200;
}

/// Performance and optimization constants
class VStoryPerformanceConstants {
  VStoryPerformanceConstants._();

  /// Maximum number of stories to preload
  static const int maxPreloadCount = 3;

  /// Video controller pool size
  static const int videoControllerPoolSize = 2;

  /// Image cache memory limit (in MB)
  static const int imageCacheMemoryLimit = 50;

  /// Maximum widget rebuild frequency (FPS)
  static const int maxRebuildFrequency = 60;
}

/// Error handling constants
class VStoryErrorConstants {
  VStoryErrorConstants._();

  /// Default error display duration
  static const Duration errorDisplayDuration = Duration(seconds: 3);

  /// Maximum error retry attempts
  static const int maxErrorRetryAttempts = 3;

  /// Error recovery delay
  static const Duration errorRecoveryDelay = Duration(seconds: 1);
}

/// Accessibility constants
class VStoryAccessibilityConstants {
  VStoryAccessibilityConstants._();

  /// Minimum touch target size (following Material guidelines)
  static const double minTouchTargetSize = 44;

  /// Focus highlight border width
  static const double focusHighlightBorderWidth = 2;

  /// Screen reader announcement delay
  static const Duration screenReaderDelay = Duration(milliseconds: 500);
}

/// Development and debugging constants
class VStoryDebugConstants {
  VStoryDebugConstants._();

  /// Enable debug mode by default in debug builds
  static const bool enableDebugMode = true;

  /// Debug overlay opacity
  static const double debugOverlayOpacity = 0.8;

  /// Performance monitoring sample rate
  static const double performanceMonitoringSampleRate = 0.1;
}
