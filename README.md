# v_story_viewer

A Flutter package for WhatsApp/Instagram-style story viewing with comprehensive gesture controls, media caching, and cross-platform support.

[![pub package](https://img.shields.io/pub/v/v_story_viewer.svg)](https://pub.dev/packages/v_story_viewer)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

✨ **Multiple Media Types**
- Image stories (network, asset, file, bytes)
- Video stories with automatic playback
- Text stories with customizable backgrounds
- Custom widget stories

🎮 **Intuitive Gesture Controls**
- Tap navigation (left/right zones)
- Swipe down to dismiss
- Horizontal swipe between story groups
- Double tap for reactions
- Long press to pause

⚡ **Performance Optimized**
- Media caching with flutter_cache_manager
- Efficient progress animations using LinearProgressIndicator
- Single video controller instance
- Selective widget rebuilds

🎨 **Highly Customizable**
- Custom themes and colors
- Customizable headers, footers, and actions
- Reply and reaction systems
- RTL support with localization

🌍 **Cross-Platform Support**
- iOS, Android, Web, macOS, Windows, Linux
- Platform-specific optimizations
- Unified file handling with v_platform

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  v_story_viewer: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:v_story_viewer/v_story_viewer.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StoryViewerExample(),
    );
  }
}

class StoryViewerExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final storyGroups = [
      VStoryGroup(
        id: 'user1',
        user: VStoryUser(
          name: 'John Doe',
          profileUrl: 'https://example.com/profile.jpg',
        ),
        stories: [
          VImageStory(
            id: 'story1',
            url: 'https://example.com/image1.jpg',
            duration: Duration(seconds: 5),
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
        storyGroups: storyGroups,
        onComplete: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
```

## Story Types

### Image Story

Display image stories from various sources:

```dart
// Network URL
VImageStory(
  id: 'img1',
  url: 'https://example.com/image.jpg',
  duration: Duration(seconds: 5),
  caption: 'Beautiful sunset',
)

// Asset path
VImageStory(
  id: 'img2',
  url: 'assets/images/story.jpg',
  duration: Duration(seconds: 5),
)

// File path
VImageStory(
  id: 'img3',
  url: '/path/to/local/image.jpg',
  duration: Duration(seconds: 5),
)
```

### Video Story

Videos play automatically with sound:

```dart
VVideoStory(
  id: 'vid1',
  url: 'https://example.com/video.mp4',
  caption: 'Amazing moments',
)
```

### Text Story

Create text-only stories with custom styling:

```dart
VTextStory(
  id: 'txt1',
  text: 'Hello World!',
  backgroundColor: Colors.blue,
  textStyle: TextStyle(
    fontSize: 32,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  ),
  duration: Duration(seconds: 3),
)
```

### Custom Story

Display any Flutter widget as a story:

```dart
VCustomStory(
  id: 'custom1',
  duration: Duration(seconds: 5),
  builder: (context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.star, size: 100, color: Colors.yellow),
        SizedBox(height: 20),
        Text('Custom Content', style: TextStyle(fontSize: 24)),
      ],
    ),
  ),
)
```

## Gesture Controls

The story viewer supports WhatsApp/Instagram-style gestures:

| Gesture | Action |
|---------|--------|
| Tap left side | Previous story |
| Tap right side | Next story |
| Swipe down | Dismiss viewer |
| Swipe left/right | Navigate between user groups |
| Double tap | Trigger reaction |
| Long press | Pause story |

### Customizing Tap Zones

```dart
VStoryViewer(
  storyGroups: storyGroups,
  gestureConfig: VGestureConfig(
    leftTapZoneWidth: 0.4, // 40% of screen width
    rightTapZoneWidth: 0.6, // 60% of screen width
    enableVerticalSwipe: true,
    enableHorizontalSwipe: true,
  ),
)
```

## Story Controller

Programmatically control story playback:

```dart
final controller = VStoryController();

// Control playback
controller.play();
controller.pause();
controller.stop();
controller.reset();

// Navigate programmatically
controller.nextStory();
controller.previousStory();
controller.nextGroup();
controller.previousGroup();

// Jump to specific story
controller.jumpToStory(groupIndex: 0, storyIndex: 2);

// Listen to state changes
controller.addListener(() {
  print('Current state: ${controller.state}');
});

// Dispose when done
controller.dispose();
```

## Customization

### Theme Customization

```dart
VStoryViewer(
  storyGroups: storyGroups,
  theme: VStoryTheme(
    progressBarStyle: VProgressBarStyle(
      activeColor: Colors.white,
      inactiveColor: Colors.white.withOpacity(0.3),
      height: 2.0,
    ),
    headerStyle: VHeaderStyle(
      backgroundColor: Colors.black.withOpacity(0.3),
      textStyle: TextStyle(color: Colors.white),
    ),
    footerStyle: VFooterStyle(
      backgroundColor: Colors.black.withOpacity(0.5),
    ),
  ),
)
```

### Reply System

Enable reply functionality:

```dart
VStoryViewer(
  storyGroups: storyGroups,
  replyConfig: VReplyConfig(
    enabled: true,
    placeholder: 'Reply to story...',
    onReply: (String reply, String storyId) {
      print('Reply: $reply for story: $storyId');
    },
  ),
)
```

### Reaction System

Enable quick reactions:

```dart
VStoryViewer(
  storyGroups: storyGroups,
  reactionConfig: VReactionConfig(
    enabled: true,
    reactions: ['❤️', '😂', '😮', '😢', '👏'],
    onReaction: (String reaction, String storyId) {
      print('Reaction: $reaction for story: $storyId');
    },
  ),
)
```

### Custom Header and Footer

```dart
VStoryViewer(
  storyGroups: storyGroups,
  headerBuilder: (context, storyGroup, story) {
    return CustomHeader(
      user: storyGroup.user,
      timestamp: story.timestamp,
    );
  },
  footerBuilder: (context, storyGroup, story) {
    return CustomFooter(
      caption: story.caption,
    );
  },
)
```

## Callbacks

Track story viewer events:

```dart
VStoryViewer(
  storyGroups: storyGroups,
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

## Caching

The package uses `flutter_cache_manager` for efficient media caching:

```dart
VStoryViewer(
  storyGroups: storyGroups,
  cacheManager: CustomCacheManager(), // Optional custom cache manager
)
```

## Localization

The package supports internationalization:

```dart
VStoryViewer(
  storyGroups: storyGroups,
  locale: Locale('ar'), // Arabic
  textDirection: TextDirection.rtl, // Right-to-left
)
```

## Platform Support

| Platform | Support |
|----------|---------|
| iOS | ✅ |
| Android | ✅ |
| Web | ✅ |
| macOS | ✅ |
| Windows | ✅ |
| Linux | ✅ |

## Requirements

- Flutter SDK: `>=3.0.0`
- Dart SDK: `^3.9.0`

## Dependencies

- `flutter_cache_manager: ^3.4.1` - Media caching
- `video_player: ^2.10.0` - Video playback
- `cached_network_image: ^3.4.1` - Image caching
- `v_platform: ^2.1.4` - Cross-platform file handling
- `share_plus: ^12.0.0` - Share functionality
- `gal: ^2.3.2` - Gallery access
- `permission_handler: ^12.0.1` - Permission management

## Examples

Check out the [example](example/) directory for complete working examples:

- Basic story viewer
- Custom themes
- Reply and reaction systems
- Programmatic navigation
- Custom story content

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting pull requests.

## Issues and Feedback

Please file issues and feedback on the [GitHub issue tracker](https://github.com/hatemragap/v_story_viewer/issues).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

Developed and maintained by [Hatem Ragap](https://github.com/hatemragap).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and updates.
