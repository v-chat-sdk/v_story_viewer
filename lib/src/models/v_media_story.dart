import 'package:v_platform/v_platform.dart';
import 'v_base_story.dart';

/// Abstract class for stories that contain media (images, videos).
///
/// This class provides a common interface for stories that have media files,
/// allowing type checking to determine if a story is media-based or not.
abstract base class VMediaStory extends VBaseStory {
  /// The media file for this story
  VPlatformFile get media;
  
  const VMediaStory({
    required super.id,
    required super.storyType,
    required super.duration,
    super.viewedAt,
    required super.createdAt,
    super.reactedAt,
    super.metadata,
  });
  
  /// Whether the media source is from a URL
  bool get isFromUrl => media.networkUrl != null;
  
  /// Whether the media source is from local path
  bool get isFromPath => media.fileLocalPath != null;
  
  /// Whether the media source is from assets
  bool get isFromAssets => media.assetsPath != null;
  
  /// Whether the media source is from bytes
  bool get isFromBytes => media.bytes != null;
}