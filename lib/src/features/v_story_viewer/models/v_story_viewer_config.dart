import 'package:flutter/material.dart';

import 'v_story_transition.dart';

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
    this.loadingSpinnerColor,
    this.transitionConfig = const VTransitionConfig(),
    this.groupSwipeDirection = Axis.horizontal,
    this.groupTransitionType = VTransitionType.slide,
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

  /// Color of the loading spinner (defaults to theme's primary color)
  final Color? loadingSpinnerColor;

  /// Configuration for story transition animations
  final VTransitionConfig transitionConfig;

  /// Swipe direction for group-to-group navigation
  ///
  /// Controls whether users swipe horizontally (Axis.horizontal) or
  /// vertically (Axis.vertical) to navigate between story groups.
  /// Defaults to horizontal.
  final Axis groupSwipeDirection;

  /// Transition type for group-to-group navigation
  ///
  /// Controls the animation style when transitioning between story groups.
  /// Supports slide, fade, and zoom transitions.
  /// Defaults to slide (cube effect for horizontal, smooth transitions).
  final VTransitionType groupTransitionType;

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
    Color? loadingSpinnerColor,
    VTransitionConfig? transitionConfig,
    Axis? groupSwipeDirection,
    VTransitionType? groupTransitionType,
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
      loadingSpinnerColor: loadingSpinnerColor ?? this.loadingSpinnerColor,
      transitionConfig: transitionConfig ?? this.transitionConfig,
      groupSwipeDirection: groupSwipeDirection ?? this.groupSwipeDirection,
      groupTransitionType: groupTransitionType ?? this.groupTransitionType,
    );
  }
}
