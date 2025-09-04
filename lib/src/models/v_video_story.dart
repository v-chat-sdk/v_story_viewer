import 'package:v_platform/v_platform.dart';
import 'story_type.dart';
import 'v_media_story.dart';

/// A story that displays a video with playback controls.
final class VVideoStory extends VMediaStory {
  @override
  final VPlatformFile media;
  
  /// Whether to show video controls
  final bool showControls;
  
  /// Whether to loop the video
  final bool loop;
  
  /// Whether to mute the video initially
  final bool muted;
  
  /// Video aspect ratio (width/height)
  final double? aspectRatio;
  
  /// Maximum duration for the video story (null means use actual video duration)
  final Duration? maxDuration;
  
  /// Creates a video story with the specified media and properties
  const VVideoStory({
    required super.id,
    required this.media,
    super.duration = const Duration(seconds: 0), // Will be calculated from video
    this.showControls = false,
    this.loop = false,
    this.muted = false,
    this.aspectRatio,
    this.maxDuration,
    super.viewedAt,
    required super.createdAt,
    super.reactedAt,
    super.metadata,
  }) : super(storyType: StoryType.video);
  
  /// Factory constructor for creating a video story from a URL
  factory VVideoStory.fromUrl({
    required String id,
    required String url,
    Duration? duration,
    Duration? maxDuration,
    bool showControls = false,
    bool loop = false,
    bool muted = false,
    double? aspectRatio,
    DateTime? viewedAt,
    required DateTime createdAt,
    DateTime? reactedAt,
    Map<String, dynamic>? metadata,
  }) {
    return VVideoStory(
      id: id,
      media: VPlatformFile.fromUrl(networkUrl: url),
      duration: duration ?? const Duration(seconds: 0),
      maxDuration: maxDuration,
      showControls: showControls,
      loop: loop,
      muted: muted,
      aspectRatio: aspectRatio,
      viewedAt: viewedAt,
      createdAt: createdAt,
      reactedAt: reactedAt,
      metadata: metadata,
    );
  }
  
  /// Factory constructor for creating a video story from a file path
  factory VVideoStory.fromPath({
    required String id,
    required String path,
    Duration? duration,
    Duration? maxDuration,
    bool showControls = false,
    bool loop = false,
    bool muted = false,
    double? aspectRatio,
    DateTime? viewedAt,
    required DateTime createdAt,
    DateTime? reactedAt,
    Map<String, dynamic>? metadata,
  }) {
    return VVideoStory(
      id: id,
      media: VPlatformFile.fromPath(fileLocalPath: path),
      duration: duration ?? const Duration(seconds: 0),
      maxDuration: maxDuration,
      showControls: showControls,
      loop: loop,
      muted: muted,
      aspectRatio: aspectRatio,
      viewedAt: viewedAt,
      createdAt: createdAt,
      reactedAt: reactedAt,
      metadata: metadata,
    );
  }
  
  /// Factory constructor for creating a video story from an asset
  factory VVideoStory.fromAsset({
    required String id,
    required String assetPath,
    Duration? duration,
    Duration? maxDuration,
    bool showControls = false,
    bool loop = false,
    bool muted = false,
    double? aspectRatio,
    DateTime? viewedAt,
    required DateTime createdAt,
    DateTime? reactedAt,
    Map<String, dynamic>? metadata,
  }) {
    return VVideoStory(
      id: id,
      media: VPlatformFile.fromAssets(assetsPath: assetPath),
      duration: duration ?? const Duration(seconds: 0),
      maxDuration: maxDuration,
      showControls: showControls,
      loop: loop,
      muted: muted,
      aspectRatio: aspectRatio,
      viewedAt: viewedAt,
      createdAt: createdAt,
      reactedAt: reactedAt,
      metadata: metadata,
    );
  }
  
  /// Whether the video has a maximum duration set
  bool get hasMaxDuration => maxDuration != null;
  
  /// Gets the effective aspect ratio
  double get effectiveAspectRatio => aspectRatio ?? 16 / 9; // Default 16:9
  
  /// Convenience getter for accessing the URL from media
  String? get url => media.networkUrl;
  
  /// Convenience getter for accessing the asset path from media
  String? get assetPath => media.assetsPath;
  
  /// Convenience getter for accessing the file from media
  String? get file => media.fileLocalPath;
  
  /// Gets the video duration (alias for duration field)
  Duration get videoDuration => duration;
  
  @override
  VVideoStory copyWith({
    String? id,
    VPlatformFile? media,
    Duration? duration,
    Duration? maxDuration,
    bool? showControls,
    bool? loop,
    bool? muted,
    double? aspectRatio,
    DateTime? viewedAt,
    DateTime? createdAt,
    DateTime? reactedAt,
    Map<String, dynamic>? metadata,
    StoryType? storyType,
  }) {
    return VVideoStory(
      id: id ?? this.id,
      media: media ?? this.media,
      duration: duration ?? this.duration,
      maxDuration: maxDuration ?? this.maxDuration,
      showControls: showControls ?? this.showControls,
      loop: loop ?? this.loop,
      muted: muted ?? this.muted,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      viewedAt: viewedAt ?? this.viewedAt,
      createdAt: createdAt ?? this.createdAt,
      reactedAt: reactedAt ?? this.reactedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}