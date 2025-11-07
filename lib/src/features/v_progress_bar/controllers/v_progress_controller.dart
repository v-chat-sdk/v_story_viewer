import 'package:flutter/foundation.dart';

import '../models/v_progress_callbacks.dart';
import '../utils/v_progress_timer.dart';

/// Controller for managing story progress with count-based tracking
///
/// Refactored to delegate timer logic to VProgressTimer for better separation of concerns.
class VProgressController extends ChangeNotifier {
  VProgressController({required this.barCount, this.callbacks})
    : assert(barCount > 0, 'barCount must be greater than 0') {
    _timer = VProgressTimer(
      onTick: _handleProgressTick,
      onComplete: _handleProgressComplete,
    );
  }

  final int barCount;
  final VProgressCallbacks? callbacks;

  late final VProgressTimer _timer;
  int _currentIndex = -1;
  double _currentProgress = 0;
  Duration? _reportedDuration;

  int get currentIndex => _currentIndex;

  double get currentProgress => _currentProgress;

  bool get isRunning => _timer.isActive;

  double getProgress(int index) {
    assert(index >= 0 && index < barCount, 'Index out of bounds: $index');

    if (index < _currentIndex) return 1;
    if (index == _currentIndex) return _currentProgress;
    return 0;
  }

  void startProgress(int index, Duration duration) {
    assert(index >= 0 && index < barCount, 'Index out of bounds: $index');
    _currentIndex = index;
    _currentProgress = 0;
    final durationToUse = _reportedDuration ?? duration;
    _timer.start(durationToUse);
  }

  void setCursorAt(int index) {
    assert(index >= 0 && index < barCount, 'Index out of bounds: $index');
    _timer.pause();
    _currentIndex = index;
    _currentProgress = 0;
    _reportedDuration = null;
    notifyListeners();
  }

  void pauseProgress() {
    _timer.pause();
  }

  void resumeProgress() {
    if (_currentIndex != -1 && !isRunning) {
      _timer.resume();
    }
  }

  void resetProgress() {
    if (_currentIndex != -1) {
      _currentProgress = 0;
      notifyListeners();
    }
  }

  void updateDuration(Duration newDuration) {
    if (_currentIndex == -1) return;
    _reportedDuration = newDuration;
    if (isRunning) {
      final currentProgress = _currentProgress;
      _timer.start(newDuration, initialProgress: currentProgress);
    } else {
      _timer.setDuration(newDuration);
    }
    notifyListeners();
  }

  void _handleProgressTick(double progress) {
    _currentProgress = progress;
    callbacks?.onProgressUpdate?.call(progress);
    notifyListeners();
  }

  void _handleProgressComplete() {
    callbacks?.onBarComplete?.call(_currentIndex);
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }
}
