# V Story Viewer

A high-performance Flutter story viewer like WhatsApp/Instagram. Supports image, video, text, voice stories with 3D cube transitions.

[![pub package](https://img.shields.io/pub/v/v_story_viewer.svg)](https://pub.dev/packages/v_story_viewer)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Showcase

| Mobile | Mobile | Mobile | Mobile |
|--------|--------|--------|--------|
| ![Story 1](images/1.png) | ![Story 2](images/2.png) | ![Story 3](images/3.png) | ![Story 4](images/4.png) |

| Desktop | Desktop |
|---------|---------|
| ![Desktop 1](images/5.png) | ![Desktop 2](images/6.png) |

## Features

- **Multiple Story Types**: Image, Video, Text, Voice, and Custom stories
- **3D Cube Transitions**: Smooth cube animation between users
- **Segmented Progress Bar**: Visual indicator with gradient ring
- **RTL Support**: Full Arabic/Hebrew layout support
- **Keyboard Navigation**: Arrow keys, space, escape for desktop/web
- **Custom Overlays**: Add captions, stickers, watermarks
- **Rich Text**: TextSpan gradients and custom text builders
- **Auto Retry**: Exponential backoff for failed media
- **24h Expiry**: Automatic story expiration
- **Customizable**: Header, footer, colors, loading/error builders

## Installation

```yaml
dependencies:
  v_story_viewer: ^2.0.0
```

## Quick Start

```dart
import 'package:v_story_viewer/v_story_viewer.dart';

// Create story groups
final storyGroups = [
  VStoryGroup(
    user: VStoryUser(
      id: 'user1',
      name: 'John Doe',
      imageUrl: 'https://example.com/avatar.jpg',
    ),
    stories: [
      VImageStory(
        url: 'https://example.com/image.jpg',
        createdAt: DateTime.now(),
        isSeen: false,
      ),
      VVideoStory(
        url: 'https://example.com/video.mp4',
        createdAt: DateTime.now(),
        isSeen: false,
      ),
      VTextStory(
        text: 'Hello World!',
        backgroundColor: Colors.blue,
        createdAt: DateTime.now(),
        isSeen: false,
      ),
    ],
  ),
];

// Display story circles
VStoryCircleList(
  storyGroups: storyGroups,
  onUserTap: (group, index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VStoryViewer(
          storyGroups: storyGroups,
          initialGroupIndex: index,
          onStoryViewed: (group, item) => print('Viewed'),
          onReply: (group, item, text) => print('Reply: $text'),
        ),
      ),
    );
  },
);
```

## Story Types

### Image Story
```dart
VImageStory(
  url: 'https://example.com/image.jpg',
  // or filePath: '/path/to/local/image.jpg',
  duration: Duration(seconds: 5),
  createdAt: DateTime.now(),
  isSeen: false,
  caption: 'My caption',
  overlayBuilder: (context) => Positioned(
    bottom: 100,
    child: Text('Overlay text'),
  ),
)
```

### Video Story
```dart
VVideoStory(
  url: 'https://example.com/video.mp4',
  // duration auto-detected from video
  createdAt: DateTime.now(),
  isSeen: false,
)
```

### Text Story
```dart
VTextStory(
  text: 'Hello World!',
  backgroundColor: Colors.purple,
  textStyle: TextStyle(fontSize: 24),
  createdAt: DateTime.now(),
  isSeen: false,
  // Rich text with gradients
  richText: TextSpan(
    children: [
      TextSpan(text: 'Hello ', style: TextStyle(color: Colors.white)),
      TextSpan(text: 'World', style: TextStyle(color: Colors.amber)),
    ],
  ),
)
```

### Voice Story
```dart
VVoiceStory(
  url: 'https://example.com/audio.mp3',
  backgroundColor: Colors.indigo,
  createdAt: DateTime.now(),
  isSeen: false,
)
```

### Custom Story
```dart
VCustomStory(
  createdAt: DateTime.now(),
  isSeen: false,
  contentBuilder: (context, isPaused, isMuted, onLoaded, onError) {
    // Call onLoaded when your content is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onLoaded(Duration(seconds: 10));
    });
    return YourCustomWidget(isPaused: isPaused);
  },
)
```

## Configuration

```dart
VStoryViewer(
  storyGroups: storyGroups,
  config: VStoryConfig(
    // Colors
    progressColor: Colors.white,
    progressBackgroundColor: Colors.white24,
    // UI toggles
    showHeader: true,
    showProgressBar: true,
    showReplyField: true,
    showEmojiButton: true,
    // Behavior
    autoPauseOnBackground: true,
    defaultDuration: Duration(seconds: 5),
    // Custom builders
    loadingBuilder: (context) => CircularProgressIndicator(),
    errorBuilder: (context, error, retry) => ErrorWidget(retry: retry),
    headerBuilder: (context, user, item, onClose) => CustomHeader(),
    footerBuilder: (context, group, item) => CustomFooter(),
    // i18n
    texts: VStoryTexts(
      replyHint: 'Send a message...',
      errorLoadingMedia: 'Failed to load',
    ),
  ),
  // Callbacks
  onComplete: (group, item) => print('All done'),
  onClose: (group, item) => Navigator.pop(context),
  onStoryViewed: (group, item) => markAsSeen(group, item),
  onReply: (group, item, text) => sendReply(text),
  onSwipeUp: (group, item) => openLink(),
  onMenuTap: (group, item) => showMenu(),
  onUserTap: (group, item) => showProfile(),
  onError: (group, item, error) => logError(error),
)
```

## Circle Configuration

```dart
VStoryCircleList(
  storyGroups: storyGroups,
  circleConfig: VStoryCircleConfig(
    unseenColor: Colors.green,
    seenColor: Colors.grey,
    ringWidth: 4,
    segmentGap: 0.2,
  ),
  onUserTap: (group, index) => openViewer(index),
)
```

## Platform Support

| Android | iOS | Web | macOS | Windows | Linux |
|---------|-----|-----|-------|---------|-------|
| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |✅ | ✅ | ✅ | ✅ |  

## License

MIT License - see [LICENSE](LICENSE) for details.
