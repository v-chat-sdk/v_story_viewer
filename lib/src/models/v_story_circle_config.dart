import 'package:flutter/material.dart';

/// Configuration for [VStoryCircle] appearance.
///
/// Controls the size, colors, and ring styling of story circle avatars.
/// Used in [VStoryCircleList] to display user avatars with story rings.
///
/// ## Basic Usage
/// ```dart
/// VStoryCircle(
///   group: storyGroup,
///   config: VStoryCircleConfig(
///     size: 80,
///     unseenColor: Colors.purple,
///     ringWidth: 4.0,
///   ),
/// )
/// ```
///
/// ## Ring Appearance
/// The ring around the avatar is segmented based on story count:
/// - **Unseen stories**: Colored with [unseenColor]
/// - **Seen stories**: Colored with [seenColor]
/// - **Segment gap**: Space between segments controlled by [segmentGap]
///
/// ## Visual Layout
/// ```
/// ┌─────────────────┐
/// │  ╭───────────╮  │ ← Ring (ringWidth)
/// │  │           │  │
/// │  │  Avatar   │  │ ← size - ringWidth - ringPadding
/// │  │           │  │
/// │  ╰───────────╯  │
/// └─────────────────┘
///      ↑ ringPadding
/// ```
///
/// ## Example with Custom Colors
/// ```dart
/// VStoryCircleConfig(
///   size: 72,
///   unseenColor: Color(0xFFE91E63), // Pink for unseen
///   seenColor: Color(0xFF9E9E9E),   // Gray for seen
///   ringWidth: 3.0,
///   ringPadding: 3.0,
///   segmentGap: 0.08, // 8% gap between segments
/// )
/// ```
class VStoryCircleConfig {
  /// Total size of the circle widget including ring.
  ///
  /// The avatar size will be: `size - (ringWidth * 2) - (ringPadding * 2)`
  /// Must be greater than 0.
  final double size;

  /// Color for unseen story ring segments.
  ///
  /// Applied to ring segments representing stories the user hasn't viewed.
  /// Defaults to green (`Color(0xFF4CAF50)`).
  final Color unseenColor;

  /// Color for seen story ring segments.
  ///
  /// Applied to ring segments representing stories the user has viewed.
  /// Defaults to gray (`Color(0xFF808080)`).
  final Color seenColor;

  /// Width of the story ring in logical pixels.
  ///
  /// Controls thickness of the segmented ring around the avatar.
  /// Must be greater than 0. Defaults to 3.0.
  final double ringWidth;

  /// Padding between ring and avatar in logical pixels.
  ///
  /// Creates visual separation between the ring and avatar image.
  /// Defaults to 3.0.
  final double ringPadding;

  /// Gap between ring segments as a fraction of segment arc.
  ///
  /// Value between 0.0 (no gap) and 1.0 (full gap).
  /// - 0.0: Segments touch each other
  /// - 0.08: 8% gap (default, subtle separation)
  /// - 0.2: 20% gap (visible separation)
  ///
  /// Must be >= 0 and < 1.
  final double segmentGap;

  /// Creates configuration for [VStoryCircle].
  ///
  /// All parameters have sensible defaults for Instagram-like appearance.
  const VStoryCircleConfig({
    this.size = 72,
    this.unseenColor = const Color(0xFF4CAF50),
    this.seenColor = const Color(0xFF808080),
    this.ringWidth = 3.0,
    this.ringPadding = 3.0,
    this.segmentGap = 0.08,
  })  : assert(size > 0, 'Size must be greater than 0'),
        assert(ringWidth > 0, 'Ring width must be greater than 0'),
        assert(segmentGap >= 0 && segmentGap < 1,
            'Segment gap must be between 0 and 1 (exclusive)');
  VStoryCircleConfig copyWith({
    double? size,
    Color? unseenColor,
    Color? seenColor,
    double? ringWidth,
    double? ringPadding,
    double? segmentGap,
  }) =>
      VStoryCircleConfig(
        size: size ?? this.size,
        unseenColor: unseenColor ?? this.unseenColor,
        seenColor: seenColor ?? this.seenColor,
        ringWidth: ringWidth ?? this.ringWidth,
        ringPadding: ringPadding ?? this.ringPadding,
        segmentGap: segmentGap ?? this.segmentGap,
      );
}
