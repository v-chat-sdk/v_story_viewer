/// Enum representing the different types of stories that can be displayed
enum StoryType {
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