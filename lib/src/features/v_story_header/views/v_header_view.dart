import 'package:flutter/material.dart';

import '../../v_media_viewer/controllers/v_base_media_controller.dart';
import '../../v_media_viewer/controllers/v_video_controller.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_story_user.dart';
import '../models/v_header_config.dart';
import '../models/v_story_action.dart';
import '../widgets/v_header_container.dart';
import '../widgets/v_timestamp.dart';
import '../widgets/v_user_avatar.dart';
import '../widgets/v_user_info.dart';

/// The view for the story header.
class VHeaderView extends StatefulWidget {
  /// Creates a new instance of [VHeaderView].
  const VHeaderView({
    required this.user,
    required this.createdAt,
    this.config,
    this.onClosePressed,
    this.onActionPressed,
    this.mediaController,
    this.currentStory,
    this.onPlayPausePressed,
    this.onMutePressed,
    super.key,
  });

  /// The user who created the story.
  final VStoryUser user;

  /// The time the story was created.
  final DateTime createdAt;

  /// The configuration for the header.
  final VHeaderConfig? config;

  /// A callback for when the close button is pressed.
  final VoidCallback? onClosePressed;

  /// A callback for when the action button is pressed.
  final VoidCallback? onActionPressed;

  /// Media controller for playback state
  final VBaseMediaController? mediaController;

  /// Current story being displayed
  final VBaseStory? currentStory;

  /// Callback for play/pause button press
  final VoidCallback? onPlayPausePressed;

  /// Callback for mute button press
  final VoidCallback? onMutePressed;

  @override
  State<VHeaderView> createState() => _VHeaderViewState();
}

class _VHeaderViewState extends State<VHeaderView> {
  late bool _isPaused;
  late bool _isMuted;

  @override
  void initState() {
    super.initState();
    _isPaused = widget.mediaController?.isPaused ?? false;
    _isMuted = _getIsMuted();
    widget.mediaController?.addListener(_onMediaStateChanged);
  }

  @override
  void didUpdateWidget(VHeaderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaController != widget.mediaController) {
      oldWidget.mediaController?.removeListener(_onMediaStateChanged);
      widget.mediaController?.addListener(_onMediaStateChanged);
      _isPaused = widget.mediaController?.isPaused ?? false;
      _isMuted = _getIsMuted();
    }
  }

  void _onMediaStateChanged() {
    if (!mounted) return;
    setState(() {
      _isPaused = widget.mediaController?.isPaused ?? false;
      _isMuted = _getIsMuted();
    });
  }

  bool _getIsMuted() {
    final controller = widget.mediaController;
    if (controller is VVideoController) {
      return controller.isMuted;
    }
    return false;
  }

  bool _isVideoStory() => widget.currentStory != null && widget.currentStory!.runtimeType.toString().contains('VVideoStory');

  void _showActionMenu(BuildContext context) {
    final actions = widget.config?.actions ?? [];
    if (actions.isEmpty) {
      widget.onActionPressed?.call();
      return;
    }
    showMenu<VStoryAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 60,
        50,
        8,
        0,
      ),
      items: actions
          .map(
            (action) => PopupMenuItem<VStoryAction>(
              value: action,
              child: Row(
                children: [
                  Icon(
                    action.icon,
                    color: action.iconColor ?? Colors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    action.label,
                    style: TextStyle(color: action.textColor ?? Colors.black),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ).then((selectedAction) {
      selectedAction?.onPressed();
    });
  }

  @override
  void dispose() {
    widget.mediaController?.removeListener(_onMediaStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VHeaderContainer(
      padding: widget.config?.padding,
      child: Row(
        children: [
          VUserAvatar(
            avatarUrl: widget.user.profilePicture,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VUserInfo(
                  user: widget.user,
                  textStyle: widget.config?.titleTextStyle,
                ),
                VTimestamp(
                  createdAt: widget.createdAt,
                  textStyle: widget.config?.subtitleTextStyle,
                ),
              ],
            ),
          ),
          if (widget.config?.showPlaybackControls ?? false) ...[
            IconButton(
              icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
              color: widget.config?.controlButtonColor ?? Colors.white,
              onPressed: widget.onPlayPausePressed,
            ),
            if (_isVideoStory())
              IconButton(
                icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
                color: widget.config?.controlButtonColor ?? Colors.white,
                onPressed: widget.onMutePressed,
              ),
          ],
          if (widget.config?.actions != null && widget.config!.actions!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.more_vert),
              color: widget.config?.actionButtonColor ?? Colors.white,
              onPressed: () => _showActionMenu(context),
            )
          else if (widget.onActionPressed != null)
            IconButton(
              icon: const Icon(Icons.more_vert),
              color: widget.config?.actionButtonColor ?? Colors.white,
              onPressed: widget.onActionPressed,
            ),
          if (widget.onClosePressed != null)
            IconButton(
              icon: const Icon(Icons.close),
              color: widget.config?.closeButtonColor ?? Colors.white,
              onPressed: widget.onClosePressed,
            ),
        ],
      ),
    );
  }
}
