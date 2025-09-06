import 'dart:async';
import 'package:flutter/material.dart';
import '../models/v_story_models.dart';
import '../controllers/v_story_controller.dart';

/// Reply data model.
class VReplyData {
  /// Reply text
  final String text;
  
  /// Story being replied to
  final VBaseStory story;
  
  /// Story user
  final VStoryUser user;
  
  /// Timestamp
  final DateTime timestamp;
  
  /// Additional metadata
  final Map<String, dynamic>? metadata;
  
  /// Creates reply data
  const VReplyData({
    required this.text,
    required this.story,
    required this.user,
    required this.timestamp,
    this.metadata,
  });
  
  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'storyId': story.id,
      'userId': user.id,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// Reply system for story interactions.
class VReplySystem extends StatefulWidget {
  /// The current story
  final VBaseStory story;
  
  /// The story user
  final VStoryUser user;
  
  /// The story controller
  final VStoryController controller;
  
  /// Placeholder text
  final String placeholder;
  
  /// Input decoration
  final InputDecoration? decoration;
  
  /// Text style
  final TextStyle? textStyle;
  
  /// Send button widget
  final Widget? sendButton;
  
  /// Whether to show loading state
  final bool showLoadingState;
  
  /// Whether to show emoji button
  final bool showEmojiButton;
  
  /// Maximum reply length
  final int? maxLength;
  
  /// Called when reply is submitted
  final Future<void> Function(VReplyData reply)? onReplySubmitted;
  
  /// Called when reply field is focused
  final VoidCallback? onFocused;
  
  /// Called when reply field is unfocused
  final VoidCallback? onUnfocused;
  
  /// Called when emoji button is tapped
  final VoidCallback? onEmojiTap;
  
  /// Creates a reply system
  const VReplySystem({
    super.key,
    required this.story,
    required this.user,
    required this.controller,
    this.placeholder = 'Send a reply...',
    this.decoration,
    this.textStyle,
    this.sendButton,
    this.showLoadingState = true,
    this.showEmojiButton = false,
    this.maxLength,
    this.onReplySubmitted,
    this.onFocused,
    this.onUnfocused,
    this.onEmojiTap,
  });
  
  @override
  State<VReplySystem> createState() => _VReplySystemState();
}

class _VReplySystemState extends State<VReplySystem> {
  /// Text controller
  final TextEditingController _textController = TextEditingController();
  
  /// Focus node
  final FocusNode _focusNode = FocusNode();
  
  /// Whether reply is being sent
  bool _isSending = false;
  
  /// Error message
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    
    // Listen to focus changes
    _focusNode.addListener(_handleFocusChange);
  }
  
  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      // Pause story when focused
      widget.controller.pause();
      widget.onFocused?.call();
    } else {
      // Resume story when unfocused (unless sending)
      if (!_isSending) {
        widget.controller.play();
      }
      widget.onUnfocused?.call();
    }
  }
  
  Future<void> _handleSubmit(String text) async {
    if (text.trim().isEmpty || _isSending) return;
    
    setState(() {
      _isSending = true;
      _errorMessage = null;
    });
    
    try {
      // Create reply data
      final reply = VReplyData(
        text: text.trim(),
        story: widget.story,
        user: widget.user,
        timestamp: DateTime.now(),
      );
      
      // Submit reply
      if (widget.onReplySubmitted != null) {
        await widget.onReplySubmitted!(reply);
      }
      
      // Clear text on success
      _textController.clear();
      
      // Unfocus to resume story
      _focusNode.unfocus();
      
      // Show success feedback
      if (mounted) {
        _showFeedback('Reply sent');
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to send reply';
      });
      
      // Show error feedback
      if (mounted) {
        _showFeedback(_errorMessage!, isError: true);
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }
  
  void _showFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Input field
          Expanded(
            child: _buildInputField(),
          ),
          
          // Send button
          _buildSendButton(),
        ],
      ),
    );
  }
  
  Widget _buildInputField() {
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      style: widget.textStyle ?? const TextStyle(color: Colors.white),
      maxLength: widget.maxLength,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.send,
      decoration: widget.decoration ?? InputDecoration(
        hintText: widget.placeholder,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        counterText: '',
        errorText: _errorMessage,
        prefixIcon: widget.showEmojiButton
            ? IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined),
                color: Colors.white60,
                onPressed: widget.onEmojiTap ?? () {},
              )
            : null,
      ),
      onSubmitted: _handleSubmit,
    );
  }
  
  Widget _buildSendButton() {
    if (_isSending && widget.showLoadingState) {
      return Container(
        margin: const EdgeInsets.only(left: 8, bottom: 8),
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      );
    }
    
    return widget.sendButton ?? IconButton(
      icon: const Icon(Icons.send),
      color: Colors.white,
      onPressed: _textController.text.trim().isEmpty
          ? null
          : () => _handleSubmit(_textController.text),
    );
  }
}

/// Enhanced reply input with keyboard-safe viewport.
class VReplyInput extends StatefulWidget {
  /// The current story
  final VBaseStory story;
  
  /// The story user
  final VStoryUser user;
  
  /// The story controller
  final VStoryController controller;
  
  /// Whether to animate viewport changes
  final bool animateViewport;
  
  /// Animation duration
  final Duration animationDuration;
  
  /// Animation curve
  final Curve animationCurve;
  
  /// Padding above keyboard
  final double keyboardPadding;
  
  /// Background color
  final Color? backgroundColor;
  
  /// Reply configuration
  final VReplyConfig config;
  
  /// Called when reply is submitted
  final Future<void> Function(VReplyData reply)? onReplySubmitted;
  
  /// Creates an enhanced reply input
  const VReplyInput({
    super.key,
    required this.story,
    required this.user,
    required this.controller,
    this.animateViewport = true,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeOutCubic,
    this.keyboardPadding = 8.0,
    this.backgroundColor,
    this.config = const VReplyConfig(),
    this.onReplySubmitted,
  });
  
  @override
  State<VReplyInput> createState() => _VReplyInputState();
}

class _VReplyInputState extends State<VReplyInput>
    with SingleTickerProviderStateMixin {
  /// Animation controller for viewport changes
  late AnimationController _animationController;
  
  /// Slide animation
  late Animation<Offset> _slideAnimation;
  
  /// Keyboard visibility
  bool _isKeyboardVisible = false;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Check keyboard visibility
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isVisible = keyboardHeight > 0;
    
    if (isVisible != _isKeyboardVisible) {
      _isKeyboardVisible = isVisible;
      
      if (widget.animateViewport) {
        if (isVisible) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final child = Container(
      color: widget.backgroundColor ?? Colors.black.withValues(alpha: 0.3),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: widget.keyboardPadding,
        bottom: widget.keyboardPadding + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: VReplySystem(
        story: widget.story,
        user: widget.user,
        controller: widget.controller,
        placeholder: widget.config.placeholder,
        decoration: widget.config.decoration,
        textStyle: widget.config.textStyle,
        sendButton: widget.config.sendButton,
        showLoadingState: widget.config.showLoadingState,
        showEmojiButton: widget.config.showEmojiButton,
        maxLength: widget.config.maxLength,
        onReplySubmitted: widget.onReplySubmitted,
      ),
    );
    
    if (widget.animateViewport) {
      return SlideTransition(
        position: _slideAnimation,
        child: child,
      );
    }
    
    return child;
  }
}

/// Reply configuration.
class VReplyConfig {
  /// Placeholder text
  final String placeholder;
  
  /// Input decoration
  final InputDecoration? decoration;
  
  /// Text style
  final TextStyle? textStyle;
  
  /// Send button widget
  final Widget? sendButton;
  
  /// Whether to show loading state
  final bool showLoadingState;
  
  /// Whether to show emoji button
  final bool showEmojiButton;
  
  /// Maximum reply length
  final int? maxLength;
  
  /// Whether to enable reply
  final bool enableReply;
  
  /// Creates a reply configuration
  const VReplyConfig({
    this.placeholder = 'Send a reply...',
    this.decoration,
    this.textStyle,
    this.sendButton,
    this.showLoadingState = true,
    this.showEmojiButton = false,
    this.maxLength,
    this.enableReply = true,
  });
  
  /// Creates a minimal configuration
  factory VReplyConfig.minimal() => const VReplyConfig(
    showLoadingState: false,
    showEmojiButton: false,
  );
  
  /// Creates a rich configuration
  factory VReplyConfig.rich() => const VReplyConfig(
    showLoadingState: true,
    showEmojiButton: true,
    maxLength: 500,
  );
}

/// Reply state indicator.
class VReplyStateIndicator extends StatelessWidget {
  /// Reply state
  final VReplyState state;
  
  /// Error message
  final String? errorMessage;
  
  /// Retry callback
  final VoidCallback? onRetry;
  
  /// Creates a reply state indicator
  const VReplyStateIndicator({
    super.key,
    required this.state,
    this.errorMessage,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    switch (state) {
      case VReplyState.idle:
        return const SizedBox.shrink();
        
      case VReplyState.sending:
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        );
        
      case VReplyState.success:
        return const Center(
          child: Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 24,
          ),
        );
        
      case VReplyState.error:
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error,
                color: Colors.red,
                size: 20,
              ),
              if (errorMessage != null) ...[
                const SizedBox(width: 8),
                Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onRetry,
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
    }
  }
}

/// Reply state enum.
enum VReplyState {
  idle,
  sending,
  success,
  error,
}