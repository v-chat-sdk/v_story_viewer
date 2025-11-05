import 'package:flutter/foundation.dart';

/// Configuration for blur effects on web reply overlay
@immutable
class VBlurEffectConfig {
  const VBlurEffectConfig({
    this.enableBlur = true,
    this.blurSigmaX = 8,
    this.blurSigmaY = 8,
    this.overlayOpacity = 0.3,
    this.animationDuration = const Duration(milliseconds: 200),
    this.curve = 'easeInOut',
    this.webOnly = true,
  });

  /// Enable/disable blur effects
  final bool enableBlur;

  /// X-axis blur sigma (web)
  final double blurSigmaX;

  /// Y-axis blur sigma (web)
  final double blurSigmaY;

  /// Opacity of the dark overlay
  final double overlayOpacity;

  /// Animation duration for fade in/out
  final Duration animationDuration;

  /// Animation curve name
  final String curve;

  /// Apply blur effect only on web platform
  final bool webOnly;

  VBlurEffectConfig copyWith({
    bool? enableBlur,
    double? blurSigmaX,
    double? blurSigmaY,
    double? overlayOpacity,
    Duration? animationDuration,
    String? curve,
    bool? webOnly,
  }) {
    return VBlurEffectConfig(
      enableBlur: enableBlur ?? this.enableBlur,
      blurSigmaX: blurSigmaX ?? this.blurSigmaX,
      blurSigmaY: blurSigmaY ?? this.blurSigmaY,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      animationDuration: animationDuration ?? this.animationDuration,
      curve: curve ?? this.curve,
      webOnly: webOnly ?? this.webOnly,
    );
  }
}

/// Preset blur effect configurations
class VBlurEffectPresets {
  /// Subtle blur (light web overlay)
  static const VBlurEffectConfig subtle = VBlurEffectConfig(
    blurSigmaX: 4,
    blurSigmaY: 4,
    overlayOpacity: 0.15,
  );

  /// Standard blur (recommended for web reply overlay)
  static const VBlurEffectConfig standard = VBlurEffectConfig();

  /// Strong blur (for focus-intensive content)
  static const VBlurEffectConfig strong = VBlurEffectConfig(
    blurSigmaX: 12,
    blurSigmaY: 12,
    overlayOpacity: 0.45,
  );

  /// Heavy blur (for maximum focus)
  static const VBlurEffectConfig heavy = VBlurEffectConfig(
    blurSigmaX: 16,
    blurSigmaY: 16,
    overlayOpacity: 0.6,
  );
}

/// State management for blur effect visibility
class VBlurEffectNotifier extends ChangeNotifier {
  bool _isVisible = false;
  double _opacity = 0;

  bool get isVisible => _isVisible;

  double get opacity => _opacity;

  /// Show blur effect
  void show() {
    _isVisible = true;
    _opacity = 1;
    notifyListeners();
  }

  /// Hide blur effect
  void hide() {
    _isVisible = false;
    _opacity = 0;
    notifyListeners();
  }

  /// Toggle blur effect visibility
  void toggle() {
    _isVisible ? hide() : show();
  }

  /// Set custom opacity
  void setOpacity(double value) {
    _opacity = value.clamp(0, 1);
    notifyListeners();
  }
}
