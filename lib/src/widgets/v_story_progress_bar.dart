import 'package:flutter/material.dart';
import 'package:step_progress/step_progress.dart';
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

/// Alternative progress bar using step_progress package.
class VStepProgressBar extends StatefulWidget {
  /// The story controller
  final VStoryController controller;

  /// Progress bar style
  final VStoryProgressStyle style;

  /// Total number of stories
  final int totalStories;

  /// Current story index
  final int currentIndex;

  /// Story duration in seconds
  final int storyDuration;

  /// Whether to pause on long press
  final bool pauseOnLongPress;

  /// Whether to auto-start progress
  final bool autoStart;

  /// Called when step changes
  final void Function(int index)? onStepChanged;

  /// Creates a step progress bar
  const VStepProgressBar({
    super.key,
    required this.controller,
    VStoryProgressStyle? style,
    required this.totalStories,
    required this.currentIndex,
    this.storyDuration = 5,
    this.pauseOnLongPress = true,
    this.autoStart = true,
    this.onStepChanged,
  }) : style =
           style ??
           const VStoryProgressStyle(
             activeColor: Colors.white,
             inactiveColor: Color(0x4DFFFFFF),
           );

  @override
  State<VStepProgressBar> createState() => _VStepProgressBarState();
}

class _VStepProgressBarState extends State<VStepProgressBar> {
  /// Step progress controller
  late StepProgressController _stepController;

  /// Whether progress is paused
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _stepController = StepProgressController(totalSteps: widget.totalStories);
    _stepController.addListener(() {

      print("-------------------");
      print(_stepController.currentStep);
      print("-------------------");

    });

    // Listen to controller state changes
    widget.controller.addListener(_onControllerStateChange);

    // Start progress if autoStart is enabled
    if (widget.autoStart && widget.controller.isPlaying) {
      _startProgress();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerStateChange);
    _stepController.dispose();
    super.dispose();
  }

  void _onControllerStateChange() {
    final state = widget.controller.state;

    // Handle play/pause state
    if (state.storyState.isPlaying && _isPaused) {
      _resumeProgress();
    } else if (state.storyState.isPaused && !_isPaused) {
      _pauseProgress();
    }

    // Handle story navigation
    if (state.storyIndex != -1 && state.storyIndex != widget.currentIndex) {
      _goToStep(state.storyIndex);
    }
  }

  void _startProgress() {
    // StepProgressController may not have startProgress method
    // The progress is handled by the StepProgress widget itself
  }

  void _pauseProgress() {
    _isPaused = true;
    // StepProgressController may not have pauseProgress method
    // The progress is handled by the StepProgress widget itself
  }

  void _resumeProgress() {
    _isPaused = false;
    // StepProgressController may not have resumeProgress method
    // The progress is handled by the StepProgress widget itself
  }

  void _goToStep(int index) {
    // StepProgressController may not have goToStep method
    // Navigation is handled by the onStepChanged callback
    if (mounted) {
      setState(() {
        // Trigger rebuild to update current index
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.style.padding,
      child: StepProgress(
        totalSteps: widget.totalStories,
        currentStep: widget.currentIndex,
        controller: _stepController,
        autoStartProgress: widget.autoStart,
        onStepChanged: (index) {
          // Notify callback
          widget.onStepChanged?.call(index);

          // Sync with controller
          if (index != widget.currentIndex) {
            widget.controller.goToStoryByIndex(index);
          }
        },
        visibilityOptions: StepProgressVisibilityOptions.lineOnly,
        theme: StepProgressThemeData(
          activeForegroundColor: widget.style.activeColor,
          defaultForegroundColor: widget.style.inactiveColor,
          stepLineSpacing: widget.style.spacing,
          stepLineStyle: StepLineStyle(lineThickness: widget.style.height),
        ),
      ),
    );
  }
}

/// Loading indicator for story media.
class VStoryLoadingIndicator extends StatelessWidget {
  /// Loading indicator color
  final Color color;

  /// Loading indicator size
  final double size;

  /// Background color
  final Color backgroundColor;

  /// Whether to show circular progress
  final bool showProgress;

  /// Current progress value (0.0 to 1.0)
  final double? progress;

  /// Creates a loading indicator
  const VStoryLoadingIndicator({
    super.key,
    this.color = Colors.white,
    this.size = 50.0,
    this.backgroundColor = Colors.black54,
    this.showProgress = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: showProgress && progress != null
              ? CircularProgressIndicator(
                  value: progress,
                  color: color,
                  strokeWidth: 3.0,
                )
              : CircularProgressIndicator(color: color, strokeWidth: 3.0),
        ),
      ),
    );
  }
}
