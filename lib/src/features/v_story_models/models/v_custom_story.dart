import 'package:flutter/material.dart';

import 'story_type.dart';
import 'v_base_story.dart';

/// Custom story model for displaying arbitrary Flutter widgets
@immutable
class VCustomStory extends VBaseStory {
  const VCustomStory({
    required super.id,
    required this.builder,
    required super.createdAt,

    super.duration = const Duration(seconds: 5),
    super.isViewed,
    super.isReacted,
    super.metadata,
    this.errorBuilder,
    this.loadingBuilder,
  }) : super(storyType: VStoryType.custom);

  /// Builder function to create the custom widget
  final Widget Function(BuildContext context) builder;

  /// Optional custom error widget builder
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Optional loading widget while custom content is being prepared
  final Widget Function(BuildContext context)? loadingBuilder;

  @override
  VCustomStory copyWith({
    String? id,
    Widget Function(BuildContext context)? builder,
    Duration? duration,
    DateTime? createdAt,

    bool? isViewed,
    bool? isReacted,

    Map<String, dynamic>? metadata,
    Widget Function(BuildContext context, Object error)? errorBuilder,
    Widget Function(BuildContext context)? loadingBuilder,
  }) {
    return VCustomStory(
      id: id ?? this.id,
      builder: builder ?? this.builder,
      duration: duration ?? this.duration,

      isViewed: isViewed ?? this.isViewed,
      isReacted: isReacted ?? this.isReacted,
      metadata: metadata ?? this.metadata,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,

      createdAt: createdAt ?? this.createdAt,
    );
  }
}
