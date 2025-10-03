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

  /// Toggle between light and dark theme
  void toggleTheme() {
    if (_isDarkMode) {
      updateTheme(VStoryTheme.light());
    } else {
      updateTheme(VStoryTheme.dark());
    }
  }

  /// Set WhatsApp theme
  void setWhatsAppTheme() {
    updateTheme(VStoryTheme.whatsapp());
  }

  /// Set Instagram theme
  void setInstagramTheme() {
    updateTheme(VStoryTheme.instagram());
  }

  /// Apply theme from brightness
  void applyThemeFromBrightness(Brightness brightness) {
    if (brightness == Brightness.dark) {
      updateTheme(VStoryTheme.dark());
    } else {
      updateTheme(VStoryTheme.light());
    }
  }

  /// Create a custom theme
  void setCustomTheme({required VStoryTheme theme}) {
    updateTheme(theme);
  }

  /// Reset to default theme
  void resetTheme() {
    updateTheme(VStoryTheme.dark());
  }

  @override
  void dispose() {
    super.dispose();
  }
}
