import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../../v_theme_system/models/v_responsive_utils.dart';
import '../models/v_reply_config.dart';
import 'v_reply_close_button.dart';
import 'v_reply_emoji_button.dart';
import 'v_reply_send_button.dart';

/// A widget for inputting and sending a reply with emoji picker support.
class VReplyInput extends StatefulWidget {
  /// Creates a new instance of [VReplyInput].
  const VReplyInput({
    required this.onSubmitted,
    required this.focusNode,
    required this.maxContentWidth,
    this.config,
    super.key,
  });

  /// The configuration for the reply input.
  final VReplyConfig? config;

  /// A callback for when a reply is submitted.
  final void Function(String txt) onSubmitted;

  /// The focus node for the input field.
  final FocusNode focusNode;

  /// The maximum width for the content.
  final double maxContentWidth;

  @override
  State<VReplyInput> createState() => _VReplyInputState();
}

class _VReplyInputState extends State<VReplyInput> {
  late final TextEditingController _controller;
  bool _showEmojiPicker = false;
  double _inputHeight = 48;
  static const double _minHeight = 48;
  static const double _maxHeight = 140;
  static const int _maxLines = 4;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_updateInputHeight);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_updateInputHeight)
      ..dispose();
    super.dispose();
  }

  void _updateInputHeight() {
    final lines = _controller.text.split('\n').length;
    final newHeight = _minHeight + (lines - 1) * 24.0;
    final constrainedHeight = newHeight.clamp(_minHeight, _maxHeight);
    if (_inputHeight != constrainedHeight) {
      setState(() {
        _inputHeight = constrainedHeight;
      });
    }
  }

  void _handleSubmit() {
    if (_controller.text.isNotEmpty) {
      widget.onSubmitted(_controller.text);
      _controller.clear();
      _updateInputHeight();
      FocusScope.of(context).unfocus();
    }
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
      if (_showEmojiPicker) {
        widget.focusNode.unfocus();
      } else {
        widget.focusNode.requestFocus();
      }
    });
  }

  Config _buildEmojiPickerConfig(BuildContext context, bool isDarkMode) {
    if (isDarkMode) {
      return Config(
        emojiViewConfig: EmojiViewConfig(
          noRecents: Text(
            'No recent emojis',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ),
        categoryViewConfig: CategoryViewConfig(
          backgroundColor: const Color(0xFF000000),
          iconColorSelected: Colors.white,
          iconColor: Colors.white.withValues(alpha: 0.5),
          backspaceColor: Colors.white.withValues(alpha: 0.5),
          indicatorColor: Colors.white,
          dividerColor: Colors.white.withValues(alpha: 0.1),
        ),
        bottomActionBarConfig: BottomActionBarConfig(
          backgroundColor: const Color(0xFF000000),
        ),
      );
    } else {
      return Config(
        emojiViewConfig: EmojiViewConfig(
          noRecents: Text(
            'No recent emojis',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ),

        categoryViewConfig: CategoryViewConfig(
          backgroundColor: const Color(0xFFF5F5F5),
          iconColorSelected: Colors.black,
          iconColor: Colors.black.withValues(alpha: 0.5),
          backspaceColor: Colors.black.withValues(alpha: 0.6),
          indicatorColor: Colors.black,
          dividerColor: Colors.black.withValues(alpha: 0.1),
        ),
        bottomActionBarConfig: BottomActionBarConfig(
          backgroundColor: const Color(0xFFF5F5F5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = VResponsiveUtils.isDarkMode(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // Calculate maximum available height for emoji picker
    // Reserve space for input and keyboard
    final availableHeightForEmoji = _showEmojiPicker
        ? (screenHeight - _inputHeight - 100 - bottomInset).clamp(150.0, 280.0)
        : 0.0;

    // Add bottom padding when emoji picker is shown to prevent overflow
    final bottomPadding = _showEmojiPicker ? 16.0 : 24.0;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxContentWidth),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          reverse: true,
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(12, 16, 12, bottomPadding),
                child: Row(
                  children: [
                    if (_showEmojiPicker)
                      VReplyCloseButton(onPressed: _toggleEmojiPicker),
                    if (_showEmojiPicker) const SizedBox(width: 8),
                    VReplyEmojiButton(
                      onPressed: _toggleEmojiPicker,
                      isEmojiPickerOpen: _showEmojiPicker,
                    ),
                    const SizedBox(width: 8),
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
                        child: SizedBox(
                          height: _inputHeight,
                          child: TextField(
                            controller: _controller,
                            focusNode: widget.focusNode,
                            maxLines: _maxLines,
                            minLines: 1,
                            textCapitalization: TextCapitalization.sentences,
                            style:
                                widget.config?.textStyle ??
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                            decoration:
                                widget.config?.inputDecoration ??
                                InputDecoration(
                                  hintText:
                                      widget.config?.placeholderText ??
                                      'Send a message',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 16,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                            onSubmitted: (_) => _handleSubmit(),
                            onChanged: (_) => _updateInputHeight(),
                          ),
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
              ),
              if (_showEmojiPicker)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: availableHeightForEmoji,
                    minHeight: availableHeightForEmoji,
                  ),
                  child: EmojiPicker(
                    onBackspacePressed: () {
                      _controller.text = _controller.text.characters
                          .skipLast(1)
                          .string;
                      _updateInputHeight();
                    },
                    textEditingController: _controller,
                    config: Config(
                      emojiViewConfig: EmojiViewConfig(
                        backgroundColor: isDarkMode
                            ? Colors.black
                            : Colors.white,
                      ),
                      categoryViewConfig: CategoryViewConfig(
                        backgroundColor: isDarkMode
                            ? Colors.black
                            : Colors.white,
                        indicatorColor: isDarkMode
                            ? Colors.white
                            : Colors.black,
                        iconColor: isDarkMode ? Colors.white : Colors.black,
                        iconColorSelected: isDarkMode
                            ? Colors.blueAccent
                            : Colors.blue,
                      ),
                      bottomActionBarConfig: BottomActionBarConfig(
                        backgroundColor: isDarkMode
                            ? Colors.black
                            : Colors.white,
                        buttonIconColor: isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                      searchViewConfig: SearchViewConfig(
                        backgroundColor: isDarkMode
                            ? Colors.black
                            : Colors.white,
                        buttonIconColor: isDarkMode
                            ? Colors.white
                            : Colors.black,
                        hintText: 'Search',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
