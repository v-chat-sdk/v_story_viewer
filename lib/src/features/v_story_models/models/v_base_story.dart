import 'package:flutter/foundation.dart';

import 'story_type.dart';

/// Base abstract class for all story types
@immutable
abstract class VBaseStory {
  const VBaseStory({
    required this.id,
    required this.createdAt,
    required this.storyType,
    required this.groupId,
    this.duration,
    this.isViewed = false,
    this.isReacted = false,
    this.metadata,
  });

  /// Unique identifier for the story
  final String id;

  /// groupId for the story
  final String groupId;

  /// Duration for how long the story should be displayed
  /// If null, defaults will be calculated based on story type
  final Duration? duration;

  /// Timestamp when the story was created
  final DateTime createdAt;
  final VStoryType storyType;

  /// Whether the story has been viewed by the current user
  final bool isViewed;

  /// Whether the story has been reacted to by the current user
  final bool isReacted;

  /// Additional metadata as key-value pairs
  final Map<String, dynamic>? metadata;

  /// Creates a copy of the story with updated fields
  VBaseStory copyWith({
    String? id,
    Duration? duration,
    DateTime? createdAt,
    bool? isViewed,
    bool? isReacted,
    String? groupId,
    Map<String, dynamic>? metadata,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VBaseStory && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '${storyType.name}(id: $id)';
}
