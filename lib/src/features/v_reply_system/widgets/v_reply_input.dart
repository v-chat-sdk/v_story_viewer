import 'package:flutter/material.dart';

import '../models/v_reply_config.dart';
import 'v_reply_send_button.dart';

/// A widget for inputting and sending a reply.
class VReplyInput extends StatefulWidget {
  /// Creates a new instance of [VReplyInput].
  const VReplyInput({
    required this.onSubmitted,
    required this.focusNode,
    this.config,
    super.key,
  });

  /// The configuration for the reply input.
  final VReplyConfig? config;

  /// A callback for when a reply is submitted.
  final void Function(String) onSubmitted;

  /// The focus node for the input field.
  final FocusNode focusNode;

  @override
  State<VReplyInput> createState() => _VReplyInputState();
}

class _VReplyInputState extends State<VReplyInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_controller.text.isNotEmpty) {
      widget.onSubmitted(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      style: widget.config?.textStyle ?? const TextStyle(color: Colors.white),
      decoration: widget.config?.inputDecoration ??
          InputDecoration(
            hintText: widget.config?.placeholderText ?? 'Send a message',
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            suffixIcon: VReplySendButton(
              onPressed: _handleSubmit,
              color: widget.config?.sendButtonColor,
            ),
          ),
      onSubmitted: (_) => _handleSubmit(),
    );
  }
}
