import 'package:flutter/material.dart';

import 'v_story_action.dart';

/// Configuration for the story header.
class VHeaderConfig {
  /// Creates a new instance of [VHeaderConfig].
  const VHeaderConfig({
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.padding,
    this.spacing,
    this.closeButtonColor,
    this.actionButtonColor,
    this.actions,
    this.showPlaybackControls = true,
    this.controlButtonColor,
    this.showDefaultActions = true,
  });

  /// The text style for the user's name.
  final TextStyle? titleTextStyle;

  /// The text style for the story's timestamp.
  final TextStyle? subtitleTextStyle;

  /// The padding around the header.
  final EdgeInsetsGeometry? padding;

  /// The space between the avatar and the user info.
  final double? spacing;

  /// The color of the close button.
  final Color? closeButtonColor;

  /// The color of the action buttons.
  final Color? actionButtonColor;

  /// List of custom actions to display in the action menu
  final List<VStoryAction>? actions;

  /// Whether to show playback controls (pause/play and mute) in the header
  final bool showPlaybackControls;

  /// The color of playback control buttons
  final Color? controlButtonColor;

  /// Whether to show default actions (Share, Save, Report) when no custom actions provided
  final bool showDefaultActions;

  /// Get the effective actions list (custom actions or defaults)
  List<VStoryAction>? getEffectiveActions() {
    // If custom actions are provided, use them
    if (actions != null && actions!.isNotEmpty) {
      return actions;
    }
    // If showDefaultActions is enabled, return default actions
    if (showDefaultActions) {
      return _getDefaultActions();
    }
    // Otherwise return null
    return null;
  }

  /// Default actions (Share, Save, Report)
  static List<VStoryAction> _getDefaultActions() {
    return [
      VStoryAction(
        label: 'Share',
        icon: Icons.share,
        onPressed: () {
          debugPrint('Share story');
        },
      ),
      VStoryAction(
        label: 'Save',
        icon: Icons.bookmark,
        onPressed: () {
          debugPrint('Save story');
        },
      ),
      VStoryAction(
        label: 'Report',
        icon: Icons.flag,
        onPressed: () {
          debugPrint('Report story');
        },
      ),
    ];
  }
}
