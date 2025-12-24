import 'package:flutter/material.dart';
import 'v_story_error.dart';

/// Builder for overlay content displayed on top of story content.
///
/// Use this to add captions, stickers, watermarks, or any custom UI elements
/// that should appear on top of the story media.
///
/// Example:
/// ```dart
/// VImageStory(
///   url: 'https://example.com/image.jpg',
///   overlayBuilder: (context) => Positioned(
///     bottom: 100,
///     left: 16,
///     child: Text('My Caption', style: TextStyle(color: Colors.white)),
///   ),
/// )
/// ```
typedef StoryOverlayBuilder = Widget Function(BuildContext context);

/// Base class for all story types using Dart 3 sealed classes.
///
/// This sealed class ensures exhaustive pattern matching when handling
/// different story types. All stories share common properties:
/// - [duration]: How long the story displays (null = auto-detect or default)
/// - [createdAt]: When the story was created (used for 24h expiry)
/// - [isSeen]: Whether the user has viewed this story
/// - [overlayBuilder]: Optional overlay widget rendered on top of content
///
/// ## Story Types
/// - [VImageStory]: Static image from URL or file
/// - [VVideoStory]: Video content with auto-play
/// - [VTextStory]: Text with customizable background
/// - [VVoiceStory]: Audio with playback slider
/// - [VCustomStory]: Fully custom content (Lottie, 3D, etc.)
///
/// ## Duration Behavior
/// | Story Type | Default Duration | Behavior |
/// |------------|-----------------|----------|
/// | VImageStory | 5 seconds | Fixed display time |
/// | VVideoStory | null | Uses video's actual duration |
/// | VTextStory | 5 seconds | Fixed display time |
/// | VVoiceStory | null | Uses audio's actual duration |
/// | VCustomStory | null | Waits for onLoaded() callback |
///
/// ## 24-Hour Expiry
/// Stories automatically expire 24 hours after [createdAt]. Use [isExpired]
/// to check. The viewer filters expired stories automatically.
///
/// Example:
/// ```dart
/// switch (story) {
///   case VImageStory s: // Handle image
///   case VVideoStory s: // Handle video
///   case VTextStory s:  // Handle text
///   case VVoiceStory s: // Handle voice
///   case VCustomStory s: // Handle custom
/// }
/// ```
sealed class VStoryItem {
  /// How long this story should be displayed.
  ///
  /// - For [VImageStory] and [VTextStory]: Defaults to 5 seconds if null.
  /// - For [VVideoStory] and [VVoiceStory]: Uses media duration if null.
  /// - For [VCustomStory]: Waits for `onLoaded(duration)` callback if null.
  final Duration? duration;

  /// When this story was created. Used for 24-hour expiry calculation.
  ///
  /// Stories older than 24 hours are considered expired and filtered out.
  /// Uses UTC internally for timezone-safe comparisons.
  final DateTime createdAt;

  /// Whether this story has been viewed by the user.
  ///
  /// The viewer does NOT automatically mark stories as seen - you must
  /// track this yourself using [VStoryViewer.onStoryViewed] callback.
  ///
  /// Affects:
  /// - Story ring color (unseen = gradient, seen = gray)
  /// - Sort order (unseen stories appear first in group)
  final bool isSeen;

  /// Optional overlay widget rendered on top of story content.
  ///
  /// Use for captions, stickers, watermarks, or any custom overlay elements.
  /// The builder receives the current [BuildContext] and should return a
  /// widget that will be positioned in a [Stack] above the story content.
  final StoryOverlayBuilder? overlayBuilder;
  const VStoryItem({
    this.duration,
    required this.createdAt,
    required this.isSeen,
    this.overlayBuilder,
  });

  /// Returns `true` if this story is older than 24 hours.
  ///
  /// Expired stories are automatically filtered from display by the viewer.
  /// Uses UTC internally for timezone-safe comparisons.
  bool get isExpired {
    final now = DateTime.now().toUtc();
    final created = createdAt.toUtc();
    return now.difference(created).inHours >= 24;
  }
}

/// Displays a static image from a URL or local file.
///
/// The image is displayed full-screen with [BoxFit.contain] scaling.
/// Supports automatic retry on network failures with exponential backoff.
///
/// ## Loading from URL
/// ```dart
/// VImageStory(
///   url: 'https://example.com/story.jpg',
///   createdAt: DateTime.now(),
///   isSeen: false,
/// )
/// ```
///
/// ## Loading from file
/// ```dart
/// VImageStory(
///   filePath: '/path/to/image.jpg',
///   createdAt: DateTime.now(),
///   isSeen: false,
/// )
/// ```
///
/// ## With caption
/// ```dart
/// VImageStory(
///   url: 'https://example.com/story.jpg',
///   caption: 'Beautiful sunset!',
///   createdAt: DateTime.now(),
///   isSeen: false,
/// )
/// ```
final class VImageStory extends VStoryItem {
  /// Network URL to load image from.
  ///
  /// Either [url] or [filePath] must be provided, not both null.
  /// Supports JPEG, PNG, GIF, WebP, and BMP formats.
  final String? url;

  /// Local file path to load image from.
  ///
  /// Either [url] or [filePath] must be provided, not both null.
  /// Use for images from camera, gallery, or app documents.
  final String? filePath;

  /// Optional caption displayed at bottom of story.
  ///
  /// Rendered with semi-transparent background for readability.
  /// Single line with ellipsis overflow.
  final String? caption;
  const VImageStory({
    this.url,
    this.filePath,
    this.caption,
    super.duration = const Duration(seconds: 5),
    required super.createdAt,
    required super.isSeen,
    super.overlayBuilder,
  }) : assert(url != null || filePath != null,
            'Either url or filePath must be provided');

  /// Returns a unique cache key based on URL for caching purposes.
  ///
  /// Returns `null` if [url] is null or empty.
  /// Format: `scheme://host/path` (excludes query parameters)
  String? get cacheKey {
    if (url == null) return null;
    if (url!.isEmpty) return null;
    try {
      final uri = Uri.parse(url!);
      return '${uri.scheme}://${uri.host}${uri.path}'.hashCode.toString();
    } catch (e) {
      return null;
    }
  }

  /// Creates a copy of this story with the given fields replaced.
  ///
  /// Useful for updating seen state or other properties:
  /// ```dart
  /// final seenStory = story.copyWith(isSeen: true);
  /// ```
  VImageStory copyWith({
    String? url,
    String? filePath,
    String? caption,
    Duration? duration,
    DateTime? createdAt,
    bool? isSeen,
    StoryOverlayBuilder? overlayBuilder,
  }) {
    return VImageStory(
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
      caption: caption ?? this.caption,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      isSeen: isSeen ?? this.isSeen,
      overlayBuilder: overlayBuilder ?? this.overlayBuilder,
    );
  }
}

/// Displays video content from a URL or local file with auto-play.
///
/// Videos play automatically when displayed and pause when navigating away.
/// The progress bar syncs with video playback duration automatically.
///
/// ## Features
/// - Auto-play when story becomes active
/// - Auto-pause on navigation, long-press, or app background
/// - Mute/unmute toggle (on web, starts muted for autoplay compliance)
/// - Optional caching on mobile platforms
/// - Retry on network failures
///
/// ## Duration Behavior
/// - If [duration] is `null`: Uses video's actual duration
/// - If [duration] is set: Overrides video duration (story ends at this time)
///
/// ## Example
/// ```dart
/// VVideoStory(
///   url: 'https://example.com/story.mp4',
///   caption: 'Check this out!',
///   createdAt: DateTime.now(),
///   isSeen: false,
/// )
/// ```
///
/// ## Supported formats
/// Depends on platform video_player support: MP4 (H.264), WebM, etc.
final class VVideoStory extends VStoryItem {
  /// Network URL to load video from.
  ///
  /// Either [url] or [filePath] must be provided, not both null.
  final String? url;

  /// Local file path to load video from.
  ///
  /// Either [url] or [filePath] must be provided, not both null.
  final String? filePath;

  /// Optional caption displayed at bottom of story.
  final String? caption;
  const VVideoStory({
    this.url,
    this.filePath,
    this.caption,
    super.duration,
    required super.createdAt,
    required super.isSeen,
    super.overlayBuilder,
  }) : assert(url != null || filePath != null,
            'Either url or filePath must be provided');

  /// Returns a unique cache key based on URL for caching purposes.
  ///
  /// Returns `null` if [url] is null or empty.
  String? get cacheKey {
    if (url == null) return null;
    if (url!.isEmpty) return null;
    try {
      final uri = Uri.parse(url!);
      return '${uri.scheme}://${uri.host}${uri.path}';
    } catch (e) {
      return null;
    }
  }

  /// Creates a copy of this story with the given fields replaced.
  ///
  /// Useful for updating seen state or other properties:
  /// ```dart
  /// final seenStory = story.copyWith(isSeen: true);
  /// ```
  VVideoStory copyWith({
    String? url,
    String? filePath,
    String? caption,
    Duration? duration,
    DateTime? createdAt,
    bool? isSeen,
    StoryOverlayBuilder? overlayBuilder,
  }) {
    return VVideoStory(
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
      caption: caption ?? this.caption,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      isSeen: isSeen ?? this.isSeen,
      overlayBuilder: overlayBuilder ?? this.overlayBuilder,
    );
  }
}

/// Builder function for custom text rendering in [VTextStory].
///
/// Receives the [BuildContext] and the [text] content to render.
/// Useful for markdown rendering or custom text layouts.
typedef StoryTextBuilder = Widget Function(BuildContext context, String text);

/// Displays text content with a solid background color.
///
/// Text automatically scales to fit the screen using [FittedBox].
/// Supports plain text, rich text with [TextSpan], or fully custom rendering.
///
/// ## Rendering Priority
/// 1. [textBuilder] - If provided, used for custom widget rendering
/// 2. [richText] - If provided, renders as [RichText] with TextSpan
/// 3. [text] - Default plain text rendering
///
/// ## Plain Text Example
/// ```dart
/// VTextStory(
///   text: 'Hello World! 🌍',
///   backgroundColor: Colors.purple,
///   textStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
///   createdAt: DateTime.now(),
///   isSeen: false,
/// )
/// ```
///
/// ## Rich Text Example
/// ```dart
/// VTextStory(
///   text: '', // Required but ignored when richText is provided
///   richText: TextSpan(
///     children: [
///       TextSpan(text: 'Hello ', style: TextStyle(color: Colors.white)),
///       TextSpan(text: 'World', style: TextStyle(color: Colors.yellow)),
///     ],
///   ),
///   backgroundColor: Colors.blue,
///   createdAt: DateTime.now(),
///   isSeen: false,
/// )
/// ```
///
/// ## Custom Builder Example (Markdown)
/// ```dart
/// VTextStory(
///   text: '# Hello\n**Bold** and *italic*',
///   textBuilder: (context, text) => MarkdownBody(data: text),
///   backgroundColor: Colors.black,
///   createdAt: DateTime.now(),
///   isSeen: false,
/// )
/// ```
final class VTextStory extends VStoryItem {
  /// The text content to display.
  ///
  /// Required even when using [richText] or [textBuilder] (for accessibility).
  final String text;

  /// Background color for the entire story screen.
  ///
  /// Defaults to Material blue (`Color(0xFF2196F3)`).
  final Color backgroundColor;

  /// Text style applied to plain [text] rendering.
  ///
  /// Ignored when [richText] or [textBuilder] is provided.
  final TextStyle? textStyle;

  /// Rich text content using [TextSpan] for styled text.
  ///
  /// Overrides plain [text] rendering. Ignored when [textBuilder] is provided.
  final InlineSpan? richText;

  /// Custom widget builder for fully custom text rendering.
  ///
  /// Overrides both [text] and [richText]. Use for markdown, HTML, etc.
  final StoryTextBuilder? textBuilder;
  const VTextStory({
    required this.text,
    this.backgroundColor = const Color(0xFF2196F3),
    this.textStyle,
    this.richText,
    this.textBuilder,
    super.duration = const Duration(seconds: 5),
    required super.createdAt,
    required super.isSeen,
    super.overlayBuilder,
  });

  /// Creates a copy of this story with the given fields replaced.
  ///
  /// Useful for updating seen state or other properties:
  /// ```dart
  /// final seenStory = story.copyWith(isSeen: true);
  /// ```
  VTextStory copyWith({
    String? text,
    Color? backgroundColor,
    TextStyle? textStyle,
    InlineSpan? richText,
    StoryTextBuilder? textBuilder,
    Duration? duration,
    DateTime? createdAt,
    bool? isSeen,
    StoryOverlayBuilder? overlayBuilder,
  }) {
    return VTextStory(
      text: text ?? this.text,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      richText: richText ?? this.richText,
      textBuilder: textBuilder ?? this.textBuilder,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      isSeen: isSeen ?? this.isSeen,
      overlayBuilder: overlayBuilder ?? this.overlayBuilder,
    );
  }
}

/// Displays an audio player with a progress slider (voice message style).
///
/// Shows a visual waveform-style indicator with playback position.
/// Audio plays automatically when the story becomes active.
///
/// ## Features
/// - Auto-play when story becomes active
/// - Visual progress slider (read-only, shows position)
/// - Mute/unmute support
/// - Optional caching on mobile platforms
/// - Duration auto-detected from audio file
///
/// ## Duration Behavior
/// - If [duration] is `null`: Uses audio file's actual duration
/// - If [duration] is set: Overrides audio duration (story ends at this time)
///
/// ## Example
/// ```dart
/// VVoiceStory(
///   url: 'https://example.com/voice.mp3',
///   backgroundColor: Colors.indigo,
///   caption: 'Voice message',
///   createdAt: DateTime.now(),
///   isSeen: false,
/// )
/// ```
///
/// ## Supported formats
/// Depends on platform audioplayers support: MP3, AAC, WAV, etc.
final class VVoiceStory extends VStoryItem {
  /// Network URL to load audio from.
  ///
  /// Either [url] or [filePath] must be provided, not both null.
  final String? url;

  /// Local file path to load audio from.
  ///
  /// Either [url] or [filePath] must be provided, not both null.
  final String? filePath;

  /// Background color for the voice story screen.
  ///
  /// Defaults to dark gray if not specified.
  final Color? backgroundColor;

  /// Optional caption displayed at bottom of story.
  final String? caption;
  const VVoiceStory({
    this.url,
    this.filePath,
    this.backgroundColor,
    this.caption,
    super.duration,
    required super.createdAt,
    required super.isSeen,
    super.overlayBuilder,
  }) : assert(url != null || filePath != null,
            'Either url or filePath must be provided');

  /// Returns a unique cache key based on URL for caching purposes.
  ///
  /// Returns `null` if [url] is null or empty.
  String? get cacheKey {
    if (url == null) return null;
    if (url!.isEmpty) return null;
    try {
      final uri = Uri.parse(url!);
      return '${uri.scheme}://${uri.host}${uri.path}';
    } catch (e) {
      return null;
    }
  }

  /// Creates a copy of this story with the given fields replaced.
  ///
  /// Useful for updating seen state or other properties:
  /// ```dart
  /// final seenStory = story.copyWith(isSeen: true);
  /// ```
  VVoiceStory copyWith({
    String? url,
    String? filePath,
    Color? backgroundColor,
    String? caption,
    Duration? duration,
    DateTime? createdAt,
    bool? isSeen,
    StoryOverlayBuilder? overlayBuilder,
  }) {
    return VVoiceStory(
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      caption: caption ?? this.caption,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      isSeen: isSeen ?? this.isSeen,
      overlayBuilder: overlayBuilder ?? this.overlayBuilder,
    );
  }
}

/// Builder for fully custom story content with full lifecycle control.
///
/// ## Parameters
/// - [context]: Build context for widget creation
/// - [isPaused]: Whether the story is currently paused (long-press, background, etc.)
/// - [isMuted]: Whether audio should be muted (user toggle)
/// - [onLoaded]: **MUST call** when content is ready - pass duration or null for default
/// - [onError]: Call if content fails to load - triggers auto-skip after 5s
///
/// ## Important
/// - Progress bar stays at 0% until [onLoaded] is called
/// - If [onLoaded] is never called, story won't auto-advance
/// - Pass `null` to [onLoaded] to use [VStoryConfig.defaultDuration] (5s)
/// - Respond to [isPaused] to pause animations/video/etc.
///
/// ## Example
/// ```dart
/// CustomStoryContentBuilder myBuilder = (context, isPaused, isMuted, onLoaded, onError) {
///   return LottieAnimation(
///     onLoaded: () => onLoaded(Duration(seconds: 3)),
///     isPaused: isPaused,
///     onError: (e) => onError(VStoryLoadError.fromException(e)),
///   );
/// };
/// ```
typedef CustomStoryContentBuilder = Widget Function(
  BuildContext context,
  bool isPaused,
  bool isMuted,
  void Function(Duration? duration) onLoaded,
  void Function(VStoryError error) onError,
);

/// Provides full control over story content rendering.
///
/// Use for content types not covered by built-in story types:
/// - Lottie animations
/// - Interactive quizzes/polls
/// - 3D models (model_viewer)
/// - Live content (WebView, iframe)
/// - Custom video players
/// - AR experiences
///
/// ## Lifecycle Contract
/// Your [contentBuilder] **MUST**:
/// 1. Call `onLoaded(duration)` when content is ready to display
/// 2. Call `onError(error)` if content fails to load
/// 3. Respond to `isPaused` to pause/resume animations
/// 4. Respect `isMuted` for any audio content
///
/// ## Duration Behavior
/// - Pass `Duration(seconds: x)` to `onLoaded` for fixed duration
/// - Pass `null` to use [VStoryConfig.defaultDuration]
/// - Story won't advance until `onLoaded` is called
///
/// ## Example: Lottie Animation
/// ```dart
/// VCustomStory(
///   contentBuilder: (context, isPaused, isMuted, onLoaded, onError) {
///     return Lottie.network(
///       'https://example.com/animation.json',
///       repeat: false,
///       animate: !isPaused,
///       onLoaded: (composition) {
///         onLoaded(composition.duration);
///       },
///       errorBuilder: (_, __, error) {
///         onError(VStoryLoadError.fromException(error ?? 'Failed to load'));
///         return const Icon(Icons.error);
///       },
///     );
///   },
///   createdAt: DateTime.now(),
///   isSeen: false,
/// )
/// ```
///
/// ## Example: Interactive Quiz
/// ```dart
/// VCustomStory(
///   contentBuilder: (context, isPaused, isMuted, onLoaded, onError) {
///     // Call onLoaded immediately, quiz has no loading time
///     WidgetsBinding.instance.addPostFrameCallback((_) {
///       onLoaded(Duration(seconds: 15)); // 15 second quiz
///     });
///     return QuizWidget(onAnswer: (answer) => print('Answer: $answer'));
///   },
///   createdAt: DateTime.now(),
///   isSeen: false,
/// )
/// ```
final class VCustomStory extends VStoryItem {
  /// Builder function that creates the custom story content.
  ///
  /// Called every time the story needs to rebuild. Must call `onLoaded`
  /// when content is ready or `onError` if loading fails.
  final CustomStoryContentBuilder contentBuilder;

  /// Optional caption displayed at bottom of story.
  final String? caption;
  const VCustomStory({
    required this.contentBuilder,
    this.caption,
    super.duration,
    required super.createdAt,
    required super.isSeen,
    super.overlayBuilder,
  });

  /// Creates a copy of this story with the given fields replaced.
  ///
  /// Useful for updating seen state or other properties:
  /// ```dart
  /// final seenStory = story.copyWith(isSeen: true);
  /// ```
  VCustomStory copyWith({
    CustomStoryContentBuilder? contentBuilder,
    String? caption,
    Duration? duration,
    DateTime? createdAt,
    bool? isSeen,
    StoryOverlayBuilder? overlayBuilder,
  }) {
    return VCustomStory(
      contentBuilder: contentBuilder ?? this.contentBuilder,
      caption: caption ?? this.caption,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      isSeen: isSeen ?? this.isSeen,
      overlayBuilder: overlayBuilder ?? this.overlayBuilder,
    );
  }
}
