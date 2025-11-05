import 'package:flutter/material.dart';

import '../controllers/v_custom_story_controller.dart';

/// InheritedWidget that exposes VCustomStoryController to custom story widgets
///
/// Used internally to pass the controller from VCustomViewer to custom widgets.
/// Custom widgets can access it via:
/// ```dart
/// final controller = VCustomStoryControllerProvider.of(context);
/// ```
class VCustomStoryControllerProvider extends InheritedWidget {
  const VCustomStoryControllerProvider({
    required this.controller,
    required super.child,
    super.key,
  });

  final VCustomStoryController controller;

  /// Retrieve the controller from the widget tree
  ///
  /// Throws if not found. Use [maybeOf] if uncertain.
  static VCustomStoryController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<VCustomStoryControllerProvider>();
    if (provider == null) {
      throw FlutterError(
        'VCustomStoryControllerProvider.of() called with a context that '
        'does not contain a VCustomStoryControllerProvider.\n'
        'Make sure VCustomStory is being used within v_story_viewer.',
      );
    }
    return provider.controller;
  }

  /// Retrieve the controller, or null if not found
  static VCustomStoryController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<VCustomStoryControllerProvider>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(VCustomStoryControllerProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}
