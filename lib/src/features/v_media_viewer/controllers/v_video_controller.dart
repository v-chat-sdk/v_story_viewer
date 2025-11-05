import 'dart:io';

import 'package:v_platform/v_platform.dart';
import 'package:video_player/video_player.dart';

import '../../../../v_story_viewer.dart';

/// Controller for video story playback
///
/// Manages VideoPlayerController lifecycle with proper initialization,
/// pause/resume functionality, and duration notification.
/// Uses single controller instance with init/dispose per story for performance.
class VVideoController extends VBaseMediaController {
  VVideoController({required this.cacheController});

  final VCacheController cacheController;
  VideoPlayerController? _videoPlayerController;

  /// Get the video player controller for UI access
  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  @override
  Future<void> loadMedia(VBaseStory story) async {
    if (story is! VVideoStory) {
      throw ArgumentError('VVideoController requires VVideoStory');
    }
    final oldController = _videoPlayerController;
    _videoPlayerController = null;
    await oldController?.dispose();
    if (currentStory?.id != story.id) {
      return;
    }
    VPlatformFile? mediaToLoad = story.media;
    if (story.media.networkUrl != null) {
      final cachedFile = await cacheController.getFile(story.media, story.id);
      if (cachedFile != null) {
        mediaToLoad = cachedFile;
      }
    }
    if (currentStory?.id != story.id) {
      return;
    }
    _videoPlayerController = _createVideoController(mediaToLoad);
    await _initializeAndConfigureVideo(story);
  }

  VideoPlayerController _createVideoController(VPlatformFile media) {
    if (media.fileLocalPath != null) {
      return VideoPlayerController.file(File(media.fileLocalPath!));
    }
    if (media.networkUrl != null) {
      return VideoPlayerController.networkUrl(
        Uri.parse(media.networkUrl!),
      );
    }
    if (media.assetsPath != null) {
      return VideoPlayerController.asset(media.assetsPath!);
    }
    throw ArgumentError('VPlatformFile must have a valid media source');
  }

  Future<void> _initializeAndConfigureVideo(VVideoStory story) async {
    await _videoPlayerController!.initialize();
    if (currentStory?.id != story.id) {
      return;
    }
    await _videoPlayerController!.setVolume(story.muted ? 0 : 1);
    await _videoPlayerController!.setLooping(story.looping);
    final duration = _videoPlayerController!.value.duration;
    notifyDuration(duration);
    if (story.autoPlay && currentStory?.id == story.id) {
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
