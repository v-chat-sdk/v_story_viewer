import 'package:flutter/widgets.dart';

import '../controllers/v_theme_controller.dart';
import '../models/v_story_theme.dart';

/// Provider widget for theme
class VThemeProvider extends InheritedNotifier<VThemeController> {
  const VThemeProvider({
    required VThemeController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  /// Get theme controller from context
  static VThemeController? maybeOf(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<VThemeProvider>();
    return provider?.notifier;
  }

  /// Get theme controller from context (throws if not found)
  static VThemeController of(BuildContext context) {
    final controller = maybeOf(context);
    return controller!;
  }

  /// Get current theme from context
  static VStoryTheme? maybeTheme(BuildContext context) {
    return maybeOf(context)?.theme;
  }

  /// Get current theme from context (throws if not found)
  static VStoryTheme theme(BuildContext context) {
    return of(context).theme;
  }

  /// Check if dark mode is enabled
  static bool isDarkMode(BuildContext context) {
    return maybeOf(context)?.isDarkMode ?? true;
  }
}
