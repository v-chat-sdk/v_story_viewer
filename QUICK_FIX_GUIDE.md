# Quick Fix Guide - Critical Issues

## 🔴 CRITICAL FIXES (Do This Week)

### Fix 1: Media Controller Race Condition (30 min)
**File:** `lib/src/features/v_story_viewer/widgets/v_story_viewer.dart`
**Lines:** 190-229 (in `_loadCurrentStory()`)

**The Bug:**
When user rapidly navigates between stories, old controller's cached callbacks can fire AFTER the new controller is created, causing memory corruption.

**Quick Fix:**
```dart
Future<void> _loadCurrentStory() async {
  final oldController = _mediaController;
  final currentStoryId = currentStory.id; // ← ADD THIS LINE
  _mediaController = null;
  oldController?.dispose();

  if (!mounted) return;
  _initMediaController(currentStory);

  if (!mounted || _mediaController == null) return;
  try {
    await _mediaController!.loadStory(currentStory);
    // ← ADD THIS CHECK
    if (!mounted || _mediaController?.currentStory?.id != currentStoryId) return;
  } catch (e) {
    if (!mounted) return;
    rethrow;
  }
}
```

---

### Fix 2: Progress Bar Wrong Position (10 min)
**File:** `lib/src/features/v_story_viewer/widgets/v_story_viewer.dart`
**Lines:** 345-355 (in `_reinitializeProgressController()`)

**The Bug:**
Progress bar always starts at `initialStoryIndex` instead of 0 when switching groups.

**Quick Fix:**
```dart
void _reinitializeProgressController() {
  _progressController!
    ..pauseProgress()
    ..dispose();

  _progressController = VControllerInitializer.createProgressController(
    barCount: _navigationController.currentGroup.stories.length,
    currentBar: 0,  // ← CHANGE FROM: widget.initialStoryIndex
    callbacks: VProgressCallbacks(onBarComplete: _handleProgressComplete),
  );
}
```

---

### Fix 3: Unsafe Type Check (10 min)
**File:** `lib/src/features/v_story_header/views/v_header_view.dart`
**Lines:** 103-105

**The Bug:**
Using string comparison breaks with inheritance and obfuscation.

**Quick Fix:**
```dart
// CHANGE FROM:
bool _isVideoStory() =>
    widget.currentStory?.runtimeType.toString().contains('VVideoStory') ?? false;

// TO:
bool _isVideoStory() => widget.currentStory is VVideoStory;
```

---

### Fix 4: Header Listener Stale Reference (30 min)
**File:** `lib/src/features/v_story_header/views/v_header_view.dart`
**Lines:** 69-85

**The Bug:**
Multiple listeners accumulate on rapid story changes, causing performance issues.

**Quick Fix:**
```dart
class _VHeaderViewState extends State<VHeaderView> {
  VoidCallback? _mediaListenerReference;  // ← ADD THIS FIELD

  @override
  void initState() {
    super.initState();
    _isPaused = widget.mediaController?.isPaused ?? false;
    _isMuted = _getIsMuted();
    if (widget.mediaController != null) {
      widget.mediaController!.addListener(_onMediaStateChanged);
      _mediaListenerReference = _onMediaStateChanged;  // ← TRACK REFERENCE
    }
  }

  @override
  void didUpdateWidget(VHeaderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaController != widget.mediaController) {
      // ← REMOVE USING TRACKED REFERENCE
      if (_mediaListenerReference != null && oldWidget.mediaController != null) {
        oldWidget.mediaController!.removeListener(_mediaListenerReference!);
      }
      if (widget.mediaController != null) {
        widget.mediaController!.addListener(_onMediaStateChanged);
        _mediaListenerReference = _onMediaStateChanged;
      }
      _isPaused = widget.mediaController?.isPaused ?? false;
      _isMuted = _getIsMuted();
    }
  }

  @override
  void dispose() {
    // ← ADD THIS BLOCK
    if (_mediaListenerReference != null && widget.mediaController != null) {
      widget.mediaController!.removeListener(_mediaListenerReference!);
    }
    super.dispose();
  }
}
```

---

### Fix 5: Missing Mounted Checks (30 min)
**File:** `lib/src/features/v_story_viewer/widgets/v_story_viewer.dart`
**Lines:** 153-181 (in `_setupEventListener()`)

**The Bug:**
Some event handlers don't check if widget is mounted before executing.

**Quick Fix:**
```dart
void _setupEventListener() {
  _eventSubscription = VStoryEventManager.instance.on<VStoryEvent>((event) {
    if (!mounted) return;

    switch (event) {
      case VMediaReadyEvent():
        if (mounted) _handleMediaReady();  // ← ADD CHECK
      case VMediaErrorEvent():
        if (mounted) {  // ← ADD CHECK
          widget.callbacks?.onError?.call(event.error);
        }
      case VDurationKnownEvent():
        if (mounted) {  // ← ADD CHECK
          _progressController?.updateDuration(event.duration);
        }
      case VReactionSentEvent():
        if (mounted) {  // ← ADD CHECK
          debugPrint('Reaction: ${event.reactionType} for story ${event.story.id}');
        }
      case VReplyFocusChangedEvent():
        if (mounted) {  // ← ADD CHECK
          event.hasFocus ? _handlePause() : _handleResume();
        }
      case VStoryPauseStateChangedEvent():
        break;
      default:
        break;
    }
  });
}
```

---

### Fix 6: Cache Controller Disposed Check (20 min)
**File:** `lib/src/features/v_cache_manager/controllers/v_cache_controller.dart`
**Lines:** 135-178 (in `_performNetworkFetch()`)

**The Bug:**
Error handler emits events without checking if controller is disposed.

**Quick Fix:**
```dart
Future<File?> _performNetworkFetch(String url, String storyId) async {
  try {
    if (_isDisposed) return null;  // ← ADD CHECK
    final cachedFile = await _downloadManager!.getFromCache(url);
    if (_isDisposed) return null;  // ← ADD CHECK

    if (cachedFile != null && !_downloadManager!.isCacheStale(cachedFile)) {
      return _isDisposed ? null : _handleCacheHit(url, cachedFile.file, storyId);
    }
    if (_isDisposed) return null;  // ← ADD CHECK
    return await _downloadWithProgress(url, storyId);
  } catch (e) {
    if (!_isDisposed) {  // ← ADD CHECK
      _errorHandler.handleNetworkError(e, url, storyId);
    }
    return null;
  }
}
```

---

### Fix 7: Action Menu Position (20 min)
**File:** `lib/src/features/v_story_header/widgets/v_action_menu.dart`
**Lines:** 54-80

**The Bug:**
Menu positioned off-screen on small displays.

**Quick Fix:**
```dart
static RelativeRect _calculateMenuPosition({
  required Offset buttonPosition,
  required Size buttonSize,
  required Size screenSize,
  required double menuWidth,
  required double menuHeight,
}) {
  double left = buttonPosition.dx + buttonSize.width - menuWidth;
  double top = buttonPosition.dy + buttonSize.height + 8;

  if (left < 8) {
    left = 8;
  } else if (left + menuWidth > screenSize.width - 8) {
    left = screenSize.width - menuWidth - 8;
  }

  double bottom = 8;  // ← CHANGE FROM: 0
  if (top + menuHeight > screenSize.height - 8) {
    top = screenSize.height - menuHeight - 8;
    bottom = 8;
  }

  return RelativeRect.fromLTRB(left, top, 8, bottom);
}
```

---

### Fix 8: Video Controller Race Condition (20 min)
**File:** `lib/src/features/v_media_viewer/controllers/v_video_controller.dart`
**Lines:** 23-44

**The Bug:**
Multiple async gaps where state becomes inconsistent.

**Quick Fix:**
```dart
@override
Future<void> loadMedia(VBaseStory story) async {
  if (story is! VVideoStory) {
    throw ArgumentError('VVideoController requires VVideoStory');
  }

  final storyId = story.id;  // ← CAPTURE IMMEDIATELY
  final oldController = _videoPlayerController;
  _videoPlayerController = null;
  await oldController?.dispose();

  if (currentStory?.id != storyId) return;  // ← USE CAPTURED ID

  VPlatformFile? mediaToLoad = story.media;
  if (story.media.networkUrl != null) {
    final cachedFile = await cacheController.getFile(story.media, storyId);
    if (cachedFile != null) {
      mediaToLoad = cachedFile;
    }
  }

  if (currentStory?.id != storyId) return;  // ← USE CAPTURED ID

  _videoPlayerController = _createVideoController(mediaToLoad);
  await _initializeAndConfigureVideo(story);
}
```

---

## Summary of Quick Fixes

| # | Issue | File | Time | Impact |
|---|-------|------|------|--------|
| 1 | Media race condition | v_story_viewer.dart | 30 min | Prevents crashes |
| 2 | Progress bar position | v_story_viewer.dart | 10 min | Correct display |
| 3 | Type check | v_header_view.dart | 10 min | Fixes mute button |
| 4 | Listener cleanup | v_header_view.dart | 30 min | Performance |
| 5 | Mounted checks | v_story_viewer.dart | 30 min | Memory safety |
| 6 | Cache disposal | v_cache_controller.dart | 20 min | Prevents leaks |
| 7 | Menu position | v_action_menu.dart | 20 min | UI fix |
| 8 | Video race | v_video_controller.dart | 20 min | State safety |

**Total Time:** ~2.5 hours
**Risk After Fixes:** 🟢 LOW

---

## Testing After Fixes

After applying all fixes, test these scenarios:

```dart
// Test 1: Rapid navigation
for (int i = 0; i < 10; i++) {
  handleNextStory();
}
await tester.pumpAndSettle();
// Should not crash, progress bar should be correct

// Test 2: Menu on small screen
showMenu();
// Menu should be visible, not off-screen

// Test 3: Video story mute
tapVideoStory();
// Mute icon should appear

// Test 4: Group change
viewMultipleStories();
jumpToNextGroup();
// Progress bar should reset to 0
```

---

## Verification Checklist

- [ ] Fix #1 applied and tested
- [ ] Fix #2 applied and tested
- [ ] Fix #3 applied and tested
- [ ] Fix #4 applied and tested
- [ ] Fix #5 applied and tested
- [ ] Fix #6 applied and tested
- [ ] Fix #7 applied and tested
- [ ] Fix #8 applied and tested
- [ ] Run `flutter analyze` - no errors
- [ ] Manual testing - rapid navigation works
- [ ] Manual testing - menu displays correctly
- [ ] Manual testing - progress bar synced

---

**Estimated Total Fix Time:** 2.5 hours
**Estimated Testing Time:** 1 hour
**Total Effort:** ~3.5 hours

After these fixes, the codebase will be much more stable and safe!
