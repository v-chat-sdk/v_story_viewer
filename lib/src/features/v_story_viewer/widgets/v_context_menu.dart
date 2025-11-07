import 'package:flutter/material.dart';

import '../../v_story_models/models/v_base_story.dart';

/// Menu item action type
enum VContextMenuAction { copyCaption, share, save, report, viewDetails }

/// Configuration for context menu
class VContextMenuConfig {
  const VContextMenuConfig({
    this.enableContextMenu = true,
    this.webOnly = true,
    this.showCopyCaption = true,
    this.showShare = true,
    this.showSave = true,
    this.showReport = true,
    this.showViewDetails = true,
  });

  /// Enable/disable context menu
  final bool enableContextMenu;

  /// Show only on web platform
  final bool webOnly;

  /// Show copy caption option
  final bool showCopyCaption;

  /// Show share option
  final bool showShare;

  /// Show save option
  final bool showSave;

  /// Show report option
  final bool showReport;

  /// Show view details option
  final bool showViewDetails;
}

/// Builder for context menu with story actions
class VContextMenuBuilder {
  /// Create context menu for a story
  static Future<VContextMenuAction?> show(
    BuildContext context,
    Offset position,
    VBaseStory story, {
    VContextMenuConfig config = const VContextMenuConfig(),
  }) {
    return showMenu<VContextMenuAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: _buildMenuItems(config, story),
    );
  }

  /// Build menu items based on configuration
  static List<PopupMenuEntry<VContextMenuAction>> _buildMenuItems(
    VContextMenuConfig config,
    VBaseStory story,
  ) {
    final items = <PopupMenuEntry<VContextMenuAction>>[];

    if (config.showCopyCaption && story.caption != null) {
      items.add(
        PopupMenuItem(
          value: VContextMenuAction.copyCaption,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.content_copy, size: 18),
              const SizedBox(width: 12),
              const Text('Copy caption'),
            ],
          ),
        ),
      );
    }

    if (config.showShare) {
      items.add(
        PopupMenuItem(
          value: VContextMenuAction.share,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.share, size: 18),
              const SizedBox(width: 12),
              const Text('Share'),
            ],
          ),
        ),
      );
    }

    if (config.showSave) {
      items.add(
        PopupMenuItem(
          value: VContextMenuAction.save,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.download, size: 18),
              const SizedBox(width: 12),
              const Text('Save'),
            ],
          ),
        ),
      );
    }

    if (config.showReport) {
      items.add(
        PopupMenuItem(
          value: VContextMenuAction.report,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flag, size: 18, color: Colors.red),
              const SizedBox(width: 12),
              const Text('Report', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      );
    }

    if (config.showViewDetails) {
      items.add(
        PopupMenuItem(
          value: VContextMenuAction.viewDetails,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, size: 18),
              const SizedBox(width: 12),
              const Text('View details'),
            ],
          ),
        ),
      );
    }

    return items;
  }
}

/// Widget that provides right-click context menu support
class VContextMenuWrapper extends StatelessWidget {
  const VContextMenuWrapper({
    required this.child,
    required this.story,
    required this.onMenuAction,
    this.config = const VContextMenuConfig(),
    super.key,
  });

  /// The child widget to wrap
  final Widget child;

  /// The story associated with this menu
  final VBaseStory story;

  /// Callback when menu action is selected
  final void Function(VContextMenuAction action) onMenuAction;

  /// Context menu configuration
  final VContextMenuConfig config;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        if (!config.enableContextMenu) return;

        VContextMenuBuilder.show(
          context,
          details.globalPosition,
          story,
          config: config,
        ).then((action) {
          if (action != null) {
            onMenuAction(action);
          }
        });
      },
      child: child,
    );
  }
}

/// Enum extension for action display text
extension VContextMenuActionExt on VContextMenuAction {
  /// Get display label for action
  String get label {
    return switch (this) {
      VContextMenuAction.copyCaption => 'Copy caption',
      VContextMenuAction.share => 'Share',
      VContextMenuAction.save => 'Save',
      VContextMenuAction.report => 'Report',
      VContextMenuAction.viewDetails => 'View details',
    };
  }

  /// Get icon for action
  IconData get icon {
    return switch (this) {
      VContextMenuAction.copyCaption => Icons.content_copy,
      VContextMenuAction.share => Icons.share,
      VContextMenuAction.save => Icons.download,
      VContextMenuAction.report => Icons.flag,
      VContextMenuAction.viewDetails => Icons.info_outline,
    };
  }
}
