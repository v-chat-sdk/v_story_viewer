# API Reference

Complete API documentation for `v_story_viewer` package.

## Table of Contents

1. [Core Widgets](#core-widgets)
2. [Controllers](#controllers)
3. [Data Models](#data-models)
4. [Configuration Classes](#configuration-classes)
5. [Error Handling](#error-handling)
6. [Constants](#constants)
7. [Examples](#examples)

---

## Core Widgets

### VStoryViewer

The main widget that displays stories with gesture controls and customization options.

```dart
VStoryViewer(
  storyGroups: List<VStoryGroup>,
  controller: VStoryController?,
  onComplete: VoidCallback?,
  onDispose: VoidCallback?,
  onStoryChanged: Function(int, int)?,
  onGroupChanged: Function(int)?,
  theme: VStoryTheme?,
  gestureConfig: VGestureConfig?,
  replyConfig: VReplyConfig?,
  reactionConfig: VReactionConfig?,
  headerBuilder: Function?,
  footerBuilder: Function?,
  cacheManager: BaseCacheManager?,
  locale: Locale?,
  textDirection: TextDirection?,
)
```

#### Parameters

| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| `storyGroups` | `List<VStoryGroup>` | Story groups to display | ✅ Yes |
| `controller` | `VStoryController?` | Controller for programmatic control | ❌ No |
| `onComplete` | `VoidCallback?` | Called when all stories are completed | ❌ No |
| `onDispose` | `VoidCallback?` | Called when viewer is disposed | ❌ No |
| `onStoryChanged` | `Function(int, int)?` | Called with (groupIndex, storyIndex) on story change | ❌ No |
| `onGroupChanged` | `Function(int)?` | Called with groupIndex on group change | ❌ No |
| `theme` | `VStoryTheme?` | Customize appearance | ❌ No |
| `gestureConfig` | `VGestureConfig?` | Configure gesture behavior | ❌ No |
| `replyConfig` | `VReplyConfig?` | Enable reply system | ❌ No |
| `reactionConfig` | `VReactionConfig?` | Enable reaction system | ❌ No |
| `headerBuilder` | `Function?` | Custom header widget builder | ❌ No |
| `footerBuilder` | `Function?` | Custom footer widget builder | ❌ No |
| `cacheManager` | `BaseCacheManager?` | Custom cache manager instance | ❌ No |
| `locale` | `Locale?` | Language and region setting | ❌ No |
| `textDirection` | `TextDirection?` | Text direction (LTR/RTL) | ❌ No |

#### Example

```dart
VStoryViewer(
  storyGroups: storyGroups,
  onComplete: () => Navigator.pop(context),
  onStoryChanged: (groupIndex, storyIndex) {
    print('Viewing story $storyIndex from group $groupIndex');
  },
)
```

---

## Controllers

### VStoryController

Provides programmatic control over story playback and navigation.

```dart
final controller = VStoryController();
```

#### Methods

##### Playback Control

```dart
void play()           // Resume story playback
void pause()          // Pause story playback
void stop()           // Stop playback completely
void reset()          // Reset to the first story
```

##### Navigation

```dart
void nextStory()      // Navigate to next story
void previousStory()  // Navigate to previous story

void nextGroup()      // Navigate to next story group
void previousGroup()  // Navigate to previous story group

void jumpToStory({
  required int groupIndex,
  required int storyIndex,
})                    // Jump to specific story
```

##### State Management

```dart
void addListener(VoidCallback listener)      // Listen to state changes
void removeListener(VoidCallback listener)   // Remove listener
void dispose()                                // Cleanup resources
```

##### Properties

```dart
VStoryState get state          // Current controller state
bool get isPlaying             // Whether story is playing
int get currentGroupIndex      // Current group index
int get currentStoryIndex      // Current story index
```

#### Example

```dart
final controller = VStoryController();

// Use with VStoryViewer
VStoryViewer(
  storyGroups: storyGroups,
  controller: controller,
)

// Listen to changes
controller.addListener(() {
  if (controller.isPlaying) {
    print('Playing story at ${controller.currentGroupIndex}:${controller.currentStoryIndex}');
  }
});

// Programmatic control
controller.nextStory();
controller.jumpToStory(groupIndex: 1, storyIndex: 2);

// Cleanup
controller.dispose();
```

---

## Data Models

### VStoryGroup

Container for stories from a single user.

```dart
VStoryGroup({
  required String id,
  required VStoryUser user,
  required List<VBaseStory> stories,
})
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique identifier for the group |
| `user` | `VStoryUser` | User information |
| `stories` | `List<VBaseStory>` | List of stories in the group |

### VStoryUser

User information displayed in story headers.

```dart
VStoryUser({
  required String name,
  String? profileUrl,
  bool verified = false,
})
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | User's display name |
| `profileUrl` | `String?` | Profile image URL (optional) |
| `verified` | `bool` | Verification badge (default: false) |

### VBaseStory (Abstract)

Base class for all story types. Do not instantiate directly.

```dart
abstract class VBaseStory {
  String get id;
  Duration? get duration;
  bool get isViewed;
  bool get isReacted;
  DateTime get createdAt;
  String get groupId;
  String? get caption;
  Map<String, dynamic>? get metadata;
}
```

### VImageStory

Display image stories.

```dart
VImageStory({
  required String id,
  required String url,          // Network, asset, or file path
  Duration? duration,           // Display duration (default: 5s)
  String? caption,
  BoxFit fit = BoxFit.contain,
  double? aspectRatio,
  Size? dimensions,
  bool isViewed = false,
  bool isReacted = false,
  required DateTime createdAt,
  required String groupId,
  Map<String, dynamic>? metadata,
})
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `url` | `String` | Image URL (supports network, asset, file paths) |
| `duration` | `Duration?` | How long to display the image |
| `caption` | `String?` | Optional caption text |
| `fit` | `BoxFit` | Image fit mode (default: contain) |
| `aspectRatio` | `double?` | Custom aspect ratio |
| `dimensions` | `Size?` | Image dimensions for better layout |

#### Example

```dart
VImageStory(
  id: 'img1',
  url: 'https://example.com/image.jpg',
  duration: const Duration(seconds: 5),
  caption: 'Beautiful view',
  fit: BoxFit.cover,
)
```

### VVideoStory

Display video stories with auto-play.

```dart
VVideoStory({
  required String id,
  required String url,          // Video URL
  String? caption,
  VPlatformFile? thumbnail,
  double? aspectRatio,
  bool autoPlay = true,
  bool muted = false,
  bool looping = false,
  bool isViewed = false,
  bool isReacted = false,
  required DateTime createdAt,
  required String groupId,
  Duration? duration,           // Video duration (auto-detected)
  Map<String, dynamic>? metadata,
})
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `url` | `String` | Video URL (network or local file) |
| `caption` | `String?` | Optional caption |
| `thumbnail` | `VPlatformFile?` | Custom thumbnail |
| `aspectRatio` | `double?` | Custom aspect ratio |
| `autoPlay` | `bool` | Auto-play when displayed (default: true) |
| `muted` | `bool` | Start muted (default: false) |
| `looping` | `bool` | Loop video (default: false) |
| `duration` | `Duration?` | Video duration (auto-detected if null) |

#### Example

```dart
VVideoStory(
  id: 'vid1',
  url: 'https://example.com/video.mp4',
  caption: 'Check this out!',
  autoPlay: true,
  muted: false,
)
```

### VTextStory

Display text-based stories.

```dart
VTextStory({
  required String id,
  required String text,
  required Color backgroundColor,
  TextStyle? textStyle,
  Duration? duration,           // Default: calculated from text length
  bool isViewed = false,
  bool isReacted = false,
  required DateTime createdAt,
  required String groupId,
  Map<String, dynamic>? metadata,
})
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `text` | `String` | Text content to display |
| `backgroundColor` | `Color` | Background color |
| `textStyle` | `TextStyle?` | Custom text styling |
| `duration` | `Duration?` | Display duration (auto-calculated if null) |

#### Example

```dart
VTextStory(
  id: 'txt1',
  text: 'Hello World!',
  backgroundColor: Colors.blue,
  textStyle: const TextStyle(
    fontSize: 32,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  ),
  duration: const Duration(seconds: 5),
)
```

### VCustomStory

Display any Flutter widget as a story.

```dart
VCustomStory({
  required String id,
  required Duration duration,
  required WidgetBuilder builder,
  bool isViewed = false,
  bool isReacted = false,
  required DateTime createdAt,
  required String groupId,
  Map<String, dynamic>? metadata,
})
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `duration` | `Duration` | How long to display the widget |
| `builder` | `WidgetBuilder` | Function that builds the custom widget |

#### Example

```dart
VCustomStory(
  id: 'custom1',
  duration: const Duration(seconds: 5),
  builder: (context) => Container(
    color: Colors.purple,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, color: Colors.red, size: 100),
          const SizedBox(height: 20),
          const Text(
            'Custom Content',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ],
      ),
    ),
  ),
)
```

---

## Configuration Classes

### VStoryTheme

Customize the visual appearance of the story viewer.

```dart
VStoryTheme({
  VProgressBarStyle? progressBarStyle,
  VHeaderStyle? headerStyle,
  VFooterStyle? footerStyle,
  Color? backgroundColor,
  double? cornerRadius,
})
```

#### Nested Classes

#### VProgressBarStyle

```dart
VProgressBarStyle({
  Color activeColor = Colors.white,
  Color inactiveColor = Colors.white30,
  double height = 2.0,
})
```

#### VHeaderStyle

```dart
VHeaderStyle({
  Color backgroundColor = Colors.transparent,
  TextStyle? textStyle,
  EdgeInsets padding = const EdgeInsets.all(16),
})
```

#### VFooterStyle

```dart
VFooterStyle({
  Color backgroundColor = Colors.black54,
  TextStyle? textStyle,
  EdgeInsets padding = const EdgeInsets.all(16),
})
```

#### Example

```dart
VStoryTheme(
  progressBarStyle: VProgressBarStyle(
    activeColor: Colors.amber,
    inactiveColor: Colors.amber.withOpacity(0.3),
    height: 3.0,
  ),
  headerStyle: VHeaderStyle(
    backgroundColor: Colors.black87,
    textStyle: const TextStyle(color: Colors.white),
  ),
  footerStyle: VFooterStyle(
    backgroundColor: Colors.black87,
  ),
  backgroundColor: Colors.black,
  cornerRadius: 12,
)
```

### VGestureConfig

Configure gesture behavior and tap zones.

```dart
VGestureConfig({
  double leftTapZoneWidth = 0.4,
  double rightTapZoneWidth = 0.6,
  bool enableVerticalSwipe = true,
  bool enableHorizontalSwipe = true,
  bool enableDoubleTap = true,
  bool enableLongPress = true,
  double swipeDownThreshold = 100.0,
})
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `leftTapZoneWidth` | `double` | Left tap zone width (0-1, percentage of screen) |
| `rightTapZoneWidth` | `double` | Right tap zone width (0-1, percentage of screen) |
| `enableVerticalSwipe` | `bool` | Enable swipe down to dismiss |
| `enableHorizontalSwipe` | `bool` | Enable swipe left/right between groups |
| `enableDoubleTap` | `bool` | Enable double tap for reactions |
| `enableLongPress` | `bool` | Enable long press to pause |
| `swipeDownThreshold` | `double` | Distance threshold for swipe down |

#### Example

```dart
VGestureConfig(
  leftTapZoneWidth: 0.3,      // 30% of screen
  rightTapZoneWidth: 0.7,     // 70% of screen
  enableVerticalSwipe: true,
  enableHorizontalSwipe: true,
  enableDoubleTap: true,
  enableLongPress: true,
  swipeDownThreshold: 150.0,
)
```

### VReplyConfig

Enable and configure the reply system.

```dart
VReplyConfig({
  bool enabled = true,
  String placeholder = 'Reply to story...',
  int maxLength = 280,
  Function(String message, String storyId)? onReply,
})
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `enabled` | `bool` | Enable reply functionality |
| `placeholder` | `String` | Input field placeholder text |
| `maxLength` | `int` | Maximum reply message length |
| `onReply` | `Function?` | Callback with (message, storyId) |

#### Example

```dart
VReplyConfig(
  enabled: true,
  placeholder: 'Reply to this story...',
  maxLength: 500,
  onReply: (message, storyId) {
    print('User replied: $message to story: $storyId');
    // Send to backend
  },
)
```

### VReactionConfig

Enable and configure emoji reactions.

```dart
VReactionConfig({
  bool enabled = true,
  List<String> reactions = const ['❤️', '😂', '😮', '😢', '👏'],
  Function(String emoji, String storyId)? onReaction,
})
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `enabled` | `bool` | Enable reaction functionality |
| `reactions` | `List<String>` | List of available emoji reactions |
| `onReaction` | `Function?` | Callback with (emoji, storyId) |

#### Example

```dart
VReactionConfig(
  enabled: true,
  reactions: ['❤️', '😂', '😮', '😢', '👏', '🔥', '💯', '🎉'],
  onReaction: (emoji, storyId) {
    print('User reacted with $emoji to story $storyId');
    // Send to backend
  },
)
```

---

## Error Handling

### VStoryError

Base error class for story viewer exceptions.

```dart
abstract class VStoryError implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  VStoryError({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}
```

### Common Errors

```dart
// Media loading error
try {
  // Story viewer operation
} on VMediaLoadError catch (e) {
  print('Failed to load media: ${e.message}');
}

// Cache error
try {
  // Cache operation
} on VCacheError catch (e) {
  print('Cache error: ${e.message}');
}

// Video initialization error
try {
  // Video operation
} on VVideoError catch (e) {
  print('Video error: ${e.message}');
}

// General story error
try {
  // Story operation
} on VStoryError catch (e) {
  print('Error: ${e.message}');
}
```

---

## Constants

### VStoryConstants

Default configuration values and limits.

```dart
class VStoryConstants {
  // Durations
  static const Duration defaultStoryDuration = Duration(seconds: 5);
  static const Duration progressAnimationDuration = Duration(milliseconds: 500);
  static const Duration transitionDuration = Duration(milliseconds: 300);

  // Progress bar
  static const double minProgressBarHeight = 1.0;
  static const double maxProgressBarHeight = 4.0;
  static const double defaultProgressBarHeight = 2.0;

  // Layout
  static const double headerHeight = 60.0;
  static const double footerHeight = 80.0;

  // Gesture thresholds
  static const double swipeDownThreshold = 100.0;
  static const int doubleTapTimeWindow = 500;  // milliseconds

  // Text duration calculation
  static const int defaultWordsPerMinute = 200;
  static const Duration minTextDuration = Duration(seconds: 2);
  static const Duration maxTextDuration = Duration(seconds: 10);
}
```

---

## Examples

### Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story Viewer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StoryPage(),
    );
  }
}

class StoryPage extends StatelessWidget {
  const StoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stories = [
      VStoryGroup(
        id: 'user1',
        user: const VStoryUser(
          name: 'John Doe',
          profileUrl: 'https://example.com/john.jpg',
        ),
        stories: [
          VImageStory(
            id: 'story1',
            url: 'https://example.com/image1.jpg',
            duration: const Duration(seconds: 5),
          ),
          VVideoStory(
            id: 'story2',
            url: 'https://example.com/video1.mp4',
          ),
        ],
      ),
    ];

    return Scaffold(
      body: VStoryViewer(
        storyGroups: stories,
        onComplete: () => Navigator.pop(context),
      ),
    );
  }
}
```

### With Controller

```dart
class StoryPageWithController extends StatefulWidget {
  const StoryPageWithController({Key? key}) : super(key: key);

  @override
  State<StoryPageWithController> createState() => _StoryPageWithControllerState();
}

class _StoryPageWithControllerState extends State<StoryPageWithController> {
  late final VStoryController _controller = VStoryController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      print('Current story: ${_controller.currentGroupIndex}:${_controller.currentStoryIndex}');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VStoryViewer(
        storyGroups: stories,
        controller: _controller,
        onComplete: () => Navigator.pop(context),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'prev',
            onPressed: _controller.previousStory,
            child: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'next',
            onPressed: _controller.nextStory,
            child: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
```

### With Customization

```dart
VStoryViewer(
  storyGroups: stories,
  theme: VStoryTheme(
    progressBarStyle: VProgressBarStyle(
      activeColor: Colors.amber,
      inactiveColor: Colors.amber.withOpacity(0.3),
      height: 3.0,
    ),
    headerStyle: VHeaderStyle(
      backgroundColor: Colors.black87,
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
  gestureConfig: VGestureConfig(
    leftTapZoneWidth: 0.3,
    rightTapZoneWidth: 0.7,
    enableVerticalSwipe: true,
    enableHorizontalSwipe: true,
  ),
  replyConfig: VReplyConfig(
    enabled: true,
    placeholder: 'Reply to story...',
    onReply: (message, storyId) {
      print('Reply: $message');
    },
  ),
  reactionConfig: VReactionConfig(
    enabled: true,
    reactions: ['❤️', '😂', '😮', '😢', '👏', '🔥'],
    onReaction: (emoji, storyId) {
      print('Reaction: $emoji');
    },
  ),
  onComplete: () => Navigator.pop(context),
)
```

---

For more information and examples, see [README.md](README.md).
