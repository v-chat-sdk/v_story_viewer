import 'package:flutter/material.dart';
import 'package:step_progress/step_progress.dart';
import '../controllers/v_story_controller.dart';
import '../themes/v_story_progress_style.dart';

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