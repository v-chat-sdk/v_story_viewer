import '../translations/ar.dart';
import '../translations/en.dart';
import '../translations/es.dart';

/// Comprehensive localization model providing type-safe access to all translatable strings
class VLocalization {
  const VLocalization({
    required Map<String, String> translations,
    required this.languageCode,
  }) : _translations = translations;

  /// Create Spanish localization
  factory VLocalization.es() =>
      const VLocalization(translations: esTranslations, languageCode: 'es');

  /// Create Arabic localization
  factory VLocalization.ar() =>
      const VLocalization(translations: arTranslations, languageCode: 'ar');

  /// Create English localization
  factory VLocalization.en() =>
      const VLocalization(translations: enTranslations, languageCode: 'en');

  /// Language code of this localization
  final String languageCode;

  /// Map of all translation keys and values
  final Map<String, String> _translations;

  /// Get translation by key with optional parameter replacement
  String get(String key, [Map<String, String>? params]) {
    final value = _translations[key] ?? key;
    if (params != null) {
      var result = value;
      params.forEach((k, v) {
        result = result.replaceAll('{$k}', v);
      });
      return result;
    }
    return value;
  }

  // ============================================================================
  // ACTION LABELS
  // ============================================================================

  String get reply => get('reply');
  String get send => get('send');
  String get close => get('close');
  String get share => get('share');
  String get save => get('save');
  String get delete => get('delete');
  String get report => get('report');
  String get mute => get('mute');
  String get unmute => get('unmute');
  String get pause => get('pause');
  String get play => get('play');
  String get retry => get('retry');

  // ============================================================================
  // TIME FORMATTING
  // ============================================================================

  String get justNow => get('just_now');
  String minutesAgo(int count) =>
      get('minutes_ago', {'count': count.toString()});
  String hoursAgo(int count) => get('hours_ago', {'count': count.toString()});
  String daysAgo(int count) => get('days_ago', {'count': count.toString()});
  String secondsAgo(int count) =>
      get('seconds_ago', {'count': count.toString()});
  String get weeksAgo => get('weeks_ago');
  String monthsAgo(int count) => get('months_ago', {'count': count.toString()});
  String yearsAgo(int count) => get('years_ago', {'count': count.toString()});

  // ============================================================================
  // ERROR MESSAGES
  // ============================================================================

  String get errorLoading => get('error_loading');
  String get errorNetwork => get('error_network');
  String get errorPermission => get('error_permission');
  String get errorGeneric => get('error_generic');
  String get errorTimeout => get('error_timeout');
  String get errorNotFound => get('error_not_found');
  String get errorCustom => get('error_custom');
  String get errorUnknown => get('error_unknown');

  // ============================================================================
  // ERROR HEADERS & STATES
  // ============================================================================

  String get errorHeader => get('error_header');
  String get errorMaxRetries => get('error_max_retries');
  String get errorRetrying => get('error_retrying');
  String errorRetriesLeft(int count) =>
      get('error_retries_left', {'count': count.toString()});

  // ============================================================================
  // VALIDATION ERRORS
  // ============================================================================

  String errorInvalidIndex(int index, int max) => get('error_invalid_index', {
    'index': index.toString(),
    'max': max.toString(),
  });
  String errorStoryNotFound(String storyId, String groupId) =>
      get('error_story_not_found', {'storyId': storyId, 'groupId': groupId});
  String get errorEmptyStories => get('error_empty_stories');
  String get errorDuplicateIds => get('error_duplicate_ids');
  String get errorEmptyId => get('error_empty_id');
  String get errorEmptyGroups => get('error_empty_groups');
  String get errorInvalidGroupIndex => get('error_invalid_group_index');
  String get errorInvalidStoryIndex => get('error_invalid_story_index');

  // ============================================================================
  // MEDIA TYPE ERRORS
  // ============================================================================

  String get errorTextEmpty => get('error_text_empty');
  String get errorInvalidPlatformFile => get('error_invalid_platform_file');
  String get errorUnknownStoryType => get('error_unknown_story_type');
  String get errorWebFileOps => get('error_web_file_ops');
  String get errorWebBytesOps => get('error_web_bytes_ops');

  // ============================================================================
  // CONTROLLER VALIDATION
  // ============================================================================

  String get errorTextController => get('error_text_controller');
  String get errorImageController => get('error_image_controller');
  String get errorVideoController => get('error_video_controller');
  String get errorCustomController => get('error_custom_controller');

  // ============================================================================
  // PROGRESS BAR ERRORS
  // ============================================================================

  String get errorBarCount => get('error_bar_count');
  String errorBarIndex(int index) =>
      get('error_bar_index', {'index': index.toString()});

  // ============================================================================
  // CACHE CONFIGURATION ERRORS
  // ============================================================================

  String get errorMaxAge => get('error_max_age');
  String get errorStaleDuration => get('error_stale_duration');
  String get errorStaleMaxAge => get('error_stale_max_age');
  String get errorCacheMaxRetries => get('error_cache_max_retries');
  String get errorEmptyStoryId => get('error_empty_story_id');
  String get errorEmptyUrl => get('error_empty_url');
  String get errorNegativeBytes => get('error_negative_bytes');
  String get errorBaseDelay => get('error_base_delay');
  String get errorNegativeAttempt => get('error_negative_attempt');

  // ============================================================================
  // CONTEXT MENU ACTIONS
  // ============================================================================

  String get actionCopyCaption => get('action_copy_caption');
  String get actionViewDetails => get('action_view_details');

  // ============================================================================
  // VOICE INPUT STATES
  // ============================================================================

  String get voiceReady => get('voice_ready');
  String get voiceInitializing => get('voice_initializing');
  String get voiceListening => get('voice_listening');
  String get voiceProcessing => get('voice_processing');
  String get voiceRecognized => get('voice_recognized');
  String get voiceError => get('voice_error');

  // ============================================================================
  // GESTURE LABELS
  // ============================================================================

  String get gestureSlow => get('gesture_slow');
  String get gestureNormal => get('gesture_normal');
  String get gestureFast => get('gesture_fast');
  String get gestureVeryFast => get('gesture_very_fast');

  // ============================================================================
  // DIRECTION LABELS
  // ============================================================================

  String get directionLeft => get('direction_left');
  String get directionRight => get('direction_right');
  String get directionUp => get('direction_up');
  String get directionDown => get('direction_down');
  String get directionNone => get('direction_none');

  // ============================================================================
  // TOOLTIPS & ACCESSIBILITY
  // ============================================================================

  String get tooltipMuteVideo => get('tooltip_mute_video');
  String get tooltipUnmuteVideo => get('tooltip_unmute_video');
  String get tooltipMoreOptions => get('tooltip_more_options');
  String get tooltipCloseViewer => get('tooltip_close_viewer');
  String get tooltipShowKeyboard => get('tooltip_show_keyboard');
  String get tooltipShowEmoji => get('tooltip_show_emoji');
  String get tooltipCloseEmoji => get('tooltip_close_emoji');
  String get tooltipGestureControls => get('tooltip_gesture_controls');

  // ============================================================================
  // PLACEHOLDER & HINT TEXT
  // ============================================================================

  String get placeholderNoEmojis => get('placeholder_no_emojis');
  String get placeholderMessage => get('placeholder_message');
  String get placeholderSearch => get('placeholder_search');
  String get placeholderVoiceText => get('placeholder_voice_text');

  // ============================================================================
  // ENGAGEMENT INDICATORS
  // ============================================================================

  String engagementViews(String count) =>
      get('engagement_views', {'count': count});
  String engagementReactions(String count) =>
      get('engagement_reactions', {'count': count});
  String engagementShares(String count) =>
      get('engagement_shares', {'count': count});
  String engagementComments(String count) =>
      get('engagement_comments', {'count': count});

  // ============================================================================
  // CAPTION DISPLAY
  // ============================================================================

  String get captionShowMore => get('caption_show_more');

  // ============================================================================
  // STORY TYPES
  // ============================================================================

  String get storyTypeText => get('story_type_text');
  String get storyTypeImage => get('story_type_image');
  String get storyTypeVideo => get('story_type_video');
  String get storyTypeCustom => get('story_type_custom');
  String get storyTypeUnknown => get('story_type_unknown');

  // ============================================================================
  // SIZE FORMATTING
  // ============================================================================

  String sizeBytes(String size) => get('size_bytes', {'size': size});
  String sizeKilobytes(String size) => get('size_kilobytes', {'size': size});
  String sizeMegabytes(String size) => get('size_megabytes', {'size': size});
  String get sizeUnknown => get('size_unknown');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VLocalization &&
          runtimeType == other.runtimeType &&
          languageCode == other.languageCode &&
          _translations == other._translations;

  @override
  int get hashCode => languageCode.hashCode ^ _translations.hashCode;
}
