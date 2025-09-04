import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/v_story_models.dart';

/// Action item for story actions menu.
class VStoryAction {
  /// Action identifier
  final String id;
  
  /// Action label
  final String label;
  
  /// Action icon
  final IconData? icon;
  
  /// Whether this is a destructive action
  final bool isDestructive;
  
  /// Whether action is enabled
  final bool isEnabled;
  
  /// Action callback
  final VoidCallback? onTap;
  
  /// Creates a story action
  const VStoryAction({
    required this.id,
    required this.label,
    this.icon,
    this.isDestructive = false,
    this.isEnabled = true,
    this.onTap,
  });
  
  /// Creates a hide action
  factory VStoryAction.hide({VoidCallback? onTap}) {
    return VStoryAction(
      id: 'hide',
      label: 'Hide Story',
      icon: Icons.visibility_off,
      onTap: onTap,
    );
  }
  
  /// Creates a mute action
  factory VStoryAction.mute({VoidCallback? onTap}) {
    return VStoryAction(
      id: 'mute',
      label: 'Mute User',
      icon: Icons.volume_off,
      onTap: onTap,
    );
  }
  
  /// Creates a report action
  factory VStoryAction.report({VoidCallback? onTap}) {
    return VStoryAction(
      id: 'report',
      label: 'Report',
      icon: Icons.flag,
      isDestructive: true,
      onTap: onTap,
    );
  }
  
  /// Creates a share action
  factory VStoryAction.share({VoidCallback? onTap}) {
    return VStoryAction(
      id: 'share',
      label: 'Share',
      icon: Icons.share,
      onTap: onTap,
    );
  }
  
  /// Creates a save action
  factory VStoryAction.save({VoidCallback? onTap}) {
    return VStoryAction(
      id: 'save',
      label: 'Save',
      icon: Icons.download,
      onTap: onTap,
    );
  }
  
  /// Creates a delete action
  factory VStoryAction.delete({VoidCallback? onTap}) {
    return VStoryAction(
      id: 'delete',
      label: 'Delete',
      icon: Icons.delete,
      isDestructive: true,
      onTap: onTap,
    );
  }
}

/// Story actions menu widget with three vertical dots.
class VStoryActions extends StatelessWidget {
  /// The current story
  final VBaseStory story;
  
  /// The story user
  final VStoryUser user;
  
  /// Available actions
  final List<VStoryAction> actions;
  
  /// Icon color
  final Color iconColor;
  
  /// Icon size
  final double iconSize;
  
  /// Menu background color
  final Color? menuBackgroundColor;
  
  /// Menu text style
  final TextStyle? menuTextStyle;
  
  /// Menu shape
  final ShapeBorder? menuShape;
  
  /// Called when an action is selected
  final void Function(VStoryAction action, VBaseStory story)? onActionSelected;
  
  /// Creates a story actions widget
  const VStoryActions({
    super.key,
    required this.story,
    required this.user,
    this.actions = const [],
    this.iconColor = Colors.white,
    this.iconSize = 24,
    this.menuBackgroundColor,
    this.menuTextStyle,
    this.menuShape,
    this.onActionSelected,
  });
  
  /// Creates with default actions
  factory VStoryActions.withDefaults({
    Key? key,
    required VBaseStory story,
    required VStoryUser user,
    void Function(String actionId, VBaseStory story)? onAction,
  }) {
    return VStoryActions(
      key: key,
      story: story,
      user: user,
      actions: [
        VStoryAction.hide(
          onTap: () => onAction?.call('hide', story),
        ),
        VStoryAction.mute(
          onTap: () => onAction?.call('mute', story),
        ),
        VStoryAction.share(
          onTap: () => onAction?.call('share', story),
        ),
        VStoryAction.save(
          onTap: () => onAction?.call('save', story),
        ),
        VStoryAction.report(
          onTap: () => onAction?.call('report', story),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return PopupMenuButton<VStoryAction>(
      icon: Icon(
        Icons.more_vert,
        color: iconColor,
        size: iconSize,
      ),
      color: menuBackgroundColor ?? Colors.grey[900],
      shape: menuShape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (context) => _buildMenuItems(context),
      onSelected: (action) => _handleAction(action),
    );
  }
  
  List<PopupMenuEntry<VStoryAction>> _buildMenuItems(BuildContext context) {
    final items = <PopupMenuEntry<VStoryAction>>[];
    
    for (int i = 0; i < actions.length; i++) {
      final action = actions[i];
      
      // Add separator before destructive actions
      if (i > 0 && action.isDestructive && !actions[i - 1].isDestructive) {
        items.add(const PopupMenuDivider());
      }
      
      items.add(
        PopupMenuItem<VStoryAction>(
          value: action,
          enabled: action.isEnabled,
          child: Row(
            children: [
              if (action.icon != null) ...[
                Icon(
                  action.icon,
                  color: action.isDestructive 
                      ? Colors.red 
                      : (action.isEnabled ? Colors.white : Colors.white38),
                  size: 20,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  action.label,
                  style: menuTextStyle ?? TextStyle(
                    color: action.isDestructive 
                        ? Colors.red 
                        : (action.isEnabled ? Colors.white : Colors.white38),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return items;
  }
  
  void _handleAction(VStoryAction action) {
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Call action callback
    action.onTap?.call();
    
    // Call selection callback
    onActionSelected?.call(action, story);
  }
}

/// Bottom sheet style actions menu.
class VStoryActionsSheet extends StatelessWidget {
  /// The current story
  final VBaseStory story;
  
  /// The story user
  final VStoryUser user;
  
  /// Available actions
  final List<VStoryAction> actions;
  
  /// Sheet title
  final String? title;
  
  /// Sheet subtitle
  final String? subtitle;
  
  /// Background color
  final Color? backgroundColor;
  
  /// Text style
  final TextStyle? textStyle;
  
  /// Whether to show handle
  final bool showHandle;
  
  /// Called when an action is selected
  final void Function(VStoryAction action)? onActionSelected;
  
  /// Creates a story actions sheet
  const VStoryActionsSheet({
    super.key,
    required this.story,
    required this.user,
    required this.actions,
    this.title,
    this.subtitle,
    this.backgroundColor,
    this.textStyle,
    this.showHandle = true,
    this.onActionSelected,
  });
  
  /// Shows the actions sheet
  static Future<VStoryAction?> show({
    required BuildContext context,
    required VBaseStory story,
    required VStoryUser user,
    required List<VStoryAction> actions,
    String? title,
    String? subtitle,
    Color? backgroundColor,
    TextStyle? textStyle,
    bool showHandle = true,
  }) {
    return showModalBottomSheet<VStoryAction>(
      context: context,
      backgroundColor: backgroundColor ?? Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => VStoryActionsSheet(
        story: story,
        user: user,
        actions: actions,
        title: title,
        subtitle: subtitle,
        backgroundColor: backgroundColor,
        textStyle: textStyle,
        showHandle: showHandle,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          if (showHandle) _buildHandle(),
          
          // Header
          if (title != null || subtitle != null) _buildHeader(),
          
          // Actions
          ..._buildActions(context),
          
          // Cancel button
          _buildCancelButton(context),
        ],
      ),
    );
  }
  
  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          if (title != null)
            Text(
              title!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
  
  List<Widget> _buildActions(BuildContext context) {
    final widgets = <Widget>[];
    
    for (int i = 0; i < actions.length; i++) {
      final action = actions[i];
      
      // Add separator before destructive actions
      if (i > 0 && action.isDestructive && !actions[i - 1].isDestructive) {
        widgets.add(
          const Divider(
            color: Colors.white12,
            height: 1,
          ),
        );
      }
      
      widgets.add(
        ListTile(
          leading: action.icon != null
              ? Icon(
                  action.icon,
                  color: action.isDestructive 
                      ? Colors.red 
                      : (action.isEnabled ? Colors.white : Colors.white38),
                )
              : null,
          title: Text(
            action.label,
            style: textStyle ?? TextStyle(
              color: action.isDestructive 
                  ? Colors.red 
                  : (action.isEnabled ? Colors.white : Colors.white38),
            ),
          ),
          enabled: action.isEnabled,
          onTap: () {
            Navigator.pop(context, action);
            _handleAction(action);
          },
        ),
      );
    }
    
    return widgets;
  }
  
  Widget _buildCancelButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 20, right: 20),
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.white10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
  
  void _handleAction(VStoryAction action) {
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Call action callback
    action.onTap?.call();
    
    // Call selection callback
    onActionSelected?.call(action);
  }
}

/// Action feedback widget for visual confirmation.
class VStoryActionFeedback extends StatefulWidget {
  /// The action that was performed
  final VStoryAction action;
  
  /// Duration to show feedback
  final Duration duration;
  
  /// Animation duration
  final Duration animationDuration;
  
  /// Creates an action feedback widget
  const VStoryActionFeedback({
    super.key,
    required this.action,
    this.duration = const Duration(seconds: 2),
    this.animationDuration = const Duration(milliseconds: 300),
  });
  
  /// Shows action feedback
  static void show({
    required BuildContext context,
    required VStoryAction action,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => VStoryActionFeedback(
        action: action,
        duration: duration,
      ),
    );
    
    overlay.insert(entry);
    
    Future.delayed(duration + const Duration(milliseconds: 300), () {
      entry.remove();
    });
  }
  
  @override
  State<VStoryActionFeedback> createState() => _VStoryActionFeedbackState();
}

class _VStoryActionFeedbackState extends State<VStoryActionFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _controller.forward();
    
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 100,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.action.icon != null) ...[
                    Icon(
                      widget.action.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    '${widget.action.label} successful',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}