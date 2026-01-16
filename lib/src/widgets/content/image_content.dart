import 'dart:io';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import '../../models/v_story_error.dart';
import '../../models/v_story_item.dart';
import '../../models/v_story_config.dart';

/// Widget for displaying image stories
class ImageContent extends StatefulWidget {
  final VImageStory story;
  final VoidCallback onLoaded;
  final void Function(VStoryError error) onError;
  final void Function(double progress)? onProgress;
  final StoryLoadingBuilder? loadingBuilder;
  final StoryErrorBuilder? errorBuilder;
  const ImageContent({
    super.key,
    required this.story,
    required this.onLoaded,
    required this.onError,
    this.onProgress,
    this.loadingBuilder,
    this.errorBuilder,
  });
  @override
  State<ImageContent> createState() => _ImageContentState();
}

class _ImageContentState extends State<ImageContent> {
  bool _hasLoaded = false;
  bool _hasError = false;
  bool _isRetrying = false;
  int _retryCount = 0;
  static const int _maxRetries = 5;
  @override
  Widget build(BuildContext context) {
    if (widget.story.filePath != null) {
      return _buildFileImage();
    }
    return _buildNetworkImage();
  }

  Widget _buildFileImage() {
    return Image.file(
      File(widget.story.filePath!),
      fit: BoxFit.contain,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          if (!_hasLoaded) {
            _hasLoaded = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onLoaded();
            });
          }
          return child;
        }
        return _buildLoading();
      },
      errorBuilder: (context, error, stack) {
        _notifyError(error);
        return _buildError();
      },
    );
  }

  Widget _buildNetworkImage() {
    return ExtendedImage.network(
      widget.story.url!,
      fit: BoxFit.contain,
      cache: true,
      cacheKey: widget.story.cacheKey,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            final progress = state.loadingProgress?.expectedTotalBytes != null
                ? state.loadingProgress!.cumulativeBytesLoaded /
                    state.loadingProgress!.expectedTotalBytes!
                : null;
            if (progress != null) {
              widget.onProgress?.call(progress);
            }
            return _buildLoading(progress: progress);
          case LoadState.completed:
            if (!_hasLoaded) {
              _hasLoaded = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onLoaded();
              });
            }
            return state.completedWidget;
          case LoadState.failed:
            if (!_hasError && _retryCount < _maxRetries) {
              _retryWithBackoff();
            } else if (!_hasError) {
              _hasError = true;
              _notifyError(
                  Exception('Failed to load image after $_maxRetries retries'));
            }
            return _buildError();
        }
      },
    );
  }

  void _retryWithBackoff() {
    if (_isRetrying) return;
    _isRetrying = true;
    _retryCount++;
    final delay =
        Duration(seconds: 1 << (_retryCount - 1)); // 1s, 2s, 4s, 8s, 16s
    Future.delayed(delay, () {
      if (mounted) {
        _isRetrying = false;
        setState(() {});
      }
    });
  }

  void _notifyError(Object error, [StackTrace? stackTrace]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onError(_classifyError(error, stackTrace));
      }
    });
  }

  VStoryError _classifyError(Object error, [StackTrace? stackTrace]) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('socket') ||
        errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('unreachable')) {
      return VStoryNetworkError.fromException(error, stackTrace);
    }
    if (errorString.contains('timeout')) {
      return VStoryTimeoutError(
        message: 'Image load timed out',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    if (errorString.contains('permission') || errorString.contains('denied')) {
      return VStoryPermissionError.denied('storage', error, stackTrace);
    }
    if (errorString.contains('format') ||
        errorString.contains('codec') ||
        errorString.contains('unsupported')) {
      return VStoryFormatError(
        message: 'Unsupported image format',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    return VStoryLoadError.fromException(error, stackTrace);
  }

  Widget _buildLoading({double? progress}) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context);
    }
    return Container(
      color: Colors.black,
      child: Center(
        child: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _retry() {
    _retryCount = 0;
    _hasError = false;
    setState(() {});
  }

  Widget _buildError() {
    final error = VStoryLoadError(message: 'Failed to load image');
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, error, _retry);
    }
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load image',
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
