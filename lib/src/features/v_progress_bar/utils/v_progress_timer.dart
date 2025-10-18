import 'dart:async';

import 'package:flutter/foundation.dart';

/// Handles timer logic for progress animation
class VProgressTimer {
  VProgressTimer({required this.onTick, required this.onComplete});

  final void Function(double progress) onTick;
  final VoidCallback onComplete;

  Timer? _timer;
  double _currentProgress = 0;
  Duration _duration = const Duration(seconds: 5);

  bool get isActive => _timer != null && _timer!.isActive;

  void start(Duration duration, {double initialProgress = 0}) {
    cancel();
    _duration = duration;
    _currentProgress = initialProgress;
    _startPeriodicTimer();
  }

  void pause() {
    cancel();
  }

  void resume() {
    if (_currentProgress < 1) {
      _startPeriodicTimer();
    }
  }

  void updateProgress(double progress) {
    assert(
      progress >= 0 && progress <= 1,
      'Progress must be between 0.0 and 1.0',
    );
    _currentProgress = progress;
    if (_currentProgress >= 1) {
      _currentProgress = 1;
      cancel();
      onTick(_currentProgress);
      onComplete();
      return;
    }
    onTick(_currentProgress);
  }

  /// Set duration without restarting timer (use before timer starts)
  void setDuration(Duration duration) {
    _duration = duration;
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void _startPeriodicTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 60), _handleTimerTick);
  }

  void _handleTimerTick(Timer timer) {
    if (_timer == null || _timer != timer) {
      timer.cancel();
      return;
    }
    _currentProgress +=
        Duration(milliseconds: 60).inMilliseconds / _duration.inMilliseconds;
    if (_currentProgress >= 1) {
      _currentProgress = 1;
      timer.cancel();
      _timer = null;
      onTick(_currentProgress);
      onComplete();
      return;
    }
    onTick(_currentProgress);
  }

  void dispose() {
    cancel();
  }
}
