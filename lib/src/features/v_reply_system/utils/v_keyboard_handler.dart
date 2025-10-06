import 'package:flutter/material.dart';

/// A utility for handling keyboard visibility.
class VKeyboardHandler extends ChangeNotifier with WidgetsBindingObserver {
  /// Creates a new instance of [VKeyboardHandler].
  VKeyboardHandler() {
    WidgetsBinding.instance.addObserver(this);
  }

  bool _isKeyboardVisible = false;

  /// Whether the keyboard is currently visible.
  bool get isKeyboardVisible => _isKeyboardVisible;

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;
    final newVisibility = bottomInset > 0;
    if (newVisibility != _isKeyboardVisible) {
      _isKeyboardVisible = newVisibility;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
