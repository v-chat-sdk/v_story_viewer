import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/v_story_error.dart';
import '../../models/v_story_item.dart';
import '../../models/v_story_config.dart';
import '../../utils/story_cache_manager.dart';

/// State for video content loading
enum _VideoLoadState {
  checkingCache,
  downloading,
  initializing,
  ready,
  error,
}

/// Widget for displaying video stories with caching support
class VideoContent extends StatefulWidget {
  final VVideoStory story;
  final bool isPaused;
  final bool isMuted;
  final bool enableCaching;
  final void Function(Duration duration) onLoaded;
  final void Function(VStoryError error) onError;
  final void Function(Duration position)? onProgress;
  final StoryLoadingBuilder? loadingBuilder;
  final StoryErrorBuilder? errorBuilder;
  const VideoContent({
    super.key,
    required this.story,
    required this.isPaused,
    this.isMuted = false,
    this.enableCaching = true,
    required this.onLoaded,
    required this.onError,
    this.onProgress,
    this.loadingBuilder,
    this.errorBuilder,
  });
  @override
  State<VideoContent> createState() => _VideoContentState();
}

class _VideoContentState extends State<VideoContent> {
  VideoPlayerController? _controller;
  _VideoLoadState _loadState = _VideoLoadState.checkingCache;
  double _overallProgress = 0.0;
  int _retryCount = 0;
  static const int _maxRetries = 5;
  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  @override
  void didUpdateWidget(VideoContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.story != oldWidget.story) {
      _disposeController().then((_) {
        if (mounted) {
          _retryCount = 0;
          _overallProgress = 0.0;
          _loadState = _VideoLoadState.checkingCache;
          _loadVideo();
        }
      });
      return;
    }
    if (widget.isPaused != oldWidget.isPaused) {
      Future.microtask(() {
        if (widget.isPaused) {
          _controller?.pause();
        } else {
          _controller?.play();
        }
      });
    }
    if (widget.isMuted != oldWidget.isMuted) {
      _controller?.setVolume(widget.isMuted ? 0.0 : 1.0);
    }
  }

  Future<void> _loadVideo() async {
    // If local file path provided, use it directly
    if (widget.story.filePath != null) {
      await _initializeFromFile(widget.story.filePath!);
      return;
    }
    // Check if caching is supported and enabled
    final shouldCache = widget.enableCaching &&
        StoryCacheManager.isCachingSupported &&
        widget.story.cacheKey != null;
    if (!shouldCache) {
      // Stream directly from URL
      await _initializeFromUrl();
      return;
    }
    // Check cache first
    if (!mounted) return;
    setState(() => _loadState = _VideoLoadState.checkingCache);
    final cacheKey = widget.story.cacheKey!;
    final cachedFile = await StoryCacheManager.instance.getCachedFile(cacheKey);
    if (!mounted) return;
    if (cachedFile != null) {
      // Play from cached file
      await _initializeFromFile(cachedFile.path);
      return;
    }
    // Download with progress
    if (!mounted) return;
    setState(() => _loadState = _VideoLoadState.downloading);
    final downloadedFile = await StoryCacheManager.instance.downloadFile(
      widget.story.url!,
      cacheKey,
      onProgress: (progress) {
        if (mounted) {
          setState(() => _overallProgress = progress * 0.8); // 0-80%
        }
      },
    );
    if (!mounted) return;
    if (downloadedFile != null) {
      await _initializeFromFile(downloadedFile.path);
    } else {
      // Download failed, try streaming from URL
      await _initializeFromUrl();
    }
  }

  Future<void> _initializeFromFile(String filePath) async {
    if (!mounted) return;
    setState(() {
      _loadState = _VideoLoadState.initializing;
      _overallProgress = 0.8; // Start at 80%
    });
    Timer? progressTimer;
    try {
      final controller = VideoPlayerController.file(File(filePath));
      // Simulate progress 80% -> 95% during init
      progressTimer =
          Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted || _overallProgress >= 0.95) {
          timer.cancel();
          return;
        }
        setState(() =>
            _overallProgress = (_overallProgress + 0.01).clamp(0.0, 0.95));
      });
      await controller.initialize().timeout(const Duration(seconds: 30));
      progressTimer.cancel();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() => _overallProgress = 1.0); // 100% when truly ready
      _setupController(controller);
    } catch (e) {
      progressTimer?.cancel();
      if (mounted) _handleError(e);
    }
  }

  Future<void> _initializeFromUrl() async {
    if (!mounted) return;
    setState(() {
      _loadState = _VideoLoadState.initializing;
      _overallProgress = 0.0; // URL streaming starts from 0
    });
    Timer? progressTimer;
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.story.url!),
      );
      // Simulate progress 0% -> 95% during streaming init
      progressTimer =
          Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted || _overallProgress >= 0.95) {
          timer.cancel();
          return;
        }
        setState(() =>
            _overallProgress = (_overallProgress + 0.02).clamp(0.0, 0.95));
      });
      await controller.initialize().timeout(const Duration(seconds: 30));
      progressTimer.cancel();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() => _overallProgress = 1.0); // 100% when truly ready
      if (kIsWeb) await controller.setVolume(0.0);
      _setupController(controller);
    } catch (e) {
      progressTimer?.cancel();
      if (mounted) _handleError(e);
    }
  }

  void _setupController(VideoPlayerController controller) {
    if (!mounted) {
      controller.dispose();
      return;
    }
    _controller = controller;
    _controller!.addListener(_onVideoProgress);
    _controller!.setLooping(false);
    _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);
    if (!widget.isPaused) {
      _controller!.play();
    }
    setState(() => _loadState = _VideoLoadState.ready);
    widget.onLoaded(_controller!.value.duration);
  }

  void _handleError(Object error, [StackTrace? stackTrace]) {
    if (!mounted) return;
    if (_retryCount < _maxRetries) {
      _retryCount++;
      final delay = Duration(seconds: 1 << (_retryCount - 1));
      Future.delayed(delay, () {
        if (mounted) _loadVideo();
      });
    } else {
      setState(() => _loadState = _VideoLoadState.error);
      widget.onError(_classifyError(error, stackTrace));
    }
  }

  VStoryError _classifyError(Object error, [StackTrace? stackTrace]) {
    final errorString = error.toString().toLowerCase();
    if (error is TimeoutException || errorString.contains('timeout')) {
      return VStoryTimeoutError.withDuration(
        const Duration(seconds: 30),
        error,
        stackTrace,
      );
    }
    if (errorString.contains('socket') ||
        errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('unreachable')) {
      return VStoryNetworkError.fromException(error, stackTrace);
    }
    if (errorString.contains('cache') ||
        errorString.contains('disk') ||
        errorString.contains('storage full')) {
      return VStoryCacheError.fromException(error, stackTrace);
    }
    if (errorString.contains('permission') || errorString.contains('denied')) {
      return VStoryPermissionError.denied('storage', error, stackTrace);
    }
    if (errorString.contains('format') ||
        errorString.contains('codec') ||
        errorString.contains('unsupported')) {
      return VStoryFormatError(
        message: 'Unsupported video format',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    return VStoryLoadError.fromException(error, stackTrace);
  }

  void _onVideoProgress() {
    if (_controller?.value.position != null) {
      widget.onProgress?.call(_controller!.value.position);
    }
  }

  Future<void> _disposeController() async {
    if (_controller == null) return;
    final controller = _controller;
    _controller = null;
    await controller!.pause();
    controller.removeListener(_onVideoProgress);
    await controller.dispose();
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _retry() {
    _retryCount = 0;
    _overallProgress = 0.0;
    _loadState = _VideoLoadState.checkingCache;
    setState(() {});
    _loadVideo();
  }

  @override
  Widget build(BuildContext context) {
    return switch (_loadState) {
      _VideoLoadState.error => _buildError(),
      _VideoLoadState.ready => _buildVideo(),
      _VideoLoadState.checkingCache => _buildLoading(null),
      _VideoLoadState.downloading => _buildLoading(_overallProgress),
      _VideoLoadState.initializing =>
        _buildLoading(_overallProgress), // Show progress during init
    };
  }

  Widget _buildLoading(double? progress) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.loadingBuilder != null)
              widget.loadingBuilder!(context)
            else
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            if (progress != null) ...[
              const SizedBox(height: 16),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideo() {
    return Container(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }

  Widget _buildError() {
    final error = VStoryLoadError(message: 'Failed to load video');
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, error, _retry);
    }
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle,
              color: Colors.white54,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load video',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _retry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
