import 'package:flutter/foundation.dart';

import '../../v_story_models/models/v_base_story.dart';

/// Callbacks for reaction events
class VReactionCallbacks {
  const VReactionCallbacks({
    this.onReactionSent,
    this.onReactionAnimationStart,
    this.onReactionAnimationComplete,
  });

  /// Called when a reaction is sent to a story
  final void Function(VBaseStory story, String reactionType)? onReactionSent;

  /// Called when reaction animation starts
  final VoidCallback? onReactionAnimationStart;

  /// Called when reaction animation completes
  final VoidCallback? onReactionAnimationComplete;
}
