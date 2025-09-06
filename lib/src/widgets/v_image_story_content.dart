import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/v_story_models.dart';
import 'v_story_content.dart';

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