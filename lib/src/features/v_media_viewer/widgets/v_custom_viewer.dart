import 'package:flutter/material.dart';

import '../../v_story_models/models/v_custom_story.dart';
import '../controllers/v_custom_controller.dart';
import 'v_custom_story_controller_provider.dart';

/// Widget for displaying custom widget stories
///
/// Renders custom widgets with support for asynchronous loading,
/// pause/resume control, and error handling.
/// The custom widget can access the custom story controller via
/// VCustomStoryControllerProvider.of(context).
class VCustomViewer extends StatefulWidget {
  const VCustomViewer({
    required this.story,
    required this.controller,
    super.key,
  });

  final VCustomStory story;
  final VCustomController controller;

  @override
  State<VCustomViewer> createState() => _VCustomViewerState();
}

class _VCustomViewerState extends State<VCustomViewer> {
  late VCustomStory _story;
  Object? _error;

  @override
  void didUpdateWidget(VCustomViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.story != widget.story) {
      _story = widget.story;
      _error = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    _story = widget.story;

    return VCustomStoryControllerProvider(
      controller: widget.controller.customController,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    // Show custom loading widget if controller is loading
    if (widget.controller.customController.isLoading) {
      if (_story.loadingBuilder != null) {
        return _story.loadingBuilder!(context);
      }
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show error state if controller has error
    if (widget.controller.customController.errorMessage != null) {
      if (_story.errorBuilder != null) {
        return _story.errorBuilder!(
          context,
          _story.errorBuilder != null
              ? _error ?? 'Unknown error'
              : Exception(widget.controller.customController.errorMessage),
        );
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.controller.customController.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    // Build custom widget
    try {
      return _story.builder(context);
    } catch (error) {
      _error = error;
      // Use custom error builder if provided
      if (_story.errorBuilder != null) {
        return _story.errorBuilder!(context, error);
      }

      // Default error widget
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Error loading custom story',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }
}
