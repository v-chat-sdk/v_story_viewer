# v_story_viewer

A production-ready Flutter package for displaying WhatsApp/Instagram-style stories with intuitive gesture controls, smart media caching, and extensive customization options. Built for performance with 60 FPS animations and full cross-platform support.

## 📸 Showcase

Check out the screenshots to see the package in action:

- **Mobile Demo**: WhatsApp-style story viewer with smooth transitions
- **Tablet/Desktop Support**: Responsive design works on all screen sizes
- **Rich Media**: Images, videos, text, and custom widgets

See full demonstrations on [GitHub](https://github.com/v-chat-sdk/v_story_viewer)

[![pub package](https://img.shields.io/pub/v/v_story_viewer.svg)](https://pub.dev/packages/v_story_viewer)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/flutter-3.0+-blue.svg)](https://flutter.dev)

## ✨ Key Features

- **📱 Multiple Media Types** - Images, videos, text, and custom widgets
- **🎮 Intuitive Gestures** - Tap to navigate, swipe to dismiss, long press to pause
- **⚡ High Performance** - 60 FPS animations with efficient caching
- **🎨 Fully Customizable** - Themes, headers, footers, and custom content
- **🌍 Cross-Platform** - iOS, Android, Web, macOS, Windows, Linux
- **🔄 Smart Caching** - Automatic media caching with offline support
- **🌐 Internationalization** - RTL support and multi-language ready

## 📋 Roadmap (Upcoming Features)

- **🎙️ Voice Stories** - Support for audio/voice recordings as stories
- Video trimming capabilities
- Advanced filters and effects
- Story analytics and metrics

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  v_story_viewer: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story Viewer Demo',
      home: const StoryViewerScreen(),
    );
  }
}

class StoryViewerScreen extends StatelessWidget {
  const StoryViewerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storyGroups = [
      VStoryGroup(
        id: 'user1',
        user: VStoryUser(
          name: 'John Doe',
          profileUrl: 'https://example.com/profile1.jpg',
          verified: true,
        ),
        stories: [
          VImageStory(
            id: 'story1',
            url: 'https://example.com/image1.jpg',
            duration: const Duration(seconds: 5),
            caption: 'Beautiful sunset 🌅',
          ),
          VVideoStory(
            id: 'story2',
            url: 'https://example.com/video1.mp4',
            caption: 'Amazing moments 🎥',
          ),
        ],
      ),
      VStoryGroup(
        id: 'user2',
        user: VStoryUser(
          name: 'Jane Smith',
          profileUrl: 'https://example.com/profile2.jpg',
        ),
        stories: [
          VTextStory(
            id: 'story3',
            text: 'Hello World! 👋',
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        ],
      ),
    ];

    return Scaffold(
      body: VStoryViewer(
        storyGroups: storyGroups,
        onComplete: () => Navigator.pop(context),
      ),
    );
  }
}
```

## 📖 Story Types

### Image Stories

Display images from various sources:

```dart
// Network URL
VImageStory(
  id: 'img1',
  url: 'https://example.com/image.jpg',
  duration: const Duration(seconds: 5),
  caption: 'Optional caption',
)

// Asset
VImageStory(
  id: 'img2',
  url: 'assets/images/story.jpg',
  duration: const Duration(seconds: 5),
)

// Local file
VImageStory(
  id: 'img3',
  url: '/path/to/image.jpg',
  duration: const Duration(seconds: 5),
)
```

### Video Stories

Play videos automatically:

```dart
VVideoStory(
  id: 'vid1',
  url: 'https://example.com/video.mp4',
  caption: 'Video story',
  autoPlay: true,
  muted: false,
)
```

### Text Stories

Create text-based stories:

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

### Custom Stories

Display any Flutter widget:

```dart
VCustomStory(
  id: 'custom1',
  duration: const Duration(seconds: 5),
  builder: (context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.star, size: 100, color: Colors.yellow),
        const SizedBox(height: 20),
        const Text(
          'Custom Content',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ],
    ),
  ),
)
```

## 🎮 Gesture Controls

Built-in WhatsApp-style gestures:

| Gesture | Action |
|---------|--------|
| Tap left | Previous story |
| Tap right | Next story |
| Swipe down | Dismiss viewer |
| Swipe left/right | Navigate between groups |
| Double tap | Send reaction |
| Long press | Pause story |

Customize gesture behavior:

```dart
VStoryViewer(
  storyGroups: storyGroups,
  gestureConfig: VGestureConfig(
    leftTapZoneWidth: 0.4,      // 40% of screen
    rightTapZoneWidth: 0.6,     // 60% of screen
    enableVerticalSwipe: true,
    enableHorizontalSwipe: true,
    enableDoubleTap: true,
    enableLongPress: true,
  ),
)
```

## 🎛️ Programmatic Control

Use `VStoryController` for programmatic control:

```dart
final controller = VStoryController();

// Playback control
controller.play();
controller.pause();
controller.stop();
controller.reset();

// Navigation
controller.nextStory();
controller.previousStory();
controller.jumpToStory(groupIndex: 0, storyIndex: 2);

// Listen to changes
controller.addListener(() {
  print('Current state: ${controller.state}');
});

// Cleanup
controller.dispose();
```

Use the controller with VStoryViewer:

```dart
VStoryViewer(
  storyGroups: storyGroups,
  controller: controller,
  onComplete: () => Navigator.pop(context),
)
```

## 🎨 Customization

### Theme Configuration

```dart
VStoryViewer(
  storyGroups: storyGroups,
  theme: VStoryTheme(
    progressBarStyle: VProgressBarStyle(
      activeColor: Colors.white,
      inactiveColor: Colors.white30,
      height: 2.0,
    ),
    headerStyle: VHeaderStyle(
      backgroundColor: Colors.black26,
      textStyle: const TextStyle(color: Colors.white),
    ),
    footerStyle: VFooterStyle(
      backgroundColor: Colors.black54,
      textStyle: const TextStyle(color: Colors.white),
    ),
  ),
)
```

### Custom Header and Footer

```dart
VStoryViewer(
  storyGroups: storyGroups,
  headerBuilder: (context, group, story) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(group.user.profileUrl ?? ''),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.user.name),
              Text(
                'Just now',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
        ],
      ),
    );
  },
  footerBuilder: (context, group, story) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        story.caption ?? '',
        style: const TextStyle(color: Colors.white),
      ),
    );
  },
)
```

### Reply System

```dart
VStoryViewer(
  storyGroups: storyGroups,
  replyConfig: VReplyConfig(
    enabled: true,
    placeholder: 'Reply to story...',
    maxLength: 280,
    onReply: (message, storyId) {
      // Handle reply
      print('Reply: $message to story: $storyId');
    },
  ),
)
```

### Reaction System

```dart
VStoryViewer(
  storyGroups: storyGroups,
  reactionConfig: VReactionConfig(
    enabled: true,
    reactions: ['❤️', '😂', '😮', '😢', '👏', '🔥'],
    onReaction: (emoji, storyId) {
      // Handle reaction
      print('Reaction: $emoji on story: $storyId');
    },
  ),
)
```

## 📡 Event Callbacks

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
    print('All stories viewed');
    Navigator.pop(context);
  },
  onDispose: () {
    print('Viewer disposed');
  },
)
```

## 🌍 Localization & RTL

```dart
VStoryViewer(
  storyGroups: storyGroups,
  locale: const Locale('ar'),           // Arabic
  textDirection: TextDirection.rtl,      // Right-to-left
)
```

Supported languages: English, Arabic, Spanish, and more.

## 💾 Caching

The package automatically uses `flutter_cache_manager` for efficient media caching:

```dart
// Use default cache manager (automatic)
VStoryViewer(
  storyGroups: storyGroups,
)

// Or provide custom cache manager
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager extends BaseCacheManager {
  static const key = 'customStoryCache';
  CustomCacheManager() : super(key);
}

VStoryViewer(
  storyGroups: storyGroups,
  cacheManager: CustomCacheManager(),
)
```

## 📋 API Reference

### Core Classes

#### VStoryViewer

Main widget for displaying stories.

**Properties:**
- `storyGroups: List<VStoryGroup>` - Story groups to display
- `controller: VStoryController?` - Optional controller for programmatic control
- `onComplete: VoidCallback?` - Called when all stories complete
- `onDispose: VoidCallback?` - Called when widget disposed
- `onStoryChanged: Function(int, int)?` - Called on story change
- `onGroupChanged: Function(int)?` - Called on group change
- `theme: VStoryTheme?` - Customize appearance
- `gestureConfig: VGestureConfig?` - Configure gestures
- `replyConfig: VReplyConfig?` - Enable replies
- `reactionConfig: VReactionConfig?` - Enable reactions
- `headerBuilder: Function?` - Custom header widget
- `footerBuilder: Function?` - Custom footer widget
- `locale: Locale?` - Language/region setting
- `textDirection: TextDirection?` - RTL/LTR support

#### VStoryController

Programmatic control over story playback.

**Methods:**
- `play()` - Resume playback
- `pause()` - Pause playback
- `stop()` - Stop playback
- `reset()` - Reset to start
- `nextStory()` - Go to next story
- `previousStory()` - Go to previous story
- `jumpToStory({required int groupIndex, required int storyIndex})` - Jump to specific story
- `addListener(VoidCallback)` - Listen to state changes
- `dispose()` - Cleanup resources

### Data Models

#### VStoryGroup

```dart
VStoryGroup({
  required String id,
  required VStoryUser user,
  required List<VBaseStory> stories,
})
```

#### VStoryUser

```dart
VStoryUser({
  required String name,
  String? profileUrl,
  bool verified = false,
})
```

#### Story Types

- **VImageStory** - Display images from network, assets, or files
- **VVideoStory** - Play videos with auto-play and controls
- **VTextStory** - Text with custom background and styling
- **VCustomStory** - Any Flutter widget as story content

### Configuration Classes

- **VStoryTheme** - Progress bar, header, and footer styling
- **VGestureConfig** - Gesture behavior customization
- **VReplyConfig** - Reply system setup
- **VReactionConfig** - Reaction emoji configuration

For detailed API documentation, see [API_REFERENCE.md](API_REFERENCE.md).

## 🔧 Troubleshooting

### Videos not playing

Ensure the video URL is accessible and in a supported format (MP4, WebM). Check platform permissions for video playback.

### Images not loading

Verify image URLs are correct and accessible. For local files, ensure paths are absolute. For assets, check `pubspec.yaml` configuration.

### Gestures not responding

Verify `gestureConfig` properties are correctly set. Ensure the device has proper touch capabilities.

### Performance issues

- Reduce story count per session
- Use cached URLs instead of streaming
- Enable caching with `flutter_cache_manager`
- Use `const` constructors for static stories

### Memory leaks

Always dispose the controller when done:

```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

## 📱 Platform Support

| Platform | Status |
|----------|--------|
| iOS | ✅ Fully supported |
| Android | ✅ Fully supported |
| Web | ✅ Fully supported |
| macOS | ✅ Fully supported |
| Windows | ✅ Fully supported |
| Linux | ✅ Fully supported |

## 📋 Requirements

- **Flutter**: >=3.0.0
- **Dart**: ^3.9.0

## 📦 Dependencies

- `flutter_cache_manager: ^3.4.1` - Media caching
- `video_player: ^2.10.0` - Video playback
- `cached_network_image: ^3.4.1` - Image caching
- `v_platform: ^2.1.4` - Cross-platform file handling

## 📚 Examples

Complete examples are available in the [example](example/) directory:

- Basic story viewer
- Multiple story types
- Custom themes and styling
- Reply and reaction systems
- Programmatic navigation
- Error handling

Run the example:

```bash
cd example
flutter run
```

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

## 🎯 Need Help?

- **Documentation**: Full API reference available in [API_REFERENCE.md](API_REFERENCE.md)
- **Issues**: Report bugs on [GitHub Issues](https://github.com/hatemragap/v_story_viewer/issues)
- **Discussions**: Ask questions in [GitHub Discussions](https://github.com/hatemragap/v_story_viewer/discussions)

## ✍️ Author

Created and maintained by [Hatem Ragap](https://github.com/hatemragap)

---

**Made with ❤️ for the Flutter community**
