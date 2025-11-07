import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Enum for swipe direction detection
enum VSwipeDirection { left, right, up, down, none }

/// Data class for gesture velocity information
@immutable
class VGestureVelocityData {
  const VGestureVelocityData({
    required this.pixelsPerSecond,
    required this.direction,
    required this.distance,
    required this.duration,
    this.isSwipe = false,
    this.speed = VGestureSpeed.slow,
  });

  /// Factory constructor from raw gesture data
  factory VGestureVelocityData.fromGestureData({
    required Offset startPosition,
    required Offset endPosition,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final distance = (endPosition - startPosition).distance;
    final duration = endTime.difference(startTime).inMilliseconds;

    // Calculate velocity (pixels per second)
    final pixelsPerSecond = duration > 0 ? (distance / duration) * 1000 : 0.0;

    // Determine swipe direction
    final dx = endPosition.dx - startPosition.dx;
    final dy = endPosition.dy - startPosition.dy;
    final absDx = dx.abs();
    final absDy = dy.abs();

    VSwipeDirection direction;
    if (absDx > absDy) {
      direction = dx > 0 ? VSwipeDirection.right : VSwipeDirection.left;
    } else if (absDy > absDx) {
      direction = dy > 0 ? VSwipeDirection.down : VSwipeDirection.up;
    } else {
      direction = VSwipeDirection.none;
    }

    // Determine speed category
    final speed = _categorizeSpeed(pixelsPerSecond);

    // Check if it's a valid swipe
    final isSwipe =
        pixelsPerSecond >= minSwipeVelocity &&
        direction != VSwipeDirection.none;

    return VGestureVelocityData(
      pixelsPerSecond: pixelsPerSecond,
      direction: direction,
      distance: distance,
      duration: duration,
      isSwipe: isSwipe,
      speed: speed,
    );
  }

  /// Velocity in pixels per second
  final double pixelsPerSecond;

  /// Direction of the swipe gesture
  final VSwipeDirection direction;

  /// Total distance traveled in pixels
  final double distance;

  /// Duration of the gesture in milliseconds
  final int duration;

  /// Whether this gesture qualifies as a swipe
  /// (velocity > 100 pixels/second)
  final bool isSwipe;

  /// Speed category of the gesture
  final VGestureSpeed speed;

  /// Minimum velocity threshold for swipe detection (pixels/second)
  static const double minSwipeVelocity = 100;

  /// Categorize velocity into speed categories
  static VGestureSpeed _categorizeSpeed(double pixelsPerSecond) {
    if (pixelsPerSecond < 150) {
      return VGestureSpeed.slow;
    } else if (pixelsPerSecond < 300) {
      return VGestureSpeed.normal;
    } else if (pixelsPerSecond < 500) {
      return VGestureSpeed.fast;
    } else {
      return VGestureSpeed.veryFast;
    }
  }

  /// Get formatted velocity string
  String get formattedVelocity {
    return '${pixelsPerSecond.toStringAsFixed(0)} px/s';
  }

  /// Get formatted distance string
  String get formattedDistance {
    return '${distance.toStringAsFixed(1)} px';
  }

  /// Get formatted duration string
  String get formattedDuration {
    return '${duration}ms';
  }

  VGestureVelocityData copyWith({
    double? pixelsPerSecond,
    VSwipeDirection? direction,
    double? distance,
    int? duration,
    bool? isSwipe,
    VGestureSpeed? speed,
  }) {
    return VGestureVelocityData(
      pixelsPerSecond: pixelsPerSecond ?? this.pixelsPerSecond,
      direction: direction ?? this.direction,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      isSwipe: isSwipe ?? this.isSwipe,
      speed: speed ?? this.speed,
    );
  }
}

/// Enum for categorizing gesture speed
enum VGestureSpeed { slow, normal, fast, veryFast }

/// Extension for getting speed label and color
extension VGestureSpeedExt on VGestureSpeed {
  /// Get human-readable label for the speed
  String get label {
    return switch (this) {
      VGestureSpeed.slow => 'Slow',
      VGestureSpeed.normal => 'Normal',
      VGestureSpeed.fast => 'Fast',
      VGestureSpeed.veryFast => 'Very Fast',
    };
  }

  /// Get numeric value for animation purposes
  double get value {
    return switch (this) {
      VGestureSpeed.slow => 0.25,
      VGestureSpeed.normal => 0.5,
      VGestureSpeed.fast => 0.75,
      VGestureSpeed.veryFast => 1,
    };
  }
}

/// Extension for swipe direction labels
extension VSwipeDirectionExt on VSwipeDirection {
  /// Get human-readable label
  String get label {
    return switch (this) {
      VSwipeDirection.left => 'Left',
      VSwipeDirection.right => 'Right',
      VSwipeDirection.up => 'Up',
      VSwipeDirection.down => 'Down',
      VSwipeDirection.none => 'None',
    };
  }

  /// Get arrow unicode for display
  String get arrow {
    return switch (this) {
      VSwipeDirection.left => '←',
      VSwipeDirection.right => '→',
      VSwipeDirection.up => '↑',
      VSwipeDirection.down => '↓',
      VSwipeDirection.none => '·',
    };
  }
}

/// Controller for tracking and managing gesture velocity
class VGestureVelocityController extends ChangeNotifier {
  VGestureVelocityData? _lastVelocityData;
  final List<VGestureVelocityData> _velocityHistory = [];
  final int _maxHistorySize = 10;

  /// Get the last recorded velocity data
  VGestureVelocityData? get lastVelocityData => _lastVelocityData;

  /// Get velocity history (most recent first)
  List<VGestureVelocityData> get velocityHistory =>
      List.unmodifiable(_velocityHistory);

  /// Get average velocity from history
  double get averageVelocity {
    if (_velocityHistory.isEmpty) return 0;
    final sum = _velocityHistory.fold<double>(
      0,
      (prev, data) => prev + data.pixelsPerSecond,
    );
    return sum / _velocityHistory.length;
  }

  /// Record a new velocity measurement
  void recordVelocity(VGestureVelocityData data) {
    _lastVelocityData = data;
    _velocityHistory.insert(0, data);

    // Keep only the most recent measurements
    if (_velocityHistory.length > _maxHistorySize) {
      _velocityHistory.removeAt(_velocityHistory.length - 1);
    }

    notifyListeners();
  }

  /// Clear velocity history
  void clearHistory() {
    _velocityHistory.clear();
    _lastVelocityData = null;
    notifyListeners();
  }
}
