import 'package:flutter/material.dart';

import '../../v_media_viewer/controllers/v_base_media_controller.dart';
import '../../v_media_viewer/controllers/v_video_controller.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_story_user.dart';
import '../../v_theme_system/models/v_responsive_utils.dart';
import '../models/v_header_config.dart';
import '../widgets/v_action_menu.dart';
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
    this.onMutePressed,
    this.onHeaderTap,
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

  /// Callback for mute button press
  final VoidCallback? onMutePressed;

  /// Callback when header is tapped
  final VoidCallback? onHeaderTap;

  @override
  State<VHeaderView> createState() => _VHeaderViewState();
}

class _VHeaderViewState extends State<VHeaderView> {
  late bool _isMuted;
  final _actionButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _isMuted = _getIsMuted();
    widget.mediaController?.addListener(_onMediaStateChanged);
  }

  @override
  void didUpdateWidget(VHeaderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaController != widget.mediaController) {
      oldWidget.mediaController?.removeListener(_onMediaStateChanged);
      widget.mediaController?.addListener(_onMediaStateChanged);
      _isMuted = _getIsMuted();
    }
  }

  void _onMediaStateChanged() {
    if (!mounted) return;
    setState(() {
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

  bool _isVideoStory() =>
      widget.currentStory != null &&
      widget.currentStory!.runtimeType.toString().contains('VVideoStory');

  /// Calculate responsive icon button size based on screen width
  double _getResponsiveIconSize(BuildContext context) {
    return VResponsiveUtils.getIconSize(
      context,
      mobileSize: 48,
      tabletSize: 52,
      desktopSize: 56,
    );
  }

  void _showActionMenu(BuildContext context) {
    final actions = widget.config?.getEffectiveActions() ?? [];
    if (actions.isEmpty) {
      widget.onActionPressed?.call();
      return;
    }

    // Get button position from GlobalKey
    final buttonContext = _actionButtonKey.currentContext;
    if (buttonContext == null) return;

    final renderObject = buttonContext.findRenderObject();
    if (renderObject is! RenderBox) return;

    final buttonSize = renderObject.size;
    final buttonPosition = renderObject.localToGlobal(Offset.zero);

    // No need to track pause state - play/pause button removed

    VActionMenu.show(
      context: context,
      actions: actions,
      buttonPosition: buttonPosition,
      buttonSize: buttonSize,
    ).then((selectedAction) {
      selectedAction?.onPressed();

      // No need to resume - play/pause button removed
    });
  }

  @override
  void dispose() {
    widget.mediaController?.removeListener(_onMediaStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsiveIconSize = _getResponsiveIconSize(context);

    return VHeaderContainer(
      padding: widget.config?.padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: widget.onHeaderTap,
            child: Row(
              children: [
                VUserAvatar(avatarUrl: widget.user.profilePicture),
                const SizedBox(width: 8),
                Column(
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
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: const SizedBox()),
          if (widget.config?.showPlaybackControls ?? true) ...[
            // Play/pause button removed
            if (_isVideoStory())
              SizedBox(
                height: responsiveIconSize,
                width: responsiveIconSize,
                child: Semantics(
                  label: _isMuted ? 'Unmute video' : 'Mute video',
                  button: true,
                  enabled: true,
                  onTap: widget.onMutePressed,
                  child: IconButton(
                    icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
                    color: widget.config?.controlButtonColor ?? Colors.white,
                    onPressed: widget.onMutePressed,
                  ),
                ),
              ),
          ],
          if (widget.config?.getEffectiveActions() != null &&
              widget.config!.getEffectiveActions()!.isNotEmpty)
            SizedBox(
              key: _actionButtonKey,
              height: responsiveIconSize,
              width: responsiveIconSize,
              child: Semantics(
                label: 'More options',
                button: true,
                enabled: true,
                onTap: () => _showActionMenu(context),
                child: IconButton(
                  icon: const Icon(Icons.more_vert),
                  color: widget.config?.actionButtonColor ?? Colors.white,
                  onPressed: () => _showActionMenu(context),
                ),
              ),
            )
          else if (widget.onActionPressed != null)
            SizedBox(
              height: responsiveIconSize,
              width: responsiveIconSize,
              child: Semantics(
                label: 'More options',
                button: true,
                enabled: true,
                onTap: widget.onActionPressed,
                child: IconButton(
                  icon: const Icon(Icons.more_vert),
                  color: widget.config?.actionButtonColor ?? Colors.white,
                  onPressed: widget.onActionPressed,
                ),
              ),
            ),
          if (widget.onClosePressed != null)
            SizedBox(
              height: responsiveIconSize,
              width: responsiveIconSize,
              child: Semantics(
                label: 'Close story viewer',
                button: true,
                enabled: true,
                onTap: widget.onClosePressed,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  color: widget.config?.closeButtonColor ?? Colors.white,
                  onPressed: widget.onClosePressed,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
