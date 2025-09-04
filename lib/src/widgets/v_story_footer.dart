import 'package:flutter/material.dart';
import '../models/v_story_models.dart';
import '../controllers/v_story_controller.dart';
import 'v_reply_system.dart';

/// Footer widget for story viewer with reply and action options.
class VStoryFooter extends StatelessWidget {
  /// The current story
  final VBaseStory story;
  
  /// The story controller
  final VStoryController controller;
  
  /// The story user
  final VStoryUser? user;
  
  /// Whether to show reply field
  final bool showReplyField;
  
  /// Whether to show share button
  final bool showShareButton;
  
  /// Placeholder text for reply field
  final String replyPlaceholder;
  
  /// Called when reply is submitted
  final Future<void> Function(VReplyData reply)? onReplySubmitted;
  
  /// Whether to use enhanced reply system
  final bool useEnhancedReply;
  
  /// Called when share button is tapped
  final VoidCallback? onShare;
  
  /// Reply field decoration
  final InputDecoration? replyDecoration;
  
  /// Creates a story footer
  const VStoryFooter({
    super.key,
    required this.story,
    required this.controller,
    this.user,
    this.showReplyField = true,
    this.showShareButton = true,
    this.replyPlaceholder = 'Send a reply...',
    this.onReplySubmitted,
    this.useEnhancedReply = true,
    this.onShare,
    this.replyDecoration,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Reply field
          if (showReplyField)
            Expanded(
              child: _buildReplyField(context),
            ),
          
          // Share button
          if (showShareButton) ...[
            if (showReplyField) const SizedBox(width: 12),
            _buildShareButton(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildReplyField(BuildContext context) {
    // Use enhanced reply system if enabled and user is provided
    if (useEnhancedReply && user != null) {
      return VReplySystem(
        story: story,
        user: user!,
        controller: controller,
        placeholder: replyPlaceholder,
        decoration: replyDecoration,
        onReplySubmitted: onReplySubmitted,
      );
    }
    
    // Fallback to simple text field
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: replyDecoration ?? InputDecoration(
        hintText: replyPlaceholder,
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
      ),
      onTap: () {
        // Pause story when reply field is focused
        controller.pause();
      },
      onSubmitted: (text) async {
        if (text.trim().isNotEmpty && user != null) {
          final reply = VReplyData(
            text: text.trim(),
            story: story,
            user: user!,
            timestamp: DateTime.now(),
          );
          await onReplySubmitted?.call(reply);
          // Resume story after reply
          controller.play();
        }
      },
    );
  }
  
  Widget _buildShareButton() {
    return IconButton(
      icon: const Icon(Icons.share_outlined, color: Colors.white),
      onPressed: onShare,
    );
  }
}

/// Quick reaction bar for story reactions.
class VStoryReactionBar extends StatelessWidget {
  /// The current story
  final VBaseStory story;
  
  /// Available reactions
  final List<VReaction> reactions;
  
  /// Called when a reaction is selected
  final void Function(VReaction reaction)? onReactionSelected;
  
  /// Creates a story reaction bar
  const VStoryReactionBar({
    super.key,
    required this.story,
    this.reactions = const [
      VReaction(emoji: '❤️', name: 'love'),
      VReaction(emoji: '😂', name: 'laugh'),
      VReaction(emoji: '😮', name: 'wow'),
      VReaction(emoji: '😢', name: 'sad'),
      VReaction(emoji: '🔥', name: 'fire'),
    ],
    this.onReactionSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: reactions.map((reaction) {
          return _buildReactionButton(reaction);
        }).toList(),
      ),
    );
  }
  
  Widget _buildReactionButton(VReaction reaction) {
    return InkWell(
      onTap: () => onReactionSelected?.call(reaction),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Text(
          reaction.emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

/// Reaction model
class VReaction {
  /// Emoji for the reaction
  final String emoji;
  
  /// Name of the reaction
  final String name;
  
  /// Creates a reaction
  const VReaction({
    required this.emoji,
    required this.name,
  });
}

/// Minimal footer with just navigation hints.
class VMinimalStoryFooter extends StatelessWidget {
  /// Whether to show navigation hints
  final bool showNavigationHints;
  
  /// Creates a minimal story footer
  const VMinimalStoryFooter({
    super.key,
    this.showNavigationHints = true,
  });
  
  @override
  Widget build(BuildContext context) {
    if (!showNavigationHints) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHint(Icons.chevron_left, 'Previous'),
          _buildHint(Icons.pause, 'Pause'),
          _buildHint(Icons.chevron_right, 'Next'),
        ],
      ),
    );
  }
  
  Widget _buildHint(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.5),
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Custom footer with flexible layout.
class VCustomStoryFooter extends StatelessWidget {
  /// Leading widget
  final Widget? leading;
  
  /// Center widget
  final Widget? center;
  
  /// Trailing widget
  final Widget? trailing;
  
  /// Background color
  final Color? backgroundColor;
  
  /// Padding
  final EdgeInsets padding;
  
  /// Creates a custom story footer
  const VCustomStoryFooter({
    super.key,
    this.leading,
    this.center,
    this.trailing,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: padding,
      child: Row(
        children: [
          if (leading != null) leading!,
          if (center != null) ...[
            Expanded(child: Center(child: center!)),
          ] else ...[
            const Spacer(),
          ],
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}