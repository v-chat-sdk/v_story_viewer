/// Configuration for story gesture handling
/// This is an alias for VGestureConfig with story-specific naming
class VStoryGestureConfig {
  /// Whether tap navigation is enabled
  final bool enableTapNavigation;
  
  /// Whether vertical swipe is enabled
  final bool enableSwipeVertical;
  
  /// Whether long press is enabled
  final bool enableLongPress;
  
  /// Whether double tap is enabled
  final bool enableDoubleTap;
  
  /// Whether haptic feedback is enabled
  final bool enableHapticFeedback;
  
  /// Creates a story gesture configuration
  const VStoryGestureConfig({
    this.enableTapNavigation = true,
    this.enableSwipeVertical = true,
    this.enableLongPress = true,
    this.enableDoubleTap = true,
    this.enableHapticFeedback = true,
  });
}