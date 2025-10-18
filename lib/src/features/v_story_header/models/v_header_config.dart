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
    this.showPlaybackControls = false,
    this.controlButtonColor,
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
}
