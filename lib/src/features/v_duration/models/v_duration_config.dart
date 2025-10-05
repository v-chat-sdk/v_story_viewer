import 'package:flutter/foundation.dart';

/// Configuration for story duration calculations
@immutable
class VDurationConfig {
  const VDurationConfig({
    this.defaultImageDuration = const Duration(seconds: 5),
    this.defaultTextDuration = const Duration(seconds: 3),
    this.wordsPerMinute = 180,
    this.minTextDuration = const Duration(seconds: 2),
    this.maxTextDuration = const Duration(seconds: 10),
  });

  /// Default duration for image stories
  final Duration defaultImageDuration;

  /// Default duration for text stories (used as fallback)
  final Duration defaultTextDuration;

  /// Words per minute for reading speed calculation
  final int wordsPerMinute;

  /// Minimum duration for text stories
  final Duration minTextDuration;

  /// Maximum duration for text stories
  final Duration maxTextDuration;

  VDurationConfig copyWith({
    Duration? defaultImageDuration,
    Duration? defaultTextDuration,
    int? wordsPerMinute,
    Duration? minTextDuration,
    Duration? maxTextDuration,
  }) {
    return VDurationConfig(
      defaultImageDuration: defaultImageDuration ?? this.defaultImageDuration,
      defaultTextDuration: defaultTextDuration ?? this.defaultTextDuration,
      wordsPerMinute: wordsPerMinute ?? this.wordsPerMinute,
      minTextDuration: minTextDuration ?? this.minTextDuration,
      maxTextDuration: maxTextDuration ?? this.maxTextDuration,
    );
  }
}
