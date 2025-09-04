import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../models/v_story_models.dart';
import '../models/v_story_error.dart';
import '../controllers/v_story_controller.dart';
import '../utils/v_error_recovery.dart';
import '../utils/v_error_logger.dart';
import 'v_story_progress_bar.dart';

/// Base widget for displaying story content.
abstract class VStoryContent extends StatelessWidget {
  /// The story to display
  final VBaseStory story;
  
  /// The story controller
  final VStoryController controller;
  
  /// Whether the story is currently visible
  final bool isVisible;
  
  /// Error widget builder
  final Widget Function(BuildContext, Object?)? errorBuilder;
  
  /// Loading widget builder
  final Widget Function(BuildContext)? loadingBuilder;
  
  /// Creates a story content widget
  const VStoryContent({
    super.key,
    required this.story,
    required this.controller,
    this.isVisible = true,
    this.errorBuilder,
    this.loadingBuilder,
  });
  
  /// Factory constructor to create appropriate content widget
  factory VStoryContent.fromStory({
    Key? key,
    required VBaseStory story,
    required VStoryController controller,
    bool isVisible = true,
    Widget Function(BuildContext, Object?)? errorBuilder,
    Widget Function(BuildContext)? loadingBuilder,
    VTextStoryStyle? textStyle,
  }) {
    switch (story) {
      case VImageStory():
        return VImageStoryContent(
          key: key,
          story: story,
          controller: controller,
          isVisible: isVisible,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
        );
      case VVideoStory():
        return VVideoStoryContent(
          key: key,
          story: story,
          controller: controller,
          isVisible: isVisible,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
        );
      case VTextStory():
        return VTextStoryContent(
          key: key,
          story: story,
          controller: controller,
          isVisible: isVisible,
          style: textStyle,
        );
      case VCustomStory():
        return VCustomStoryContent(
          key: key,
          story: story,
          controller: controller,
          isVisible: isVisible,
        );
      default:
        throw UnsupportedError('Unknown story type: ${story.runtimeType}');
    }
  }
  
  /// Default loading widget
  Widget buildDefaultLoading(BuildContext context) {
    return loadingBuilder?.call(context) ??
        const VStoryLoadingIndicator();
  }
  
  /// Default error widget
  Widget buildDefaultError(BuildContext context, Object? error) {
    // Convert to VStoryError if needed
    final storyError = error is VStoryError 
        ? error 
        : VGenericError('Failed to load content', error);
    
    // Log the error
    VErrorLogger.logError(storyError);
    
    return errorBuilder?.call(context, error) ??
        VErrorRecovery.buildErrorPlaceholder(
          error: storyError,
          onRetry: storyError.isRetryable ? () {
            // Trigger reload through controller
            controller.reload();
          } : null,
        );
  }
}

/// Widget for displaying image stories.
class VImageStoryContent extends VStoryContent {
  /// Creates an image story content widget
  const VImageStoryContent({
    super.key,
    required VImageStory super.story,
    required super.controller,
    super.isVisible,
    super.errorBuilder,
    super.loadingBuilder,
  });
  
  VImageStory get imageStory => story as VImageStory;
  
  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }
    
    // Handle different image sources using VPlatformFile
    final media = imageStory.media;
    if (media.networkUrl != null) {
      return _buildNetworkImage(context);
    } else if (media.assetsPath != null) {
      return _buildAssetImage(context);
    } else if (media.fileLocalPath != null) {
      return _buildFileImage(context);
    } else if (media.bytes != null) {
      return _buildMemoryImage(context);
    } else {
      return buildDefaultError(context, 'No image source provided');
    }
  }
  
  Widget _buildNetworkImage(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageStory.media.networkUrl!,
      cacheKey: imageStory.media.getCachedUrlKey,
      fit: BoxFit.contain,
      placeholder: (context, url) => buildDefaultLoading(context),
      errorWidget: (context, url, error) => buildDefaultError(context, error),
      fadeInDuration: const Duration(milliseconds: 300),
    );
  }
  
  Widget _buildAssetImage(BuildContext context) {
    return Image.asset(
      imageStory.media.assetsPath!,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => 
          buildDefaultError(context, error),
    );
  }
  
  Widget _buildFileImage(BuildContext context) {
    return Image.file(
      File(imageStory.media.fileLocalPath!),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => 
          buildDefaultError(context, error),
    );
  }
  
  Widget _buildMemoryImage(BuildContext context) {
    return Image.memory(
      Uint8List.fromList(imageStory.media.bytes!),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => 
          buildDefaultError(context, error),
    );
  }
}

/// Widget for displaying video stories.
class VVideoStoryContent extends VStoryContent {
  /// Creates a video story content widget
  const VVideoStoryContent({
    super.key,
    required VVideoStory super.story,
    required super.controller,
    super.isVisible,
    super.errorBuilder,
    super.loadingBuilder,
  });
  
  VVideoStory get videoStory => story as VVideoStory;
  
  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }
    
    // Get video controller from story controller
    final videoController = controller.getVideoController(videoStory.id);
    
    if (videoController == null || !videoController.value.isInitialized) {
      return buildDefaultLoading(context);
    }
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player
        Center(
          child: AspectRatio(
            aspectRatio: videoController.value.aspectRatio,
            // Wrap VideoPlayer with IgnorePointer to prevent it from consuming gestures
            // This allows our gesture coordinator to handle all gestures properly
            child: IgnorePointer(
              child: VideoPlayer(videoController),
            ),
          ),
        ),
        // Mute button
        Positioned(
          bottom: 100,
          right: 16,
          child: VVideoMuteButton(
            controller: controller,
            videoStory: videoStory,
          ),
        ),
      ],
    );
  }
}

/// Mute button widget for video stories
class VVideoMuteButton extends StatefulWidget {
  final VStoryController controller;
  final VVideoStory videoStory;
  
  const VVideoMuteButton({
    super.key,
    required this.controller,
    required this.videoStory,
  });
  
  @override
  State<VVideoMuteButton> createState() => _VVideoMuteButtonState();
}

class _VVideoMuteButtonState extends State<VVideoMuteButton> {
  bool _isMuted = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize mute state from video story
    _isMuted = widget.videoStory.muted;
  }
  
  void _toggleMute() {
    final videoController = widget.controller.getVideoController(widget.videoStory.id);
    if (videoController != null) {
      setState(() {
        _isMuted = !_isMuted;
        videoController.setVolume(_isMuted ? 0.0 : 1.0);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleMute,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isMuted ? Icons.volume_off : Icons.volume_up,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Style configuration for text stories.
class VTextStoryStyle {
  /// Background color
  final Color backgroundColor;
  
  /// Text color
  final Color textColor;
  
  /// Text style
  final TextStyle? textStyle;
  
  /// Text alignment
  final TextAlign textAlign;
  
  /// Padding around text
  final EdgeInsets padding;
  
  /// Background gradient
  final Gradient? backgroundGradient;
  
  /// Creates a text story style
  const VTextStoryStyle({
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.textStyle,
    this.textAlign = TextAlign.center,
    this.padding = const EdgeInsets.all(24),
    this.backgroundGradient,
  });
  
  /// Creates a default style
  factory VTextStoryStyle.defaultStyle() => const VTextStoryStyle();
  
  /// Creates a gradient style
  factory VTextStoryStyle.gradient({
    required List<Color> colors,
    Color textColor = Colors.white,
    TextStyle? textStyle,
  }) {
    return VTextStoryStyle(
      textColor: textColor,
      textStyle: textStyle,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
    );
  }
}

/// Widget for displaying text stories.
class VTextStoryContent extends VStoryContent {
  /// Text story style
  final VTextStoryStyle? style;
  
  /// Creates a text story content widget
  const VTextStoryContent({
    super.key,
    required VTextStory super.story,
    required super.controller,
    super.isVisible,
    this.style,
  });
  
  VTextStory get textStory => story as VTextStory;
  
  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }
    
    final effectiveStyle = style ?? VTextStoryStyle.defaultStyle();
    
    return Container(
      decoration: BoxDecoration(
        color: effectiveStyle.backgroundGradient == null 
            ? textStory.backgroundColor
            : null,
        gradient: effectiveStyle.backgroundGradient,
      ),
      padding: effectiveStyle.padding,
      child: Center(
        child: Text(
          textStory.text,
          style: effectiveStyle.textStyle ?? TextStyle(
            color: textStory.textColor,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          textAlign: effectiveStyle.textAlign,
        ),
      ),
    );
  }
}

/// Widget for displaying custom stories.
class VCustomStoryContent extends VStoryContent {
  /// Creates a custom story content widget
  const VCustomStoryContent({
    super.key,
    required VCustomStory super.story,
    required super.controller,
    super.isVisible,
  });
  
  VCustomStory get customStory => story as VCustomStory;
  
  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }
    
    // Use the builder from the custom story
    return customStory.builder(context);
  }
}

/// Container widget that combines all story elements.
class VStoryContentContainer extends StatelessWidget {
  /// The story to display
  final VBaseStory story;
  
  /// The story controller
  final VStoryController controller;
  
  /// Whether to show loading indicator
  final bool showLoading;
  
  /// Text story style
  final VTextStoryStyle? textStyle;
  
  /// Error widget builder
  final Widget Function(BuildContext, Object?)? errorBuilder;
  
  /// Loading widget builder
  final Widget Function(BuildContext)? loadingBuilder;
  
  /// Creates a story content container
  const VStoryContentContainer({
    super.key,
    required this.story,
    required this.controller,
    this.showLoading = true,
    this.textStyle,
    this.errorBuilder,
    this.loadingBuilder,
  });
  
  @override
  Widget build(BuildContext context) {

    if (showLoading && controller.state.storyState.isLoading) {
      return const VStoryLoadingIndicator();
    }
   return VStoryContent.fromStory(
      story: story,
      controller: controller,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      textStyle: textStyle,
    );
  }
}