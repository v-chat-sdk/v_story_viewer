import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/v_story_config.dart';
import '../models/v_story_error.dart';
import '../models/v_story_group.dart';
import '../models/v_story_item.dart';
import '../controllers/story_controller.dart';
import '../transitions/cube_page_view.dart';
import '../utils/story_cache_manager.dart';
import 'v_story_header.dart';
import 'v_story_progress.dart';
import 'v_story_reply_field.dart';
import 'content/image_content.dart';
import 'content/text_content.dart';
import 'content/video_content.dart';
import 'content/voice_content.dart';

/// Full-screen story viewer with 3D cube transitions (Instagram/WhatsApp style).
///
/// Displays stories from multiple users with auto-advancing progress,
/// gesture controls, and rich media support (images, videos, text, voice).
///
/// ## Basic Usage
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => VStoryViewer(
///     storyGroups: myStoryGroups,
///     initialGroupIndex: 0,
///     onStoryViewed: (group, item) {
///       // Mark story as seen in your backend
///     },
///     onComplete: (group, item) {
///       Navigator.pop(context);
///     },
///   ),
/// ));
/// ```
///
/// ## Full Example with All Callbacks
/// ```dart
/// VStoryViewer(
///   storyGroups: storyGroups,
///   initialGroupIndex: selectedIndex,
///   config: VStoryConfig(
///     progressColor: Colors.blue,
///     showReplyField: true,
///   ),
///   onStoryViewed: (group, item) => markAsSeen(group.user.id, item),
///   onPause: (group, item) => pauseBackgroundMusic(),
///   onResume: (group, item) => resumeBackgroundMusic(),
///   onReply: (group, item, text) => sendReply(group.user.id, text),
///   onUserTap: (group, item) async {
///     await showUserProfile(group.user);
///     return true; // Resume story
///   },
///   onMenuTap: (group, item) async {
///     final action = await showStoryMenu();
///     if (action == 'report') reportStory(item);
///     return true; // Resume story
///   },
///   onComplete: (_, __) => Navigator.pop(context),
///   onClose: (_, __) => Navigator.pop(context),
/// )
/// ```
///
/// ## Gesture Controls
/// | Gesture | Action |
/// |---------|--------|
/// | Tap left side | Previous story |
/// | Tap right side | Next story |
/// | Long press | Pause story |
/// | Swipe left/right | Navigate between users (3D cube) |
/// | Swipe up | Triggers [onSwipeUp] callback |
///
/// ## Keyboard Controls (Desktop/Web)
/// | Key | Action |
/// |-----|--------|
/// | Left Arrow | Previous story |
/// | Right Arrow | Next story |
/// | Space | Toggle pause |
/// | Escape | Close viewer |
///
/// ## Story Types
/// Renders appropriate content based on story type:
/// - [VImageStory]: Static image with optional caption
/// - [VVideoStory]: Video with auto-play and duration detection
/// - [VTextStory]: Styled text with background color
/// - [VVoiceStory]: Audio with visual waveform
/// - [VCustomStory]: Custom widget via builder
///
/// ## Callback Timing
/// | Callback | When Fired |
/// |----------|------------|
/// | [onLoad] | Content finished loading |
/// | [onStoryViewed] | Story becomes visible (after load) |
/// | [onProgress] | Progress updates (~60fps throttled) |
/// | [onPause] | Story paused (long press, app background) |
/// | [onResume] | Story resumed |
/// | [onSkip] | Story skipped via tap navigation |
/// | [onComplete] | All stories in all groups viewed |
/// | [onClose] | Close button tapped |
///
/// ## Important Notes
/// - The viewer does NOT automatically mark stories as seen
/// - Use [onStoryViewed] to track seen state in your backend
/// - [onUserTap] and [onMenuTap] pause until callback completes
/// - Web platform shows additional play/pause and mute buttons
///
/// ## See Also
/// - [VStoryCircleList] for story list display
/// - [VStoryConfig] for customization options
/// - [VStoryGroup] and [VStoryItem] for data models
class VStoryViewer extends StatefulWidget {
  /// List of story groups to display.
  ///
  /// Each group represents one user's stories.
  /// Must not be empty.
  final List<VStoryGroup> storyGroups;

  /// Initial group to display (0-based index).
  ///
  /// Typically set to the tapped user's index from [VStoryCircleList].
  /// Defaults to 0 (first user).
  final int initialGroupIndex;

  /// Configuration for viewer appearance and behavior.
  ///
  /// Controls colors, durations, visibility flags, and custom builders.
  /// See [VStoryConfig] for all options.
  final VStoryConfig config;

  /// Called when all stories in all groups have been viewed.
  ///
  /// Typically used to close the viewer:
  /// ```dart
  /// onComplete: (group, item) => Navigator.pop(context),
  /// ```
  final void Function(VStoryGroup group, VStoryItem item)? onComplete;

  /// Called when close button is tapped.
  ///
  /// Typically used to close the viewer:
  /// ```dart
  /// onClose: (group, item) => Navigator.pop(context),
  /// ```
  final void Function(VStoryGroup group, VStoryItem item)? onClose;

  /// Called when a story becomes visible (after loading).
  ///
  /// **Important**: Use this to track seen state in your backend.
  /// The viewer does NOT automatically update [VStoryItem.isSeen].
  final void Function(VStoryGroup group, VStoryItem item)? onStoryViewed;

  /// Called when story playback is paused.
  ///
  /// Triggers: long press, app background, reply field focus.
  final void Function(VStoryGroup group, VStoryItem item)? onPause;

  /// Called when story playback resumes.
  final void Function(VStoryGroup group, VStoryItem item)? onResume;

  /// Called when a story is skipped via tap navigation.
  ///
  /// Fires when user taps to go to next/previous story.
  final void Function(VStoryGroup group, VStoryItem item)? onSkip;

  /// Called when user submits a reply.
  ///
  /// The [text] parameter contains the reply message.
  final void Function(VStoryGroup group, VStoryItem item, String text)? onReply;

  /// Called on progress updates (~60fps, throttled).
  ///
  /// The [progress] parameter is 0.0 to 1.0.
  final void Function(VStoryGroup group, VStoryItem item, double progress)?
      onProgress;

  /// Called when content fails to load.
  ///
  /// Provides structured error information for specific error handling:
  /// ```dart
  /// onError: (group, item, error) {
  ///   switch (error) {
  ///     case VStoryNetworkError():
  ///       showSnackBar('Check your internet connection');
  ///     case VStoryTimeoutError():
  ///       showSnackBar('Loading timed out');
  ///     case VStoryCacheError():
  ///       clearCache();
  ///     case VStoryFormatError():
  ///       log('Unsupported: ${error.format}');
  ///     case VStoryPermissionError():
  ///       requestPermission();
  ///     case VStoryLoadError():
  ///       log('Failed: ${error.message}');
  ///   }
  /// },
  /// ```
  final void Function(VStoryGroup group, VStoryItem item, VStoryError error)?
      onError;

  /// Called when content finishes loading.
  ///
  /// Fires before [onStoryViewed].
  final void Function(VStoryGroup group, VStoryItem item)? onLoad;

  /// Called when user swipes up on a story.
  ///
  /// Typically used for "See more" or link navigation.
  /// Disabled when [VStoryConfig.groupScrollDirection] is [Axis.vertical].
  final void Function(VStoryGroup group, VStoryItem item)? onSwipeUp;

  /// Called when the user taps on user avatar/name in header.
  ///
  /// The story is paused while waiting for this callback to complete.
  /// Return `true` to resume the story, `false` to keep it paused.
  ///
  /// Example:
  /// ```dart
  /// onUserTap: (group, item) async {
  ///   await Navigator.push(context, UserProfileRoute(group.user));
  ///   return true; // Resume story after returning
  /// },
  /// ```
  final Future<bool> Function(VStoryGroup group, VStoryItem item)? onUserTap;

  /// Called when the user taps the three-dots menu button.
  ///
  /// The story is paused while waiting for this callback to complete.
  /// Return `true` to resume the story, `false` to keep it paused.
  /// If this callback is null, the three-dots button is hidden.
  ///
  /// Example:
  /// ```dart
  /// onMenuTap: (group, item) async {
  ///   final action = await showModalBottomSheet(...);
  ///   if (action == 'report') reportStory(item);
  ///   return true; // Resume story
  /// },
  /// ```
  final Future<bool> Function(VStoryGroup group, VStoryItem item)? onMenuTap;

  /// Creates a full-screen story viewer.
  const VStoryViewer({
    super.key,
    required this.storyGroups,
    this.initialGroupIndex = 0,
    this.config = const VStoryConfig(),
    this.onComplete,
    this.onClose,
    this.onStoryViewed,
    this.onPause,
    this.onResume,
    this.onSkip,
    this.onReply,
    this.onProgress,
    this.onError,
    this.onLoad,
    this.onSwipeUp,
    this.onUserTap,
    this.onMenuTap,
  });
  @override
  State<VStoryViewer> createState() => _VStoryViewerState();
}

class _VStoryViewerState extends State<VStoryViewer>
    with TickerProviderStateMixin {
  late StoryController _controller;
  late PageController _pageController;
  late AnimationController _progressAnimController;
  Timer? _autoSkipTimer;
  bool _isPaused = false;
  bool _isContentLoaded = false;
  final FocusNode _focusNode = FocusNode();
  // Long press focus mode
  bool _isLongPressed = false;
  // Reply overlay state
  bool _isReplyFieldFocused = false;
  // Mute state for web
  bool _isMuted = false;
  // Pointer tracking for instant pause (tap vs hold detection)
  DateTime? _pointerDownTime;
  Offset? _pointerDownPosition;
  static const _tapThreshold = Duration(milliseconds: 200);
  static const _moveThreshold = 20.0;
  // Progress callback throttling
  DateTime? _lastProgressCallback;
  // App lifecycle handling
  AppLifecycleListener? _lifecycleListener;
  bool _wasPausedBeforeBackground = false;
  // Preload queue management
  final Set<String> _preloadingUrls = {};
  static const _maxConcurrentPreloads = 2;
  @override
  void initState() {
    super.initState();
    _controller = StoryController(
      storyGroups: widget.storyGroups,
      initialGroupIndex: widget.initialGroupIndex,
    );
    _pageController = PageController(initialPage: widget.initialGroupIndex);
    _progressAnimController = AnimationController(vsync: this);
    _progressAnimController.addListener(_onProgressUpdate);
    _progressAnimController.addStatusListener(_onProgressComplete);
    _setupLifecycleListener();
    _initializeCacheManager();
    _setupImmersiveMode();
  }

  void _setupImmersiveMode() {
    if (widget.config.hideStatusBar) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  void _restoreSystemUI() {
    if (widget.config.hideStatusBar) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _initializeCacheManager() {
    if (widget.config.enableCaching && StoryCacheManager.isCachingSupported) {
      StoryCacheManager.instance.initialize(
        maxCacheSize: widget.config.maxCacheSize,
        maxCacheAge: widget.config.maxCacheAge,
        maxCacheObjects: widget.config.maxCacheObjects,
      );
    }
  }

  void _setupLifecycleListener() {
    if (!widget.config.autoPauseOnBackground) return;
    _lifecycleListener = AppLifecycleListener(
      onInactive: _onAppInactive,
      onPause: _onAppPaused,
      onResume: _onAppResumed,
      onHide: _onAppPaused,
      onDetach: _onAppDetached,
    );
  }

  void _onAppInactive() {
    if (!_isPaused) {
      _wasPausedBeforeBackground = false;
      _pauseProgress();
    }
  }

  void _onAppPaused() {
    if (!_isPaused) {
      _wasPausedBeforeBackground = false;
      _pauseProgress();
    }
  }

  void _onAppResumed() {
    if (!_wasPausedBeforeBackground &&
        _isPaused &&
        !_isReplyFieldFocused &&
        !_isLongPressed) {
      _resumeProgress();
    }
    _wasPausedBeforeBackground = true;
  }

  void _onAppDetached() {
    _progressAnimController.stop();
  }

  @override
  void dispose() {
    _restoreSystemUI();
    try {
      _preloadingUrls.clear();
      _lifecycleListener?.dispose();
      _autoSkipTimer?.cancel();
    } catch (_) {}
    try {
      _progressAnimController.removeListener(_onProgressUpdate);
      _progressAnimController.removeStatusListener(_onProgressComplete);
      _progressAnimController.dispose();
    } catch (_) {}
    try {
      _pageController.dispose();
    } catch (_) {}
    try {
      _controller.dispose();
    } catch (_) {}
    try {
      _focusNode.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _onProgressUpdate() {
    _controller.setProgress(_progressAnimController.value);
    final now = DateTime.now();
    if (_lastProgressCallback == null ||
        now.difference(_lastProgressCallback!).inMilliseconds >= 16) {
      _lastProgressCallback = now;
      widget.onProgress?.call(
        _controller.currentGroup,
        _controller.currentItem,
        _progressAnimController.value,
      );
    }
  }

  void _onProgressComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onStoryViewed?.call(
        _controller.currentGroup,
        _controller.currentItem,
      );
      _goToNext();
    }
  }

  void _startProgress(Duration duration) {
    _progressAnimController.duration = duration;
    _progressAnimController.forward(from: 0);
  }

  void _pauseProgress() {
    if (_isPaused) return; // Already paused, avoid redundant setState
    _progressAnimController.stop();
    _isPaused = true;
    _controller.pause();
    widget.onPause?.call(_controller.currentGroup, _controller.currentItem);
    setState(() {}); // Sync UI (pause icon)
  }

  void _resumeProgress() {
    if (!_isPaused) return; // Already playing, avoid redundant setState
    if (_isContentLoaded) {
      _progressAnimController.forward();
    }
    _isPaused = false;
    _controller.resume();
    widget.onResume?.call(_controller.currentGroup, _controller.currentItem);
    setState(() {}); // Sync UI (pause icon)
  }

  void _goToNext() {
    if (!_controller.next()) {
      if (!_controller.nextGroup()) {
        widget.onComplete
            ?.call(_controller.currentGroup, _controller.currentItem);
        _close();
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        _resetContent();
      }
    } else {
      _resetContent();
    }
  }

  void _goToPrevious() {
    if (_controller.previous()) {
      widget.onSkip?.call(_controller.currentGroup, _controller.currentItem);
      _resetContent();
    } else if (_controller.previousGroup()) {
      widget.onSkip?.call(_controller.currentGroup, _controller.currentItem);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _resetContent();
    } else {
      _progressAnimController.forward(from: 0);
    }
  }

  void _resetContent() {
    _autoSkipTimer?.cancel();
    _isLongPressed = false;
    _isContentLoaded = false;
    _isPaused = false;
    _progressAnimController.reset();
    setState(() {});
  }

  void _close() {
    widget.onClose?.call(_controller.currentGroup, _controller.currentItem);
    Navigator.of(context).pop();
  }

  void _onContentLoaded({Duration? duration}) {
    _isContentLoaded = true;
    final storyDuration = duration ??
        _controller.currentItem.duration ??
        const Duration(seconds: 5);
    widget.onLoad?.call(_controller.currentGroup, _controller.currentItem);
    if (!_isPaused) {
      _startProgress(storyDuration);
    } else {
      _progressAnimController.duration = storyDuration;
    }
    setState(() {});
    // Preload next video/audio story
    if (widget.config.enablePreloading) {
      _preloadNextMedia();
    }
  }

  void _preloadNextMedia() {
    if (!widget.config.enableCaching || !StoryCacheManager.isCachingSupported) {
      return;
    }
    if (_preloadingUrls.length >= _maxConcurrentPreloads) return;
    // Find next media story to preload
    VStoryItem? nextMedia;
    String? cacheKey;
    String? url;
    // Check next story in current group
    final currentGroup = _controller.currentGroup;
    final currentIndex = _controller.currentItemIndex;
    final stories = currentGroup.sortedStories;
    for (var i = currentIndex + 1; i < stories.length; i++) {
      final story = stories[i];
      if (story is VVideoStory && story.url != null && story.cacheKey != null) {
        nextMedia = story;
        cacheKey = story.cacheKey;
        url = story.url;
        break;
      } else if (story is VVoiceStory &&
          story.url != null &&
          story.cacheKey != null) {
        nextMedia = story;
        cacheKey = story.cacheKey;
        url = story.url;
        break;
      }
    }
    // If no media in current group, check first story of next group
    if (nextMedia == null && !_controller.isLastGroup) {
      final nextGroupIndex = _controller.currentGroupIndex + 1;
      final nextGroup = widget.storyGroups[nextGroupIndex];
      for (final story in nextGroup.sortedStories) {
        if (story is VVideoStory &&
            story.url != null &&
            story.cacheKey != null) {
          cacheKey = story.cacheKey;
          url = story.url;
          break;
        } else if (story is VVoiceStory &&
            story.url != null &&
            story.cacheKey != null) {
          cacheKey = story.cacheKey;
          url = story.url;
          break;
        }
      }
    }
    // Preload in background if found
    if (cacheKey != null && url != null) {
      final urlNonNull = url;
      final cacheKeyNonNull = cacheKey;
      if (_preloadingUrls.contains(urlNonNull)) return;
      StoryCacheManager.instance
          .getCachedFile(cacheKeyNonNull)
          .then((cachedFile) {
        if (cachedFile != null) return;
        _preloadingUrls.add(urlNonNull);
        StoryCacheManager.instance
            .preloadFile(urlNonNull, cacheKeyNonNull)
            .whenComplete(() {
          _preloadingUrls.remove(urlNonNull);
        });
      });
    }
  }

  void _onContentError(VStoryError error) {
    widget.onError?.call(
      _controller.currentGroup,
      _controller.currentItem,
      error,
    );
    _autoSkipTimer?.cancel();
    _autoSkipTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _goToNext();
      }
    });
  }

  void _handleKeyboard(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowRight:
        _goToNext();
        break;
      case LogicalKeyboardKey.arrowLeft:
        _goToPrevious();
        break;
      case LogicalKeyboardKey.space:
        if (_isPaused) {
          _resumeProgress();
        } else {
          _pauseProgress();
        }
        break;
      case LogicalKeyboardKey.escape:
        _close();
        break;
    }
  }

  void _handleTapNavigation(Offset localPosition) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final screenWidth = MediaQuery.of(context).size.width;
    final leftThreshold = screenWidth * 0.5;
    if (isRtl) {
      if (localPosition.dx > screenWidth - leftThreshold) {
        _goToPrevious();
      } else {
        widget.onSkip?.call(_controller.currentGroup, _controller.currentItem);
        _goToNext();
      }
    } else {
      if (localPosition.dx < leftThreshold) {
        _goToPrevious();
      } else {
        widget.onSkip?.call(_controller.currentGroup, _controller.currentItem);
        _goToNext();
      }
    }
  }

  // Instant pointer handlers (no delay like onLongPressStart)
  void _onPointerDown(PointerDownEvent event) {
    _pointerDownTime = DateTime.now();
    _pointerDownPosition = event.position;
    _pauseProgress();
    setState(() => _isLongPressed = true);
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_pointerDownTime == null || _pointerDownPosition == null) return;
    final duration = DateTime.now().difference(_pointerDownTime!);
    final distance = (event.position - _pointerDownPosition!).distance;
    setState(() => _isLongPressed = false);
    _resumeProgress();
    if (duration < _tapThreshold && distance < _moveThreshold) {
      _handleTapNavigation(event.localPosition);
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    setState(() => _isLongPressed = false);
    _resumeProgress();
  }

  // Reply field focus handlers
  void _onReplyFieldFocus() {
    _pauseProgress();
    setState(() => _isReplyFieldFocused = true);
  }

  void _onReplyFieldUnfocus() {
    setState(() => _isReplyFieldFocused = false);
    _resumeProgress();
  }

  void _dismissReplyOverlay() {
    FocusScope.of(context).unfocus();
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
  }

  void _togglePause() {
    if (_isPaused) {
      _resumeProgress();
    } else {
      _pauseProgress();
    }
  }

  bool get _isMediaStory {
    final story = _controller.currentItem;
    return story is VVideoStory || story is VVoiceStory;
  }

  static final _captionDecoration = BoxDecoration(
    color: Colors.black.withValues(alpha: 0.6),
    borderRadius: BorderRadius.circular(8),
  );
  String? _getCaptionForStory(VStoryItem story) => switch (story) {
        VImageStory s => s.caption,
        VVideoStory s => s.caption,
        VVoiceStory s => s.caption,
        VCustomStory s => s.caption,
        VTextStory() => null,
      };
  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyboard,
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Main viewer
            CubePageView(
              controller: _pageController,
              itemCount: widget.storyGroups.length,
              scrollDirection: widget.config.groupScrollDirection,
              onDragStart: _pauseProgress,
              onDragEnd: () {},
              onDragCancel: _resumeProgress,
              onPageChanged: (index) {
                _controller.goToGroup(index);
                _resetContent();
              },
              itemBuilder: (context, groupIndex) {
                return _buildStoryPage(groupIndex);
              },
            ),
            // Reply focus overlay (0.3 opacity)
            if (_isReplyFieldFocused)
              Positioned.fill(
                key: const ValueKey('reply_overlay'),
                child: GestureDetector(
                  onTap: _dismissReplyOverlay,
                  child: ColoredBox(color: Colors.black.withValues(alpha: 0.3)),
                ),
              ),
            // Footer - on top of overlay for interaction
            if (!_isLongPressed &&
                (widget.config.footerBuilder != null ||
                    widget.config.showReplyField))
              Positioned(
                key: const ValueKey('reply_footer'),
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  bottom: MediaQuery.of(context).viewInsets.bottom == 0,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: widget.config.footerBuilder != null
                          ? widget.config.footerBuilder!(
                              context,
                              _controller.currentGroup,
                              _controller.currentItem,
                              (hasFocus) {
                                if (hasFocus) {
                                  _onReplyFieldFocus();
                                } else {
                                  _onReplyFieldUnfocus();
                                }
                              },
                            )
                          : VStoryReplyField(
                              onSubmit: (text) {
                                widget.onReply?.call(
                                  _controller.currentGroup,
                                  _controller.currentItem,
                                  text,
                                );
                                _dismissReplyOverlay();
                              },
                              texts: widget.config.texts,
                              showEmojiButton: widget.config.showEmojiButton,
                              onFocus: _onReplyFieldFocus,
                              onUnfocus: _onReplyFieldUnfocus,
                            ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryPage(int groupIndex) {
    final group = widget.storyGroups[groupIndex];
    final isCurrentGroup = groupIndex == _controller.currentGroupIndex;
    final allowVerticalGestures =
        widget.config.groupScrollDirection == Axis.horizontal;
    return GestureDetector(
      onVerticalDragEnd: allowVerticalGestures
          ? (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 300) {
                _close();
              } else if (details.primaryVelocity != null &&
                  details.primaryVelocity! < -300) {
                widget.onSwipeUp?.call(
                  _controller.currentGroup,
                  _controller.currentItem,
                );
              }
            }
          : null,
      child: Stack(
        children: [
          // Story content
          Positioned.fill(
            child: isCurrentGroup ? _buildContent() : const SizedBox.expand(),
          ),
          // Navigation tap zones - above content, below controls (excludes footer area)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bottomPadding = MediaQuery.of(context).padding.bottom;
                final footerHeight = (widget.config.showReplyField ||
                        widget.config.footerBuilder != null)
                    ? 100.0 + bottomPadding
                    : 0.0;
                return Column(
                  children: [
                    Expanded(
                      child: Listener(
                        onPointerDown: _onPointerDown,
                        onPointerUp: _onPointerUp,
                        onPointerCancel: _onPointerCancel,
                        behavior: HitTestBehavior.translucent,
                        child: const SizedBox.expand(),
                      ),
                    ),
                    SizedBox(height: footerHeight),
                  ],
                );
              },
            ),
          ),
          // Story overlay (captions, stickers, watermarks)
          if (isCurrentGroup && _controller.currentItem.overlayBuilder != null)
            _controller.currentItem.overlayBuilder!(context),
          // Caption
          if (isCurrentGroup &&
              _getCaptionForStory(_controller.currentItem) != null)
            Positioned(
              bottom: widget.config.showReplyField ? 80 : 16,
              left: 16,
              right: 16,
              child: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 650),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: _captionDecoration,
                      child: Text(
                        _getCaptionForStory(_controller.currentItem)!,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Progress bar
          if (widget.config.showProgressBar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 650),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          final storyCount = group.sortedStories.length;
                          final currentIndex =
                              isCurrentGroup ? _controller.currentItemIndex : 0;
                          final progress =
                              isCurrentGroup ? _controller.progress : 0.0;
                          // Use custom progress builder if provided
                          if (widget.config.progressBuilder != null) {
                            return widget.config.progressBuilder!(
                              context,
                              storyCount,
                              currentIndex,
                              progress,
                            );
                          }
                          final screenWidth = MediaQuery.of(context).size.width;
                          final progressHeight = kIsWeb && screenWidth > 800
                              ? (screenWidth > 1200 ? 5.0 : 4.0)
                              : 2.5;
                          return VStoryProgress(
                            storyCount: storyCount,
                            currentIndex: currentIndex,
                            progress: progress,
                            height: progressHeight,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Header - hide on long press
          if (widget.config.showHeader && !_isLongPressed)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 650),
                    child: widget.config.headerBuilder != null
                        ? widget.config.headerBuilder!(
                            context,
                            group.user,
                            isCurrentGroup
                                ? _controller.currentItem
                                : group.sortedStories.first,
                            _close,
                          )
                        : VStoryHeader(
                            user: group.user,
                            timestamp: isCurrentGroup
                                ? _controller.currentItem.createdAt
                                : null,
                            onUserTap: widget.onUserTap != null
                                ? () async {
                                    _pauseProgress();
                                    final shouldResume =
                                        await widget.onUserTap!(
                                      _controller.currentGroup,
                                      _controller.currentItem,
                                    );
                                    if (shouldResume) _resumeProgress();
                                  }
                                : null,
                            onMenuTap:
                                widget.onMenuTap != null && isCurrentGroup
                                    ? () async {
                                        _pauseProgress();
                                        final shouldResume =
                                            await widget.onMenuTap!(
                                                group, _controller.currentItem);
                                        if (shouldResume) _resumeProgress();
                                      }
                                    : null,
                            onCloseTap: _close,
                            isPaused: _isPaused,
                            isMuted: _isMuted,
                            showMuteButton: _isMediaStory,
                            onPlayPauseTap: _togglePause,
                            onMuteTap: _toggleMute,
                            showBackButton: widget.config.showBackButton,
                            showUserInfo: widget.config.showUserInfo,
                            showMenuButton: widget.onMenuTap != null,
                            showCloseButton: widget.config.showCloseButton,
                          ),
                  ),
                ),
              ),
            ),
          // Web navigation arrows
          if (kIsWeb && !_isLongPressed) ...[
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildNavArrow(
                  icon: CupertinoIcons.chevron_left,
                  enabled:
                      !_controller.isFirstStory || !_controller.isFirstGroup,
                  onTap: _goToPrevious,
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildNavArrow(
                  icon: CupertinoIcons.chevron_right,
                  enabled: !_controller.isLastStory || !_controller.isLastGroup,
                  onTap: _goToNext,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    final story = _controller.currentItem;
    final config = widget.config;
    final loadingBuilder = config.loadingBuilder;
    final errorBuilder = config.errorBuilder;
    return switch (story) {
      VImageStory() => config.imageBuilder != null
          ? config.imageBuilder!(
              context, story, () => _onContentLoaded(), _onContentError)
          : ImageContent(
              key: ValueKey(
                  '${_controller.currentGroupIndex}_${_controller.currentItemIndex}_image'),
              story: story,
              onLoaded: () => _onContentLoaded(),
              onError: _onContentError,
              loadingBuilder: loadingBuilder,
              errorBuilder: errorBuilder,
            ),
      VTextStory() => TextContent(
          key: ValueKey(
              '${_controller.currentGroupIndex}_${_controller.currentItemIndex}_text'),
          story: story,
          onLoaded: () => _onContentLoaded(),
        ),
      VVideoStory() => config.videoBuilder != null
          ? config.videoBuilder!(
              context,
              story,
              _isPaused,
              _isMuted,
              (duration) => _onContentLoaded(duration: duration),
              _onContentError,
            )
          : VideoContent(
              key: ValueKey(
                  '${_controller.currentGroupIndex}_${_controller.currentItemIndex}_video'),
              story: story,
              isPaused: _isPaused,
              isMuted: _isMuted,
              enableCaching: config.enableCaching,
              onLoaded: (duration) => _onContentLoaded(duration: duration),
              onError: _onContentError,
              loadingBuilder: loadingBuilder,
              errorBuilder: errorBuilder,
            ),
      VVoiceStory() => config.voiceBuilder != null
          ? config.voiceBuilder!(
              context,
              story,
              _isPaused,
              _isMuted,
              (duration) => _onContentLoaded(duration: duration),
              _onContentError,
            )
          : VoiceContent(
              key: ValueKey(
                  '${_controller.currentGroupIndex}_${_controller.currentItemIndex}_voice'),
              story: story,
              isPaused: _isPaused,
              isMuted: _isMuted,
              enableCaching: config.enableCaching,
              onLoaded: (duration) => _onContentLoaded(duration: duration),
              onError: _onContentError,
              loadingBuilder: loadingBuilder,
              errorBuilder: errorBuilder,
            ),
      VCustomStory() => story.contentBuilder(
          context,
          _isPaused,
          _isMuted,
          (duration) => _onContentLoaded(duration: duration),
          _onContentError,
        ),
    };
  }

  Widget _buildNavArrow({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
