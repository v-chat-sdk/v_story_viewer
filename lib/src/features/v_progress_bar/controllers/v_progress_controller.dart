import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/v_progress_callbacks.dart';

/// Controller for managing story progress with count-based tracking
class VProgressController extends ChangeNotifier {
  VProgressController({required this.barCount, this.callbacks})
    : assert(barCount > 0, 'barCount must be greater than 0');

  /// Number of progress bars
  final int barCount;

  /// Callbacks for progress events
  final VProgressCallbacks? callbacks;

  /// Current index in the progress bar list
  int _currentIndex = -1;

  /// Current progress value (0.0 to 1.0) for the current bar
  double _currentProgress = 0;

  /// Current duration for the progress animation
  Duration _currentDuration = const Duration(seconds: 5);

  /// Animation timer
  Timer? _timer;

  /// Get current index
  int get currentIndex => _currentIndex;

  /// Get current progress
  double get currentProgress => _currentProgress;

  /// Check if progress is running
  bool get isRunning => _timer != null && _timer!.isActive;

  /// Get progress value for a specific bar index
  /// Returns:
  /// - 1.0 for completed bars (before current)
  /// - Current progress (0.0-1.0) for current bar
  /// - 0.0 for future bars (after current)
  double getProgress(int index) {
    assert(index >= 0 && index < barCount, 'Index out of bounds: $index');

    if (index < _currentIndex) return 1; // Completed bars
    if (index == _currentIndex) return _currentProgress; // Current bar
    return 0; // Future bars
  }

  /// Start progress for a specific bar index
  /// This will start animating from 0.0
  void startProgress(int index, Duration duration) {
    assert(index >= 0 && index < barCount, 'Index out of bounds: $index');

    // Cancel existing timer
    _timer?.cancel();

    // Update state
    _currentIndex = index;
    _currentProgress = 0;
    _currentDuration = duration;
    // Start timer
    _startTimer();
  }



  /// Start progress for a specific bar index
  /// This will start animating from 0.0
  void setCursorAt(int index) {
    assert(index >= 0 && index < barCount, 'Index out of bounds: $index');

    // Cancel existing timer
    _timer?.cancel();

    // Update state
    _currentIndex = index;
    _currentProgress = 0;
    notifyListeners();

  }

  /// Pause progress for current bar
  void pauseProgress() {
    _timer?.cancel();
    _timer = null;
  }

  /// Resume progress for current bar
  void resumeProgress() {
    if (_currentIndex != -1 && !isRunning) {
      _startTimer();
    }
  }

  /// Reset progress for current bar to 0.0
  void resetProgress() {
    if (_currentIndex != -1) {
      _currentProgress = 0;
      notifyListeners();
    }
  }


  /// Internal method to start the animation timer
  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      // Safety check: if timer was cancelled or controller disposed, stop execution
      if (_timer == null || _timer != timer) {
        timer.cancel();
        return;
      }

      _currentProgress += 60 / _currentDuration.inMilliseconds;

      if (_currentProgress >= 1) {
        _currentProgress = 1;
        timer.cancel();
        _timer = null;

        // Notify completion
        callbacks?.onBarComplete?.call(_currentIndex);
      }

      // Notify progress update
      callbacks?.onProgressUpdate?.call(_currentProgress);

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
