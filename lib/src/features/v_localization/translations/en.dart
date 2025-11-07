/// English translations
const Map<String, String> enTranslations = {
  // Action Labels
  'reply': 'Reply to story...',
  'send': 'Send',
  'close': 'Close',
  'share': 'Share',
  'save': 'Save',
  'delete': 'Delete',
  'report': 'Report',
  'mute': 'Mute',
  'unmute': 'Unmute',
  'pause': 'Pause',
  'play': 'Play',
  'retry': 'Retry',

  // Time Formatting
  'just_now': 'Just now',
  'minutes_ago': '{count}m ago',
  'hours_ago': '{count}h ago',
  'days_ago': '{count}d ago',
  'seconds_ago': '{count}s ago',
  'weeks_ago': 'weeks ago',
  'months_ago': '{count}mo ago',
  'years_ago': '{count}y ago',

  // Error Messages
  'error_loading': 'Failed to load story',
  'error_network': 'Network error',
  'error_permission': 'Permission denied',
  'error_generic': 'An error occurred',
  'error_timeout': 'The request timed out. Please try again.',
  'error_not_found': 'Story not found or deleted.',
  'error_custom': 'Error loading custom story',
  'error_unknown': 'Unknown error',

  // Error Headers & States
  'error_header': 'Error',
  'error_max_retries': 'Max retries reached',
  'error_retrying': 'Retrying...',
  'error_retries_left': 'Retries left: {count}',

  // Validation Errors
  'error_invalid_index': 'Index {index} out of bounds. Valid: 0-{max}',
  'error_story_not_found': 'Story "{storyId}" not found in group "{groupId}"',
  'error_empty_stories': 'Story group cannot have empty stories list',
  'error_duplicate_ids': 'Story group contains duplicate story IDs',
  'error_empty_id': 'Story group contains story with empty ID',
  'error_empty_groups': 'Story groups cannot be empty',
  'error_invalid_group_index': 'Initial group index out of bounds',
  'error_invalid_story_index': 'Initial story index out of bounds',

  // Media Type Errors
  'error_text_empty': 'Text story cannot be empty',
  'error_invalid_platform_file': 'VPlatformFile must have a valid media source',
  'error_unknown_story_type': 'Unknown story type please update the app to latest version',
  'error_web_file_ops': 'File operations are not supported on web. Use VPlatformFile.assetsPath directly.',
  'error_web_bytes_ops': 'File operations are not supported on web. Use VPlatformFile.bytes directly.',

  // Controller Validation
  'error_text_controller': 'VTextController requires VTextStory',
  'error_image_controller': 'VImageController requires VImageStory',
  'error_video_controller': 'VVideoController requires VVideoStory',
  'error_custom_controller': 'VCustomController requires VCustomStory',

  // Progress Bar Errors
  'error_bar_count': 'barCount must be greater than 0',
  'error_bar_index': 'Index out of bounds: {index}',

  // Cache Configuration Errors
  'error_max_age': 'maxAge must be positive',
  'error_stale_duration': 'staleDuration must be positive',
  'error_stale_max_age': 'staleDuration must be >= maxAge',
  'error_cache_max_retries': 'maxRetries must be non-negative',
  'error_empty_story_id': 'storyId must not be empty',
  'error_empty_url': 'url must not be empty',
  'error_negative_bytes': 'downloadedBytes must be non-negative',
  'error_base_delay': 'baseDelay must be positive',
  'error_negative_attempt': 'attempt must be non-negative',

  // Context Menu Actions
  'action_copy_caption': 'Copy caption',
  'action_view_details': 'View details',

  // Voice Input States
  'voice_ready': 'Ready',
  'voice_initializing': 'Initializing...',
  'voice_listening': 'Listening...',
  'voice_processing': 'Processing...',
  'voice_recognized': 'Recognized',
  'voice_error': 'Error',

  // Gesture Labels
  'gesture_slow': 'Slow',
  'gesture_normal': 'Normal',
  'gesture_fast': 'Fast',
  'gesture_very_fast': 'Very Fast',

  // Direction Labels
  'direction_left': 'Left',
  'direction_right': 'Right',
  'direction_up': 'Up',
  'direction_down': 'Down',
  'direction_none': 'None',

  // Tooltips & Accessibility
  'tooltip_mute_video': 'Mute video',
  'tooltip_unmute_video': 'Unmute video',
  'tooltip_more_options': 'More options',
  'tooltip_close_viewer': 'Close story viewer',
  'tooltip_show_keyboard': 'Show keyboard',
  'tooltip_show_emoji': 'Show emoji picker',
  'tooltip_close_emoji': 'Close emoji picker',
  'tooltip_gesture_controls': 'Story viewer gesture controls',

  // Placeholder & Hint Text
  'placeholder_no_emojis': 'No recent emojis',
  'placeholder_message': 'Send a message',
  'placeholder_search': 'Search',
  'placeholder_voice_text': 'Your speech text here',

  // Engagement Indicators
  'engagement_views': '{count} views',
  'engagement_reactions': '{count} reactions',
  'engagement_shares': '{count} shares',
  'engagement_comments': '{count} comments',

  // Caption Display
  'caption_show_more': 'Show more',

  // Story Types
  'story_type_text': 'Text',
  'story_type_image': 'Image',
  'story_type_video': 'Video',
  'story_type_custom': 'Custom',
  'story_type_unknown': 'Unknown',

  // Size Formatting
  'size_bytes': '{size} B',
  'size_kilobytes': '{size} KB',
  'size_megabytes': '{size} MB',
  'size_unknown': 'Unknown',
};
