import 'package:flutter/foundation.dart';

import '../../../core/callbacks/v_reply_callbacks.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_story_group.dart';

/// Callbacks for story viewer events
///
/// These callbacks allow parent widgets to respond to viewer events.
@immutable
class VStoryViewerCallbacks {
  const VStoryViewerCallbacks({
    this.onStoryChanged,
    this.onGroupChanged,
    this.onComplete,
    this.onDismiss,
    this.onError,
    this.replyCallbacks,
  });

  /// Called when current story changes
  final void Function(VStoryGroup group, VBaseStory story, int storyIndex)?
      onStoryChanged;

  /// Called when current group changes
  final void Function(VStoryGroup group, int groupIndex)? onGroupChanged;

  /// Called when all stories in all groups are completed
  final VoidCallback? onComplete;

  /// Called when user dismisses the viewer
  final VoidCallback? onDismiss;

  /// Called when an error occurs
  final void Function(String error)? onError;

  /// Callbacks for reply actions
  final VReplyCallbacks? replyCallbacks;

  /// Empty callbacks instance
  static const empty = VStoryViewerCallbacks();
}
