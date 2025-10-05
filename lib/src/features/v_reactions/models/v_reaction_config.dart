import 'package:flutter/material.dart';

/// Configuration for reaction feature
@immutable
class VReactionConfig {
  const VReactionConfig({
    this.enabled = true,
    this.reactionType = '❤️',
    this.animationDuration = const Duration(milliseconds: 800),
    this.iconSize = 100.0,
    this.iconColor = Colors.red,
  });

  /// Whether reactions are enabled
  final bool enabled;

  /// Default reaction emoji/icon
  final String reactionType;

  /// Duration of the reaction animation
  final Duration animationDuration;

  /// Size of the reaction icon
  final double iconSize;

  /// Color of the reaction icon
  final Color iconColor;

  VReactionConfig copyWith({
    bool? enabled,
    String? reactionType,
    Duration? animationDuration,
    double? iconSize,
    Color? iconColor,
  }) {
    return VReactionConfig(
      enabled: enabled ?? this.enabled,
      reactionType: reactionType ?? this.reactionType,
      animationDuration: animationDuration ?? this.animationDuration,
      iconSize: iconSize ?? this.iconSize,
      iconColor: iconColor ?? this.iconColor,
    );
  }
}
