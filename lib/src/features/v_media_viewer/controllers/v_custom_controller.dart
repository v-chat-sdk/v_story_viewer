import 'package:flutter/foundation.dart';

import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_custom_story.dart';
import 'v_base_media_controller.dart';
import 'v_custom_story_controller.dart';

/// Implementation of VCustomStoryController
///
/// Provides communication bridge between custom story widgets and media controller.
/// Manages loading states, pause/resume, and error handling.
class _VCustomStoryControllerImpl implements VCustomStoryController {
  _VCustomStoryControllerImpl(this._mediaController);

  final VCustomController _mediaController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void startLoading() {
    _isLoading = true;
    _mediaController.pause();
  }

  @override
  void finishLoading() {
    _isLoading = false;
    _errorMessage = null;
    _mediaController.resume();
    // ignore: cascade_invocations
    _mediaController._onCustomLoaded();
  }

  @override
  void pauseProgress() {
    _mediaController.pause();
  }

  @override
  void resumeProgress() {
    _mediaController.resume();
  }

  @override
  void setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    _mediaController._onCustomError(message);
  }

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;
}

/// Controller for custom widget stories
///
/// Supports custom widgets that can load data asynchronously.
/// Provides a controller that custom widgets can use to signal loading states,
/// pause/resume progress, and handle errors.
///
/// Custom widgets receive a [VCustomStoryController] that allows them to:
/// - Signal when they start loading data
/// - Notify when they finish loading
/// - Pause/resume the progress bar
/// - Report errors
class VCustomController extends VBaseMediaController {
  VCustomController();

  late _VCustomStoryControllerImpl _customStoryController;
  bool _readySignaled = false;

  /// Get the custom story controller to pass to widgets
  VCustomStoryController get customController => _customStoryController;

  /// Check if custom controller is currently loading
  bool get isCustomLoading => _customStoryController.isLoading;

  @override
  Future<void> loadMedia(VBaseStory story) async {
    if (story is! VCustomStory) {
      throw ArgumentError('VCustomController requires VCustomStory');
    }
    _customStoryController = _VCustomStoryControllerImpl(this);
    _readySignaled = false;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!_readySignaled && !_customStoryController.isLoading) {
      notifyReady();
      _readySignaled = true;
    }
  }

  /// Called when custom content finishes loading
  @protected
  void _onCustomLoaded() {
    if (!_readySignaled) {
      notifyReady();
      _readySignaled = true;
    }
  }

  /// Called when custom content encounters an error
  @protected
  void _onCustomError(String message) {
    _readySignaled = false;
    notifyError(message);
  }

  @override
  void dispose() {
    _readySignaled = false;
    super.dispose();
  }
}
