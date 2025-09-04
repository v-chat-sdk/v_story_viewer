import 'dart:io';
import 'package:flutter/material.dart';
import '../models/v_story_models.dart';
import 'v_story_actions.dart';

/// Header widget for story viewer displaying user info and actions.
class VStoryHeader extends StatelessWidget {
  /// The story user
  final VStoryUser user;
  
  /// The current story
  final VBaseStory story;
  
  /// Called when close button is tapped
  final VoidCallback? onClose;
  
  /// Called when more button is tapped
  final VoidCallback? onMore;
  
  /// Story actions for the menu
  final List<VStoryAction>? storyActions;
  
  /// Called when an action is selected
  final void Function(VStoryAction action, VBaseStory story)? onActionSelected;
  
  /// Whether to show close button
  final bool showCloseButton;
  
  /// Whether to show more button
  final bool showMoreButton;
  
  /// Text style for username
  final TextStyle? usernameStyle;
  
  /// Text style for timestamp
  final TextStyle? timestampStyle;
  
  /// Creates a story header
  const VStoryHeader({
    super.key,
    required this.user,
    required this.story,
    this.onClose,
    this.onMore,
    this.storyActions,
    this.onActionSelected,
    this.showCloseButton = true,
    this.showMoreButton = true,
    this.usernameStyle,
    this.timestampStyle,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // User avatar
          _buildAvatar(),
          const SizedBox(width: 12),
          
          // User info
          Expanded(
            child: _buildUserInfo(context),
          ),
          
          // Action buttons
          if (showMoreButton)
            _buildMoreButton(),
          if (showCloseButton)
            _buildCloseButton(),
        ],
      ),
    );
  }
  
  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: _buildAvatarImage(),
      ),
    );
  }
  
  Widget _buildAvatarImage() {
    if (user.avatarUrl != null) {
      return Image.network(
        user.avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(),
      );
    } else if (user.avatarAsset != null) {
      return Image.asset(
        user.avatarAsset!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(),
      );
    } else if (user.avatarFile != null && user.avatarFile!.fileLocalPath != null) {
      return Image.file(
        File(user.avatarFile!.fileLocalPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(),
      );
    } else {
      return _buildAvatarPlaceholder();
    }
  }
  
  Widget _buildAvatarPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildUserInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Username
        Text(
          user.name,
          style: usernameStyle ?? const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        // Timestamp
        Text(
          _formatTimestamp(story.createdAt),
            style: timestampStyle ?? TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
      ],
    );
  }
  
  Widget _buildMoreButton() {
    // If story actions are provided, use the actions menu
    if (storyActions != null && storyActions!.isNotEmpty) {
      return VStoryActions(
        story: story,
        user: user,
        actions: storyActions!,
        onActionSelected: onActionSelected,
      );
    }
    
    // Otherwise, use simple icon button
    return IconButton(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onPressed: onMore,
    );
  }
  
  Widget _buildCloseButton() {
    return IconButton(
      icon: const Icon(Icons.close, color: Colors.white),
      onPressed: onClose,
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}

/// Minimal story header with just close button.
class VMinimalStoryHeader extends StatelessWidget {
  /// Called when close button is tapped
  final VoidCallback? onClose;
  
  /// Creates a minimal story header
  const VMinimalStoryHeader({
    super.key,
    this.onClose,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topRight,
      padding: const EdgeInsets.all(16),
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.white, size: 28),
        onPressed: onClose,
      ),
    );
  }
}

/// Custom story header with additional info.
class VCustomStoryHeader extends StatelessWidget {
  /// The story user
  final VStoryUser user;
  
  /// The current story
  final VBaseStory story;
  
  /// Leading widget (replaces avatar)
  final Widget? leading;
  
  /// Title widget (replaces username)
  final Widget? title;
  
  /// Subtitle widget (replaces timestamp)
  final Widget? subtitle;
  
  /// Trailing widgets
  final List<Widget> trailing;
  
  /// Creates a custom story header
  const VCustomStoryHeader({
    super.key,
    required this.user,
    required this.story,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing = const [],
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Leading
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) title!,
                if (subtitle != null) subtitle!,
              ],
            ),
          ),
          
          // Trailing
          ...trailing,
        ],
      ),
    );
  }
}