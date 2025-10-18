import 'package:flutter/material.dart';

/// Represents a single action in the story action menu
class VStoryAction {
  /// Creates a new story action
  const VStoryAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.textColor,
    this.iconColor,
    this.backgroundColor,
  });

  /// The label text for the action
  final String label;

  /// The icon to display
  final IconData icon;

  /// Callback when action is selected
  final VoidCallback onPressed;

  /// Text color for the action
  final Color? textColor;

  /// Icon color for the action
  final Color? iconColor;

  /// Background color for the action
  final Color? backgroundColor;
}
