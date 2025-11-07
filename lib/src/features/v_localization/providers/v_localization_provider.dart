import 'package:flutter/material.dart';
import '../models/v_localization.dart';

/// Provides VLocalization to the widget tree using InheritedWidget
class VLocalizationProvider extends InheritedWidget {
  const VLocalizationProvider({
    required this.localization,
    required super.child,
    super.key,
  });

  /// The localization instance
  final VLocalization localization;

  /// Get VLocalization from context
  static VLocalization of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<VLocalizationProvider>();
    assert(
      provider != null,
      'VLocalizationProvider not found in widget tree. '
      'Ensure VStoryViewer is wrapped with VLocalizationProvider or pass localization to VStoryViewer.',
    );
    return provider!.localization;
  }

  /// Try to get VLocalization without asserting
  static VLocalization? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<VLocalizationProvider>()?.localization;
  }

  @override
  bool updateShouldNotify(VLocalizationProvider oldWidget) {
    return localization != oldWidget.localization;
  }
}
