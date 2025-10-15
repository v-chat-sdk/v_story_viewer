import 'dart:io';

import 'package:video_player/video_player.dart';

import '../../../../v_story_viewer.dart';

/// Controller for video story playback
///
/// Manages VideoPlayerController lifecycle with proper initialization,
/// pause/resume functionality, and duration notification.
/// Uses single controller instance with init/dispose per story for performance.
class VVideoController extends VBaseMediaController {
  VVideoController({required this.cacheController, super.callbacks});

  final VCacheController cacheController;
  VideoPlayerController? _videoPlayerController;

  /// Get the video player controller for UI access
  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  @override
  Future<void> loadMedia(VBaseStory story) async {
    if (story is! VVideoStory) {
      throw ArgumentError('VVideoController requires VVideoStory');
    }

    // Trigger cache download for network videos
    // Progress tracking happens in VStoryViewer via global stream listener
    if (story.media.networkUrl != null) {
      await cacheController.getFile(story.media, story.id);
    }

    await _videoPlayerController?.dispose();
    _videoPlayerController = _createVideoController(story);
    await _initializeAndConfigureVideo(story);
  }

  VideoPlayerController _createVideoController(VVideoStory story) {
    if (story.media.networkUrl != null) {
      return VideoPlayerController.networkUrl(
        Uri.parse(story.media.networkUrl!),
      );
    }
    if (story.media.fileLocalPath != null) {
      return VideoPlayerController.file(File(story.media.fileLocalPath!));
    }
    if (story.media.assetsPath != null) {
      return VideoPlayerController.asset(story.media.assetsPath!);
    }
    throw ArgumentError('VVideoStory must have a valid media source');
  }

  Future<void> _initializeAndConfigureVideo(VVideoStory story) async {
    await _videoPlayerController!.initialize();
    await _videoPlayerController!.setVolume(story.muted ? 0 : 1);
    await _videoPlayerController!.setLooping(story.looping);

    final duration = _videoPlayerController!.value.duration;
    if (duration != Duration.zero) {
      notifyDuration(duration);
    }

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
