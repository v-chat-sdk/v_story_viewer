import 'package:flutter/material.dart';

/// Segmented progress bar for stories (Instagram/WhatsApp style).
///
/// Displays a row of progress segments, one per story. Shows completed,
/// current (animating), and upcoming segments with appropriate fill states.
///
/// ## Basic Usage
/// ```dart
/// VStoryProgress(
///   storyCount: 5,
///   currentIndex: 2,
///   progress: 0.65, // 65% through story at index 2
/// )
/// ```
///
/// ## Custom Styling
/// ```dart
/// VStoryProgress(
///   storyCount: stories.length,
///   currentIndex: currentStoryIndex,
///   progress: animationProgress,
///   progressColor: Colors.blue,
///   backgroundColor: Colors.blue.withOpacity(0.3),
///   height: 3.0,
///   spacing: 6,
/// )
/// ```
///
/// ## Segment States
/// | Index vs Current | Progress Value | Description |
/// |------------------|----------------|-------------|
/// | index < current  | 1.0            | Completed   |
/// | index == current | 0.0 - 1.0      | Animating   |
/// | index > current  | 0.0            | Upcoming    |
///
/// ## Visual Example
/// ```
/// Story 0    Story 1    Story 2    Story 3
/// [████████] [████████] [████░░░░] [░░░░░░░░]
///  Complete   Complete   Current    Upcoming
///                        (65%)
/// ```
///
/// ## RTL Support
/// Automatically respects [Directionality] for RTL languages.
/// Progress direction reverses appropriately.
///
/// ## See Also
/// - [VStoryViewer] which manages progress animation
/// - [VStoryConfig.progressColor] for viewer-level configuration
class VStoryProgress extends StatelessWidget {
  /// Total number of story segments to display.
  ///
  /// Typically matches the story count in current group.
  final int storyCount;

  /// Index of the currently playing story (0-based).
  ///
  /// Segments before this index show as completed (100%).
  /// Segment at this index shows animated progress.
  /// Segments after show as upcoming (0%).
  final int currentIndex;

  /// Progress of the current story (0.0 to 1.0).
  ///
  /// Applied only to segment at [currentIndex].
  /// Typically driven by [AnimationController].
  final double progress;

  /// Fill color for progress portion of segments.
  ///
  /// Defaults to white for visibility on dark backgrounds.
  final Color progressColor;

  /// Background color for unfilled portion of segments.
  ///
  /// Defaults to semi-transparent white (`Color(0x40FFFFFF)`).
  final Color backgroundColor;

  /// Height of each progress segment in logical pixels.
  ///
  /// Defaults to 2.5 for Instagram-like appearance.
  final double height;

  /// Horizontal spacing between segments in logical pixels.
  ///
  /// Defaults to 4.
  final double spacing;

  /// Creates a segmented story progress bar.
  const VStoryProgress({
    super.key,
    required this.storyCount,
    required this.currentIndex,
    required this.progress,
    this.progressColor = Colors.white,
    this.backgroundColor = const Color(0x40FFFFFF),
    this.height = 2.5,
    this.spacing = 4,
  });
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(height / 2);
    return Directionality(
      textDirection: Directionality.of(context),
      child: Row(
        children: List.generate(storyCount, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : spacing / 2,
                right: index == storyCount - 1 ? 0 : spacing / 2,
              ),
              child: ClipRRect(
                borderRadius: borderRadius,
                child: LinearProgressIndicator(
                  value: _getProgressValue(index),
                  backgroundColor: backgroundColor,
                  valueColor: AlwaysStoppedAnimation(progressColor),
                  minHeight: height,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  double _getProgressValue(int index) {
    if (index < currentIndex) {
      return 1.0; // Completed
    } else if (index == currentIndex) {
      return progress; // Current - animated
    } else {
      return 0.0; // Upcoming
    }
  }
}
