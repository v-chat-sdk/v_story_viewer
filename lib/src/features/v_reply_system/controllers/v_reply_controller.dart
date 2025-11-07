import 'package:flutter/foundation.dart';

import '../../../core/callbacks/v_reply_callbacks.dart';
import '../../v_story_models/v_story_models.dart';
import 'v_reply_state_controller.dart';

/// The main controller for the reply system.
class VReplyController extends ChangeNotifier {
  /// Creates a new instance of [VReplyController].
  VReplyController({required this.story, this.callbacks})
    : stateController = VReplyStateController();

  /// The state controller for the reply UI.
  final VReplyStateController stateController;

  /// The callbacks for reply actions.
  final VReplyCallbacks? callbacks;

  /// The story being replied to.
  final VBaseStory story;

  bool _isDisposed = false;
  bool _isFocused = false;

  /// Whether the reply input is currently focused
  bool get isFocused => _isFocused;

  /// Updates the focus state
  void setFocusState(bool focused) {
    if (_isFocused != focused) {
      _isFocused = focused;
      notifyListeners();
    }
  }

  /// Sends a reply.
  Future<void> sendReply(String reply) async {
    if (callbacks?.onReplySubmitted == null) return;
    stateController.setSending();
    final success = await callbacks!.onReplySubmitted!(story, reply);
    if (success) {
      stateController.setSuccess();
    } else {
      stateController.setError();
    }
    Future.delayed(const Duration(seconds: 2), () {
      if (!_isDisposed) {
        stateController.reset();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    stateController.dispose();
    super.dispose();
  }
}
