import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../v_story_models/models/v_image_story.dart';

/// Widget for displaying image stories
///
/// Handles different image sources (network, asset, file) with proper caching.
class VImageViewer extends StatelessWidget {
  const VImageViewer({
    required this.story,
    super.key,
  });

  final VImageStory story;

  @override
  Widget build(BuildContext context) {
    // Network image with caching
    if (story.media.networkUrl != null) {
      return CachedNetworkImage(
        imageUrl: story.media.networkUrl!,
        fit: story.fit,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.error, color: Colors.white),
        ),
      );
    }

    // Asset image
    if (story.media.assetsPath != null) {
      return Image.asset(
        story.media.assetsPath!,
        fit: story.fit,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.error, color: Colors.white),
        ),
      );
    }

    // File image
    if (story.media.fileLocalPath != null) {
      return Image.network(
        story.media.fileLocalPath!,
        fit: story.fit,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.error, color: Colors.white),
        ),
      );
    }

    // Bytes image
    if (story.media.bytes != null) {
      final rawBytes = story.media.bytes!;
      final bytes = rawBytes is Uint8List
          ? rawBytes
          : Uint8List.fromList(rawBytes);
      return Image.memory(
        bytes,
        fit: story.fit,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.error, color: Colors.white),
        ),
      );
    }

    // No valid source
    return const Center(
      child: Icon(Icons.broken_image, color: Colors.white, size: 48),
    );
  }
}
