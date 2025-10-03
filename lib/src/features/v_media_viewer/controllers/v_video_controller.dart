import 'dart:io';

import 'package:video_player/video_player.dart';

import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_video_story.dart';
import '../models/v_media_callbacks.dart';
import 'v_base_media_controller.dart';

/// Controller for video story playback
///
/// Manages VideoPlayerController lifecycle with proper initialization,
/// pause/resume functionality, and duration notification.
/// Uses single controller instance with init/dispose per story for performance.
class VVideoController extends VBaseMediaController {
  VVideoController({
    VMediaCallbacks? callbacks,
  }) : super(callbacks: callbacks);

  VideoPlayerController? _videoPlayerController;

  /// Get the video player controller for UI access
  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  @override
  Future<void> loadMedia(VBaseStory story) async {
    if (story is! VVideoStory) {
      throw ArgumentError('VVideoController requires VVideoStory');
    }

    // Dispose previous controller
    await _videoPlayerController?.dispose();

    // Create new video controller based on source
    if (story.media.networkUrl != null) {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(story.media.networkUrl!),
      );
    } else if (story.media.fileLocalPath != null) {
      _videoPlayerController = VideoPlayerController.file(
        File(story.media.fileLocalPath!),
      );
    } else if (story.media.assetsPath != null) {
      _videoPlayerController = VideoPlayerController.asset(
        story.media.assetsPath!,
      );
    } else {
      throw ArgumentError('VVideoStory must have a valid media source');
    }

    // Initialize video
    await _videoPlayerController!.initialize();

    // Set muted state
    await _videoPlayerController!.setVolume(story.muted ? 0 : 1);

    // Set looping
    await _videoPlayerController!.setLooping(story.looping);

    // Notify duration
    final duration = _videoPlayerController!.value.duration;
    if (duration != Duration.zero) {
      notifyDuration(duration);
    }

    // Auto-play if enabled
    if (story.autoPlay) {
      await _videoPlayerController!.play();
    }
  }

  @override
  void pauseMedia() {
    _videoPlayerController?.pause();
  }

  @override
  void resumeMedia() {
    _videoPlayerController?.play();
  }

  /// Toggle mute state
  Future<void> toggleMute() async {
    final currentVolume = _videoPlayerController?.value.volume ?? 0;
    final newVolume = currentVolume > 0 ? 0.0 : 1.0;
    await _videoPlayerController?.setVolume(newVolume);
    notifyListeners();
  }

  /// Check if video is muted
  bool get isMuted => (_videoPlayerController?.value.volume ?? 0) == 0;

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }
}
