import 'package:flutter/material.dart';

import '../models/v_reply_config.dart';
import 'v_reply_send_button.dart';

/// A widget for inputting and sending a reply.
class VReplyInput extends StatefulWidget {
  /// Creates a new instance of [VReplyInput].
  const VReplyInput({
    required this.onSubmitted,
    required this.focusNode,
    required this.onChanged,
    this.config,
    super.key,
  });

  /// The configuration for the reply input.
  final VReplyConfig? config;

  /// A callback for when a reply is submitted.
  final void Function(String txt) onSubmitted;
  final void Function(String txt) onChanged;

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
      child: Row(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: widget.focusNode,
                onChanged: widget.onChanged,
                style: widget.config?.textStyle ??
                    const TextStyle(color: Colors.white, fontSize: 16),
                decoration: widget.config?.inputDecoration ??
                    InputDecoration(
                      hintText: widget.config?.placeholderText ?? 'Send a message',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                onSubmitted: (_) => _handleSubmit(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          VReplySendButton(
            onPressed: _handleSubmit,
            color: widget.config?.sendButtonColor,
          ),
        ],
      ),
    );
  }
}
