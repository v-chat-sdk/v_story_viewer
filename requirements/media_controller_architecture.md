# Media Controller Architecture - Base Controller Pattern

## Problem Statement

The v_media_viewer feature has multiple controllers (Image, Video, Text, Custom) that share common functionality:
- Pause/Resume capabilities
- Loading states
- Error handling
- Callback management
- Lifecycle management

**Goal**: Create a base controller to eliminate duplication and provide consistent behavior.

## Recommended Architecture: Abstract Base Controller

### Design Pattern: Template Method + Strategy

```
┌──────────────────────────────────────────────┐
│        VBaseMediaController                  │
│         (Abstract Base Class)                │
│                                              │
│  Common State:                               │
│  - isLoading, isPaused, hasError            │
│  - currentStory, callbacks                   │
│                                              │
│  Common Methods:                             │
│  - pause(), resume(), dispose()             │
│  - notifyReady(), notifyError()             │
│                                              │
│  Abstract Methods:                           │
│  - loadMedia() - Implemented by subclasses  │
│  - pauseMedia() - Optional override         │
│  - resumeMedia() - Optional override        │
└──────────────────────────────────────────────┘
                    ▲
        ┌───────────┼───────────┬───────────┐
        │           │           │           │
┌───────┴────┐ ┌────┴─────┐ ┌──┴──────┐ ┌──┴──────────┐
│  VImage    │ │  VVideo  │ │  VText  │ │  VCustom    │
│ Controller │ │Controller│ │Controller│ │Controller  │
│            │ │          │ │          │ │             │
│ - Caching  │ │ - Video  │ │ - Text  │ │ - Custom    │
│ - Network  │ │   Player │ │   Render│ │   Builder   │
└────────────┘ └──────────┘ └─────────┘ └─────────────┘
```

## Implementation

### 1. Define Media Callbacks

```dart
/// lib/src/features/v_media_viewer/models/v_media_callbacks.dart

/// Callbacks for media controller events
class VMediaCallbacks {
  /// Called when media is ready to display
  final VoidCallback? onMediaReady;

  /// Called when media fails to load
  final void Function(String error)? onMediaError;

  /// Called when media is paused
  final VoidCallback? onPaused;

  /// Called when media is resumed
  final VoidCallback? onResumed;

  /// Called when media duration is known (videos)
  final void Function(Duration duration)? onDurationKnown;

  /// Called when loading progress updates
  final void Function(double progress)? onLoadingProgress;

  const VMediaCallbacks({
    this.onMediaReady,
    this.onMediaError,
    this.onPaused,
    this.onResumed,
    this.onDurationKnown,
    this.onLoadingProgress,
  });
}
```

### 2. Create Base Controller

```dart
/// lib/src/features/v_media_viewer/controllers/v_base_media_controller.dart

import 'package:flutter/foundation.dart';
import '../models/v_media_callbacks.dart';
import '../../v_story_models/models/v_base_story.dart';

/// Abstract base controller for all media types
/// Provides common functionality for pause/resume, loading, and error handling
abstract class VBaseMediaController extends ChangeNotifier {
  VBaseMediaController({
    VMediaCallbacks? callbacks,
  }) : _callbacks = callbacks ?? const VMediaCallbacks();

  final VMediaCallbacks _callbacks;

  // ==================== Common State ====================

  /// Current story being displayed
  VBaseStory? _currentStory;
  VBaseStory? get currentStory => _currentStory;

  /// Whether media is currently loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Whether media is paused
  bool _isPaused = false;
  bool get isPaused => _isPaused;

  /// Whether media has error
  bool _hasError = false;
  bool get hasError => _hasError;

  /// Error message if any
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ==================== Public API ====================

  /// Load and prepare media for display
  /// This is the main entry point called by VStoryViewer
  Future<void> loadStory(VBaseStory story) async {
    _currentStory = story;
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      // Template method - subclasses implement specific loading
      await loadMedia(story);

      _isLoading = false;
      notifyListeners();

      // Notify orchestrator that media is ready
      _callbacks.onMediaReady?.call();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = e.toString();
      notifyListeners();

      // Notify orchestrator of error
      _callbacks.onMediaError?.call(e.toString());
    }
  }

  /// Pause media playback (if applicable)
  void pause() {
    if (!_isPaused) {
      _isPaused = true;
      notifyListeners();

      // Template method - subclasses can override
      pauseMedia();

      _callbacks.onPaused?.call();
    }
  }

  /// Resume media playback (if applicable)
  void resume() {
    if (_isPaused) {
      _isPaused = false;
      notifyListeners();

      // Template method - subclasses can override
      resumeMedia();

      _callbacks.onResumed?.call();
    }
  }

  /// Reset controller state
  void reset() {
    _currentStory = null;
    _isLoading = false;
    _isPaused = false;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== Protected Methods (for subclasses) ====================

  /// Update loading progress (0.0 to 1.0)
  @protected
  void updateProgress(double progress) {
    _callbacks.onLoadingProgress?.call(progress);
  }

  /// Notify that video duration is known
  @protected
  void notifyDuration(Duration duration) {
    _callbacks.onDurationKnown?.call(duration);
  }

  /// Manually trigger ready callback (for synchronous media like text)
  @protected
  void notifyReady() {
    _callbacks.onMediaReady?.call();
  }

  /// Manually trigger error callback
  @protected
  void notifyError(String error) {
    _hasError = true;
    _errorMessage = error;
    _callbacks.onMediaError?.call(error);
    notifyListeners();
  }

  // ==================== Abstract Methods (must be implemented) ====================

  /// Load media specific to this controller type
  /// Called by loadStory() template method
  @protected
  Future<void> loadMedia(VBaseStory story);

  // ==================== Virtual Methods (optional override) ====================

  /// Pause media-specific playback
  /// Default implementation does nothing (for static media like images/text)
  @protected
  void pauseMedia() {
    // Default: no-op for static media
  }

  /// Resume media-specific playback
  /// Default implementation does nothing (for static media like images/text)
  @protected
  void resumeMedia() {
    // Default: no-op for static media
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }
}
```

### 3. Implement Specific Controllers

#### Image Controller

```dart
/// lib/src/features/v_media_viewer/controllers/v_image_controller.dart

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'v_base_media_controller.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_image_story.dart';
import '../models/v_media_callbacks.dart';

/// Controller for image story display
class VImageController extends VBaseMediaController {
  VImageController({
    VMediaCallbacks? callbacks,
    BaseCacheManager? cacheManager,
  })  : _cacheManager = cacheManager ?? DefaultCacheManager(),
        super(callbacks: callbacks);

  final BaseCacheManager _cacheManager;

  @override
  Future<void> loadMedia(VBaseStory story) async {
    if (story is! VImageStory) {
      throw ArgumentError('VImageController requires VImageStory');
    }

    // Download and cache image
    final fileInfo = await _cacheManager.getFileFromCache(story.url);

    if (fileInfo == null || fileInfo.file == null) {
      // Download with progress
      final stream = _cacheManager.downloadFile(story.url);

      await for (final progress in stream) {
        if (progress is DownloadProgress) {
          updateProgress(progress.progress ?? 0.0);
        } else if (progress is FileInfo) {
          // Download complete
          break;
        }
      }
    }

    // Image is ready (loading happens in widget via cached_network_image)
  }

  // Image is static - no pause/resume needed (use defaults)
}
```

#### Video Controller

```dart
/// lib/src/features/v_media_viewer/controllers/v_video_controller.dart

import 'package:video_player/video_player.dart';
import 'v_base_media_controller.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_video_story.dart';
import '../models/v_media_callbacks.dart';

/// Controller for video story playback
class VVideoController extends VBaseMediaController {
  VVideoController({
    VMediaCallbacks? callbacks,
  }) : super(callbacks: callbacks);

  VideoPlayerController? _videoPlayerController;
  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  @override
  Future<void> loadMedia(VBaseStory story) async {
    if (story is! VVideoStory) {
      throw ArgumentError('VVideoController requires VVideoStory');
    }

    // Dispose previous controller
    await _videoPlayerController?.dispose();

    // Create new video controller
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(story.url),
    );

    // Initialize
    await _videoPlayerController!.initialize();

    // Notify duration
    final duration = _videoPlayerController!.value.duration;
    if (duration != Duration.zero) {
      notifyDuration(duration);
    }

    // Auto-play
    await _videoPlayerController!.play();
  }

  @override
  void pauseMedia() {
    _videoPlayerController?.pause();
  }

  @override
  void resumeMedia() {
    _videoPlayerController?.play();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }
}
```

#### Text Controller

```dart
/// lib/src/features/v_media_viewer/controllers/v_text_controller.dart

import 'v_base_media_controller.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_text_story.dart';
import '../models/v_media_callbacks.dart';

/// Controller for text story display
class VTextController extends VBaseMediaController {
  VTextController({
    VMediaCallbacks? callbacks,
  }) : super(callbacks: callbacks);

  @override
  Future<void> loadMedia(VBaseStory story) async {
    if (story is! VTextStory) {
      throw ArgumentError('VTextController requires VTextStory');
    }

    // Text is synchronous - immediately ready
    // No loading needed, just validate

    if (story.text.isEmpty) {
      throw ArgumentError('Text story cannot be empty');
    }

    // Notify ready immediately
    notifyReady();
  }

  // Text is static - no pause/resume needed (use defaults)
}
```

#### Custom Controller

```dart
/// lib/src/features/v_media_viewer/controllers/v_custom_controller.dart

import 'v_base_media_controller.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_custom_story.dart';
import '../models/v_media_callbacks.dart';

/// Controller for custom widget stories
class VCustomController extends VBaseMediaController {
  VCustomController({
    VMediaCallbacks? callbacks,
  }) : super(callbacks: callbacks);

  @override
  Future<void> loadMedia(VBaseStory story) async {
    if (story is! VCustomStory) {
      throw ArgumentError('VCustomController requires VCustomStory');
    }

    // Custom widgets are built by user-provided builder
    // No loading needed - immediately ready
    notifyReady();
  }

  // Custom widgets handle their own pause/resume if needed (use defaults)
}
```

### 4. Media Controller Factory (Optional)

```dart
/// lib/src/features/v_media_viewer/controllers/v_media_controller_factory.dart

import 'v_base_media_controller.dart';
import 'v_image_controller.dart';
import 'v_video_controller.dart';
import 'v_text_controller.dart';
import 'v_custom_controller.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_image_story.dart';
import '../../v_story_models/models/v_video_story.dart';
import '../../v_story_models/models/v_text_story.dart';
import '../../v_story_models/models/v_custom_story.dart';
import '../models/v_media_callbacks.dart';

/// Factory for creating appropriate media controllers
class VMediaControllerFactory {
  /// Create controller based on story type
  static VBaseMediaController createController({
    required VBaseStory story,
    VMediaCallbacks? callbacks,
  }) {
    return switch (story) {
      VImageStory() => VImageController(callbacks: callbacks),
      VVideoStory() => VVideoController(callbacks: callbacks),
      VTextStory() => VTextController(callbacks: callbacks),
      VCustomStory() => VCustomController(callbacks: callbacks),
      _ => throw ArgumentError('Unknown story type: ${story.runtimeType}'),
    };
  }
}
```

## Usage in VStoryViewer

```dart
class _VStoryViewerState extends State<VStoryViewer> {
  late VBaseMediaController _mediaController;

  void _initializeControllers() {
    final currentStory = _getCurrentStory();

    // Create appropriate controller for story type
    _mediaController = VMediaControllerFactory.createController(
      story: currentStory,
      callbacks: VMediaCallbacks(
        onMediaReady: _handleMediaReady,
        onMediaError: _handleMediaError,
        onDurationKnown: _handleDurationKnown,
        onPaused: _handleMediaPaused,
        onResumed: _handleMediaResumed,
      ),
    );
  }

  void _handleMediaReady() {
    // Start progress animation
    _progressController.startProgress(_getCurrentStory().duration);
  }

  void _handlePauseToggle(bool isPaused) {
    if (isPaused) {
      _mediaController.pause();
      _progressController.pause();
    } else {
      _mediaController.resume();
      _progressController.resume();
    }
  }
}
```

## Advantages

### 1. **DRY Principle**
- Common functionality (pause/resume/loading/error) in one place
- No duplication across controllers

### 2. **Consistent Behavior**
- All media types handle callbacks consistently
- Uniform error handling
- Standard lifecycle management

### 3. **Easy to Extend**
- Add new media types by extending base
- Override only what's different (template method pattern)

### 4. **Type Safety**
- Abstract methods enforce implementation
- Callbacks are typed, not string-based

### 5. **Testability**
```dart
test('base controller handles loading state correctly', () {
  final controller = TestMediaController();
  expect(controller.isLoading, isFalse);

  controller.loadStory(mockStory);
  expect(controller.isLoading, isTrue);
});

test('video controller pauses playback', () {
  final controller = VVideoController();
  controller.loadStory(videoStory);

  controller.pause();
  expect(controller.isPaused, isTrue);
  expect(controller.videoPlayerController?.value.isPlaying, isFalse);
});
```

### 6. **Separation of Concerns**
- Base handles common orchestration
- Specific controllers handle media-specific logic
- Callbacks handle communication with VStoryViewer

## Design Decisions

### Why Abstract Class instead of Composition?

**Abstract Class (chosen):**
✅ Natural "is-a" relationship (VVideoController IS A media controller)
✅ Template method pattern for lifecycle hooks
✅ Protected methods for subclass use
✅ Single inheritance keeps design simple

**Composition alternative:**
- Would require delegation boilerplate
- Less natural for this use case
- Better when multiple behaviors need mixing

### Why Template Method Pattern?

The `loadStory()` method uses template method pattern:
1. Base class defines algorithm (set loading → load media → handle result)
2. Subclasses implement specific steps (`loadMedia()`)
3. Ensures consistent behavior across all controllers

### Why Protected Methods?

Methods like `updateProgress()` and `notifyReady()` are protected:
- Subclasses can use them
- External code cannot (encapsulation)
- Clear API boundary

## Migration Checklist

- [ ] Create `v_media_callbacks.dart`
- [ ] Create `v_base_media_controller.dart`
- [ ] Implement `v_image_controller.dart`
- [ ] Implement `v_video_controller.dart`
- [ ] Implement `v_text_controller.dart`
- [ ] Implement `v_custom_controller.dart`
- [ ] Create `v_media_controller_factory.dart`
- [ ] Update VStoryViewer to use base controller
- [ ] Write unit tests for base controller
- [ ] Write tests for each specific controller
- [ ] Update documentation

## Summary

This architecture:
- ✅ Eliminates code duplication
- ✅ Provides consistent pause/resume across all media types
- ✅ Makes callbacks easy to manage
- ✅ Follows SOLID principles
- ✅ Easy to test and extend
- ✅ Clear separation between common and specific logic
