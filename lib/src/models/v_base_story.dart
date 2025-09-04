import 'story_type.dart';

/// Base sealed class for all story types in the v_story_viewer package.
/// 
/// This sealed class provides the foundation for type-safe story representations,
/// ensuring compile-time safety when handling different story types.
abstract base class VBaseStory {
  /// Unique identifier for the story
  final String id;
  
  /// The type of story (text, image, video, custom, unknown)
  final StoryType storyType;
  
  /// How long this story should be displayed
  final Duration duration;
  
  /// When this story was viewed by the current user
  final DateTime? viewedAt;
  
  /// When this story was created
  final DateTime createdAt;
  
  /// When the user reacted to this story (shows love icon if has value)
  final DateTime? reactedAt;
  
  /// Additional metadata for the story
  final Map<String, dynamic>? metadata;
  
  /// Creates a base story with required and optional properties
  const VBaseStory({
    required this.id,
    required this.storyType,
    required this.duration,
    this.viewedAt,
    required this.createdAt,
    this.reactedAt,
    this.metadata,
  });
  
  /// Whether this story has been viewed
  bool get isViewed => viewedAt != null;
  
  /// Whether this story has been reacted to
  bool get isReacted => reactedAt != null;
  
  /// Alias for createdAt for backward compatibility
  DateTime get timestamp => createdAt;
  
  /// Creates a copy of this story with updated fields
  VBaseStory copyWith({
    String? id,
    StoryType? storyType,
    Duration? duration,
    DateTime? viewedAt,
    DateTime? createdAt,
    DateTime? reactedAt,
    Map<String, dynamic>? metadata,
  });
}