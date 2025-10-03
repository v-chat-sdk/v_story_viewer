/// Enum representing different types of stories
enum VStoryType {
  /// A text-only story with customizable styling
  text,

  /// An image story from various sources (network, file, asset, bytes)
  image,

  /// A video story with playback controls
  video,

  /// A custom story type for developer-defined content
  custom,

  /// Unknown story type (fallback)
  unknown,
}

/// Extension methods for StoryType
extension VStoryTypeExtension on VStoryType {
  /// Convert enum to string for serialization
  String get name {
    switch (this) {
      case VStoryType.text:
        return 'text';
      case VStoryType.image:
        return 'image';
      case VStoryType.video:
        return 'video';
      case VStoryType.custom:
        return 'custom';
      case VStoryType.unknown:
        return 'unknown';
    }
  }

  /// Create StoryType from string
  static VStoryType fromString(String? value) {
    switch (value) {
      case 'text':
        return VStoryType.text;
      case 'image':
        return VStoryType.image;
      case 'video':
        return VStoryType.video;
      case 'custom':
        return VStoryType.custom;
      default:
        return VStoryType.unknown;
    }
  }
}
