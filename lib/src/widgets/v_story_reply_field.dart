import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../models/v_story_texts.dart';

/// Reply text field for story viewer with optional emoji picker
class VStoryReplyField extends StatefulWidget {
  final void Function(String text) onSubmit;
  final VStoryTexts texts;
  final bool showEmojiButton;
  final VoidCallback? onFocus;
  final VoidCallback? onUnfocus;
  const VStoryReplyField({
    super.key,
    required this.onSubmit,
    this.texts = const VStoryTexts(),
    this.showEmojiButton = true,
    this.onFocus,
    this.onUnfocus,
  });
  @override
  State<VStoryReplyField> createState() => _VStoryReplyFieldState();
}

class _VStoryReplyFieldState extends State<VStoryReplyField> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  bool _isEmojiPickerVisible = false;
  Timer? _debounceTimer;
  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      if (_isEmojiPickerVisible) {
        setState(() => _isEmojiPickerVisible = false);
      }
      // Defer callback to next frame to let focus stabilize before parent rebuild
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNode.hasFocus) {
          widget.onFocus?.call();
        }
      });
    } else {
      widget.onUnfocus?.call();
    }
  }

  void _toggleEmojiPicker() {
    if (_isEmojiPickerVisible) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      setState(() => _isEmojiPickerVisible = true);
      widget.onFocus?.call();
    }
  }

  void _onEmojiSelected(Category? category, Emoji emoji) {
    final text = _textController.text;
    final selection = _textController.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final newText = text.replaceRange(start, end, emoji.emoji);
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + emoji.emoji.length),
    );
  }

  void _onBackspacePressed() {
    final text = _textController.text;
    final selection = _textController.selection;
    if (text.isEmpty || !selection.isValid || selection.start == 0) return;
    final start = selection.start;
    final end = selection.end;
    if (start == end) {
      final codeUnits = text.codeUnits;
      int deleteCount = 1;
      if (start >= 2) {
        final lastTwo = codeUnits.sublist(start - 2, start);
        if (_isSurrogatePair(lastTwo[0], lastTwo[1])) {
          deleteCount = 2;
        }
      }
      final newText =
          text.substring(0, start - deleteCount) + text.substring(end);
      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start - deleteCount),
      );
    } else {
      final newText = text.substring(0, start) + text.substring(end);
      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start),
      );
    }
  }

  bool _isSurrogatePair(int high, int low) {
    return high >= 0xD800 && high <= 0xDBFF && low >= 0xDC00 && low <= 0xDFFF;
  }

  void _hideEmojiPicker() {
    if (_isEmojiPickerVisible) {
      setState(() => _isEmojiPickerVisible = false);
      widget.onUnfocus?.call();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmit(text);
      _textController.clear();
      _focusNode.unfocus();
      _hideEmojiPicker();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInputRow(),
        if (_isEmojiPickerVisible) _buildEmojiPicker(),
      ],
    );
  }

  Widget _buildInputRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Row(
        children: [
          if (widget.showEmojiButton)
            IconButton(
              icon: Icon(
                _isEmojiPickerVisible
                    ? Icons.keyboard_outlined
                    : Icons.emoji_emotions_outlined,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              tooltip: _isEmojiPickerVisible
                  ? widget.texts.keyboardLabel
                  : widget.texts.emojiLabel,
              onPressed: _toggleEmojiPicker,
            ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: widget.texts.replyHint,
                  hintStyle:
                      TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _submit(),
                onTap: _hideEmojiPicker,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _hasText ? _submit : null,
            tooltip: widget.texts.sendLabel,
            icon: Icon(
              CupertinoIcons.paperplane_fill,
              color:
                  _hasText ? Colors.white : Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 280,
      child: EmojiPicker(
        onEmojiSelected: _onEmojiSelected,
        onBackspacePressed: _onBackspacePressed,
        config: Config(
          height: 280,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            columns: 8,
            emojiSizeMax:
                28 * (defaultTargetPlatform == TargetPlatform.iOS ? 1.2 : 1.0),
            verticalSpacing: 0,
            horizontalSpacing: 0,
            gridPadding: EdgeInsets.zero,
            backgroundColor: const Color(0xFF1F1F1F),
            noRecents: Text(
              widget.texts.noRecentEmojis,
              style: const TextStyle(fontSize: 16, color: Colors.white54),
            ),
            loadingIndicator: const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            ),
            buttonMode: ButtonMode.MATERIAL,
            recentsLimit: 28,
          ),
          categoryViewConfig: const CategoryViewConfig(
            initCategory: Category.RECENT,
            backgroundColor: Color(0xFF1F1F1F),
            indicatorColor: Colors.green,
            iconColor: Colors.grey,
            iconColorSelected: Colors.green,
            tabBarHeight: 46,
          ),
          bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
          searchViewConfig: SearchViewConfig(
            backgroundColor: const Color(0xFF1F1F1F),
            buttonIconColor: Colors.white54,
            hintText: widget.texts.searchEmoji,
          ),
          skinToneConfig: const SkinToneConfig(
            enabled: true,
            dialogBackgroundColor: Color(0xFF2D2D2D),
            indicatorColor: Colors.green,
          ),
        ),
      ),
    );
  }
}
