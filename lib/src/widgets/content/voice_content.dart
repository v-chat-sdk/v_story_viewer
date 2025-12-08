import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/v_story_item.dart';
import '../../models/v_story_config.dart';
import '../../utils/story_cache_manager.dart';

/// State for voice content loading
enum _VoiceLoadState {
  checkingCache,
  downloading,
  initializing,
  ready,
  error,
}

/// Widget for displaying voice stories with slider and caching support
class VoiceContent extends StatefulWidget {
  final VVoiceStory story;
  final bool isPaused;
  final bool isMuted;
  final bool enableCaching;
  final void Function(Duration duration) onLoaded;
  final void Function(Object error) onError;
  final void Function(Duration position)? onProgress;
  final StoryLoadingBuilder? loadingBuilder;
  final StoryErrorBuilder? errorBuilder;
  const VoiceContent({
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
  State<VoiceContent> createState() => _VoiceContentState();
}

class _VoiceContentState extends State<VoiceContent> {
  final AudioPlayer _player = AudioPlayer();
  Duration? _duration;
  Duration _position = Duration.zero;
  _VoiceLoadState _loadState = _VoiceLoadState.checkingCache;
  double _downloadProgress = 0.0;
  int _retryCount = 0;
  static const int _maxRetries = 5;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  DateTime? _lastPositionUpdate;
  @override
  void initState() {
    super.initState();
    _setupListeners();
    _loadAudio();
  }

  @override
  void didUpdateWidget(VoiceContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.story != oldWidget.story) {
      _positionSubscription?.cancel();
      _durationSubscription?.cancel();
      _player.stop();
      _retryCount = 0;
      _downloadProgress = 0.0;
      _loadState = _VoiceLoadState.checkingCache;
      _position = Duration.zero;
      _duration = null;
      _setupListeners();
      _loadAudio();
      return;
    }
    if (widget.isPaused != oldWidget.isPaused) {
      Future.microtask(() {
        if (widget.isPaused) {
          _player.pause();
        } else {
          _player.resume();
        }
      });
    }
    if (widget.isMuted != oldWidget.isMuted) {
      _player.setVolume(widget.isMuted ? 0.0 : 1.0);
    }
  }

  void _setupListeners() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription = _player.onPositionChanged.listen((position) {
      if (!mounted) return;
      final now = DateTime.now();
      if (_lastPositionUpdate == null ||
          now.difference(_lastPositionUpdate!).inMilliseconds >= 100) {
        _lastPositionUpdate = now;
        setState(() => _position = position);
        widget.onProgress?.call(position);
      }
    });
    _durationSubscription = _player.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() => _duration = duration);
      }
    });
  }

  Future<void> _loadAudio() async {
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
    setState(() => _loadState = _VoiceLoadState.checkingCache);
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
    setState(() => _loadState = _VoiceLoadState.downloading);
    final downloadedFile = await StoryCacheManager.instance.downloadFile(
      widget.story.url!,
      cacheKey,
      onProgress: (progress) {
        if (mounted) {
          setState(() => _downloadProgress = progress);
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
    setState(() => _loadState = _VoiceLoadState.initializing);
    try {
      await _player.setSource(DeviceFileSource(filePath));
      await _finalizeInitialization();
    } catch (e) {
      if (mounted) _handleError(e);
    }
  }

  Future<void> _initializeFromUrl() async {
    if (!mounted) return;
    setState(() => _loadState = _VoiceLoadState.initializing);
    try {
      await _player.setSource(UrlSource(
        widget.story.url!,
        mimeType: kIsWeb ? 'audio/mpeg' : null,
      ));
      await _finalizeInitialization();
    } catch (e) {
      if (mounted) _handleError(e);
    }
  }

  Future<void> _finalizeInitialization() async {
    final duration = await _player.getDuration();
    if (!mounted) return;
    _duration = duration;
    await _player.setVolume(widget.isMuted ? 0.0 : 1.0);
    if (!mounted) return;
    setState(() => _loadState = _VoiceLoadState.ready);
    if (!widget.isPaused) {
      _player.resume();
    }
    widget.onLoaded(duration ?? const Duration(seconds: 30));
  }

  void _handleError(Object error) {
    if (!mounted) return;
    if (_retryCount < _maxRetries) {
      _retryCount++;
      final delay = Duration(seconds: 1 << (_retryCount - 1));
      Future.delayed(delay, () {
        if (mounted) _loadAudio();
      });
    } else {
      setState(() => _loadState = _VoiceLoadState.error);
      widget.onError(error);
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  void _retry() {
    _retryCount = 0;
    _downloadProgress = 0.0;
    _loadState = _VoiceLoadState.checkingCache;
    setState(() {});
    _loadAudio();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.story.backgroundColor;
    final gradient = backgroundColor == null
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          )
        : null;
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient,
      ),
      child: Center(
        child: switch (_loadState) {
          _VoiceLoadState.error => _buildError(),
          _VoiceLoadState.ready => _buildPlayer(),
          _VoiceLoadState.checkingCache => _buildLoading(null),
          _VoiceLoadState.downloading => _buildLoading(_downloadProgress),
          _VoiceLoadState.initializing => _buildLoading(null),
        },
      ),
    );
  }

  Widget _buildPlayer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Voice icon - larger with better styling
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.isPaused
                ? CupertinoIcons.play_fill
                : CupertinoIcons.mic_fill,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 40),
        // Dark container - constrained to match progress bar width (650 - 16 padding)
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 634),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  // Read-only slider - wrapped in IgnorePointer
                  Expanded(
                    child: IgnorePointer(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 5),
                          overlayShape: SliderComponentShape.noOverlay,
                          activeTrackColor: Colors.white,
                          inactiveTrackColor:
                              Colors.white.withValues(alpha: 0.3),
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: _position.inMilliseconds.toDouble(),
                          min: 0,
                          max: (_duration?.inMilliseconds ?? 1).toDouble(),
                          onChanged: (_) {},
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Time display inline
                  Text(
                    _formatDuration(_duration != null
                        ? _duration! - _position
                        : Duration.zero),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildLoading(double? downloadProgress) {
    return Column(
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
        if (downloadProgress != null) ...[
          const SizedBox(height: 16),
          Text(
            '${(downloadProgress * 100).toInt()}%',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildError() {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(
        context,
        Exception('Failed to load audio'),
        _retry,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          CupertinoIcons.exclamationmark_circle,
          color: Colors.white54,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          'Failed to load audio',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _retry,
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
