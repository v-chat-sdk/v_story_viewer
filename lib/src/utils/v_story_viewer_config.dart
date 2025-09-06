import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../v_story_viewer.dart';


/// Configuration for the story viewer.
class VStoryViewerConfig {
  /// Whether to show progress bars
  final bool showProgressBars;

  /// Whether to show header
  final bool showHeader;

  /// Whether to show footer
  final bool showFooter;

  /// Whether to enable gestures
  final bool enableGestures;


  /// Background color
  final Color backgroundColor;

  /// System UI overlay style
  final SystemUiOverlayStyle? systemUiOverlayStyle;

  /// Progress bar style
  final VStoryProgressStyle progressStyle;

  /// Text story style
  final VTextStoryStyle? textStoryStyle;

  /// Duration configuration
  final VDurationConfig durationConfig;

  /// Gesture configuration
  final VGestureConfig gestureConfig;

  /// Whether replies are enabled
  final bool enableReply;

  /// Whether reactions are enabled
  final bool enableReactions;

  /// Reply configuration
  final VReplyConfiguration? replyConfig;

  /// Reaction configuration
  final VReactionConfiguration? reactionConfig;

  /// Overall theme configuration
  final VStoryTheme? theme;

  /// Creates a viewer configuration
  const VStoryViewerConfig({
    this.showProgressBars = true,
    this.showHeader = true,
    this.showFooter = false,
    this.enableGestures = true,
    this.backgroundColor = Colors.black,
    this.systemUiOverlayStyle,
    this.progressStyle = const VStoryProgressStyle(
      activeColor: Colors.white,
      inactiveColor: Color(0x4DFFFFFF),
    ),
    this.textStoryStyle,
    this.durationConfig = const VDurationConfig(),
    this.gestureConfig = const VGestureConfig(),
    this.enableReply = false,
    this.enableReactions = false,
    this.replyConfig,
    this.reactionConfig,
    this.theme,
  });

  /// Creates a default configuration
  factory VStoryViewerConfig.defaultConfig() => const VStoryViewerConfig();

  /// Creates a minimal configuration
  factory VStoryViewerConfig.minimal() => const VStoryViewerConfig(
    showHeader: false,
    showFooter: false,
    showProgressBars: true,
  );

  /// Creates an immersive configuration
  factory VStoryViewerConfig.immersive() => VStoryViewerConfig(

    systemUiOverlayStyle: SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  /// Creates a configuration with reply system enabled
  factory VStoryViewerConfig.withReply({
    required VReplyConfiguration replyConfig,
    VStoryTheme? theme,
    bool enableReactions = false,
    VReactionConfiguration? reactionConfig,
  }) => VStoryViewerConfig(
    showFooter: true,  // Required for reply system
    enableReply: true,
    enableReactions: enableReactions,
    replyConfig: replyConfig,
    reactionConfig: reactionConfig,
    theme: theme,
  );
}