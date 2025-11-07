/// Arabic translations
const Map<String, String> arTranslations = {
  // Action Labels
  'reply': 'الرد على القصة...',
  'send': 'إرسال',
  'close': 'إغلاق',
  'share': 'مشاركة',
  'save': 'حفظ',
  'delete': 'حذف',
  'report': 'إبلاغ',
  'mute': 'كتم الصوت',
  'unmute': 'إلغاء كتم الصوت',
  'pause': 'إيقاف مؤقت',
  'play': 'تشغيل',
  'retry': 'إعادة المحاولة',

  // Time Formatting
  'just_now': 'الآن',
  'minutes_ago': 'منذ {count}d',
  'hours_ago': 'منذ {count}س',
  'days_ago': 'منذ {count}ي',
  'seconds_ago': 'منذ {count}ث',
  'weeks_ago': 'منذ أسابيع',
  'months_ago': 'منذ {count}شهر',
  'years_ago': 'منذ {count}سنة',

  // Error Messages
  'error_loading': 'فشل تحميل القصة',
  'error_network': 'خطأ في الشبكة',
  'error_permission': 'تم رفض الإذن',
  'error_generic': 'حدث خطأ ما',
  'error_timeout': 'انتهت مهلة الانتظار. يرجى المحاولة مرة أخرى.',
  'error_not_found': 'لم يتم العثور على القصة أو تم حذفها.',
  'error_custom': 'خطأ في تحميل القصة المخصصة',
  'error_unknown': 'خطأ غير معروف',

  // Error Headers & States
  'error_header': 'خطأ',
  'error_max_retries': 'تم الوصول إلى الحد الأقصى لمحاولات إعادة المحاولة',
  'error_retrying': 'جاري إعادة المحاولة...',
  'error_retries_left': 'محاولات متبقية: {count}',

  // Validation Errors
  'error_invalid_index': 'الفهرس {index} خارج النطاق. الصحيح: 0-{max}',
  'error_story_not_found': 'لم يتم العثور على القصة "{storyId}" في المجموعة "{groupId}"',
  'error_empty_stories': 'مجموعة القصص لا يمكن أن تكون فارغة',
  'error_duplicate_ids': 'مجموعة القصص تحتوي على معرفات مكررة',
  'error_empty_id': 'مجموعة القصص تحتوي على قصة بمعرف فارغ',
  'error_empty_groups': 'مجموعات القصص لا يمكن أن تكون فارغة',
  'error_invalid_group_index': 'فهرس المجموعة الأولي خارج النطاق',
  'error_invalid_story_index': 'فهرس القصة الأولي خارج النطاق',

  // Media Type Errors
  'error_text_empty': 'قصة النص لا يمكن أن تكون فارغة',
  'error_invalid_platform_file': 'VPlatformFile يجب أن يحتوي على مصدر وسائط صحيح',
  'error_unknown_story_type': 'نوع قصة غير معروف، يرجى تحديث التطبيق إلى أحدث نسخة',
  'error_web_file_ops': 'عمليات الملفات غير مدعومة على الويب. استخدم VPlatformFile.assetsPath مباشرة.',
  'error_web_bytes_ops': 'عمليات الملفات غير مدعومة على الويب. استخدم VPlatformFile.bytes مباشرة.',

  // Controller Validation
  'error_text_controller': 'VTextController يتطلب VTextStory',
  'error_image_controller': 'VImageController يتطلب VImageStory',
  'error_video_controller': 'VVideoController يتطلب VVideoStory',
  'error_custom_controller': 'VCustomController يتطلب VCustomStory',

  // Progress Bar Errors
  'error_bar_count': 'barCount يجب أن يكون أكبر من 0',
  'error_bar_index': 'الفهرس خارج النطاق: {index}',

  // Cache Configuration Errors
  'error_max_age': 'maxAge يجب أن يكون موجباً',
  'error_stale_duration': 'staleDuration يجب أن يكون موجباً',
  'error_stale_max_age': 'staleDuration يجب أن يكون >= maxAge',
  'error_cache_max_retries': 'maxRetries يجب أن يكون غير سالب',
  'error_empty_story_id': 'storyId لا يجب أن يكون فارغاً',
  'error_empty_url': 'url لا يجب أن يكون فارغاً',
  'error_negative_bytes': 'downloadedBytes يجب أن يكون غير سالب',
  'error_base_delay': 'baseDelay يجب أن يكون موجباً',
  'error_negative_attempt': 'attempt يجب أن يكون غير سالب',

  // Context Menu Actions
  'action_copy_caption': 'نسخ التسمية التوضيحية',
  'action_view_details': 'عرض التفاصيل',

  // Voice Input States
  'voice_ready': 'جاهز',
  'voice_initializing': 'جاري التهيئة...',
  'voice_listening': 'جاري الاستماع...',
  'voice_processing': 'جاري المعالجة...',
  'voice_recognized': 'معروف',
  'voice_error': 'خطأ',

  // Gesture Labels
  'gesture_slow': 'بطيء',
  'gesture_normal': 'عادي',
  'gesture_fast': 'سريع',
  'gesture_very_fast': 'سريع جداً',

  // Direction Labels
  'direction_left': 'يسار',
  'direction_right': 'يمين',
  'direction_up': 'أعلى',
  'direction_down': 'أسفل',
  'direction_none': 'لا شيء',

  // Tooltips & Accessibility
  'tooltip_mute_video': 'كتم صوت الفيديو',
  'tooltip_unmute_video': 'إلغاء كتم صوت الفيديو',
  'tooltip_more_options': 'المزيد من الخيارات',
  'tooltip_close_viewer': 'إغلاق عارض القصص',
  'tooltip_show_keyboard': 'إظهار لوحة المفاتيح',
  'tooltip_show_emoji': 'إظهار محدد الرموز التعبيرية',
  'tooltip_close_emoji': 'إغلاق محدد الرموز التعبيرية',
  'tooltip_gesture_controls': 'عناصر تحكم الإيماءات لعارض القصص',

  // Placeholder & Hint Text
  'placeholder_no_emojis': 'لا توجد رموز تعبيرية حديثة',
  'placeholder_message': 'أرسل رسالة',
  'placeholder_search': 'بحث',
  'placeholder_voice_text': 'نصك الصوتي هنا',

  // Engagement Indicators
  'engagement_views': '{count} مشاهدات',
  'engagement_reactions': '{count} ردود فعل',
  'engagement_shares': '{count} مشاركات',
  'engagement_comments': '{count} تعليقات',

  // Caption Display
  'caption_show_more': 'عرض المزيد',

  // Story Types
  'story_type_text': 'نص',
  'story_type_image': 'صورة',
  'story_type_video': 'فيديو',
  'story_type_custom': 'مخصص',
  'story_type_unknown': 'غير معروف',

  // Size Formatting
  'size_bytes': '{size} B',
  'size_kilobytes': '{size} KB',
  'size_megabytes': '{size} MB',
  'size_unknown': 'غير معروف',
};
