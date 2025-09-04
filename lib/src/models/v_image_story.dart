import 'package:flutter/widgets.dart';
import 'package:v_platform/v_platform.dart';
import 'story_type.dart';
import 'v_media_story.dart';

/// A story that displays an image with optional caption and customization.
final class VImageStory extends VMediaStory {
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
  
  /// Creates an image story with the specified media and properties
  const VImageStory({
    required super.id,
    required this.media,
    required super.duration,
    this.fit = BoxFit.contain,
    this.caption,
    this.aspectRatio,
    this.dimensions,
    super.viewedAt,
    required super.createdAt,
    super.reactedAt,
    super.metadata,
  }) : super(storyType: StoryType.image);
  
  /// Factory constructor for creating an image story from a URL
  factory VImageStory.fromUrl({
    required String id,
    required String url,
    required Duration duration,
    BoxFit fit = BoxFit.contain,
    String? caption,
    double? aspectRatio,
    Size? dimensions,
    DateTime? viewedAt,
    required DateTime createdAt,
    DateTime? reactedAt,
    Map<String, dynamic>? metadata,
  }) {
    return VImageStory(
      id: id,
      media: VPlatformFile.fromUrl(networkUrl: url),
      duration: duration,
      fit: fit,
      caption: caption,
      aspectRatio: aspectRatio,
      dimensions: dimensions,
      viewedAt: viewedAt,
      createdAt: createdAt,
      reactedAt: reactedAt,
      metadata: metadata,
    );
  }
  
  /// Factory constructor for creating an image story from a file path
  factory VImageStory.fromPath({
    required String id,
    required String path,
    required Duration duration,
    BoxFit fit = BoxFit.contain,
    String? caption,
    double? aspectRatio,
    Size? dimensions,
    DateTime? viewedAt,
    required DateTime createdAt,
    DateTime? reactedAt,
    Map<String, dynamic>? metadata,
  }) {
    return VImageStory(
      id: id,
      media:VPlatformFile.fromPath(fileLocalPath: path),
      duration: duration,
      fit: fit,
      caption: caption,
      aspectRatio: aspectRatio,
      dimensions: dimensions,
      viewedAt: viewedAt,
      createdAt: createdAt,
      reactedAt: reactedAt,
      metadata: metadata,
    );
  }
  
  /// Factory constructor for creating an image story from an asset
  factory VImageStory.fromAsset({
    required String id,
    required String assetPath,
    required Duration duration,
    BoxFit fit = BoxFit.contain,
    String? caption,
    double? aspectRatio,
    Size? dimensions,
    DateTime? viewedAt,
    required DateTime createdAt,
    DateTime? reactedAt,
    Map<String, dynamic>? metadata,
  }) {
    return VImageStory(
      id: id,
      media: VPlatformFile.fromAssets(assetsPath: assetPath),
      duration: duration,
      fit: fit,
      caption: caption,
      aspectRatio: aspectRatio,
      dimensions: dimensions,
      viewedAt: viewedAt,
      createdAt: createdAt,
      reactedAt: reactedAt,
      metadata: metadata,
    );
  }
  
  /// Gets the effective aspect ratio (calculated or provided)
  double get effectiveAspectRatio {
    if (aspectRatio != null) return aspectRatio!;
    if (dimensions != null && dimensions!.height > 0) {
      return dimensions!.width / dimensions!.height;
    }
    return 1.0; // Default square ratio
  }
  
  /// Whether the image has caption text
  bool get hasCaption => caption != null && caption!.isNotEmpty;
  
  /// Convenience getter for accessing the URL from media
  String? get url => media.networkUrl;
  
  /// Convenience getter for accessing the asset path from media
  String? get assetPath => media.assetsPath;
  
  /// Convenience getter for accessing the file path from media
  String? get file => media.fileLocalPath;
  
  /// Convenience getter for accessing bytes from media (not implemented in VPlatformFile)
  List<int>? get bytes => null; // VPlatformFile doesn't support bytes directly
  
  @override
  VImageStory copyWith({
    String? id,
    VPlatformFile? media,
    Duration? duration,
    BoxFit? fit,
    String? caption,
    double? aspectRatio,
    Size? dimensions,
    DateTime? viewedAt,
    DateTime? createdAt,
    DateTime? reactedAt,
    Map<String, dynamic>? metadata,
    StoryType? storyType,
  }) {
    return VImageStory(
      id: id ?? this.id,
      media: media ?? this.media,
      duration: duration ?? this.duration,
      fit: fit ?? this.fit,
      caption: caption ?? this.caption,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      dimensions: dimensions ?? this.dimensions,
      viewedAt: viewedAt ?? this.viewedAt,
      createdAt: createdAt ?? this.createdAt,
      reactedAt: reactedAt ?? this.reactedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}