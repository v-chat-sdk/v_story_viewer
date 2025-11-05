import 'package:flutter/material.dart';

import 'story_type.dart';
import 'v_base_story.dart';

/// Custom story model for displaying arbitrary Flutter widgets
///
/// Custom stories allow you to render any Flutter widget as a story.
/// The widget builder can optionally access the custom story controller
/// to handle asynchronous loading, pause/resume, and error states.
///
/// Example with async loading:
/// ```dart
/// VCustomStory(
///   id: 'custom_1',
///   groupId: 'group_1',
///   createdAt: DateTime.now(),
///   builder: (context) => MyCustomWidget(),
/// )
///
/// class MyCustomWidget extends StatefulWidget {
///   @override
///   State<MyCustomWidget> createState() => _MyCustomWidgetState();
/// }
///
/// class _MyCustomWidgetState extends State<MyCustomWidget> {
///   @override
///   void initState() {
///     super.initState();
///     _loadData();
///   }
///
///   Future<void> _loadData() async {
///     // Access controller via provider
///     final controller = VCustomStoryControllerProvider.of(context);
///     controller.startLoading();
///     try {
///       final data = await fetchData();
///       controller.finishLoading();
///       setState(() { /* update UI */ });
///     } catch (e) {
///       controller.setError(e.toString());
///     }
///   }
///   // ...
/// }
/// ```
@immutable
class VCustomStory extends VBaseStory {
  const VCustomStory({
    required super.id,
    required this.builder,
    required super.createdAt,
    required super.groupId,
    super.duration = const Duration(seconds: 5),
    super.isViewed,
    super.isReacted,
    super.metadata,
    this.errorBuilder,
    this.loadingBuilder,
  }) : super(storyType: VStoryType.custom);

  /// Builder function to create the custom widget
  ///
  /// The widget can access the custom story controller via:
  /// ```dart
  /// VCustomStoryControllerProvider.of(context)
  /// ```
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
    String? groupId,
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
      groupId: groupId ?? this.groupId,
      isViewed: isViewed ?? this.isViewed,
      isReacted: isReacted ?? this.isReacted,
      metadata: metadata ?? this.metadata,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
