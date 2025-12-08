/// Configurable texts for [VStoryViewer] internationalization (i18n).
///
/// All strings have English defaults. Override any or all for localization.
/// Used for both visible text and screen reader accessibility labels.
///
/// ## Basic Usage
/// ```dart
/// VStoryViewer(
///   groups: myGroups,
///   config: VStoryConfig(
///     texts: VStoryTexts(
///       replyHint: 'Nachricht senden...',
///       closeLabel: 'Schließen',
///     ),
///   ),
/// )
/// ```
///
/// ## Full Localization Example (German)
/// ```dart
/// VStoryTexts(
///   replyHint: 'Nachricht senden...',
///   pauseLabel: 'Pausieren',
///   playLabel: 'Abspielen',
///   muteLabel: 'Stumm',
///   unmuteLabel: 'Ton an',
///   closeLabel: 'Schließen',
///   nextLabel: 'Weiter',
///   previousLabel: 'Zurück',
///   sendLabel: 'Senden',
///   viewedLabel: 'Gesehen',
///   errorLoadingMedia: 'Medien konnten nicht geladen werden',
///   tapToRetry: 'Tippen zum Wiederholen',
///   backLabel: 'Zurück',
///   menuLabel: 'Menü',
///   emojiLabel: 'Emoji',
///   keyboardLabel: 'Tastatur',
///   noRecentEmojis: 'Keine kürzlichen Emojis',
///   searchEmoji: 'Emoji suchen',
/// )
/// ```
///
/// ## Accessibility
/// Labels marked as "Accessibility label" are used by screen readers
/// (TalkBack on Android, VoiceOver on iOS) to announce button purposes.
/// Ensure translations are clear and descriptive for visually impaired users.
///
/// ## Text Categories
/// | Category | Fields |
/// |----------|--------|
/// | Reply Field | replyHint, sendLabel, emojiLabel, keyboardLabel |
/// | Playback Controls | pauseLabel, playLabel, muteLabel, unmuteLabel |
/// | Navigation | nextLabel, previousLabel, backLabel, closeLabel |
/// | Status | viewedLabel, errorLoadingMedia, tapToRetry |
/// | Emoji Picker | noRecentEmojis, searchEmoji |
class VStoryTexts {
  /// Placeholder text shown in the reply input field.
  ///
  /// Displayed when the input is empty. Default: "Send message..."
  final String replyHint;

  /// Accessibility label for the pause button.
  ///
  /// Announced by screen readers. Default: "Pause"
  final String pauseLabel;

  /// Accessibility label for the play button.
  ///
  /// Announced by screen readers. Default: "Play"
  final String playLabel;

  /// Accessibility label for the mute button.
  ///
  /// Announced by screen readers. Default: "Mute"
  final String muteLabel;

  /// Accessibility label for the unmute button.
  ///
  /// Announced by screen readers. Default: "Unmute"
  final String unmuteLabel;

  /// Accessibility label for the close (X) button.
  ///
  /// Announced by screen readers. Default: "Close"
  final String closeLabel;

  /// Accessibility label for the next story gesture/button.
  ///
  /// Announced by screen readers. Default: "Next"
  final String nextLabel;

  /// Accessibility label for the previous story gesture/button.
  ///
  /// Announced by screen readers. Default: "Previous"
  final String previousLabel;

  /// Accessibility label for the send reply button.
  ///
  /// Announced by screen readers. Default: "Send"
  final String sendLabel;

  /// Label shown for the viewed/seen indicator.
  ///
  /// May be displayed in UI. Default: "Viewed"
  final String viewedLabel;

  /// Error message shown when media fails to load.
  ///
  /// Displayed to user on load failure. Default: "Failed to load media"
  final String errorLoadingMedia;

  /// Action text prompting user to retry on error.
  ///
  /// Usually shown below error message. Default: "Tap to retry"
  final String tapToRetry;

  /// Accessibility label for the back button.
  ///
  /// Announced by screen readers. Default: "Back"
  final String backLabel;

  /// Accessibility label for the menu (three dots) button.
  ///
  /// Announced by screen readers. Default: "Menu"
  final String menuLabel;

  /// Accessibility label for the emoji picker button.
  ///
  /// Announced by screen readers. Default: "Emoji"
  final String emojiLabel;

  /// Accessibility label for the keyboard toggle button.
  ///
  /// Announced by screen readers. Default: "Keyboard"
  final String keyboardLabel;

  /// Text shown in emoji picker when no recent emojis exist.
  ///
  /// Default: "No recent emojis"
  final String noRecentEmojis;

  /// Placeholder text for emoji search input.
  ///
  /// Default: "Search emoji"
  final String searchEmoji;

  /// Creates configurable texts for [VStoryViewer].
  ///
  /// All parameters have English defaults.
  const VStoryTexts({
    this.replyHint = 'Send message...',
    this.pauseLabel = 'Pause',
    this.playLabel = 'Play',
    this.muteLabel = 'Mute',
    this.unmuteLabel = 'Unmute',
    this.closeLabel = 'Close',
    this.nextLabel = 'Next',
    this.previousLabel = 'Previous',
    this.sendLabel = 'Send',
    this.viewedLabel = 'Viewed',
    this.errorLoadingMedia = 'Failed to load media',
    this.tapToRetry = 'Tap to retry',
    this.backLabel = 'Back',
    this.menuLabel = 'Menu',
    this.emojiLabel = 'Emoji',
    this.keyboardLabel = 'Keyboard',
    this.noRecentEmojis = 'No recent emojis',
    this.searchEmoji = 'Search emoji',
  });
  VStoryTexts copyWith({
    String? replyHint,
    String? pauseLabel,
    String? playLabel,
    String? muteLabel,
    String? unmuteLabel,
    String? closeLabel,
    String? nextLabel,
    String? previousLabel,
    String? sendLabel,
    String? viewedLabel,
    String? errorLoadingMedia,
    String? tapToRetry,
    String? backLabel,
    String? menuLabel,
    String? emojiLabel,
    String? keyboardLabel,
    String? noRecentEmojis,
    String? searchEmoji,
  }) {
    return VStoryTexts(
      replyHint: replyHint ?? this.replyHint,
      pauseLabel: pauseLabel ?? this.pauseLabel,
      playLabel: playLabel ?? this.playLabel,
      muteLabel: muteLabel ?? this.muteLabel,
      unmuteLabel: unmuteLabel ?? this.unmuteLabel,
      closeLabel: closeLabel ?? this.closeLabel,
      nextLabel: nextLabel ?? this.nextLabel,
      previousLabel: previousLabel ?? this.previousLabel,
      sendLabel: sendLabel ?? this.sendLabel,
      viewedLabel: viewedLabel ?? this.viewedLabel,
      errorLoadingMedia: errorLoadingMedia ?? this.errorLoadingMedia,
      tapToRetry: tapToRetry ?? this.tapToRetry,
      backLabel: backLabel ?? this.backLabel,
      menuLabel: menuLabel ?? this.menuLabel,
      emojiLabel: emojiLabel ?? this.emojiLabel,
      keyboardLabel: keyboardLabel ?? this.keyboardLabel,
      noRecentEmojis: noRecentEmojis ?? this.noRecentEmojis,
      searchEmoji: searchEmoji ?? this.searchEmoji,
    );
  }
}
