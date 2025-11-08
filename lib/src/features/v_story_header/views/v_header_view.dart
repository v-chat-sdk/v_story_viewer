import 'package:flutter/material.dart';

import '../../v_localization/providers/v_localization_provider.dart';
import '../../v_media_viewer/controllers/v_base_media_controller.dart';
import '../../v_media_viewer/controllers/v_video_controller.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_story_user.dart';
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

  List<Widget> _buildTrailingActions(BuildContext context) {
    final localization = VLocalizationProvider.maybeOf(context);
    final trailing = <Widget>[];
    if (widget.config?.showPlaybackControls ?? true) {
      if (_isVideoStory()) {
        trailing.add(
          Semantics(
            label: _isMuted
                ? (localization?.tooltipUnmuteVideo ?? 'Unmute video')
                : (localization?.tooltipMuteVideo ?? 'Mute video'),
            button: true,
            enabled: true,
            onTap: widget.onMutePressed,
            child: IconButton(
              icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
              color: widget.config?.controlButtonColor ?? Colors.white,
              onPressed: widget.onMutePressed,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ),
        );
      }
    }
    if (widget.config?.getEffectiveActions() != null &&
        widget.config!.getEffectiveActions().isNotEmpty) {
      trailing.add(
        Semantics(
          label: localization?.tooltipMoreOptions ?? 'More options',
          button: true,
          enabled: true,
          onTap: () => _showActionMenu(context),
          child: IconButton(
            key: _actionButtonKey,
            icon: const Icon(Icons.more_vert),
            color: widget.config?.actionButtonColor ?? Colors.white,
            onPressed: () => _showActionMenu(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ),
      );
    } else if (widget.onActionPressed != null) {
      trailing.add(
        Semantics(
          label: localization?.tooltipMoreOptions ?? 'More options',
          button: true,
          enabled: true,
          onTap: widget.onActionPressed,
          child: IconButton(
            icon: const Icon(Icons.more_vert),
            color: widget.config?.actionButtonColor ?? Colors.white,
            onPressed: widget.onActionPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ),
      );
    }
    if (widget.onClosePressed != null) {
      trailing.add(
        Semantics(
          label: localization?.tooltipCloseViewer ?? 'Close story viewer',
          button: true,
          enabled: true,
          onTap: widget.onClosePressed,
          child: IconButton(
            icon: const Icon(Icons.close),
            color: widget.config?.closeButtonColor ?? Colors.white,
            onPressed: widget.onClosePressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ),
      );
    }
    return trailing;
  }

  double _getTrailingWidth() {
    var buttonCount = 0;
    if (widget.config?.showPlaybackControls ?? true) {
      if (_isVideoStory()) buttonCount++;
    }
    if (widget.config?.getEffectiveActions() != null &&
        widget.config!.getEffectiveActions().isNotEmpty) {
      buttonCount++;
    } else if (widget.onActionPressed != null) {
      buttonCount++;
    }
    if (widget.onClosePressed != null) {
      buttonCount++;
    }
    return buttonCount * 48.0;
  }

  @override
  Widget build(BuildContext context) {
    return VHeaderContainer(
      padding: widget.config?.padding,
      child: ListTile(
        onTap: widget.onHeaderTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: VUserAvatar(avatarUrl: widget.user.profilePicture),
        title: VUserInfo(
          user: widget.user,
          textStyle: widget.config?.titleTextStyle,
        ),
        subtitle: VTimestamp(
          createdAt: widget.createdAt,
          textStyle: widget.config?.subtitleTextStyle,
        ),
        trailing: SizedBox(
          width: _getTrailingWidth(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: _buildTrailingActions(context),
          ),
        ),
      ),
    );
  }
}
