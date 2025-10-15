import 'package:flutter/material.dart';

import '../../v_reactions/controllers/v_reaction_controller.dart';
import '../models/v_story_viewer_callbacks.dart';
import '../models/v_story_viewer_config.dart';

/// Centralizes gesture event handling
///
/// Coordinates gestures with navigation, pause/resume, and reactions.
class VStoryGestureHandler {
  VStoryGestureHandler({
    required VStoryViewerConfig config,
    required VReactionController reactionController,
    required this.onTapPrevious,
    required this.onTapNext,
    required this.onPauseStory,
    required this.onResumeStory,
    VStoryViewerCallbacks? callbacks,
  })  : _config = config,
        _reactionController = reactionController,
        _callbacks = callbacks;

  final VStoryViewerConfig _config;
  final VReactionController _reactionController;
  final VStoryViewerCallbacks? _callbacks;
  final VoidCallback onTapPrevious;
  final VoidCallback onTapNext;
  final VoidCallback onPauseStory;
  final VoidCallback onResumeStory;

  void handleTapPrevious() => onTapPrevious();

  void handleTapNext() => onTapNext();

  void handleLongPressStart() {
    if (!_config.pauseOnLongPress) return;
    onPauseStory();
  }

  void handleLongPressEnd() {
    if (!_config.pauseOnLongPress) return;
    onResumeStory();
  }

  void handleSwipeDown(BuildContext context) {
    if (!_config.dismissOnSwipeDown) return;
    _callbacks?.onDismiss?.call();
    Navigator.of(context).pop();
  }

  void handleDoubleTap() {
    _reactionController.triggerReaction();
  }

  void handleReplyFocusChanged(bool isFocused) {
    if (isFocused) {
      onPauseStory();
    } else {
      onResumeStory();
    }
  }
}
