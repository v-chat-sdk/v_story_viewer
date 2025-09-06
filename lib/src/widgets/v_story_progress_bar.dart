import 'package:flutter/material.dart';
import '../controllers/v_story_controller.dart';
import '../themes/v_story_progress_style.dart';

/// Instagram-style segmented progress bar for stories.
class VStoryProgressBar extends StatefulWidget {
  /// The story controller
  final VStoryController controller;

  /// Progress bar style
  final VStoryProgressStyle style;

  /// Total number of stories
  final int totalStories;

  /// Current story index
  final int currentIndex;

  /// Whether progress bar is visible
  final bool isVisible;

  /// Called when a segment completes
  final void Function(int index)? onSegmentComplete;

  /// Creates a story progress bar
  const VStoryProgressBar({
    super.key,
    required this.controller,
    VStoryProgressStyle? style,
    required this.totalStories,
    required this.currentIndex,
    this.isVisible = true,
    this.onSegmentComplete,
  }) : style =
           style ??
           const VStoryProgressStyle(
             activeColor: Colors.white,
             inactiveColor: Color(0x4DFFFFFF),
           );

  @override
  State<VStoryProgressBar> createState() => _VStoryProgressBarState();
}

class _VStoryProgressBarState extends State<VStoryProgressBar>
    with SingleTickerProviderStateMixin {
  /// Animation controller for progress
  late AnimationController _animationController;

  /// Current progress value (0.0 to 1.0)
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.style.animationDuration,
    );

    // Listen to controller state changes
    widget.controller.addListener(_onControllerStateChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerStateChange);
    _animationController.dispose();
    super.dispose();
  }

  void _onControllerStateChange() {
    final state = widget.controller.state;

    // Update progress based on controller state
    if (mounted) {
      setState(() {
        _currentProgress = state.storyState.progress;
      });

      // Handle segment completion
      if (state.storyState.progress >= 1.0 && state.storyIndex != -1) {
        widget.onSegmentComplete?.call(state.storyIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: widget.style.padding,
      child: Row(
        children: List.generate(widget.totalStories, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: widget.style.spacing / 2,
              ),
              child: _buildSegment(index),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSegment(int index) {
    // Determine segment state
    final isCompleted = index < widget.currentIndex;
    final isCurrent = index == widget.currentIndex;
    final progress = isCurrent ? _currentProgress : (isCompleted ? 1.0 : 0.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.style.radius),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: widget.style.inactiveColor,
        valueColor: AlwaysStoppedAnimation<Color>(widget.style.activeColor),
        minHeight: widget.style.height,
      ),
    );
  }
}
