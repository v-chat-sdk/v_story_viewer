import 'package:flutter/foundation.dart';

/// Configuration options for VStoryViewer
@immutable
class VStoryViewerConfig {
  const VStoryViewerConfig({
    this.enableHapticFeedback = true,
    this.pauseOnLongPress = true,
    this.dismissOnSwipeDown = true,
    this.autoMoveToNextGroup = true,
    this.restartGroupWhenAllViewed = false,
    this.enableCarousel = true,
    this.pauseOnCarouselScroll = true,
    this.carouselAnimationDuration = const Duration(milliseconds: 300),
    this.maxContentWidth = 600.0,
  });

  /// Enable haptic feedback for gestures
  final bool enableHapticFeedback;

  /// Pause story on long press
  final bool pauseOnLongPress;

  /// Dismiss viewer on swipe down gesture
  final bool dismissOnSwipeDown;

  /// Automatically move to next group after current group completes
  final bool autoMoveToNextGroup;

  /// Restart group from beginning when all stories viewed
  final bool restartGroupWhenAllViewed;

  /// Enable carousel mode for horizontal swipe between groups
  ///
  /// When true and multiple story groups are provided, enables horizontal
  /// swipe navigation between groups using carousel slider.
  /// When false, uses traditional auto-advance to next group only.
  final bool enableCarousel;

  /// Pause current story while user is scrolling the carousel
  ///
  /// When true, story progress and media playback pause during horizontal swipe.
  /// This provides smoother UX and prevents story advancement during navigation.
  final bool pauseOnCarouselScroll;

  /// Duration for carousel page transition animation
  final Duration carouselAnimationDuration;

  /// Maximum width for header and progress bar content
  final double maxContentWidth;

  /// Default configuration
  static const defaultConfig = VStoryViewerConfig();

  VStoryViewerConfig copyWith({
    bool? enableHapticFeedback,
    bool? pauseOnLongPress,
    bool? dismissOnSwipeDown,
    bool? autoMoveToNextGroup,
    bool? restartGroupWhenAllViewed,
    bool? enableCarousel,
    bool? pauseOnCarouselScroll,
    Duration? carouselAnimationDuration,
    double? maxContentWidth,
  }) {
    return VStoryViewerConfig(
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      pauseOnLongPress: pauseOnLongPress ?? this.pauseOnLongPress,
      dismissOnSwipeDown: dismissOnSwipeDown ?? this.dismissOnSwipeDown,
      autoMoveToNextGroup: autoMoveToNextGroup ?? this.autoMoveToNextGroup,
      restartGroupWhenAllViewed:
          restartGroupWhenAllViewed ?? this.restartGroupWhenAllViewed,
      enableCarousel: enableCarousel ?? this.enableCarousel,
      pauseOnCarouselScroll:
          pauseOnCarouselScroll ?? this.pauseOnCarouselScroll,
      carouselAnimationDuration:
          carouselAnimationDuration ?? this.carouselAnimationDuration,
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
    );
  }
}
