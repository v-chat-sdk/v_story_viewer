import 'package:flutter/widgets.dart';
import 'story_type.dart';
import 'v_base_story.dart';

/// A story that displays custom Flutter widgets.
/// 
/// This allows developers to create any type of story content
/// using their own widgets while still benefiting from the
/// story viewer's navigation and control features.
final class VCustomStory extends VBaseStory {
  /// Builder function that creates the custom widget
  final Widget Function(BuildContext context) builder;
  
  /// Optional background color for the custom story
  final Color? backgroundColor;
  
  /// Whether to apply safe area padding
  final bool useSafeArea;
  
  /// Creates a custom story with a widget builder
  const VCustomStory({
    required super.id,
    required this.builder,
    required super.duration,
    this.backgroundColor,
    this.useSafeArea = true,
    super.viewedAt,
    required super.createdAt,
    super.reactedAt,
    super.metadata,
  }) : super(storyType: StoryType.custom);
  
  /// Factory constructor for creating a simple custom story
  factory VCustomStory.widget({
    required String id,
    required Widget Function(BuildContext context) builder,
    required Duration duration,
    Color? backgroundColor,
    bool useSafeArea = true,
    DateTime? viewedAt,
    required DateTime createdAt,
    DateTime? reactedAt,
    Map<String, dynamic>? metadata,
  }) {
    return VCustomStory(
      id: id,
      builder: builder,
      duration: duration,
      backgroundColor: backgroundColor,
      useSafeArea: useSafeArea,
      viewedAt: viewedAt,
      createdAt: createdAt,
      reactedAt: reactedAt,
      metadata: metadata,
    );
  }
  
  @override
  VCustomStory copyWith({
    String? id,
    Widget Function(BuildContext context)? builder,
    Duration? duration,
    Color? backgroundColor,
    bool? useSafeArea,
    DateTime? viewedAt,
    DateTime? createdAt,
    DateTime? reactedAt,
    Map<String, dynamic>? metadata,
    StoryType? storyType,
  }) {
    return VCustomStory(
      id: id ?? this.id,
      builder: builder ?? this.builder,
      duration: duration ?? this.duration,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      useSafeArea: useSafeArea ?? this.useSafeArea,
      viewedAt: viewedAt ?? this.viewedAt,
      createdAt: createdAt ?? this.createdAt,
      reactedAt: reactedAt ?? this.reactedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}