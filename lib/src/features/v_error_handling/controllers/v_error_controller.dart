import 'package:flutter/foundation.dart';

import '../models/v_story_error.dart';

/// Controller for managing error state
class VErrorController extends ChangeNotifier {
  VStoryError? _currentError;
  final List<VStoryError> _errorHistory = [];

  /// Get current error
  VStoryError? get currentError => _currentError;

  /// Check if there's an active error
  bool get hasError => _currentError != null;

  /// Get error history
  List<VStoryError> get errorHistory => List.unmodifiable(_errorHistory);

  /// Set an error
  void setError(VStoryError error) {
    _currentError = error;
    _errorHistory.add(error);
    notifyListeners();
  }

  /// Clear current error
  void clearError() {
    _currentError = null;
    notifyListeners();
  }

  /// Clear all errors including history
  void clearAll() {
    _currentError = null;
    _errorHistory.clear();
    notifyListeners();
  }

  /// Get error message or default
  String getErrorMessage({String defaultMessage = 'An error occurred'}) {
    return _currentError?.message ?? defaultMessage;
  }

  @override
  void dispose() {
    clearAll();
    super.dispose();
  }
}
