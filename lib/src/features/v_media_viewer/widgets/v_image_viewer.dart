import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:v_platform/v_platform.dart';

import '../controllers/v_image_controller.dart';

/// Widget for displaying image stories
///
/// Handles different image sources (network, asset, file) with proper caching.
class VImageViewer extends StatelessWidget {
  const VImageViewer({
    required this.controller,
    super.key,
  });

  final VImageController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final media = controller.cachedMedia;
        if (media == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildImageFromMedia(media);
      },
    );
  }

  Widget _buildImageFromMedia(VPlatformFile media) {
    // File image (cached local file on mobile)
    if (media.fileLocalPath != null) {
      return Image.file(
        File(media.fileLocalPath!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.error, color: Colors.white),
        ),
      );
    }

    // Network image (web or fallback)
    if (media.networkUrl != null) {
      return CachedNetworkImage(
        imageUrl: media.networkUrl!,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.error, color: Colors.white),
        ),
      );
    }

    // Asset image
    if (media.assetsPath != null) {
      return Image.asset(
        media.assetsPath!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.error, color: Colors.white),
        ),
      );
    }

    // Bytes image
    if (media.bytes != null) {
      final rawBytes = media.bytes!;
      final bytes = rawBytes is Uint8List
          ? rawBytes
          : Uint8List.fromList(rawBytes);
      return Image.memory(
        bytes,
        fit: BoxFit.contain,
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
