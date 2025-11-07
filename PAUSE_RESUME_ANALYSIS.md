# Pause/Resume Architecture Analysis

## Executive Summary

The v_story_viewer package implements pause/resume functionality through a **distributed, multi-layered architecture** with **centralized orchestration** at the VStoryViewer widget level. The system uses:

- **Callback-based mediator pattern** for feature communication
- **Event-driven architecture** for state propagation
- **Template method pattern** for media-specific implementations
- **State machine** for playback state management

**Key Finding:** There is NO single pause/resume handler, but a **coordinated system** where:
1. **VProgressController** manages progress bar pause/resume
2. **VBaseMediaController** manages media playback pause/resume
3. **VStoryViewer** orchestrates both + state management

---

## Architecture Layers

### Layer 1: Gesture Detection
- **VGestureWrapper** - Detects long press, carousel scroll, reply focus changes
- **VGestureCallbacks** - Defines gesture callback interface
- **Entry point:** Listener.onPointerDown/Up

### Layer 2: Gesture Routing
- **VStoryGestureHandler** - Routes gestures to appropriate handlers
- **Validates configuration flags** (pauseOnLongPress, pauseOnCarouselScroll)
- **Calls callbacks:** onPauseStory, onResumeStory

### Layer 3: Orchestration
- **VStoryViewer** - Main orchestrator (CENTRAL HUB)
- **Coordinates:** Progress pause/resume + Media pause/resume + State updates
- **Listens to:** Events, carousel scroll, reply focus changes
- **Maintains:** VStoryPlaybackState

### Layer 4: Implementation
- **VProgressController** → VProgressTimer (timer management)
- **VBaseMediaController** → VVideoController (video playback)
- Both emit events for state synchronization

---

## File Reference Map

```
PAUSE/RESUME SYSTEM FILES
├── Controllers (Core Logic)
│   ├── v_progress_controller.dart (Lines 57-65)
│   │   ├── pauseProgress()
│   │   └── resumeProgress()
│   ├── v_progress_timer.dart (Lines 25-33)
│   │   ├── pause()
│   │   └── resume()
│   ├── v_base_media_controller.dart (Lines 92-127)
│   │   ├── pause() - Template method
│   │   └── resume() - Template method
│   └── v_video_controller.dart (Lines 77-84)
│       ├── pauseMedia() - Override
│       └── resumeMedia() - Override
│
├── Orchestration (Central Hub)
│   └── v_story_viewer.dart (State Widget)
│       ├── _handlePause() [Lines 321-327]
│       ├── _handleResume() [Lines 329-335]
│       ├── _handleTogglePlayPause() [Lines 337-344]
│       ├── _handleCarouselScrollStateChanged() [Lines 249-255]
│       └── Event listener [Lines 153-181]
│
├── Gesture System
│   ├── v_gesture_wrapper.dart (Lines 118-124)
│   │   └── onLongPressDown/Up/End/Cancel
│   ├── v_gesture_callbacks.dart (Lines 5-31)
│   │   ├── onLongPressStart
│   │   └── onLongPressEnd
│   ├── v_story_gesture_handler.dart (Lines 35-63)
│   │   ├── handleLongPressStart()
│   │   ├── handleLongPressEnd()
│   │   └── handleReplyFocusChanged()
│   └── v_carousel_manager.dart (Lines 29-39)
│       └── _handleCarouselScrolled()
│
├── State & Events
│   ├── v_story_viewer_state.dart (Lines 7-79)
│   │   ├── VStoryPlaybackState enum
│   │   └── State getters (isPlaying, isPaused, etc.)
│   ├── v_story_viewer_config.dart (Lines 10, 15, 26, 48)
│   │   ├── pauseOnLongPress
│   │   └── pauseOnCarouselScroll
│   ├── v_story_events.dart (Lines 51-60)
│   │   └── VStoryPauseStateChangedEvent
│   └── v_reply_view.dart (Lines 59-66)
│       └── _onFocusChange()
```

---

## Complete Pause/Resume Flow

### PAUSE Flow
```
User Action (Long Press / Reply Focus / Carousel Scroll)
    ↓
Gesture Detection Layer
    ↓
VStoryGestureHandler (validate config, route gesture)
    ↓
VStoryViewer._handlePause() [ORCHESTRATION]
    ├─→ VProgressController.pauseProgress()
    │   └─→ VProgressTimer.pause()
    │       └─→ Timer.cancel() [Stops 60ms tick]
    │
    ├─→ VBaseMediaController.pause()
    │   ├─→ pauseMedia() [template method override]
    │   │   └─→ VVideoController.pauseMedia()
    │   │       └─→ VideoPlayerController?.pause()
    │   ├─→ _isPaused = true
    │   └─→ Enqueue VStoryPauseStateChangedEvent(isPaused: true)
    │
    └─→ _updateState(playbackState: VStoryPlaybackState.paused)
        └─→ notifyListeners()
```

### RESUME Flow
```
User Action (Long Press Again / Reply Unfocus / Carousel Scroll Complete)
    ↓
VStoryViewer._handleResume() [ORCHESTRATION]
    ├─→ VProgressController.resumeProgress()
    │   └─→ VProgressTimer.resume()
    │       └─→ _startPeriodicTimer() [Restart 60ms tick]
    │
    ├─→ VBaseMediaController.resume()
    │   ├─→ resumeMedia() [template method override]
    │   │   └─→ VVideoController.resumeMedia()
    │   │       └─→ VideoPlayerController?.play()
    │   ├─→ _isPaused = false
    │   └─→ Enqueue VStoryPauseStateChangedEvent(isPaused: false)
    │
    └─→ _updateState(playbackState: VStoryPlaybackState.playing)
        └─→ notifyListeners()
```

---

## Entry Points Summary

| # | Entry Point | File | Line | Trigger |
|---|---|---|---|---|
| 1 | Long Press | v_gesture_wrapper.dart | 120 | `onLongPressDown` |
| 2 | Reply Focus | v_reply_view.dart | 49 | `FocusNode.addListener()` |
| 3 | Carousel Scroll | v_carousel_manager.dart | 29 | `PageController listener` |
| 4 | Story Navigation | v_story_viewer.dart | 204 | `_loadCurrentStory()` |
| 5 | Progress Complete | v_progress_controller.dart | 40 | `startProgress()` |

---

## State Management

### Playback States
```dart
enum VStoryPlaybackState {
  playing,    // Story actively playing
  paused,     // Story paused
  stopped,    // Story stopped/idle
  loading,    // Media loading
  error,      // Error occurred
}
```

### State Tracking Points
1. **VProgressTimer._currentProgress** - Progress value (0.0-1.0)
2. **VBaseMediaController._isPaused** - Media pause flag
3. **VStoryViewerState.playbackState** - Overall state
4. **VStoryViewer._state** - Current story viewer state

---

## Configuration

### Controllable Pause Behaviors
```dart
VStoryViewerConfig(
  pauseOnLongPress: true,        // Default: pause on long press
  pauseOnCarouselScroll: true,   // Default: pause during carousel scroll
)
```

### Effects of Disabling
- `pauseOnLongPress: false` → Long press detected but pause NOT triggered
- `pauseOnCarouselScroll: false` → Carousel scroll detected but pause NOT triggered

---

## Critical Behavior: Long Press is TOGGLE, Not Hold-to-Pause

```dart
// VStoryGestureHandler (v_story_gesture_handler.dart, Lines 35-45)
void handleLongPressStart() {
  if (!_config.pauseOnLongPress) return;
  onPauseStory();           // ← Toggle pause/resume
}

void handleLongPressEnd() {
  if (!_config.pauseOnLongPress) return;
  // Does NOTHING - toggle happens on press, not release
}
```

**User Interaction Pattern:**
- Press → Pause (if playing) or Resume (if paused)
- Release → No action
- NOT: Hold to pause, Release to resume

---

## Event System

### Key Events
1. **VMediaReadyEvent** - Triggers progress start (when media ready)
2. **VDurationKnownEvent** - Updates progress duration
3. **VStoryPauseStateChangedEvent** - Signals pause state change
4. **VReplyFocusChangedEvent** - Triggers pause/resume on reply focus
5. **VProgressCompleteEvent** - Triggers story advance

### Event Propagation
```
Feature → VStoryEventManager.instance.enqueue(event)
           ↓
VStoryViewer._setupEventListener() listens for all events
           ↓
Appropriate handler called (_handlePause, _handleResume, etc.)
```

---

## Design Patterns Used

### 1. Callback-Based Mediator
- Each feature has callback interface (VProgressCallbacks, VGestureCallbacks)
- VStoryViewer (orchestrator) receives and coordinates all callbacks
- Features don't reference each other directly

### 2. Event-Driven Architecture
- VStoryEventManager singleton provides event bus
- Features emit events for state changes
- VStoryViewer listens to specific events

### 3. Template Method Pattern
- VBaseMediaController.pause() is template
- Subclasses override pauseMedia() with specific logic
- VVideoController overrides with video_player calls

### 4. State Machine
- VStoryPlaybackState enum manages valid states
- Transitions: playing ↔ paused, loading, error
- Getters enforce safe state access

---

## Distributed vs Centralized Aspects

### Distributed
- **Timer logic** - VProgressTimer handles periodicity
- **Media control** - VVideoController handles video playback
- **Gesture detection** - VGestureWrapper detects interactions
- **Event emission** - Features emit their own events

### Centralized
- **Orchestration** - VStoryViewer coordinates all pause/resume
- **State management** - VStoryViewerState tracks playback state
- **Configuration** - VStoryViewerConfig centralized flags
- **Event listening** - VStoryViewer single listener for all events

---

## Memory Management

### Disposal Cleanup (VStoryViewer.dispose(), Lines 561-576)
```dart
@override
void dispose() {
  _progressController?.dispose();   // Disposes VProgressTimer
  _mediaController?.dispose();      // Disposes VideoPlayerController
  VStoryEventManager.instance.clear(); // Clear event listeners
  _cubePageManager.dispose();       // Dispose PageController
  _keyboardFocusNode.dispose();
  _replyTextFieldFocusNode.dispose();
  super.dispose();
}
```

**Ensures:**
- All timers cancelled (no memory leaks from pause state)
- Video controllers disposed (no resource leaks)
- Event listeners cleared (no dangling references)

---

## Auto-Pause/Resume Scenarios

1. **Reply Input Focus**
   - Focus gained → Auto-pause
   - Focus lost → Auto-resume
   - File: v_reply_view.dart (Line 59)

2. **Carousel Scroll**
   - Scroll started → Auto-pause (if pauseOnCarouselScroll: true)
   - Scroll completed → Auto-resume
   - File: v_carousel_manager.dart (Line 29)

3. **Story Navigation**
   - New story selected → Progress paused via setCursorAt()
   - Media controller recreated and loaded
   - Progress resumes when media ready

---

## Testing Guidance

### Unit Test Example
```dart
test('pause pauses both progress and media', () {
  final progressCtrl = VProgressController(barCount: 3);
  final mediaCtrl = VVideoController();
  
  // Start progress
  progressCtrl.startProgress(0, Duration(seconds: 5));
  expect(progressCtrl.isRunning, true);
  
  // Pause both
  progressCtrl.pauseProgress();
  mediaCtrl.pause();
  
  // Verify paused
  expect(progressCtrl.isRunning, false);
  expect(mediaCtrl.isPaused, true);
});
```

### Integration Test Path
1. Initialize VStoryViewer with story groups
2. Wait for first story to load and progress to start
3. Simulate long press gesture
4. Verify both progress and media are paused
5. Simulate long press again
6. Verify both progress and media are resumed

---

## Key Insight: Why Distributed but Coordinated?

The architecture is deliberately distributed to maintain:
1. **Separation of Concerns** - Each layer has single responsibility
2. **Testability** - Each component testable in isolation
3. **Reusability** - Features can be composed independently
4. **Extensibility** - New media types override pauseMedia/resumeMedia

Yet coordinated through:
1. **VStoryViewer orchestration** - Single point of pause/resume logic
2. **Event propagation** - All components stay synchronized
3. **Callback routing** - Structured communication between features
4. **State sharing** - Central state machine for playback states

This balance enables both flexibility and maintainability.

---

## Quick Reference: All Pause Methods

| Class | Method | Line | Type | Purpose |
|-------|--------|------|------|---------|
| VProgressController | pauseProgress() | 57 | Public | Pause progress bar |
| VProgressController | resumeProgress() | 61 | Public | Resume progress bar |
| VProgressTimer | pause() | 25 | Public | Pause timer |
| VProgressTimer | resume() | 29 | Public | Resume timer |
| VBaseMediaController | pause() | 92 | Public | **Template:** pause media |
| VBaseMediaController | resume() | 111 | Public | **Template:** resume media |
| VBaseMediaController | pauseMedia() | 184 | Protected | Override point |
| VBaseMediaController | resumeMedia() | 191 | Protected | Override point |
| VVideoController | pauseMedia() | 77 | Protected | Override: pause video |
| VVideoController | resumeMedia() | 82 | Protected | Override: resume video |
| _VStoryViewerState | _handlePause() | 321 | Private | Orchestrate pause |
| _VStoryViewerState | _handleResume() | 329 | Private | Orchestrate resume |
| _VStoryViewerState | _handleTogglePlayPause() | 337 | Private | Toggle pause/resume |

---

## Conclusion

The pause/resume system is a **well-designed, distributed architecture** with **centralized orchestration**. It successfully balances:
- Feature separation and reusability
- Coordinated pause/resume behavior
- Event-driven state synchronization
- Extensibility for new media types
- Memory safety through proper disposal

The key to understanding it is recognizing that **VStoryViewer is the orchestration hub** that coordinates pause/resume across all subsystems while keeping those subsystems independent and testable.
