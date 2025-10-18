import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A widget that provides a blur overlay when reply input is focused
/// This creates a focused mode for typing replies with the story paused
/// Only active on web platform to resolve keyboard conflicts
class VReplyOverlay extends StatefulWidget {
  /// Creates a new instance of [VReplyOverlay].
  const VReplyOverlay({
    required this.storyContent,
    required this.replyWidget,
    required this.focusNode,
    this.blurAmount = 3.0,
    this.overlayOpacity = 0.15,
    this.enableOverlay = true,
    super.key,
  });

  /// The story content widget to be displayed under the overlay
  final Widget storyContent;

  /// The reply input widget that stays on top of the overlay
  final Widget replyWidget;

  /// The focus node to monitor for showing/hiding the overlay
  final FocusNode focusNode;

  /// The amount of blur to apply when focused
  final double blurAmount;

  /// The opacity of the dark overlay when focused
  final double overlayOpacity;

  /// Whether to enable the overlay (useful for platform-specific behavior)
  final bool enableOverlay;

  @override
  State<VReplyOverlay> createState() => _VReplyOverlayState();
}

class _VReplyOverlayState extends State<VReplyOverlay> {
  bool _isFocused = false;

  // Only enable on web platform
  bool get _shouldEnableOverlay => widget.enableOverlay && kIsWeb;

  @override
  void initState() {
    super.initState();
    if (_shouldEnableOverlay) {
      widget.focusNode.addListener(_onFocusChange);
      _isFocused = widget.focusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    if (_shouldEnableOverlay) {
      widget.focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (!_shouldEnableOverlay) return;
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
  }

  void _handleOverlayTap() {
    widget.focusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // If overlay is disabled or not focused, just show the normal layout
    if (!_shouldEnableOverlay || !_isFocused) {
      return Column(
        children: [
          Expanded(child: widget.storyContent),
          widget.replyWidget,
        ],
      );
    }

    // Web platform with overlay when focused
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Story content with blur effect
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: widget.blurAmount,
                    sigmaY: widget.blurAmount,
                  ),
                  child: widget.storyContent,
                ),
              ),

              // Dark overlay with tap detection
              GestureDetector(
                onTap: _handleOverlayTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: Colors.black.withValues(alpha: widget.overlayOpacity),
                ),
              ),
            ],
          ),
        ),

        // Reply widget stays on top, not affected by blur
        widget.replyWidget,
      ],
    );
  }
}
