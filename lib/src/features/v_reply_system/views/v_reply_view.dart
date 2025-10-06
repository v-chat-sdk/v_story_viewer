import 'package:flutter/material.dart';

import '../../../core/callbacks/v_reply_callbacks.dart';
import '../../v_story_models/v_story_models.dart';
import '../controllers/v_reply_controller.dart';
import '../models/v_reply_config.dart';
import '../widgets/v_reply_input.dart';

/// The main view for the reply system.
class VReplyView extends StatefulWidget {
  /// Creates a new instance of [VReplyView].
  const VReplyView({
    required this.story,
    this.callbacks,
    this.config,
    super.key,
  });

  /// The story being replied to.
  final VBaseStory story;

  /// The callbacks for reply actions.
  final VReplyCallbacks? callbacks;

  /// The configuration for the reply view.
  final VReplyConfig? config;

  @override
  State<VReplyView> createState() => _VReplyViewState();
}

class _VReplyViewState extends State<VReplyView> {
  late final VReplyController _replyController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _replyController = VReplyController(
      story: widget.story,
      callbacks: widget.callbacks,
    );
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    widget.callbacks?.onFocusChanged?.call(_focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return VReplyInput(
      focusNode: _focusNode,
      config: widget.config,
      onSubmitted: (reply) {
        _replyController.sendReply(reply);
        _focusNode.unfocus();
      },
    );
  }
}
