import 'package:flutter/foundation.dart';

import '../../features/v_story_models/v_story_models.dart';

/// Callbacks for handling reply actions in the story viewer.
@immutable
class VReplyCallbacks {
  /// Creates a new instance of [VReplyCallbacks].
  const VReplyCallbacks({this.onReplySubmitted, this.onFocusChanged});

  /// Called when the user submits a reply.
  ///
  /// The callback provides the story being replied to and the reply text.
  /// Returns a `Future<bool>` to indicate if the reply was sent successfully.
  final Future<bool> Function(VBaseStory story, String reply)? onReplySubmitted;

  /// Called when the focus of the reply input field changes.
  ///
  /// The `isFocused` parameter is `true` when the input field gains focus
  /// and `false` when it loses focus.
  final void Function(bool isFocused)? onFocusChanged;
}
