import 'package:flutter/widgets.dart';
import 'package:v_platform/v_platform.dart';

import 'story_type.dart';
import 'v_media_story.dart';

/// A story that displays an image with optional caption and customization.
final class VImageStory extends VMediaStory {
  /// Creates an image story with the specified media and properties
  const VImageStory({
    required super.id,
    required super.isViewed,
    required super.isReacted,
    required this.media,
    required super.duration,
    required super.createdAt,
    this.fit = BoxFit.contain,
    this.caption,
    this.aspectRatio,
    this.dimensions,
    super.metadata,
  }) : super(storyType: VStoryType.image);


  @override
  final VPlatformFile media;

  /// How the image should be fitted within its container
  final BoxFit fit;

  /// Optional caption for the image
  final String? caption;

  /// Aspect ratio of the image
  final double? aspectRatio;

  /// Image dimensions for aspect ratio calculation
  final Size? dimensions;

  /// Gets the effective aspect ratio (calculated or provided)
  double get effectiveAspectRatio {
    if (aspectRatio != null) return aspectRatio!;
    if (dimensions != null && dimensions!.height > 0) {
      return dimensions!.width / dimensions!.height;
    }
    return 1; // Default square ratio
  }

  /// Whether the image has caption text
  bool get hasCaption => caption != null && caption!.isNotEmpty;

  /// Convenience getter for accessing the URL from media
  String? get url => media.networkUrl;

  /// Convenience getter for accessing the asset path from media
  String? get assetPath => media.assetsPath;

  /// Convenience getter for accessing the file path from media
  String? get file => media.fileLocalPath;


  @override
  VImageStory copyWith({
    String? id,
    VPlatformFile? media,
    Duration? duration,
    DateTime? createdAt,
    bool? isViewed,
    bool? isReacted,
    Map<String, dynamic>? metadata,
  }) {
    return VImageStory(
      id: id ?? this.id,
      media: media ?? this.media,
      duration: duration ?? this.duration,
      fit: this.fit,
      caption: this.caption,
      aspectRatio: this.aspectRatio,
      dimensions: this.dimensions,
      createdAt: createdAt ?? this.createdAt,
      isViewed: isViewed ?? this.isViewed,
      isReacted: isReacted ?? this.isReacted,
      metadata: metadata ?? this.metadata,
    );
  }
}
