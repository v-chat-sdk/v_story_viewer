import 'package:flutter/widgets.dart';
import 'v_story_models.dart';

/// Configuration for story reactions
class VReactionConfiguration {
  /// Callback when a reaction is sent
  final void Function(VBaseStory story) onReaction;
  
  /// Whether reactions are enabled
  final bool enabled;
  
  /// Available reaction emojis
  final List<String> availableReactions;
  
  /// Custom reaction widget builder
  final Widget Function(BuildContext context, VBaseStory story)? customReactionBuilder;
  
  /// Position of reaction UI
  final VReactionPosition position;
  
  /// Whether to show reaction animation
  final bool showAnimation;
  
  /// Animation duration
  final Duration animationDuration;
  
  /// Creates a reaction configuration
  const VReactionConfiguration({
    required this.onReaction,
    this.enabled = true,
    this.availableReactions = const ['❤️', '🔥', '👏', '😍', '😂', '😮', '😢'],
    this.customReactionBuilder,
    this.position = VReactionPosition.bottomRight,
    this.showAnimation = true,
    this.animationDuration = const Duration(milliseconds: 800),
  });
}

/// Position of reaction UI
enum VReactionPosition {
  /// Bottom left corner
  bottomLeft,
  
  /// Bottom right corner
  bottomRight,
  
  /// Bottom center
  bottomCenter,
  
  /// Custom position
  custom,
}