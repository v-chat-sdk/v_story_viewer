import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import '../models/v_story_user.dart';
import '../utils/time_formatter.dart';

/// Header widget for story viewer with user info and controls.
///
/// Displays story owner information and action buttons at the top of
/// [VStoryViewer]. Includes back, user info, play/pause, mute, menu, and close.
///
/// ## Default Layout
/// ```
/// [<] [Avatar] Name       [▶] [🔊] [⋮] [✕]
///              2h ago
/// ```
///
/// ## Basic Usage
/// ```dart
/// VStoryHeader(
///   user: currentGroup.user,
///   timestamp: currentStory.createdAt,
///   onCloseTap: () => Navigator.pop(context),
/// )
/// ```
///
/// ## Custom Configuration
/// ```dart
/// VStoryHeader(
///   user: user,
///   timestamp: story.createdAt,
///   isPaused: isPaused,
///   isMuted: isMuted,
///   showMuteButton: story is VVideoStory || story is VVoiceStory,
///   onBackTap: () => goToPreviousUser(),
///   onUserTap: () => openProfile(user),
///   onPlayPauseTap: () => togglePause(),
///   onMuteTap: () => toggleMute(),
///   onMenuTap: () => showMenu(),
///   onCloseTap: () => closeViewer(),
///   showBackButton: true,
///   showUserInfo: true,
///   showMenuButton: true,
///   showCloseButton: true,
/// )
/// ```
///
/// ## Web-Specific Features
/// On web platforms (`kIsWeb`), additional controls are shown:
/// - **Play/Pause button**: Toggle story playback
/// - **Mute/Unmute button**: Toggle audio (when [showMuteButton] is true)
///
/// These compensate for lack of long-press gesture on web.
///
/// ## Visibility Flags
/// Each UI element can be shown/hidden independently:
/// - [showBackButton]: Back arrow (left)
/// - [showUserInfo]: Avatar, name, timestamp
/// - [showMenuButton]: Three dots menu (requires [onMenuTap])
/// - [showCloseButton]: X button (right)
///
/// ## SafeArea
/// Automatically handles system UI insets (notch, status bar).
///
/// ## See Also
/// - [VStoryViewer] which contains this header
/// - [VStoryConfig.headerBuilder] for full header replacement
/// - [VStoryConfig.showHeader] to hide entire header
class VStoryHeader extends StatelessWidget {
  /// User information for avatar and name display.
  final VStoryUser user;

  /// Story creation time for relative timestamp display.
  ///
  /// Shows "2h ago", "Yesterday", etc. using [TimeFormatter].
  /// If `null`, timestamp is hidden.
  final DateTime? timestamp;

  /// Callback when back button is tapped.
  ///
  /// Defaults to `Navigator.pop(context)` if not provided.
  final VoidCallback? onBackTap;

  /// Callback when user avatar or name is tapped.
  ///
  /// Typically used to navigate to user profile.
  final VoidCallback? onUserTap;

  /// Callback when menu (three dots) button is tapped.
  ///
  /// Menu button is hidden if this is `null`.
  final VoidCallback? onMenuTap;

  /// Callback when close (X) button is tapped.
  ///
  /// Typically closes the viewer and returns to previous screen.
  final VoidCallback? onCloseTap;

  /// Whether story is currently paused.
  ///
  /// Controls play/pause icon state on web. Defaults to `false`.
  final bool isPaused;

  /// Whether audio is currently muted.
  ///
  /// Controls mute icon state on web. Defaults to `false`.
  final bool isMuted;

  /// Whether to show mute button on web.
  ///
  /// Typically `true` for video/voice stories, `false` for image/text.
  /// Only applies on web platform. Defaults to `false`.
  final bool showMuteButton;

  /// Callback when play/pause button is tapped (web only).
  final VoidCallback? onPlayPauseTap;

  /// Callback when mute/unmute button is tapped (web only).
  final VoidCallback? onMuteTap;

  /// Whether to show the back button.
  ///
  /// Defaults to `true`.
  final bool showBackButton;

  /// Whether to show user avatar, name, and timestamp.
  ///
  /// If `false`, shows [Spacer] instead. Defaults to `true`.
  final bool showUserInfo;

  /// Whether to show the menu (three dots) button.
  ///
  /// Also requires [onMenuTap] to be non-null. Defaults to `true`.
  final bool showMenuButton;

  /// Whether to show the close (X) button.
  ///
  /// Defaults to `true`.
  final bool showCloseButton;

  /// Creates a story viewer header.
  const VStoryHeader({
    super.key,
    required this.user,
    this.timestamp,
    this.onBackTap,
    this.onUserTap,
    this.onMenuTap,
    this.onCloseTap,
    this.isPaused = false,
    this.isMuted = false,
    this.showMuteButton = false,
    this.onPlayPauseTap,
    this.onMuteTap,
    this.showBackButton = true,
    this.showUserInfo = true,
    this.showMenuButton = true,
    this.showCloseButton = true,
  });
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            // Back button
            if (showBackButton)
              IconButton(
                icon: const Icon(CupertinoIcons.back, color: Colors.white),
                onPressed: onBackTap ?? () => Navigator.of(context).pop(),
              ),
            // User avatar and info - single tap area for avatar + name + time
            if (showUserInfo)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onUserTap,
                  child: Row(
                    children: [
                      _UserAvatar(user: user),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (timestamp != null)
                              Text(
                                TimeFormatter.formatRelativeTime(timestamp!),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Spacer(),
            // Web controls - play/pause and mute
            if (kIsWeb) ...[
              Tooltip(
                message: 'Play/Pause',
                child: IconButton(
                  icon: Icon(
                    isPaused
                        ? CupertinoIcons.play_fill
                        : CupertinoIcons.pause_fill,
                    color: Colors.white,
                  ),
                  onPressed: onPlayPauseTap,
                ),
              ),
              if (showMuteButton)
                Tooltip(
                  message: 'Mute/Unmute',
                  child: IconButton(
                    icon: Icon(
                      isMuted
                          ? CupertinoIcons.speaker_slash_fill
                          : CupertinoIcons.speaker_2_fill,
                      color: Colors.white,
                    ),
                    onPressed: onMuteTap,
                  ),
                ),
            ],
            // Menu button (three dots)
            if (showMenuButton && onMenuTap != null)
              IconButton(
                icon: const Icon(CupertinoIcons.ellipsis_vertical,
                    color: Colors.white),
                onPressed: onMenuTap,
              ),
            // Close button
            if (showCloseButton)
              IconButton(
                icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
                onPressed: onCloseTap,
              ),
          ],
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final VStoryUser user;
  const _UserAvatar({required this.user});
  static Widget? _handleLoadState(ExtendedImageState state) {
    if (state.extendedImageLoadState == LoadState.failed) {
      return Container(
        width: 36,
        height: 36,
        color: Colors.grey[600],
        child: const Icon(CupertinoIcons.person_fill,
            color: Colors.white, size: 20),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipOval(
        child: ExtendedImage.network(
          user.imageUrl,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          cache: true,
          loadStateChanged: _handleLoadState,
        ),
      ),
    );
  }
}
