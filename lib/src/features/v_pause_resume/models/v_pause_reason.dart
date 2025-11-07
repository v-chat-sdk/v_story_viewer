/// Enum representing the reason why a story was paused
enum VPauseReason {
  /// Paused due to long press gesture
  longPress,

  /// Paused due to reply input focus
  replyFocus,

  /// Paused due to carousel scrolling
  carouselScroll,

  /// Paused due to story navigation/transition
  navigation,

  /// Paused programmatically
  manual,

  /// Paused due to error or media issue
  error,

  /// Paused due to app lifecycle (e.g., app paused)
  appLifecycle,
}
