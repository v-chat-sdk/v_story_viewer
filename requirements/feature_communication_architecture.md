# Feature Communication Architecture

## Problem Statement

Features need to communicate while maintaining:
- **Separation**: Each feature is independent and testable
- **Coordination**: Features notify each other (progress → controller, controller → progress)
- **Team Workflow**: Multiple developers work without conflicts
- **Type Safety**: Clear contracts between features

## Recommended Solution: Callback-Based Mediator Pattern

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    VStoryViewer                             │
│            (Main Orchestrator/Coordinator)                  │
│  - Holds references to all feature controllers              │
│  - Wires callbacks between features                         │
│  - Manages lifecycle                                        │
└─────────────────────────────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
┌───────▼──────┐  ┌───────▼──────┐  ┌───────▼──────┐
│  Progress    │  │   Gesture    │  │    Media     │
│  Controller  │  │  Controller  │  │  Controller  │
│              │  │              │  │              │
│ - onComplete │  │ - onTap      │  │ - onReady    │
│ - onPause    │  │ - onSwipe    │  │ - onError    │
└──────────────┘  └──────────────┘  └──────────────┘
```

### Implementation Pattern

#### 1. Define Feature Contracts (Callbacks)

Each feature defines its **output events** as typed callbacks:

```dart
/// lib/src/features/v_progress_bar/models/v_progress_callbacks.dart

/// Callbacks for progress bar events
class VProgressCallbacks {
  /// Called when current story progress completes
  final VoidCallback? onStoryComplete;

  /// Called when user taps to navigate
  final void Function(int targetIndex)? onNavigationRequest;

  /// Called when progress updates (for external monitoring)
  final void Function(double progress)? onProgressUpdate;

  const VProgressCallbacks({
    this.onStoryComplete,
    this.onNavigationRequest,
    this.onProgressUpdate,
  });
}
```

```dart
/// lib/src/features/v_gesture_detector/models/v_gesture_callbacks.dart

/// Callbacks for gesture events
class VGestureCallbacks {
  /// Called when user taps left (previous story)
  final VoidCallback? onTapPrevious;

  /// Called when user taps right (next story)
  final VoidCallback? onTapNext;

  /// Called when user long presses (pause)
  final void Function(bool isPaused)? onPauseToggle;

  /// Called when user swipes down (dismiss)
  final VoidCallback? onDismiss;

  const VGestureCallbacks({
    this.onTapPrevious,
    this.onTapNext,
    this.onPauseToggle,
    this.onDismiss,
  });
}
```

```dart
/// lib/src/features/v_media_viewer/models/v_media_callbacks.dart

/// Callbacks for media events
class VMediaCallbacks {
  /// Called when media is ready to display
  final VoidCallback? onMediaReady;

  /// Called when media fails to load
  final void Function(String error)? onMediaError;

  /// Called when video duration is known
  final void Function(Duration duration)? onDurationKnown;

  const VMediaCallbacks({
    this.onMediaReady,
    this.onMediaError,
    this.onDurationKnown,
  });
}
```

#### 2. Controllers Accept Callbacks in Constructor

Each controller receives its callbacks via dependency injection:

```dart
/// lib/src/features/v_progress_bar/controllers/v_progress_controller.dart

class VProgressController extends ChangeNotifier {
  VProgressController({
    required int storyCount,
    int initialIndex = 0,
    VProgressStyle? style,
    VProgressCallbacks? callbacks, // Inject callbacks
  })  : _storyCount = storyCount,
        _currentIndex = initialIndex,
        _callbacks = callbacks ?? const VProgressCallbacks(),
        _style = style ?? VProgressStyle.instagram;

  final VProgressCallbacks _callbacks;

  // Internal state
  int _currentIndex;
  bool _isPaused = false;

  /// Start progress for current story
  void startProgress(Duration duration) {
    _animationController.duration = duration;
    _animationController.forward().then((_) {
      // Notify orchestrator that story is complete
      _callbacks.onStoryComplete?.call();
    });
  }

  /// Pause progress (called by orchestrator)
  void pause() {
    if (!_isPaused) {
      _isPaused = true;
      _animationController.stop();
      notifyListeners();
    }
  }

  /// Resume progress (called by orchestrator)
  void resume() {
    if (_isPaused) {
      _isPaused = false;
      _animationController.forward();
      notifyListeners();
    }
  }
}
```

```dart
/// lib/src/features/v_gesture_detector/controllers/v_gesture_controller.dart

class VGestureController {
  VGestureController({
    VGestureCallbacks? callbacks,
  }) : _callbacks = callbacks ?? const VGestureCallbacks();

  final VGestureCallbacks _callbacks;

  void handleTapLeft() {
    // Notify orchestrator to navigate previous
    _callbacks.onTapPrevious?.call();
  }

  void handleTapRight() {
    // Notify orchestrator to navigate next
    _callbacks.onTapNext?.call();
  }

  void handleLongPress(bool isPaused) {
    // Notify orchestrator to pause/resume
    _callbacks.onPauseToggle?.call(isPaused);
  }
}
```

#### 3. VStoryViewer (Main Orchestrator) Wires Everything Together

The main orchestrator creates all controllers and connects their callbacks:

```dart
/// lib/src/features/v_story_viewer/widgets/v_story_viewer.dart

class VStoryViewer extends StatefulWidget {
  VStoryViewer({
    required List<VStoryGroup> storyGroups,
    int initialGroupIndex = 0,
    int initialStoryIndex = 0,
  }) {
    _storyGroups = storyGroups;
    _currentGroupIndex = initialGroupIndex;
    _currentStoryIndex = initialStoryIndex;

    // Create all feature controllers with wired callbacks
    _initializeControllers();
  }

  // Feature controllers
  late VProgressController _progressController;
  late VGestureController _gestureController;
  late VMediaController _mediaController;

  // State
  List<VStoryGroup> _storyGroups;
  int _currentGroupIndex;
  int _currentStoryIndex;

  // Getters for widgets
  VProgressController get progressController => _progressController;
  VGestureController get gestureController => _gestureController;
  VMediaController get mediaController => _mediaController;

  void _initializeControllers() {
    final currentGroup = _storyGroups[_currentGroupIndex];

    // Create progress controller with callbacks
    _progressController = VProgressController(
      storyCount: currentGroup.stories.length,
      initialIndex: _currentStoryIndex,
      callbacks: VProgressCallbacks(
        // Wire: Progress completes → Navigate to next story
        onStoryComplete: _handleStoryComplete,
        onProgressUpdate: (progress) {
          // Optional: Monitor progress for analytics
        },
      ),
    );

    // Create gesture controller with callbacks
    _gestureController = VGestureController(
      callbacks: VGestureCallbacks(
        // Wire: Tap left → Previous story
        onTapPrevious: _handleNavigatePrevious,
        // Wire: Tap right → Next story
        onTapNext: _handleNavigateNext,
        // Wire: Long press → Pause/Resume
        onPauseToggle: _handlePauseToggle,
        // Wire: Swipe down → Dismiss
        onDismiss: _handleDismiss,
      ),
    );

    // Create media controller with callbacks
    _mediaController = VMediaController(
      callbacks: VMediaCallbacks(
        // Wire: Media ready → Start progress
        onMediaReady: _handleMediaReady,
        // Wire: Media error → Handle error
        onMediaError: _handleMediaError,
        // Wire: Duration known → Update progress duration
        onDurationKnown: (duration) {
          _progressController.updateDuration(duration);
        },
      ),
    );
  }

  // ==================== VStoryViewer Orchestration Methods ====================

  /// Handle story completion (from progress controller)
  void _handleStoryComplete() {
    _navigateToNextStory();
  }

  /// Handle navigation to previous story (from gesture controller)
  void _handleNavigatePrevious() {
    if (_currentStoryIndex > 0) {
      _currentStoryIndex--;
      _loadStory();
    } else if (_currentGroupIndex > 0) {
      // Go to previous group
      _currentGroupIndex--;
      _currentStoryIndex = _storyGroups[_currentGroupIndex].stories.length - 1;
      _loadStory();
    }
  }

  /// Handle navigation to next story (from gesture controller)
  void _handleNavigateNext() {
    _navigateToNextStory();
  }

  /// Handle pause/resume toggle (from gesture controller)
  void _handlePauseToggle(bool isPaused) {
    if (isPaused) {
      _progressController.pause();
      _mediaController.pause(); // If video is playing
    } else {
      _progressController.resume();
      _mediaController.resume();
    }
  }

  /// Handle dismiss (from gesture controller)
  void _handleDismiss() {
    // Clean up and notify parent widget
    dispose();
  }

  /// Handle media ready (from media controller)
  void _handleMediaReady() {
    // Media is loaded, start progress
    final currentStory = _getCurrentStory();
    _progressController.startProgress(currentStory.duration);
  }

  /// Handle media error (from media controller)
  void _handleMediaError(String error) {
    // Skip to next story on error
    _navigateToNextStory();
  }

  // ==================== Private Helpers ====================

  void _navigateToNextStory() {
    final currentGroup = _storyGroups[_currentGroupIndex];

    if (_currentStoryIndex < currentGroup.stories.length - 1) {
      // Move to next story in current group
      _currentStoryIndex++;
      _loadStory();
    } else if (_currentGroupIndex < _storyGroups.length - 1) {
      // Move to next group
      _currentGroupIndex++;
      _currentStoryIndex = 0;
      _loadStory();
    } else {
      // All stories complete
      _handleDismiss();
    }
  }

  void _loadStory() {
    final currentStory = _getCurrentStory();

    // Reset progress for new story
    _progressController.jumpToStory(_currentStoryIndex);

    // Load media
    _mediaController.loadStory(currentStory);

    notifyListeners();
  }

  VBaseStory _getCurrentStory() {
    return _storyGroups[_currentGroupIndex].stories[_currentStoryIndex];
  }

  @override
  void dispose() {
    _progressController.dispose();
    _mediaController.dispose();
    // gesture controller doesn't need disposal
    super.dispose();
  }
}
```

## Advantages of This Approach

### 1. **Complete Separation**
- Each feature has NO direct reference to other features
- Features only know about their own callbacks interface
- Can develop/test features independently

### 2. **Type Safety**
- Callbacks are typed and documented
- Compile-time verification of contracts
- No string-based event names

### 3. **Easy Testing**

```dart
// Test progress controller in isolation
test('progress controller calls onComplete when animation finishes', () {
  var completeCalled = false;

  final controller = VProgressController(
    storyCount: 3,
    callbacks: VProgressCallbacks(
      onStoryComplete: () => completeCalled = true,
    ),
  );

  controller.startProgress(Duration(milliseconds: 100));

  // Wait for animation
  await tester.pumpAndSettle();

  expect(completeCalled, isTrue);
});
```

```dart
// Test VStoryViewer orchestration
test('VStoryViewer navigates to next story when progress completes', () {
  final viewer = VStoryViewer(
    storyGroups: mockStoryGroups,
  );

  expect(viewer.currentStoryIndex, 0);

  // Simulate progress completion
  viewer.progressController._callbacks.onStoryComplete?.call();

  expect(viewer.currentStoryIndex, 1);
});
```

### 4. **Team Collaboration**
- Developer A works on `v_progress_bar` feature
- Developer B works on `v_gesture_detector` feature
- No conflicts - they only touch their own folders
- Integration happens in orchestrator

### 5. **Clear Data Flow**

```
User taps right
    ↓
GestureController.handleTapRight()
    ↓
callbacks.onTapNext()
    ↓
VStoryViewer._handleNavigateNext()
    ↓
VStoryViewer._loadStory()
    ↓
MediaController.loadStory()
    ↓
callbacks.onMediaReady()
    ↓
VStoryViewer._handleMediaReady()
    ↓
ProgressController.startProgress()
    ↓
(animation completes)
    ↓
callbacks.onStoryComplete()
    ↓
VStoryViewer._handleStoryComplete()
    ↓
(repeat)
```

## Alternative Approach: Stream-Based Communication

If you prefer reactive programming:

```dart
/// lib/src/features/v_progress_bar/controllers/v_progress_controller.dart

class VProgressController extends ChangeNotifier {
  // Output streams (events this controller emits)
  final _storyCompleteController = StreamController<void>.broadcast();
  Stream<void> get onStoryComplete => _storyCompleteController.stream;

  final _progressUpdateController = StreamController<double>.broadcast();
  Stream<double> get onProgressUpdate => _progressUpdateController.stream;

  void startProgress(Duration duration) {
    _animationController.duration = duration;
    _animationController.forward().then((_) {
      // Emit event
      _storyCompleteController.add(null);
    });
  }

  @override
  void dispose() {
    _storyCompleteController.close();
    _progressUpdateController.close();
    super.dispose();
  }
}
```

```dart
/// VStoryViewer (main orchestrator) listens to streams

class _VStoryViewerState extends State<VStoryViewer> {
  late StreamSubscription _progressSubscription;
  late StreamSubscription _gestureSubscription;

  void _initializeControllers() {
    _progressController = VProgressController(...);

    // Subscribe to events
    _progressSubscription = _progressController.onStoryComplete.listen((_) {
      _handleStoryComplete();
    });
  }

  @override
  void dispose() {
    _progressSubscription.cancel();
    _gestureSubscription.cancel();
    super.dispose();
  }
}
```

**Pros**: More reactive, decoupled
**Cons**: More boilerplate, harder to test, stream management overhead

## Comparison Table

| Approach | Separation | Type Safety | Testability | Team Collaboration | Complexity |
|----------|------------|-------------|-------------|-------------------|------------|
| **Callback-based** | ✅ Excellent | ✅ Excellent | ✅ Excellent | ✅ Excellent | 🟢 Low |
| **Stream-based** | ✅ Excellent | ✅ Good | 🟡 Good | ✅ Excellent | 🟡 Medium |
| **Event Bus** | ⚠️ Loose coupling | ❌ Poor | ❌ Difficult | ✅ Excellent | 🟢 Low |
| **Direct References** | ❌ Tight coupling | ✅ Excellent | ❌ Difficult | ❌ Poor | 🟢 Low |

## Recommendation

**Use Callback-Based Mediator Pattern** because:

1. ✅ Your current architecture already uses this (VProgressAnimationController has `onComplete`)
2. ✅ Perfect for your feature-based structure
3. ✅ Minimal boilerplate
4. ✅ Excellent testability
5. ✅ Clear, explicit data flow
6. ✅ Type-safe
7. ✅ Team-friendly

## Migration Path

1. **Step 1**: Define callback classes for each feature
2. **Step 2**: Update controllers to accept callbacks in constructor
3. **Step 3**: Wire callbacks in VStoryViewer (main orchestrator)
4. **Step 4**: Test each controller independently
5. **Step 5**: Test VStoryViewer orchestration integration
6. **Step 6**: Connect VStoryViewer to UI layer

This keeps features completely independent while enabling rich communication through **VStoryViewer** (main orchestrator).
