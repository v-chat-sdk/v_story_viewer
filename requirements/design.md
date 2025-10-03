# Design Document - Feature-Based Architecture

## Overview

The Flutter WhatsApp Story Viewer is architected using a **feature-based folder structure**, where each feature is self-contained with its own controllers, widgets, utils, and views. This modular approach emphasizes clean separation of concerns, type safety through sealed classes, and optimal performance.

## Architecture Pattern

### Feature-Based Folder Structure

Each feature is organized in its own folder containing all related components:

```
feature_folder/
├── controllers/     # Feature-specific controllers
├── widgets/        # Feature-specific widgets
├── views/          # Feature screens/pages
├── models/         # Feature data models
├── utils/          # Feature utilities
└── feature_export.dart  # Public API exports
```

## Updated File Structure

lib/
├── src/
│   ├── features/
│   │   ├── v_story_viewer/
│   │   │   ├── controllers/
│   │   │   │   ├── v_story_controller.dart
│   │   │   │   ├── v_story_state.dart
│   │   │   │   └── v_story_navigation_controller.dart
│   │   │   ├── widgets/
│   │   │   │   ├── v_story_container.dart
│   │   │   │   ├── v_story_viewer_widget.dart
│   │   │   │   └── v_story_wrapper.dart
│   │   │   ├── views/
│   │   │   │   └── v_story_viewer_page.dart
│   │   │   ├── models/
│   │   │   │   └── v_story_viewer_config.dart
│   │   │   └── v_story_viewer.dart (exports)
│   │   │
│   │   ├── v_progress_bar/
│   │   │   ├── controllers/
│   │   │   │   ├── v_progress_controller.dart
│   │   │   │   └── v_progress_animation_controller.dart
│   │   │   ├── widgets/
│   │   │   │   ├── v_segmented_progress.dart
│   │   │   │   ├── v_progress_segment.dart
│   │   │   │   └── v_progress_indicator.dart
│   │   │   ├── utils/
│   │   │   │   ├── v_progress_calculator.dart
│   │   │   │   └── v_progress_formatter.dart
│   │   │   ├── views/
│   │   │   │   └── v_progress_bar_view.dart
│   │   │   ├── models/
│   │   │   │   └── v_progress_style.dart
│   │   │   └── v_progress_bar.dart (exports)
│   │   │
│   │   ├── v_gesture_detector/
│   │   │   ├── controllers/
│   │   │   │   ├── v_gesture_controller.dart
│   │   │   │   └── v_gesture_recognizer_controller.dart
│   │   │   ├── widgets/
│   │   │   │   ├── v_tap_zones.dart
│   │   │   │   ├── v_swipe_detector.dart
│   │   │   │   ├── v_long_press_detector.dart
│   │   │   │   └── v_double_tap_detector.dart
│   │   │   ├── utils/
│   │   │   │   ├── v_gesture_zones.dart
│   │   │   │   └── v_gesture_calculator.dart
│   │   │   ├── views/
│   │   │   │   └── v_gesture_overlay.dart
│   │   │   ├── models/
│   │   │   │   └── v_gesture_config.dart
│   │   │   └── v_gesture_detector.dart (exports)
│   │   │
│   │   ├── v_media_viewer/
│   │   │   ├── controllers/
│   │   │   │   ├── v_media_controller.dart
│   │   │   │   ├── v_image_controller.dart
│   │   │   │   ├── v_video_controller.dart
│   │   │   │   ├── v_text_controller.dart
│   │   │   │   └── v_custom_controller.dart
│   │   │   ├── widgets/
│   │   │   │   ├── v_image_viewer.dart
│   │   │   │   ├── v_video_viewer.dart
│   │   │   │   ├── v_text_viewer.dart
│   │   │   │   ├── v_custom_viewer.dart
│   │   │   │   └── v_media_placeholder.dart
│   │   │   ├── utils/
│   │   │   │   ├── v_media_loader.dart
│   │   │   │   └── v_media_validator.dart
│   │   │   ├── views/
│   │   │   │   └── v_media_display.dart
│   │   │   ├── models/
│   │   │   │   └── v_media_config.dart
│   │   │   └── v_media_viewer.dart (exports)
│   │   │
│   │   ├── v_cache_manager/
│   │   │   ├── controllers/
│   │   │   │   ├── v_cache_controller.dart
│   │   │   │   └── v_download_controller.dart
│   │   │   ├── models/
│   │   │   │   ├── v_download_progress.dart
│   │   │   │   └── v_cache_config.dart
│   │   │   ├── utils/
│   │   │   │   ├── v_cache_policy.dart
│   │   │   │   ├── v_retry_policy.dart
│   │   │   │   └── v_cache_validator.dart
│   │   │   ├── widgets/
│   │   │   │   └── v_download_indicator.dart
│   │   │   └── v_cache_manager.dart (exports)
│   │   │
│   │   ├── v_reply_system/
│   │   │   ├── controllers/
│   │   │   │   ├── v_reply_controller.dart
│   │   │   │   └── v_reply_state_controller.dart
│   │   │   ├── widgets/
│   │   │   │   ├── v_reply_input.dart
│   │   │   │   ├── v_reply_button.dart
│   │   │   │   ├── v_reply_send_button.dart
│   │   │   │   └── v_reply_loading_indicator.dart
│   │   │   ├── utils/
│   │   │   │   ├── v_keyboard_handler.dart
│   │   │   │   └── v_reply_validator.dart
│   │   │   ├── views/
│   │   │   │   └── v_reply_view.dart
│   │   │   ├── models/
│   │   │   │   └── v_reply_config.dart
│   │   │   └── v_reply_system.dart (exports)
│   │   │
│   │   ├── v_reaction_system/
│   │   │   ├── controllers/
│   │   │   │   ├── v_reaction_controller.dart
│   │   │   │   └── v_reaction_animation_controller.dart
│   │   │   ├── widgets/
│   │   │   │   ├── v_love_animation.dart
│   │   │   │   ├── v_reaction_icon.dart
│   │   │   │   └── v_reaction_overlay_widget.dart
│   │   │   ├── views/
│   │   │   │   └── v_reaction_overlay.dart
│   │   │   ├── models/
│   │   │   │   └── v_reaction_type.dart
│   │   │   └── v_reaction_system.dart (exports)
│   │   │
│   │   ├── v_story_actions/
│   │   │   ├── controllers/
│   │   │   │   ├── v_actions_controller.dart
│   │   │   │   └── v_action_handler_controller.dart
│   │   │   ├── widgets/
│   │   │   │   ├── v_action_menu.dart
│   │   │   │   ├── v_action_button.dart
│   │   │   │   ├── v_three_dots_button.dart
│   │   │   │   └── v_action_item.dart
│   │   │   ├── models/
│   │   │   │   ├── v_story_action.dart
│   │   │   │   └── v_action_config.dart
│   │   │   ├── views/
│   │   │   │   └── v_actions_menu_view.dart
│   │   │   └── v_story_actions.dart (exports)
│   │   │
│   │   ├── v_story_header/
│   │   │   ├── widgets/
│   │   │   │   ├── v_user_avatar.dart
│   │   │   │   ├── v_user_info.dart
│   │   │   │   ├── v_timestamp.dart
│   │   │   │   └── v_header_container.dart
│   │   │   ├── views/
│   │   │   │   └── v_header_view.dart
│   │   │   ├── models/
│   │   │   │   └── v_header_config.dart
│   │   │   └── v_story_header.dart (exports)
│   │   │
│   │   ├── v_story_footer/
│   │   │   ├── widgets/
│   │   │   │   ├── v_footer_container.dart
│   │   │   │   ├── v_footer_content.dart
│   │   │   │   └── v_footer_actions.dart
│   │   │   ├── views/
│   │   │   │   └── v_footer_view.dart
│   │   │   ├── models/
│   │   │   │   └── v_footer_config.dart
│   │   │   └── v_story_footer.dart (exports)
│   │   │
│   │   ├── v_story_models/
│   │   │   ├── models/
│   │   │   │   ├── v_base_story.dart
│   │   │   │   ├── v_media_story.dart
│   │   │   │   ├── v_image_story.dart
│   │   │   │   ├── v_video_story.dart
│   │   │   │   ├── v_text_story.dart
│   │   │   │   ├── v_custom_story.dart
│   │   │   │   ├── v_story_user.dart
│   │   │   │   ├── v_story_group.dart
│   │   │   │   ├── v_story_list.dart
│   │   │   │   └── v_story_metadata.dart
│   │   │   └── v_story_models.dart (exports)
│   │   │
│   │   ├── v_story_state_manager/
│   │   │   ├── controllers/
│   │   │   │   ├── v_state_controller.dart
│   │   │   │   ├── v_view_state_controller.dart
│   │   │   │   └── v_persistence_controller.dart
│   │   │   ├── models/
│   │   │   │   ├── v_story_state.dart
│   │   │   │   ├── v_view_state.dart
│   │   │   │   └── v_progress_state.dart
│   │   │   ├── utils/
│   │   │   │   ├── v_state_calculator.dart
│   │   │   │   └── v_state_serializer.dart
│   │   │   ├── widgets/
│   │   │   │   ├── v_state_indicator.dart
│   │   │   │   └── v_viewed_indicator.dart
│   │   │   └── v_story_state_manager.dart (exports)
│   │   │
│   │   ├── v_story_duration/
│   │   │   ├── controllers/
│   │   │   │   ├── v_duration_controller.dart
│   │   │   │   └── v_duration_manager.dart
│   │   │   ├── utils/
│   │   │   │   ├── v_duration_calculator.dart
│   │   │   │   ├── v_wpm_calculator.dart
│   │   │   │   └── v_text_analyzer.dart
│   │   │   ├── models/
│   │   │   │   ├── v_duration_config.dart
│   │   │   │   └── v_duration_bounds.dart
│   │   │   └── v_story_duration.dart (exports)
│   │   │
│   │   ├── v_localization/
│   │   │   ├── controllers/
│   │   │   │   └── v_localization_controller.dart
│   │   │   ├── models/
│   │   │   │   ├── v_locale_config.dart
│   │   │   │   └── v_translation_keys.dart
│   │   │   ├── utils/
│   │   │   │   ├── v_rtl_handler.dart
│   │   │   │   ├── v_date_formatter.dart
│   │   │   │   └── v_translation_loader.dart
│   │   │   ├── translations/
│   │   │   │   ├── en.dart
│   │   │   │   ├── ar.dart
│   │   │   │   └── es.dart
│   │   │   └── v_localization.dart (exports)
│   │   │
│   │   ├── v_platform_compatibility/
│   │   │   ├── controllers/
│   │   │   │   └── v_platform_controller.dart
│   │   │   ├── utils/
│   │   │   │   ├── v_platform_detector.dart
│   │   │   │   ├── v_file_handler.dart
│   │   │   │   └── v_web_compatibility.dart
│   │   │   ├── models/
│   │   │   │   └── v_platform_config.dart
│   │   │   └── v_platform_compatibility.dart (exports)
│   │   │
│   │   ├── v_theme_system/
│   │   │   ├── controllers/
│   │   │   │   └── v_theme_controller.dart
│   │   │   ├── models/
│   │   │   │   ├── v_story_theme.dart
│   │   │   │   ├── v_color_scheme.dart
│   │   │   │   ├── v_typography.dart
│   │   │   │   └── v_icon_theme.dart
│   │   │   ├── widgets/
│   │   │   │   └── v_theme_provider.dart
│   │   │   └── v_theme_system.dart (exports)
│   │   │
│   │   ├── v_safe_area/
│   │   │   ├── controllers/
│   │   │   │   ├── v_safe_area_controller.dart
│   │   │   │   └── v_orientation_controller.dart
│   │   │   ├── widgets/
│   │   │   │   ├── v_safe_area_wrapper.dart
│   │   │   │   ├── v_notch_handler.dart
│   │   │   │   └── v_status_bar_overlay.dart
│   │   │   ├── utils/
│   │   │   │   ├── v_screen_calculator.dart
│   │   │   │   └── v_device_detector.dart
│   │   │   └── v_safe_area.dart (exports)
│   │   │
│   │   ├── v_error_handling/
│   │   │   ├── controllers/
│   │   │   │   └── v_error_controller.dart
│   │   │   ├── models/
│   │   │   │   ├── v_story_error.dart
│   │   │   │   ├── v_media_error.dart
│   │   │   │   └── v_network_error.dart
│   │   │   ├── widgets/
│   │   │   │   ├── v_error_placeholder.dart
│   │   │   │   ├── v_retry_button.dart
│   │   │   │   └── v_error_message.dart
│   │   │   ├── utils/
│   │   │   │   └── v_error_recovery.dart
│   │   │   └── v_error_handling.dart (exports)
│   │   │
│   │   └── v_memory_management/
│   │       ├── controllers/
│   │       │   ├── v_memory_controller.dart
│   │       │   └── v_resource_controller.dart
│   │       ├── utils/
│   │       │   ├── v_memory_monitor.dart
│   │       │   ├── v_resource_cleaner.dart
│   │       │   └── v_video_pool_manager.dart
│   │       ├── models/
│   │       │   └── v_memory_config.dart
│   │       └── v_memory_management.dart (exports)
│   │
│   ├── core/
│   │   ├── dependency_injection/    
│   │   │   ├── providers/
│   │   │   │   ├── v_controller_provider.dart
│   │   │   │   ├── v_data_provider.dart
│   │   │   │   ├── v_data_notifier.dart
│   │   │   │   └── v_provider_cache.dart
│   │   │   ├── factories/
│   │   │   │   ├── v_controller_factory.dart
│   │   │   │   └── v_controller_bundle.dart
│   │   │   ├── patterns/
│   │   │   │   ├── v_callback_pattern.dart
│   │   │   │   ├── v_selective_builder.dart
│   │   │   │   └── v_provider_access_pattern.dart
│   │   │   └── v_dependency_injection.dart (exports)
│   │   │
│   │   ├── constants/
│   │   │   ├── v_constants.dart
│   │   │   ├── v_durations.dart
│   │   │   └── v_sizes.dart
│   │   ├── extensions/
│   │   │   ├── v_context_extensions.dart
│   │   │   └── v_string_extensions.dart
│   │   ├── mixins/
│   │   │   ├── v_lifecycle_mixin.dart
│   │   │   └── v_disposable_mixin.dart
│   │   ├── errors/
│   │   │   ├── v_dependency_errors.dart
│   │   │   └── v_initialization_errors.dart
│   │   └── callbacks/
│   │       ├── v_story_callbacks.dart
│   │       ├── v_reply_callbacks.dart
│   │       ├── v_reaction_callbacks.dart
│   │       └── v_action_callbacks.dart
│   │
│   └── shared/
│       ├── utils/
│       │   ├── v_logger.dart
│       │   ├── v_validator.dart
│       │   └── v_performance_monitor.dart
│       └── widgets/
│           ├── v_loading_indicator.dart
│           └── v_empty_widget.dart
│
├── example/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── basic_example_screen.dart
│   │   │   ├── custom_theme_screen.dart
│   │   │   ├── reply_example_screen.dart
│   │   │   └── all_features_screen.dart
│   │   ├── data/
│   │   │   ├── mock_stories.dart
│   │   │   ├── debug_stories.dart (story_1, user_2, etc.)
│   │   │   └── test_media.dart
│   │   └── widgets/
│   │       └── example_wrapper.dart
│   ├── assets/
│   │   ├── images/
│   │   └── videos/
│   └── pubspec.yaml
│
├── test/
│   ├── features/
│   │   ├── v_progress_bar/
│   │   │   ├── unit/
│   │   │   │   ├── v_progress_controller_test.dart
│   │   │   │   └── v_progress_calculator_test.dart
│   │   │   ├── widget/
│   │   │   │   └── v_segmented_progress_test.dart
│   │   │   ├── integration/
│   │   │   │   └── progress_bar_integration_test.dart
│   │   │   └── e2e/
│   │   │       └── progress_bar_e2e_test.dart
│   │   └── [similar structure for all features]
│   │
│   ├── core/
│   │   ├── dependency_injection/   
│   │   │   ├── providers/
│   │   │   │   ├── v_controller_provider_test.dart
│   │   │   │   └── v_data_provider_test.dart
│   │   │   ├── factories/
│   │   │   │   └── v_controller_factory_test.dart
│   │   │   └── integration/
│   │   │       └── di_system_integration_test.dart
│   │   └── [other core tests]
│   │
│   ├── shared/
│   │   └── [tests for shared components]
│   │
│   └── mocks/   
│       ├── mock_controllers.dart
│       ├── mock_providers.dart
│       ├── mock_callbacks.dart
│       └── test_helpers.dart
│
├── integration_test/
│   ├── story_viewer_test.dart
│   ├── performance_test.dart
│   └── di_system_test.dart    
│
├── README.md
├── CHANGELOG.md
├── LICENSE
├── pubspec.yaml
└── v_story_viewer.dart (main export file)

## Updated Component Designs

### 1. Progress Bar Feature (`v_progress_bar/`)

```dart
// v_progress_bar/controllers/v_progress_controller.dart
class VProgressController extends ChangeNotifier {
  final int totalStories;
  final Duration storyDuration;
  
  double _currentProgress = 0.0;
  int _currentIndex = 0;
  Timer? _timer;
  
  double get currentProgress => _currentProgress;
  int get currentIndex => _currentIndex;
  
  void startProgress() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      _currentProgress += 50 / storyDuration.inMilliseconds;
      if (_currentProgress >= 1.0) {
        _currentProgress = 0.0;
        nextStory();
      }
      notifyListeners();
    });
  }
  
  void pauseProgress() {
    _timer?.cancel();
  }
  
  void resetProgress() {
    _currentProgress = 0.0;
    notifyListeners();
  }
  
  void nextStory() {
    if (_currentIndex < totalStories - 1) {
      _currentIndex++;
      resetProgress();
      startProgress();
    }
  }
}

// v_progress_bar/widgets/v_segmented_progress.dart
class VSegmentedProgress extends StatelessWidget {
  final VProgressController controller;
  final VProgressStyle style;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: style.padding,
      child: Row(
        children: List.generate(
          controller.totalStories,
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              child: LinearProgressIndicator(
                value: _getProgressValue(index),
                backgroundColor: style.inactiveColor,
                valueColor: AlwaysStoppedAnimation(style.activeColor),
                minHeight: style.height,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  double _getProgressValue(int index) {
    if (index < controller.currentIndex) return 1.0;
    if (index == controller.currentIndex) return controller.currentProgress;
    return 0.0;
  }
}
```

### 2. Gesture Detector Feature (`v_gesture_detector/`)

```dart
// v_gesture_detector/controllers/v_gesture_controller.dart
class VGestureController {
  final VStoryController storyController;
  
  void handleTapLeft() {
    HapticFeedback.lightImpact();
    storyController.previous();
  }
  
  void handleTapRight() {
    HapticFeedback.lightImpact();
    storyController.next();
  }
  
  void handleLongPressStart() {
    storyController.pause();
  }
  
  void handleLongPressEnd() {
    storyController.play();
  }
  
  void handleDoubleTap() {
    storyController.triggerReaction();
  }
  
  void handleVerticalSwipe(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dy > 300) {
      storyController.dismiss();
    }
  }
  
  void handleHorizontalSwipe(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dx > 300) {
      storyController.nextGroup();
    } else if (details.velocity.pixelsPerSecond.dx < -300) {
      storyController.previousGroup();
    }
  }
}

// v_gesture_detector/widgets/v_tap_zones.dart
class VTapZones extends StatelessWidget {
  final VGestureController controller;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Row(
          children: [
            // Left 50% tap zone
            Expanded(
              child: GestureDetector(
                onTap: controller.handleTapLeft,
                behavior: HitTestBehavior.translucent,
              ),
            ),
            // Right 50% tap zone
            Expanded(
              child: GestureDetector(
                onTap: controller.handleTapRight,
                behavior: HitTestBehavior.translucent,
              ),
            ),
          ],
        ),
        // Full screen gestures
        GestureDetector(
          onLongPressStart: (_) => controller.handleLongPressStart(),
          onLongPressEnd: (_) => controller.handleLongPressEnd(),
          onDoubleTap: controller.handleDoubleTap,
          onVerticalDragEnd: controller.handleVerticalSwipe,
          onHorizontalDragEnd: controller.handleHorizontalSwipe,
          behavior: HitTestBehavior.translucent,
        ),
      ],
    );
  }
}
```

### 3. Media Viewer Feature (`v_media_viewer/`)

```dart
// v_media_viewer/controllers/v_video_controller.dart
class VVideoController {
  VideoPlayerController? _controller;
  
  Future<void> initializeVideo(VVideoStory story) async {
    // Dispose previous controller
    await _controller?.dispose();
    
    // Create new controller based on source
    if (story.media.networkUrl != null) {
      _controller = VideoPlayerController.network(story.media.networkUrl!);
    } else if (story.media.fileLocalPath != null) {
      _controller = VideoPlayerController.file(File(story.media.fileLocalPath!));
    } else if (story.media.assetsPath != null) {
      _controller = VideoPlayerController.asset(story.media.assetsPath!);
    }
    
    await _controller?.initialize();
    await _controller?.play();
  }
  
  Future<void> pause() async {
    await _controller?.pause();
  }
  
  Future<void> play() async {
    await _controller?.play();
  }
  
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
```

### 4. Cache Manager Feature (`v_cache_manager/`)

```dart
// v_cache_manager/controllers/v_cache_controller.dart
class VCacheController {
  final _cacheManager = DefaultCacheManager();
  final _progressController = StreamController<VDownloadProgress>.broadcast();
  
  Stream<VDownloadProgress> get progressStream => _progressController.stream;
  
  Future<File?> getCachedFile(String url) async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(url);
      if (fileInfo != null) {
        return fileInfo.file;
      }
      
      // Download with progress
      return await _downloadWithProgress(url);
    } catch (e) {
      // Retry with exponential backoff
      return await _retryDownload(url);
    }
  }
  
  Future<File> _downloadWithProgress(String url) async {
    final stream = _cacheManager.getFileStream(url);
    
    await for (final response in stream) {
      if (response is DownloadProgress) {
        _progressController.add(VDownloadProgress(
          url: url,
          progress: response.progress ?? 0.0,
          totalSize: response.totalSize,
          downloadedSize: response.downloaded,
        ));
      } else if (response is FileInfo) {
        return response.file;
      }
    }
    
    throw Exception('Download failed');
  }
  
  Future<File> _retryDownload(String url, {int attempts = 3}) async {
    for (int i = 0; i < attempts; i++) {
      try {
        await Future.delayed(Duration(seconds: i * 2)); // Exponential backoff
        return await _downloadWithProgress(url);
      } catch (e) {
        if (i == attempts - 1) rethrow;
      }
    }
    throw Exception('Max retry attempts reached');
  }
}
```

### 5. Updated Story Controller

```dart
// v_story_viewer/controllers/v_story_controller.dart
class VStoryController extends ChangeNotifier with WidgetsBindingObserver {
  VStoryState _state = VStoryState.initial();
  VStoryGroup? _currentGroup;
  int _currentStoryIndex = 0;
  
  // Sub-controllers
  late VProgressController progressController;
  late VCacheController cacheController;
  late VVideoController videoController;
  
  VStoryController() {
    progressController = VProgressController();
    cacheController = VCacheController();
    videoController = VVideoController();
    WidgetsBinding.instance.addObserver(this);
  }
  
  Future<void> next() async {
    if (_currentGroup == null) return;
    
    if (_currentStoryIndex < _currentGroup!.stories.length - 1) {
      _currentStoryIndex++;
      await _loadCurrentStory();
    } else {
      // Navigate to next group
      await nextGroup();
    }
  }
  
  Future<void> previous() async {
    if (_currentStoryIndex > 0) {
      _currentStoryIndex--;
      await _loadCurrentStory();
    } else {
      // Navigate to previous group or restart
      await previousGroup();
    }
  }
  
  Future<void> _loadCurrentStory() async {
    progressController.resetProgress();
    
    final story = _currentGroup!.stories[_currentStoryIndex];
    
    // Don't play until media is ready
    _state = _state.copyWith(playbackState: VStoryPlaybackState.loading);
    notifyListeners();
    
    if (story is VVideoStory) {
      await videoController.initializeVideo(story);
    } else if (story is VImageStory || story is VTextStory) {
      if (story is VImageStory && story.media.networkUrl != null) {
        await cacheController.getCachedFile(story.media.networkUrl!);
      }
    }
    
    _state = _state.copyWith(
      playbackState: VStoryPlaybackState.playing,
      currentStory: story,
    );
    progressController.startProgress();
    notifyListeners();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        pause();
        break;
      case AppLifecycleState.resumed:
        play();
        break;
      case AppLifecycleState.detached:
        dispose();
        break;
      case AppLifecycleState.hidden:
        pause();
        break;
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    progressController.dispose();
    cacheController.dispose();
    videoController.dispose();
    super.dispose();
  }
}

// v_story_viewer/controllers/v_story_state.dart
class VStoryState {
  final VStoryPlaybackState playbackState;
  final VBaseStory? currentStory;
  final VStoryGroup? currentGroup;
  final String? error;
  
  const VStoryState({
    required this.playbackState,
    this.currentStory,
    this.currentGroup,
    this.error,
  });
  
  factory VStoryState.initial() {
    return VStoryState(
      playbackState: VStoryPlaybackState.stopped,
    );
  }
  
  VStoryState copyWith({
    VStoryPlaybackState? playbackState,
    VBaseStory? currentStory,
    VStoryGroup? currentGroup,
    String? error,
  }) {
    return VStoryState(
      playbackState: playbackState ?? this.playbackState,
      currentStory: currentStory ?? this.currentStory,
      currentGroup: currentGroup ?? this.currentGroup,
      error: error ?? this.error,
    );
  }
}

enum VStoryPlaybackState { playing, paused, stopped, loading, error }
```

## Key Design Updates

### 1. Feature-Based Organization
- Each feature is self-contained with its own MVC structure
- Features can be developed, tested, and maintained independently
- Clear separation of concerns within each feature

### 2. Simplified Progress Implementation
- Using Flutter's built-in `LinearProgressIndicator` directly
- No external `step_progress` dependency
- Simple timer-based progress tracking

### 3. Controller Hierarchy
- Main `VStoryController` orchestrates sub-controllers
- Each feature has its own controller for specific logic
- Clean dependency injection pattern

### 4. State Management
- Simple `ChangeNotifier` pattern for reactive updates
- Separate state classes in their own files
- No complex animation controllers

### 5. Navigation Updates
- 50% screen split for left/right tap zones (as per requirements)
- Group navigation with horizontal swipes
- Automatic restart when all stories viewed

### 6. Media Loading
- Wait for first story to be 100% ready before playing
- Automatic retry on download failure
- Progress tracking for network downloads

## Testing Strategy Per Feature

Each feature folder should have corresponding test structure:

```
test/
├── features/
│   ├── v_progress_bar/
│   │   ├── controllers/
│   │   │   └── v_progress_controller_test.dart
│   │   ├── widgets/
│   │   │   └── v_segmented_progress_test.dart
│   │   └── integration/
│   │       └── progress_bar_integration_test.dart
│   ├── v_gesture_detector/
│   │   └── [similar structure]
│   └── [other features...]
```

This architecture provides:
- **Modularity**: Features can be added/removed easily
- **Testability**: Each feature can be tested in isolation
- **Maintainability**: Clear code organization
- **Scalability**: Easy to add new features
- **Performance**: Simple implementations without unnecessary complexity

### Core Principles

1. **Explicit Dependencies**: All dependencies must be explicitly declared through constructor injection
2. **Single Source of Truth**: Each piece of state has one authoritative source
3. **Unidirectional Data Flow**: Data flows from controllers to widgets, never backwards
4. **Callback-Based Communication**: Controllers communicate through typed callbacks, not direct references
5. **Fail Fast**: Missing dependencies or configuration errors should fail at initialization, not runtime
6. **Testability First**: Every component must be independently testable with mock dependencies

### Design Constraints

1. **No Global State**: All state must flow through providers
2. **No Circular Dependencies**: Controllers cannot have circular dependency chains
3. **No Dynamic Types**: All dependencies and callbacks must be strongly typed
4. **No Direct Feature Dependencies**: Features communicate only through the orchestrator
5. **Immutable Configuration**: Once initialized, controller dependencies cannot change
