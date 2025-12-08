import 'package:flutter/material.dart';
import '../models/v_story_group.dart';
import '../models/v_story_circle_config.dart';
import 'v_story_circle.dart';

/// Horizontal scrollable list of story circles (Instagram/WhatsApp style).
///
/// Displays a row of [VStoryCircle] widgets for multiple users with stories.
/// Automatically filters out groups with no valid (non-expired) stories.
///
/// ## Basic Usage
/// ```dart
/// VStoryCircleList(
///   storyGroups: myStoryGroups,
///   onUserTap: (group, index) {
///     Navigator.push(context, MaterialPageRoute(
///       builder: (_) => VStoryViewer(
///         groups: myStoryGroups,
///         initialGroupIndex: index,
///       ),
///     ));
///   },
/// )
/// ```
///
/// ## Customization
/// ```dart
/// VStoryCircleList(
///   storyGroups: groups,
///   spacing: 16,
///   padding: EdgeInsets.symmetric(horizontal: 20),
///   showUserName: true,
///   nameStyle: TextStyle(fontSize: 11, color: Colors.grey),
///   circleConfig: VStoryCircleConfig(
///     size: 80,
///     unseenColor: Colors.purple,
///   ),
///   onUserTap: (group, index) => openViewer(index),
/// )
/// ```
///
/// ## Features
/// - **Auto-filtering**: Groups with only expired stories are hidden
/// - **Empty handling**: Returns [SizedBox.shrink] if no valid groups
/// - **Name display**: Optional username below each circle
/// - **Consistent height**: Adjusts based on [showUserName]
///
/// ## Layout
/// ```
/// ┌──────────────────────────────────────────────┐
/// │ [padding]                                    │
/// │  ○ ○ ○ ○ ○ ○ ○ ○ ○ ○  ← Circles with spacing │
/// │  A B C D E F G H I J  ← Optional names       │
/// └──────────────────────────────────────────────┘
/// ```
///
/// ## See Also
/// - [VStoryCircle] for individual circle widget
/// - [VStoryViewer] for full-screen story viewer
/// - [VStoryGroup] for story data model
class VStoryCircleList extends StatelessWidget {
  /// List of story groups to display.
  ///
  /// Groups with no valid (non-expired) stories are automatically filtered out.
  final List<VStoryGroup> storyGroups;

  /// Callback when a user's circle is tapped.
  ///
  /// Parameters:
  /// - [group]: The tapped user's story group
  /// - [index]: Index in the filtered list (valid groups only)
  ///
  /// Typically used to open [VStoryViewer] at the tapped index.
  final void Function(VStoryGroup group, int index)? onUserTap;

  /// Horizontal spacing between circles in logical pixels.
  ///
  /// Defaults to 12.
  final double spacing;

  /// Padding around the entire list.
  ///
  /// Defaults to `EdgeInsets.symmetric(horizontal: 16)`.
  final EdgeInsetsGeometry padding;

  /// Whether to show username below each circle.
  ///
  /// When `true`, list height increases to accommodate text.
  /// Defaults to `true`.
  final bool showUserName;

  /// Custom text style for usernames.
  ///
  /// Defaults to `TextStyle(fontSize: 12)` with theme body color.
  final TextStyle? nameStyle;

  /// Vertical padding between circle and username.
  ///
  /// Only applies when [showUserName] is `true`. Defaults to 0.
  final double namePadding;

  /// Configuration for circle appearance.
  ///
  /// Applied to all circles in the list.
  /// See [VStoryCircleConfig] for options.
  final VStoryCircleConfig circleConfig;

  /// Creates a horizontal story circle list.
  const VStoryCircleList({
    super.key,
    required this.storyGroups,
    this.onUserTap,
    this.spacing = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.showUserName = true,
    this.nameStyle,
    this.namePadding = 0,
    this.circleConfig = const VStoryCircleConfig(),
  });
  @override
  Widget build(BuildContext context) {
    final validGroups = storyGroups.where((g) => g.hasValidStories).toList();
    if (validGroups.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: showUserName ? circleConfig.size + 24 : circleConfig.size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: validGroups.length,
        cacheExtent: circleConfig.size * 3,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          final group = validGroups[index];
          return _buildCircleItem(context, group, index);
        },
      ),
    );
  }

  Widget _buildCircleItem(BuildContext context, VStoryGroup group, int index) {
    final storySeenStates = group.sortedStories.map((s) => s.isSeen).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VStoryCircle(
          user: group.user,
          storySeenStates: storySeenStates,
          config: circleConfig,
          onTap: () => onUserTap?.call(group, index),
        ),
        if (showUserName) ...[
          SizedBox(height: namePadding),
          SizedBox(
            width: circleConfig.size,
            child: Text(
              group.user.name,
              style: nameStyle ??
                  TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}
