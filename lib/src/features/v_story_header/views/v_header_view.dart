import 'package:flutter/material.dart';
import '../../v_story_models/models/v_story_user.dart';
import '../models/v_header_config.dart';
import '../widgets/v_header_container.dart';
import '../widgets/v_timestamp.dart';
import '../widgets/v_user_avatar.dart';
import '../widgets/v_user_info.dart';

/// The view for the story header.
class VHeaderView extends StatelessWidget {
  /// Creates a new instance of [VHeaderView].
  const VHeaderView({
    required this.user,
    required this.createdAt,
    this.config,
    this.onClosePressed,
    this.onActionPressed,
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

  @override
  Widget build(BuildContext context) {
    return VHeaderContainer(
      padding: config?.padding,
      child: Row(
        children: [
          VUserAvatar(
            avatarUrl: user.profilePicture,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VUserInfo(
                  user: user,
                  textStyle: config?.titleTextStyle,
                ),
                VTimestamp(
                  createdAt: createdAt,
                  textStyle: config?.subtitleTextStyle,
                ),
              ],
            ),
          ),
          if (onActionPressed != null)
            IconButton(
              icon: const Icon(Icons.more_vert),
              color: config?.actionButtonColor ?? Colors.white,
              onPressed: onActionPressed,
            ),
          if (onClosePressed != null)
            IconButton(
              icon: const Icon(Icons.close),
              color: config?.closeButtonColor ?? Colors.white,
              onPressed: onClosePressed,
            ),
        ],
      ),
    );
  }
}
