import 'package:flutter/foundation.dart';
import 'package:v_platform/v_platform.dart';

import 'story_type.dart';
import 'v_media_story.dart';

/// Video story model for displaying video content
@immutable
final class VVideoStory extends VMediaStory {
  const VVideoStory({
    required super.id,
    required this.media,
    required super.isViewed,
    required super.isReacted,
    required super.duration,
    required super.createdAt,
    required super.groupId,
    this.thumbnail,
    this.aspectRatio,
    this.autoPlay = true,
    this.muted = false,
    this.looping = false,
    super.metadata,
    super.caption,
    super.source,
  }) : super(storyType: VStoryType.video);

  /// Media file containing the video resource
  @override
  final VPlatformFile media;

  /// Optional thumbnail image for the video
  final VPlatformFile? thumbnail;

  /// Aspect ratio for the video display
  final double? aspectRatio;

  /// Whether to auto-play the video
  final bool autoPlay;

  /// Whether to start muted
  final bool muted;

  /// Whether to loop the video
  final bool looping;

  /// Convenience getter for accessing the URL from media
  String? get url => media.networkUrl;

  /// Convenience getter for accessing the asset path from media
  String? get assetPath => media.assetsPath;

  /// Convenience getter for accessing the file path from media
  String? get file => media.fileLocalPath;

  @override
  VVideoStory copyWith({
    String? id,
    VPlatformFile? media,
    Duration? duration,
    DateTime? createdAt,
    bool? isViewed,
    String? groupId,
    bool? isReacted,
    Map<String, dynamic>? metadata,
    String? caption,
    String? source,
  }) {
    return VVideoStory(
      id: id ?? this.id,
      media: media ?? this.media,
      duration: duration ?? this.duration,
      groupId: groupId ?? this.groupId,
      thumbnail: this.thumbnail,
      aspectRatio: this.aspectRatio,
      autoPlay: this.autoPlay,
      muted: this.muted,
      looping: this.looping,
      createdAt: createdAt ?? this.createdAt,
      isViewed: isViewed ?? this.isViewed,
      isReacted: isReacted ?? this.isReacted,
      metadata: metadata ?? this.metadata,
      caption: caption ?? this.caption,
      source: source ?? this.source,
    );
  }
}
