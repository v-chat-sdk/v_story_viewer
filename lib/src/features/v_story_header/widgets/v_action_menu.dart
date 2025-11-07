import 'package:flutter/material.dart';

import '../models/v_story_action.dart';

/// Custom action menu widget with optimized positioning and theming
class VActionMenu {
  const VActionMenu._();

  /// Shows the action menu at the optimal position
  static Future<VStoryAction?> show({
    required BuildContext context,
    required List<VStoryAction> actions,
    required Offset buttonPosition,
    required Size buttonSize,
  }) {
    if (actions.isEmpty) {
      return Future<VStoryAction?>.value();
    }

    final screenSize = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Calculate optimal position for menu
    final position = _calculateMenuPosition(
      buttonPosition: buttonPosition,
      buttonSize: buttonSize,
      screenSize: screenSize,
      menuWidth: 200,
      menuHeight: (actions.length * 48.0) + 16,
    );

    return showMenu<VStoryAction>(
      context: context,
      position: position,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      items: actions
          .map(
            (action) => PopupMenuItem<VStoryAction>(
              value: action,
              child: _ActionMenuItemWidget(
                action: action,
                isDarkMode: isDarkMode,
              ),
            ),
          )
          .toList(),
    );
  }

  /// Calculate the optimal position for the menu
  static RelativeRect _calculateMenuPosition({
    required Offset buttonPosition,
    required Size buttonSize,
    required Size screenSize,
    required double menuWidth,
    required double menuHeight,
  }) {
    // Always position menu below the button
    var left = buttonPosition.dx + buttonSize.width - menuWidth;
    var top = buttonPosition.dy + buttonSize.height + 8;

    // Adjust horizontal position to keep menu on screen
    if (left < 8) {
      left = 8;
    } else if (left + menuWidth > screenSize.width - 8) {
      left = screenSize.width - menuWidth - 8;
    }

    // Adjust vertical position to keep menu on screen (but always below button)
    final bottom = 0.0;

    if (top + menuHeight > screenSize.height - 8) {
      // Position menu as low as possible while keeping it on screen
      top = screenSize.height - menuHeight - 8;
    }

    return RelativeRect.fromLTRB(left, top, 8, bottom);
  }
}

/// Individual action menu item widget
class _ActionMenuItemWidget extends StatefulWidget {
  const _ActionMenuItemWidget({
    required this.action,
    required this.isDarkMode,
  });

  final VStoryAction action;
  final bool isDarkMode;

  @override
  State<_ActionMenuItemWidget> createState() => _ActionMenuItemWidgetState();
}

class _ActionMenuItemWidgetState extends State<_ActionMenuItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: _isHovered
            ? (widget.isDarkMode ? Colors.grey[800] : Colors.grey[100])
            : Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.action.icon,
              size: 20,
              color: widget.action.iconColor ??
                  (widget.isDarkMode ? Colors.white : Colors.black87),
            ),
            const SizedBox(width: 12),
            Text(
              widget.action.label,
              style: TextStyle(
                color: widget.action.textColor ??
                    (widget.isDarkMode ? Colors.white : Colors.black87),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
