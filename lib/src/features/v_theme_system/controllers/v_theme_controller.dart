import 'package:flutter/foundation.dart';

import '../models/v_story_theme.dart';

/// Controller for managing theme state
class VThemeController extends ChangeNotifier {
  VThemeController({VStoryTheme? theme}) : _theme = theme ?? VStoryTheme.dark();

  VStoryTheme _theme;
  bool _isDarkMode = true;

  /// Get current theme
  VStoryTheme get theme => _theme;

  /// Check if dark mode is enabled
  bool get isDarkMode => _isDarkMode;

  /// Update theme
  void updateTheme(VStoryTheme theme) {
    if (_theme != theme) {
      _theme = theme;
      _isDarkMode = theme.colorScheme.background.computeLuminance() < 0.5;
      notifyListeners();
    }
  }
}
