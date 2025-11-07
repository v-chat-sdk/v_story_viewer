# v_story_viewer API Reference

Complete API documentation for v_story_viewer package.

## Core Components

### VStoryViewer

Main widget that displays stories with gesture controls and customization.

```dart
VStoryViewer(
  storyGroups: List<VStoryGroup>,           // Required: Story groups to display
  controller: VStoryController?,             // Optional: Programmatic control
  onComplete: VoidCallback?,                 // Called when all stories are viewed
  onDispose: VoidCallback?,                  // Called when viewer is disposed
  onStoryChanged: ValueChanged<(int, int)>?, // Called when story changes
  onGroupChanged: ValueChanged<int>?,        // Called when group changes
  theme: VStoryTheme?,                       // Customize appearance
  gestureConfig: VGestureConfig?,            // Configure gestures
  replyConfig: VReplyConfig?,                // Enable reply system
  reactionConfig: VReactionConfig?,          // Enable reaction system
  headerBuilder: HeaderBuilder?,             // Custom header widget
  footerBuilder: FooterBuilder?,             // Custom footer widget
  cacheManager: BaseCacheManager?,           // Custom cache manager
  locale: Locale?,                           // Localization support
  textDirection: TextDirection?,             // RTL/LTR support
)
```

### VStoryController

Programmatic control over story playback and navigation.

```dart
final controller = VStoryController();

// Playback control
controller.play();                           // Resume playback
controller.pause();                          // Pause playback
controller.stop();                           // Stop playback
controller.reset();                          // Reset to start

// Navigation
controller.nextStory();                      // Next story
controller.previousStory();                  // Previous story
controller.nextGroup();                      // Next group
controller.previousGroup();                  // Previous group
controller.jumpToStory({
  required int groupIndex,
  required int storyIndex,
});

// State tracking
controller.addListener(() {
  print('State: ${controller.state}');
});

controller.dispose();                        // Cleanup resources
```

## Story Models

### VStoryGroup

Container for multiple stories from a user.

```dart
VStoryGroup(
  id: String,                    // Unique identifier
  user: VStoryUser,              // User information
  stories: List<VBaseStory>,     // List of stories
)
```

### VStoryUser

User information for story header.

```dart
VStoryUser(
  name: String,                  // Display name
  profileUrl: String?,           // Profile image URL
  verified: bool = false,        // Verification badge
)
```

### Story Types

#### VImageStory

```dart
VImageStory(
  id: String,                          // Unique identifier
  url: String,                         // Image URL (network, asset, or file path)
  duration: Duration?,                 // Display duration (default: 5 seconds)
  caption: String?,                    // Optional caption
  fit: BoxFit = BoxFit.contain,        // Image fit mode
  aspectRatio: double?,                // Custom aspect ratio
  dimensions: Size?,                   // Image dimensions for calculation
  isViewed: bool = false,              // Viewed state
  isReacted: bool = false,             // Reaction state
  createdAt: DateTime,                 // Creation time
  groupId: String,                     // Parent group ID
  metadata: Map<String, dynamic>?,     // Custom metadata
)
```

#### VVideoStory

```dart
VVideoStory(
  id: String,                          // Unique identifier
  url: String,                         // Video URL
  caption: String?,                    // Optional caption
  thumbnail: VPlatformFile?,           // Custom thumbnail
  aspectRatio: double?,                // Custom aspect ratio
  autoPlay: bool = true,               // Auto play on display
  muted: bool = false,                 // Start muted
  looping: bool = false,               // Loop video
  isViewed: bool = false,              // Viewed state
  isReacted: bool = false,             // Reaction state
  createdAt: DateTime,                 // Creation time
  groupId: String,                     // Parent group ID
  duration: Duration?,                 // Video duration (auto-detected)
  metadata: Map<String, dynamic>?,     // Custom metadata
)
```

#### VTextStory

```dart
VTextStory(
  id: String,                          // Unique identifier
  text: String,                        // Text content
  backgroundColor: Color,              // Background color
  textStyle: TextStyle?,               // Text style
  duration: Duration?,                 // Display duration
  isViewed: bool = false,              // Viewed state
  isReacted: bool = false,             // Reaction state
  createdAt: DateTime,                 // Creation time
  groupId: String,                     // Parent group ID
  metadata: Map<String, dynamic>?,     // Custom metadata
)
```

#### VCustomStory

```dart
VCustomStory(
  id: String,                          // Unique identifier
  duration: Duration,                  // Display duration
  builder: WidgetBuilder,              // Custom widget builder
  isViewed: bool = false,              // Viewed state
  isReacted: bool = false,             // Reaction state
  createdAt: DateTime,                 // Creation time
  groupId: String,                     // Parent group ID
  metadata: Map<String, dynamic>?,     // Custom metadata
)
```

## Configuration Classes

### VThemeConfig

Customize the visual appearance.

```dart
VStoryTheme(
  progressBarStyle: VProgressBarStyle(
    activeColor: Color,                // Active progress color
    inactiveColor: Color,              // Inactive progress color
    height: double,                    // Progress bar height
  ),
  headerStyle: VHeaderStyle(
    backgroundColor: Color,            // Header background
    textStyle: TextStyle,              // User name style
  ),
  footerStyle: VFooterStyle(
    backgroundColor: Color,            // Footer background
    textStyle: TextStyle,              // Caption text style
  ),
  backgroundColor: Color,              // Overall background
  cornerRadius: double,                // Rounded corners
)
```

### VGestureConfig

Configure gesture behavior.

```dart
VGestureConfig(
  leftTapZoneWidth: double,            // Left tap zone width (0-1)
  rightTapZoneWidth: double,           // Right tap zone width (0-1)
  enableVerticalSwipe: bool,           // Swipe down to dismiss
  enableHorizontalSwipe: bool,         // Swipe left/right between groups
  enableDoubleTap: bool,               // Double tap for reactions
  enableLongPress: bool,               // Long press to pause
  swipeDownThreshold: double,          // Swipe distance threshold
)
```

### VReplyConfig

Enable reply functionality.

```dart
VReplyConfig(
  enabled: bool,                       // Enable replies
  placeholder: String,                 // Input placeholder
  maxLength: int,                      // Max message length
  onReply: Function(String, String),   // Callback: (message, storyId)
)
```

### VReactionConfig

Enable emoji reactions.

```dart
VReactionConfig(
  enabled: bool,                       // Enable reactions
  reactions: List<String>,             // Available emojis
  onReaction: Function(String, String),// Callback: (emoji, storyId)
)
```

## Constants

### VStoryConstants

```dart
// Default durations
VStoryConstants.defaultStoryDuration    // 5 seconds
VStoryConstants.progressAnimationDuration
VStoryConstants.transitionDuration

// Layout
VStoryConstants.minProgressBarHeight
VStoryConstants.maxProgressBarHeight
VStoryConstants.headerHeight
VStoryConstants.footerHeight

// Gesture thresholds
VStoryConstants.swipeDownThreshold
VStoryConstants.doubleTapTimeWindow
```

## Error Handling

### VStoryError

Base error class for story viewer errors.

```dart
try {
  // Story viewer operations
} on VMediaLoadError catch (e) {
  print('Failed to load media: ${e.message}');
} on VCacheError catch (e) {
  print('Cache error: ${e.message}');
} on VStoryError catch (e) {
  print('Story error: ${e.message}');
}
```

## Localization

### VLocalizationProvider

Support for multiple languages.

```dart
// Supported languages
Locale('en')  // English
Locale('ar')  // Arabic
Locale('es')  // Spanish
// ... add more as needed

// Usage
VStoryViewer(
  storyGroups: stories,
  locale: Locale('ar'),
  textDirection: TextDirection.rtl,
)
```

## Advanced Features

### Custom Headers/Footers

```dart
VStoryViewer(
  headerBuilder: (context, storyGroup, story) {
    return CustomHeader(
      user: storyGroup.user,
      timestamp: story.createdAt,
    );
  },
  footerBuilder: (context, storyGroup, story) {
    return CustomFooter(
      caption: story.caption,
    );
  },
)
```

### Cache Management

```dart
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager extends BaseCacheManager {
  static const key = 'customCacheKey';

  CustomCacheManager() : super(key);
}

VStoryViewer(
  storyGroups: stories,
  cacheManager: CustomCacheManager(),
)
```

### Media File Handling

```dart
import 'package:v_platform/v_platform.dart';

// Create from different sources
VPlatformFile.fromNetwork('https://example.com/image.jpg')
VPlatformFile.fromAsset('assets/images/story.jpg')
VPlatformFile.fromFile(File('/path/to/file.jpg'))
VPlatformFile.fromBytes(imageBytes)
```

## Event Callbacks

### Story Lifecycle Events

```dart
VStoryViewer(
  onStoryChanged: (groupIndex, storyIndex) {
    print('Story changed: group $groupIndex, story $storyIndex');
  },
  onGroupChanged: (groupIndex) {
    print('Group changed: $groupIndex');
  },
  onComplete: () {
    print('All stories completed');
    Navigator.pop(context);
  },
  onDispose: () {
    print('Story viewer disposed');
  },
)
```

### Reply and Reaction Events

```dart
VStoryViewer(
  replyConfig: VReplyConfig(
    enabled: true,
    onReply: (message, storyId) {
      print('Reply: $message to story $storyId');
      // Send to server
    },
  ),
  reactionConfig: VReactionConfig(
    enabled: true,
    onReaction: (emoji, storyId) {
      print('Reaction: $emoji on story $storyId');
      // Send to server
    },
  ),
)
```

## Best Practices

### Memory Management

```dart
// Always dispose controller
final controller = VStoryController();
// ... use controller
controller.dispose();

// Or use disposable pattern
@override
void dispose() {
  _storyController.dispose();
  super.dispose();
}
```

### Performance Optimization

```dart
// Use const constructors
const VImageStory(
  id: 'story1',
  url: 'https://example.com/image.jpg',
  duration: Duration(seconds: 5),
);

// Minimize rebuilds with proper configuration
VStoryViewer(
  storyGroups: stories,  // Avoid passing inline lists
  cacheManager: _cacheManager,  // Reuse cache manager
)
```

### Error Handling

```dart
// Provide fallback UI for errors
// Implement proper error states in custom headers/footers
// Use try-catch for programmatic operations
try {
  controller.jumpToStory(groupIndex: 0, storyIndex: 5);
} on RangeError {
  print('Invalid story index');
}
```

## Version Compatibility

- **Flutter**: >=3.0.0
- **Dart**: ^3.9.0

## Migration Guide

### From v0.x to v1.0

- Use `VStoryController()` instead of manual state management
- Configure gestures with `VGestureConfig` instead of individual properties
- Use `VStoryTheme` for consistent theming
- Reply/Reaction systems now use `VReplyConfig`/`VReactionConfig`

---

For more examples and detailed usage, see [README.md](README.md).
