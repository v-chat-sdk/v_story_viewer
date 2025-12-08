# v_story_viewer Package

## Overview
Flutter package for WhatsApp/Instagram-like story viewing with 3D cube transitions.

## Architecture

```
lib/
├── v_story_viewer.dart              # Public exports only
└── src/
    ├── models/
    │   ├── v_story_item.dart        # Sealed class: VImageStory, VVideoStory, VTextStory, VVoiceStory
    │   ├── v_story_group.dart       # User's story collection with expiry filtering
    │   ├── v_story_user.dart        # User info (id, name, imageUrl)
    │   └── v_story_config.dart      # Optional configuration
    ├── widgets/
    │   ├── v_story_circle.dart      # Avatar with segmented gradient ring
    │   ├── v_story_circle_list.dart # Horizontal scrollable list
    │   ├── v_story_viewer.dart      # Full-screen viewer with gestures
    │   ├── v_story_header.dart      # Back, avatar, name, time, menu, close
    │   ├── v_story_progress.dart    # Segmented LinearProgressIndicator
    │   ├── v_story_reply_field.dart # Bottom reply input
    │   └── content/
    │       ├── image_content.dart   # extended_image with retry
    │       ├── video_content.dart   # video_player with auto-duration
    │       ├── text_content.dart    # Auto-fit text, solid background
    │       └── voice_content.dart   # audioplayers with Slider
    ├── controllers/
    │   └── story_controller.dart    # ChangeNotifier for state
    ├── painters/
    │   └── circle_ring_painter.dart # CustomPainter for gradient ring
    ├── transitions/
    │   └── cube_page_view.dart      # 3D Matrix4 cube effect
    └── utils/
        ├── retry_helper.dart        # Exponential backoff (1s, 2s, 4s, 8s, 16s)
        └── time_formatter.dart      # Relative time display
```

## Dependencies
- `video_player: ^2.10.1` - Video playback
- `extended_image: ^10.0.1` - Image loading with state callbacks
- `audioplayers: ^6.5.1` - Audio playback

## Code Style

### Sealed Classes for Story Types
```dart
sealed class VStoryItem {
  final Duration? duration;
  final DateTime createdAt;
  bool get isExpired => DateTime.now().difference(createdAt).inHours >= 24;
}
final class VImageStory extends VStoryItem { ... }
final class VVideoStory extends VStoryItem { ... }
final class VTextStory extends VStoryItem { ... }
final class VVoiceStory extends VStoryItem { ... }
```

### Switch Expression for Content Rendering
```dart
Widget _buildContent(VStoryItem story) => switch (story) {
  VImageStory s => ImageContent(story: s, ...),
  VVideoStory s => VideoContent(story: s, ...),
  VTextStory s => TextContent(story: s, ...),
  VVoiceStory s => VoiceContent(story: s, ...),
};
```

### Use Flutter Built-ins
- `LinearProgressIndicator` for progress bar
- `Slider` for voice seek (not custom waveform)
- `CircularProgressIndicator` for loading states
- `AnimationController` for progress timing

### Memory Optimization
- Immediate dispose of video/audio controllers
- Re-initialize on return to story
- No preloading of next user's content

### RTL Support
```dart
final isRtl = Directionality.of(context) == TextDirection.rtl;
// Swap left/right tap areas for RTL
```

### Keyboard Navigation (Desktop/Web)
- Left Arrow: Previous story
- Right Arrow: Next story
- Space: Pause/Resume
- Escape: Close viewer

## Key Patterns

### Progress Bar Sync
Progress bar pauses while content is loading:
```dart
onLoadStateChanged: (state) {
  if (state is ExtendedImageLoadedState) {
    onLoaded();  // Resume progress
  }
}
```

### 3D Cube Transition
Uses Matrix4 for perspective transform between users:
```dart
transform: Matrix4.identity()
  ..setEntry(3, 2, 0.001)
  ..rotateY(rotationAngle),
```

### Exponential Backoff Retry
5 attempts with delays: 1s, 2s, 4s, 8s, 16s
Auto-skip after 5s on final failure.

### 24h Story Expiry
```dart
bool get isExpired => DateTime.now().difference(createdAt).inHours >= 24;
```

## Callbacks
All exposed for user control:
- `onComplete` - All stories viewed
- `onClose` - Viewer closed
- `onStoryViewed(groupIndex, itemIndex)` - Track seen state
- `onPause` / `onResume` - Long press events
- `onSkip(groupIndex, itemIndex)` - Story skipped
- `onReply(text, groupIndex, itemIndex)` - Reply submitted
- `onProgress(progress, groupIndex, itemIndex)` - Progress updates
- `onError(error, groupIndex, itemIndex)` - Load failures
- `onLoad(groupIndex, itemIndex)` - Content loaded
- `onSwipeUp(groupIndex, itemIndex)` - Swipe up gesture
- `onUserTap(user)` - Header user tap
- `onMenuTap(groupIndex, itemIndex)` - Menu button tap

## Rules
1. No backend APIs - UI + state management only
2. User manages seen state via callbacks
3. Max 20 ring segments (performance)
4. Filter expired stories in release, assert in debug
5. Auto-duration from video/audio media
6. Bouncing physics for cube transition
7. **always ask me questions** to get very clear understand of what you are coding this is very important 
