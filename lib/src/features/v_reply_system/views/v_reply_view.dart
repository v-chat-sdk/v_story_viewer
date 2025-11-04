import 'package:flutter/material.dart';

import '../../../core/callbacks/v_reply_callbacks.dart';
import '../../../core/models/v_story_events.dart';
import '../../v_story_models/v_story_models.dart';
import '../../v_story_viewer/utils/v_story_event_manager.dart';
import '../controllers/v_reply_controller.dart';
import '../models/v_reply_config.dart';
import '../widgets/v_reply_input.dart';

/// The main view for the reply system.
/// Focus changes are emitted as events for story pause/resume coordination.
class VReplyView extends StatefulWidget {
  /// Creates a new instance of [VReplyView].
  const VReplyView({
    required this.story,
    required this.replyTextFieldFocusNode,
    required this.maxContentWidth,
    this.callbacks,
    this.config,
    super.key,
  });

  /// The story being replied to.
  final VBaseStory story;
  final FocusNode replyTextFieldFocusNode;
  final double maxContentWidth;

  /// The callbacks for reply actions.
  final VReplyCallbacks? callbacks;

  /// The configuration for the reply view.
  final VReplyConfig? config;

  @override
  State<VReplyView> createState() => _VReplyViewState();
}

class _VReplyViewState extends State<VReplyView> {
  late final VReplyController _replyController;

  @override
  void initState() {
    super.initState();
    _replyController = VReplyController(
      story: widget.story,
      callbacks: widget.callbacks,
    );
    widget.replyTextFieldFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.replyTextFieldFocusNode.removeListener(_onFocusChange);
    _replyController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    VStoryEventManager.instance.enqueue(
      VReplyFocusChangedEvent(
        hasFocus: widget.replyTextFieldFocusNode.hasFocus,
        story: widget.story,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VReplyInput(
      focusNode: widget.replyTextFieldFocusNode,
      config: widget.config,
      maxContentWidth: widget.maxContentWidth,
      onSubmitted: (reply) {
        _replyController.sendReply(reply);
        widget.replyTextFieldFocusNode.unfocus();
      },
    );
  }
}
