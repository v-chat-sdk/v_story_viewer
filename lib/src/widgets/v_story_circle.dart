import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import '../models/v_story_user.dart';
import '../models/v_story_circle_config.dart';
import '../painters/circle_ring_painter.dart';

/// Circular avatar widget with segmented story ring (WhatsApp/Instagram style).
///
/// Displays a user's avatar with a ring divided into segments representing
/// individual stories. Each segment is colored based on seen/unseen state.
///
/// ## Basic Usage
/// ```dart
/// VStoryCircle(
///   user: VStoryUser(id: '1', name: 'John', imageUrl: '...'),
///   storySeenStates: [false, true, false], // 3 stories: unseen, seen, unseen
///   onTap: () => openStoryViewer(),
/// )
/// ```
///
/// ## With Custom Configuration
/// ```dart
/// VStoryCircle(
///   user: user,
///   storySeenStates: group.sortedStories.map((s) => s.isSeen).toList(),
///   config: VStoryCircleConfig(
///     size: 80,
///     unseenColor: Colors.purple,
///     seenColor: Colors.grey,
///     ringWidth: 4.0,
///   ),
///   onTap: () => openViewer(group),
/// )
/// ```
///
/// ## Ring Segments
/// - Each story gets one segment in the ring
/// - Unseen stories: Colored with [VStoryCircleConfig.unseenColor]
/// - Seen stories: Colored with [VStoryCircleConfig.seenColor]
/// - Gap between segments: Controlled by [VStoryCircleConfig.segmentGap]
///
/// ## Avatar Loading States
/// - **Loading**: Shows gray placeholder with spinner
/// - **Failed**: Shows gray placeholder with person icon
/// - **Success**: Displays the avatar image
///
/// ## See Also
/// - [VStoryCircleList] for horizontal scrollable list of circles
/// - [VStoryCircleConfig] for customization options
/// - [VStoryGroup] for story data model
class VStoryCircle extends StatelessWidget {
  /// User information for avatar and identification.
  final VStoryUser user;

  /// List of seen states for each story segment.
  ///
  /// Length determines number of ring segments.
  /// - `true`: Segment colored with [VStoryCircleConfig.seenColor]
  /// - `false`: Segment colored with [VStoryCircleConfig.unseenColor]
  ///
  /// Example: `[false, true, false]` = 3 segments (unseen, seen, unseen)
  final List<bool> storySeenStates;

  /// Callback when the circle is tapped.
  ///
  /// Typically used to open the story viewer for this user.
  final VoidCallback? onTap;

  /// Configuration for circle appearance.
  ///
  /// Controls size, colors, ring width, and segment gaps.
  /// Defaults to [VStoryCircleConfig()] with standard Instagram-like values.
  final VStoryCircleConfig config;

  /// Creates a story circle with segmented ring.
  const VStoryCircle({
    super.key,
    required this.user,
    required this.storySeenStates,
    this.onTap,
    this.config = const VStoryCircleConfig(),
  });
  @override
  Widget build(BuildContext context) {
    final totalPadding = config.ringWidth + config.ringPadding;
    final avatarSize = config.size - (totalPadding * 2);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: config.size,
        height: config.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ring with per-segment colors
            RepaintBoundary(
              child: CustomPaint(
                size: Size(config.size, config.size),
                painter: CircleRingPainter(
                  segmentSeenStates: storySeenStates,
                  unseenColor: config.unseenColor,
                  seenColor: config.seenColor,
                  strokeWidth: config.ringWidth,
                  segmentGap: config.segmentGap,
                ),
              ),
            ),
            // Avatar
            ClipOval(
              child: ExtendedImage.network(
                user.imageUrl,
                width: avatarSize,
                height: avatarSize,
                fit: BoxFit.cover,
                cache: true,
                loadStateChanged: (state) {
                  switch (state.extendedImageLoadState) {
                    case LoadState.loading:
                      return Container(
                        width: avatarSize,
                        height: avatarSize,
                        color: Colors.grey[300],
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    case LoadState.failed:
                      return Container(
                        width: avatarSize,
                        height: avatarSize,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          size: avatarSize * 0.5,
                          color: Colors.grey[600],
                        ),
                      );
                    case LoadState.completed:
                      return null;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
