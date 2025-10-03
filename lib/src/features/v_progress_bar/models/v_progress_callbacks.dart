import 'package:flutter/foundation.dart';

/// Callbacks for progress bar events
@immutable
class VProgressCallbacks {
  const VProgressCallbacks({
    this.onBarComplete,
    this.onProgressUpdate,
  });

  /// Called when a progress bar reaches 1.0
  /// Passes the completed bar index
  final ValueChanged<int>? onBarComplete;

  /// Called on progress updates with current progress value (0.0-1.0)
  final ValueChanged<double>? onProgressUpdate;
}
