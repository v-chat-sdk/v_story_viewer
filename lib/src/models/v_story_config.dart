import 'package:flutter/widgets.dart';
import 'v_story_error.dart';
import 'v_story_group.dart';
import 'v_story_item.dart';
import 'v_story_user.dart';
import 'v_story_texts.dart';

/// Builder for custom loading widget displayed while content loads.
///
/// Example:
/// ```dart
/// StoryLoadingBuilder loadingBuilder = (context) => Center(
///   child: SpinKitWave(color: Colors.white),
/// );
/// ```
typedef StoryLoadingBuilder = Widget Function(BuildContext context);

/// Builder for custom error widget with retry callback.
///
/// Parameters:
/// - [context]: Build context
/// - [error]: Structured error with type and details
/// - [retry]: Callback to retry loading
///
/// Example:
/// ```dart
/// StoryErrorBuilder errorBuilder = (context, error, retry) => Center(
///   child: Column(
///     mainAxisSize: MainAxisSize.min,
///     children: [
///       Icon(Icons.error, color: Colors.red),
///       Text(switch (error) {
///         VStoryNetworkError() => 'No internet connection',
///         VStoryTimeoutError() => 'Request timed out',
///         _ => 'Failed to load',
///       }),
///       ElevatedButton(onPressed: retry, child: Text('Retry')),
///     ],
///   ),
/// );
/// ```
typedef StoryErrorBuilder = Widget Function(
    BuildContext context, VStoryError error, VoidCallback retry);

/// Builder for custom header replacing the default story header.
///
/// When provided, all header visibility flags (showBackButton, showCloseButton, etc.)
/// are ignored since you control the entire header.
///
/// Parameters:
/// - [context]: Build context
/// - [user]: The story owner's information
/// - [item]: The current story being displayed
/// - [onClose]: Callback to close the viewer
///
/// Example:
/// ```dart
/// StoryHeaderBuilder headerBuilder = (context, user, item, onClose) => Row(
///   children: [
///     CircleAvatar(backgroundImage: NetworkImage(user.imageUrl)),
///     Text(user.name),
///     Spacer(),
///     IconButton(icon: Icon(Icons.close), onPressed: onClose),
///   ],
/// );
/// ```
typedef StoryHeaderBuilder = Widget Function(
  BuildContext context,
  VStoryUser user,
  VStoryItem item,
  VoidCallback onClose,
);

/// Builder for custom footer replacing the reply field area.
///
/// When provided, showReplyField is ignored since you control the entire footer.
///
/// Parameters:
/// - [context]: Build context
/// - [group]: The current story group
/// - [item]: The current story being displayed
/// - [onReplyFocusChanged]: Call with true/false when a reply input gains/loses
///   focus to pause/resume playback (and show the reply overlay)
///
/// Example:
/// ```dart
/// StoryFooterBuilder footerBuilder =
///     (context, group, item, onReplyFocusChanged) => Container(
///           padding: EdgeInsets.all(16),
///           child: Row(
///             children: [
///               Icon(Icons.favorite_border, color: Colors.white),
///               SizedBox(width: 16),
///               Icon(Icons.share, color: Colors.white),
///             ],
///           ),
///         );
/// ```
typedef StoryFooterBuilder = Widget Function(
  BuildContext context,
  VStoryGroup group,
  VStoryItem item,
  ValueChanged<bool> onReplyFocusChanged,
);

/// Builder for custom progress bar replacing the default segmented progress.
///
/// Parameters:
/// - [context]: Build context
/// - [storyCount]: Total number of stories in current group
/// - [currentIndex]: Current story index (0-based)
/// - [progress]: Current story progress (0.0 to 1.0)
///
/// Example:
/// ```dart
/// StoryProgressBuilder progressBuilder = (context, count, index, progress) {
///   return Row(
///     children: List.generate(count, (i) => Expanded(
///       child: LinearProgressIndicator(
///         value: i < index ? 1.0 : (i == index ? progress : 0.0),
///       ),
///     )),
///   );
/// };
/// ```
typedef StoryProgressBuilder = Widget Function(
  BuildContext context,
  int storyCount,
  int currentIndex,
  double progress,
);

/// Builder for custom image content replacing the default ImageContent widget.
///
/// Parameters:
/// - [context]: Build context
/// - [story]: The image story to display
/// - [onLoaded]: **MUST call** when image is loaded to start progress
/// - [onError]: Call if image fails to load
///
/// Example:
/// ```dart
/// StoryImageBuilder imageBuilder = (context, story, onLoaded, onError) {
///   return CachedNetworkImage(
///     imageUrl: story.url!,
///     fit: BoxFit.contain,
///     imageBuilder: (_, provider) {
///       onLoaded();
///       return Image(image: provider, fit: BoxFit.contain);
///     },
///     errorWidget: (_, __, error) {
///       onError(error);
///       return Icon(Icons.error);
///     },
///   );
/// };
/// ```
typedef StoryImageBuilder = Widget Function(
  BuildContext context,
  VImageStory story,
  VoidCallback onLoaded,
  void Function(VStoryError error) onError,
);

/// Builder for custom video content replacing the default VideoContent widget.
///
/// Parameters:
/// - [context]: Build context
/// - [story]: The video story to display
/// - [isPaused]: Whether video should be paused (long press, app background)
/// - [isMuted]: Whether audio should be muted
/// - [onLoaded]: **MUST call** with video duration when ready
/// - [onError]: Call if video fails to load
///
/// Example:
/// ```dart
/// StoryVideoBuilder videoBuilder = (context, story, isPaused, isMuted, onLoaded, onError) {
///   return BetterPlayer.network(
///     story.url!,
///     betterPlayerConfiguration: BetterPlayerConfiguration(
///       autoPlay: !isPaused,
///     ),
///     betterPlayerDataSource: BetterPlayerDataSource.network(story.url!),
///   );
/// };
/// ```
typedef StoryVideoBuilder = Widget Function(
  BuildContext context,
  VVideoStory story,
  bool isPaused,
  bool isMuted,
  void Function(Duration duration) onLoaded,
  void Function(VStoryError error) onError,
);

/// Builder for custom voice content replacing the default VoiceContent widget.
///
/// Parameters:
/// - [context]: Build context
/// - [story]: The voice story to display
/// - [isPaused]: Whether audio should be paused
/// - [isMuted]: Whether audio should be muted
/// - [onLoaded]: **MUST call** with audio duration when ready
/// - [onError]: Call if audio fails to load
///
/// Example:
/// ```dart
/// StoryVoiceBuilder voiceBuilder = (context, story, isPaused, isMuted, onLoaded, onError) {
///   return CustomAudioPlayer(
///     url: story.url!,
///     isPaused: isPaused,
///     isMuted: isMuted,
///     onDurationLoaded: onLoaded,
///   );
/// };
/// ```
typedef StoryVoiceBuilder = Widget Function(
  BuildContext context,
  VVoiceStory story,
  bool isPaused,
  bool isMuted,
  void Function(Duration duration) onLoaded,
  void Function(VStoryError error) onError,
);

/// Configuration for [VStoryViewer] appearance and behavior.
///
/// Controls colors, durations, caching, visibility toggles, and custom builders.
/// All parameters have sensible defaults for Instagram/WhatsApp-like appearance.
///
/// ## Basic Usage
/// ```dart
/// VStoryViewer(
///   groups: myGroups,
///   config: VStoryConfig(
///     progressColor: Colors.blue,
///     defaultDuration: Duration(seconds: 7),
///   ),
/// )
/// ```
///
/// ## Full Customization Example
/// ```dart
/// VStoryConfig(
///   // Colors
///   unseenGradient: [Colors.purple, Colors.pink],
///   seenColor: Colors.grey,
///   progressColor: Colors.white,
///
///   // Timing
///   defaultDuration: Duration(seconds: 5),
///   networkTimeout: 30,
///   maxRetries: 3,
///
///   // Caching (mobile only)
///   enableCaching: true,
///   maxCacheSize: 500 * 1024 * 1024, // 500MB
///
///   // Visibility
///   showHeader: true,
///   showProgressBar: true,
///   showReplyField: false,
///
///   // Custom builders
///   loadingBuilder: (ctx) => MyCustomLoader(),
///   headerBuilder: (ctx, user, item, close) => MyHeader(...),
///
///   // Internationalization
///   texts: VStoryTexts(replyHint: 'Nachricht senden...'),
/// )
/// ```
///
/// ## Visibility Flags
/// | Flag | Default | Description |
/// |------|---------|-------------|
/// | showHeader | true | Show/hide entire header section |
/// | showProgressBar | true | Show/hide progress segments |
/// | showBackButton | true | Show/hide back arrow |
/// | showUserInfo | true | Show/hide avatar + name + time |
/// | showMenuButton | true | Show/hide three dots menu |
/// | showCloseButton | true | Show/hide X button |
/// | showReplyField | true | Show/hide reply input |
/// | showEmojiButton | true | Show/hide emoji picker |
///
/// ## Caching Behavior
/// - **Mobile (Android/iOS)**: Caches video/audio for offline playback
/// - **Web/Desktop**: Always streams directly from URL (no caching)
class VStoryConfig {
  /// Gradient colors for unseen story ring
  final List<Color> unseenGradient;

  /// Color for seen story ring
  final Color seenColor;

  /// Progress bar fill color
  final Color progressColor;

  /// Progress bar background color
  final Color progressBackgroundColor;

  /// Default story duration for image/text stories
  final Duration defaultDuration;

  /// Timeout for network requests (seconds)
  final int networkTimeout;

  /// Number of retry attempts for failed loads
  final int maxRetries;
  // Cache configuration (mobile only - Android/iOS)
  /// Enable video/audio caching on mobile devices
  /// Web and desktop always stream directly from URL
  final bool enableCaching;

  /// Maximum cache size in bytes (default: 500MB)
  final int maxCacheSize;

  /// Maximum age for cached files (default: 7 days)
  final Duration maxCacheAge;

  /// Maximum number of cached files (default: 100)
  final int maxCacheObjects;

  /// Preload next video/audio while current story plays
  final bool enablePreloading;

  /// Scroll direction for navigating between story groups (users).
  final Axis groupScrollDirection;
  // Visibility toggles
  /// Show/hide entire header (includes all header elements)
  final bool showHeader;

  /// Show/hide progress bar at top
  final bool showProgressBar;

  /// Show/hide back button in header
  final bool showBackButton;

  /// Show/hide user info (avatar + name + timestamp)
  final bool showUserInfo;

  /// Show/hide three dots menu button
  final bool showMenuButton;

  /// Show/hide close (X) button
  final bool showCloseButton;

  /// Show/hide reply field at bottom
  final bool showReplyField;

  /// Show/hide emoji button in reply field
  final bool showEmojiButton;

  /// Auto-pause story when app goes to background
  final bool autoPauseOnBackground;

  /// Hide status bar for immersive full-screen experience (Android/iOS)
  final bool hideStatusBar;

  /// Configurable texts for internationalization
  final VStoryTexts texts;
  // Custom builders
  /// Custom loading widget builder - replaces default CircularProgressIndicator
  final StoryLoadingBuilder? loadingBuilder;

  /// Custom error widget builder - replaces default error display
  final StoryErrorBuilder? errorBuilder;

  /// Custom header builder - replaces entire default header
  /// When provided, visibility flags (showBackButton, etc.) are ignored
  final StoryHeaderBuilder? headerBuilder;

  /// Custom footer builder - replaces reply field area
  /// When provided, showReplyField is ignored; call onReplyFocusChanged to
  /// pause/resume playback when a custom input focuses.
  final StoryFooterBuilder? footerBuilder;

  /// Custom progress bar builder - replaces default segmented progress
  /// When provided, showProgressBar visibility still applies
  final StoryProgressBuilder? progressBuilder;
  // Content builders - replace default content widgets
  /// Custom image content builder - replaces default ImageContent
  final StoryImageBuilder? imageBuilder;

  /// Custom video content builder - replaces default VideoContent
  final StoryVideoBuilder? videoBuilder;

  /// Custom voice content builder - replaces default VoiceContent
  final StoryVoiceBuilder? voiceBuilder;
  const VStoryConfig({
    this.unseenGradient = const [Color(0xFFDD2A7B), Color(0xFFF58529)],
    this.seenColor = const Color(0xFF9E9E9E),
    this.progressColor = const Color(0xFFFFFFFF),
    this.progressBackgroundColor = const Color(0x40FFFFFF),
    this.defaultDuration = const Duration(seconds: 5),
    this.networkTimeout = 30,
    this.maxRetries = 5,
    this.enableCaching = true,
    this.maxCacheSize = 500 * 1024 * 1024, // 500MB
    this.maxCacheAge = const Duration(days: 7),
    this.maxCacheObjects = 100,
    this.enablePreloading = true,
    this.groupScrollDirection = Axis.horizontal,
    this.showHeader = true,
    this.showProgressBar = true,
    this.showBackButton = true,
    this.showUserInfo = true,
    this.showMenuButton = true,
    this.showCloseButton = true,
    this.showReplyField = true,
    this.showEmojiButton = true,
    this.autoPauseOnBackground = true,
    this.hideStatusBar = true,
    this.texts = const VStoryTexts(),
    this.loadingBuilder,
    this.errorBuilder,
    this.headerBuilder,
    this.footerBuilder,
    this.progressBuilder,
    this.imageBuilder,
    this.videoBuilder,
    this.voiceBuilder,
  })  : assert(networkTimeout > 0, 'Network timeout must be greater than 0'),
        assert(maxRetries >= 0, 'Max retries must be 0 or greater');

  /// Configuration preset for viewing your own stories.
  ///
  /// Optimized for story owner with:
  /// - No reply field (can't reply to own stories)
  /// - Menu button visible (for delete/insights/share)
  /// - No emoji button
  ///
  /// ## Usage
  /// ```dart
  /// VStoryViewer(
  ///   storyGroups: myStories,
  ///   config: VStoryConfig.forOwner(),
  ///   onMenuTap: (group, item) async {
  ///     final action = await showOwnerMenu(); // delete, insights, share
  ///     if (action == 'delete') deleteStory(item);
  ///     return true;
  ///   },
  /// )
  /// ```
  const VStoryConfig.forOwner({
    List<Color> unseenGradient = const [Color(0xFFDD2A7B), Color(0xFFF58529)],
    Color seenColor = const Color(0xFF9E9E9E),
    Color progressColor = const Color(0xFFFFFFFF),
    Color progressBackgroundColor = const Color(0x40FFFFFF),
    Duration defaultDuration = const Duration(seconds: 5),
    int networkTimeout = 30,
    int maxRetries = 5,
    bool enableCaching = true,
    int maxCacheSize = 500 * 1024 * 1024,
    Duration maxCacheAge = const Duration(days: 7),
    int maxCacheObjects = 100,
    bool enablePreloading = true,
    Axis groupScrollDirection = Axis.horizontal,
    bool showHeader = true,
    bool showProgressBar = true,
    bool showBackButton = true,
    bool showUserInfo = true,
    bool showCloseButton = true,
    bool autoPauseOnBackground = true,
    bool hideStatusBar = true,
    VStoryTexts texts = const VStoryTexts(),
    StoryLoadingBuilder? loadingBuilder,
    StoryErrorBuilder? errorBuilder,
    StoryHeaderBuilder? headerBuilder,
    StoryFooterBuilder? footerBuilder,
    StoryProgressBuilder? progressBuilder,
    StoryImageBuilder? imageBuilder,
    StoryVideoBuilder? videoBuilder,
    StoryVoiceBuilder? voiceBuilder,
  })  : unseenGradient = unseenGradient,
        seenColor = seenColor,
        progressColor = progressColor,
        progressBackgroundColor = progressBackgroundColor,
        defaultDuration = defaultDuration,
        networkTimeout = networkTimeout,
        maxRetries = maxRetries,
        enableCaching = enableCaching,
        maxCacheSize = maxCacheSize,
        maxCacheAge = maxCacheAge,
        maxCacheObjects = maxCacheObjects,
        enablePreloading = enablePreloading,
        groupScrollDirection = groupScrollDirection,
        showHeader = showHeader,
        showProgressBar = showProgressBar,
        showBackButton = showBackButton,
        showUserInfo = showUserInfo,
        showMenuButton = true,
        showCloseButton = showCloseButton,
        showReplyField = false,
        showEmojiButton = false,
        autoPauseOnBackground = autoPauseOnBackground,
        hideStatusBar = hideStatusBar,
        texts = texts,
        loadingBuilder = loadingBuilder,
        errorBuilder = errorBuilder,
        headerBuilder = headerBuilder,
        footerBuilder = footerBuilder,
        progressBuilder = progressBuilder,
        imageBuilder = imageBuilder,
        videoBuilder = videoBuilder,
        voiceBuilder = voiceBuilder,
        assert(networkTimeout > 0, 'Network timeout must be greater than 0'),
        assert(maxRetries >= 0, 'Max retries must be 0 or greater');

  /// Configuration preset for viewing others' stories.
  ///
  /// Optimized for story viewer with:
  /// - Reply field visible (can send replies)
  /// - Emoji button visible
  /// - Menu button visible (for report/mute options)
  ///
  /// ## Usage
  /// ```dart
  /// VStoryViewer(
  ///   storyGroups: otherUserStories,
  ///   config: VStoryConfig.forViewer(),
  ///   onReply: (group, item, text) => sendReply(group.user.id, text),
  ///   onMenuTap: (group, item) async {
  ///     final action = await showViewerMenu(); // report, mute
  ///     if (action == 'report') reportStory(item);
  ///     return true;
  ///   },
  /// )
  /// ```
  const VStoryConfig.forViewer({
    List<Color> unseenGradient = const [Color(0xFFDD2A7B), Color(0xFFF58529)],
    Color seenColor = const Color(0xFF9E9E9E),
    Color progressColor = const Color(0xFFFFFFFF),
    Color progressBackgroundColor = const Color(0x40FFFFFF),
    Duration defaultDuration = const Duration(seconds: 5),
    int networkTimeout = 30,
    int maxRetries = 5,
    bool enableCaching = true,
    int maxCacheSize = 500 * 1024 * 1024,
    Duration maxCacheAge = const Duration(days: 7),
    int maxCacheObjects = 100,
    bool enablePreloading = true,
    Axis groupScrollDirection = Axis.horizontal,
    bool showHeader = true,
    bool showProgressBar = true,
    bool showBackButton = true,
    bool showUserInfo = true,
    bool showCloseButton = true,
    bool autoPauseOnBackground = true,
    bool hideStatusBar = true,
    VStoryTexts texts = const VStoryTexts(),
    StoryLoadingBuilder? loadingBuilder,
    StoryErrorBuilder? errorBuilder,
    StoryHeaderBuilder? headerBuilder,
    StoryFooterBuilder? footerBuilder,
    StoryProgressBuilder? progressBuilder,
    StoryImageBuilder? imageBuilder,
    StoryVideoBuilder? videoBuilder,
    StoryVoiceBuilder? voiceBuilder,
  })  : unseenGradient = unseenGradient,
        seenColor = seenColor,
        progressColor = progressColor,
        progressBackgroundColor = progressBackgroundColor,
        defaultDuration = defaultDuration,
        networkTimeout = networkTimeout,
        maxRetries = maxRetries,
        enableCaching = enableCaching,
        maxCacheSize = maxCacheSize,
        maxCacheAge = maxCacheAge,
        maxCacheObjects = maxCacheObjects,
        enablePreloading = enablePreloading,
        groupScrollDirection = groupScrollDirection,
        showHeader = showHeader,
        showProgressBar = showProgressBar,
        showBackButton = showBackButton,
        showUserInfo = showUserInfo,
        showMenuButton = true,
        showCloseButton = showCloseButton,
        showReplyField = true,
        showEmojiButton = true,
        autoPauseOnBackground = autoPauseOnBackground,
        hideStatusBar = hideStatusBar,
        texts = texts,
        loadingBuilder = loadingBuilder,
        errorBuilder = errorBuilder,
        headerBuilder = headerBuilder,
        footerBuilder = footerBuilder,
        progressBuilder = progressBuilder,
        imageBuilder = imageBuilder,
        videoBuilder = videoBuilder,
        voiceBuilder = voiceBuilder,
        assert(networkTimeout > 0, 'Network timeout must be greater than 0'),
        assert(maxRetries >= 0, 'Max retries must be 0 or greater');

  /// Minimal configuration for clean, distraction-free viewing.
  ///
  /// Optimized for media-focused experience:
  /// - No reply field
  /// - No menu button
  /// - No emoji button
  /// - Header and progress bar visible
  ///
  /// ## Usage
  /// ```dart
  /// VStoryViewer(
  ///   storyGroups: stories,
  ///   config: VStoryConfig.minimal(),
  /// )
  /// ```
  const VStoryConfig.minimal({
    List<Color> unseenGradient = const [Color(0xFFDD2A7B), Color(0xFFF58529)],
    Color seenColor = const Color(0xFF9E9E9E),
    Color progressColor = const Color(0xFFFFFFFF),
    Color progressBackgroundColor = const Color(0x40FFFFFF),
    Duration defaultDuration = const Duration(seconds: 5),
    int networkTimeout = 30,
    int maxRetries = 5,
    bool enableCaching = true,
    int maxCacheSize = 500 * 1024 * 1024,
    Duration maxCacheAge = const Duration(days: 7),
    int maxCacheObjects = 100,
    bool enablePreloading = true,
    Axis groupScrollDirection = Axis.horizontal,
    bool showHeader = true,
    bool showProgressBar = true,
    bool showUserInfo = true,
    bool showCloseButton = true,
    bool autoPauseOnBackground = true,
    bool hideStatusBar = true,
    VStoryTexts texts = const VStoryTexts(),
    StoryLoadingBuilder? loadingBuilder,
    StoryErrorBuilder? errorBuilder,
    StoryHeaderBuilder? headerBuilder,
    StoryProgressBuilder? progressBuilder,
    StoryImageBuilder? imageBuilder,
    StoryVideoBuilder? videoBuilder,
    StoryVoiceBuilder? voiceBuilder,
  })  : unseenGradient = unseenGradient,
        seenColor = seenColor,
        progressColor = progressColor,
        progressBackgroundColor = progressBackgroundColor,
        defaultDuration = defaultDuration,
        networkTimeout = networkTimeout,
        maxRetries = maxRetries,
        enableCaching = enableCaching,
        maxCacheSize = maxCacheSize,
        maxCacheAge = maxCacheAge,
        maxCacheObjects = maxCacheObjects,
        enablePreloading = enablePreloading,
        groupScrollDirection = groupScrollDirection,
        showHeader = showHeader,
        showProgressBar = showProgressBar,
        showBackButton = false,
        showUserInfo = showUserInfo,
        showMenuButton = false,
        showCloseButton = showCloseButton,
        showReplyField = false,
        showEmojiButton = false,
        autoPauseOnBackground = autoPauseOnBackground,
        hideStatusBar = hideStatusBar,
        texts = texts,
        loadingBuilder = loadingBuilder,
        errorBuilder = errorBuilder,
        headerBuilder = headerBuilder,
        footerBuilder = null,
        progressBuilder = progressBuilder,
        imageBuilder = imageBuilder,
        videoBuilder = videoBuilder,
        voiceBuilder = voiceBuilder,
        assert(networkTimeout > 0, 'Network timeout must be greater than 0'),
        assert(maxRetries >= 0, 'Max retries must be 0 or greater');

  /// Creates a copy of this config with the given fields replaced.
  ///
  /// Useful for making small adjustments to preset configs:
  /// ```dart
  /// VStoryConfig.forViewer().copyWith(
  ///   showEmojiButton: false,
  ///   progressColor: Colors.blue,
  /// )
  /// ```
  VStoryConfig copyWith({
    List<Color>? unseenGradient,
    Color? seenColor,
    Color? progressColor,
    Color? progressBackgroundColor,
    Duration? defaultDuration,
    int? networkTimeout,
    int? maxRetries,
    bool? enableCaching,
    int? maxCacheSize,
    Duration? maxCacheAge,
    int? maxCacheObjects,
    bool? enablePreloading,
    Axis? groupScrollDirection,
    bool? showHeader,
    bool? showProgressBar,
    bool? showBackButton,
    bool? showUserInfo,
    bool? showMenuButton,
    bool? showCloseButton,
    bool? showReplyField,
    bool? showEmojiButton,
    bool? autoPauseOnBackground,
    bool? hideStatusBar,
    VStoryTexts? texts,
    StoryLoadingBuilder? loadingBuilder,
    StoryErrorBuilder? errorBuilder,
    StoryHeaderBuilder? headerBuilder,
    StoryFooterBuilder? footerBuilder,
    StoryProgressBuilder? progressBuilder,
    StoryImageBuilder? imageBuilder,
    StoryVideoBuilder? videoBuilder,
    StoryVoiceBuilder? voiceBuilder,
  }) {
    return VStoryConfig(
      unseenGradient: unseenGradient ?? this.unseenGradient,
      seenColor: seenColor ?? this.seenColor,
      progressColor: progressColor ?? this.progressColor,
      progressBackgroundColor:
          progressBackgroundColor ?? this.progressBackgroundColor,
      defaultDuration: defaultDuration ?? this.defaultDuration,
      networkTimeout: networkTimeout ?? this.networkTimeout,
      maxRetries: maxRetries ?? this.maxRetries,
      enableCaching: enableCaching ?? this.enableCaching,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      maxCacheAge: maxCacheAge ?? this.maxCacheAge,
      maxCacheObjects: maxCacheObjects ?? this.maxCacheObjects,
      enablePreloading: enablePreloading ?? this.enablePreloading,
      groupScrollDirection: groupScrollDirection ?? this.groupScrollDirection,
      showHeader: showHeader ?? this.showHeader,
      showProgressBar: showProgressBar ?? this.showProgressBar,
      showBackButton: showBackButton ?? this.showBackButton,
      showUserInfo: showUserInfo ?? this.showUserInfo,
      showMenuButton: showMenuButton ?? this.showMenuButton,
      showCloseButton: showCloseButton ?? this.showCloseButton,
      showReplyField: showReplyField ?? this.showReplyField,
      showEmojiButton: showEmojiButton ?? this.showEmojiButton,
      autoPauseOnBackground:
          autoPauseOnBackground ?? this.autoPauseOnBackground,
      hideStatusBar: hideStatusBar ?? this.hideStatusBar,
      texts: texts ?? this.texts,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      headerBuilder: headerBuilder ?? this.headerBuilder,
      footerBuilder: footerBuilder ?? this.footerBuilder,
      progressBuilder: progressBuilder ?? this.progressBuilder,
      imageBuilder: imageBuilder ?? this.imageBuilder,
      videoBuilder: videoBuilder ?? this.videoBuilder,
      voiceBuilder: voiceBuilder ?? this.voiceBuilder,
    );
  }
}
