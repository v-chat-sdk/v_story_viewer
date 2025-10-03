import 'package:flutter/material.dart';

import 'v_color_scheme.dart';
import 'v_icon_theme.dart';
import 'v_typography.dart';

/// Main theme configuration for story viewer
@immutable
class VStoryTheme {
  const VStoryTheme({
    required this.typography,
    this.colorScheme = const VColorScheme(),
    this.iconTheme = VIconTheme.dark,
    this.borderRadius = 8.0,
    this.elevation = 4.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.progressBarHeight = 2.0,
    this.progressBarSpacing = 4.0,
    this.headerHeight = 60.0,
    this.footerHeight = 60.0,
    this.replyInputHeight = 48.0,
    this.tapZoneWidth = 0.3,
    this.enableShadows = true,
    this.enableRippleEffect = true,
    this.enableHapticFeedback = false,
  });

  /// Color scheme
  final VColorScheme colorScheme;

  /// Typography
  final VTypography typography;

  /// Icon theme
  final VIconTheme iconTheme;

  /// Default border radius
  final double borderRadius;

  /// Default elevation
  final double elevation;

  /// Default animation duration
  final Duration animationDuration;

  /// Progress bar height
  final double progressBarHeight;

  /// Progress bar spacing
  final double progressBarSpacing;

  /// Header height
  final double headerHeight;

  /// Footer height
  final double footerHeight;

  /// Reply input height
  final double replyInputHeight;

  /// Tap zone width (percentage of screen width)
  final double tapZoneWidth;

  /// Enable shadows
  final bool enableShadows;

  /// Enable ripple effect
  final bool enableRippleEffect;

  /// Enable haptic feedback
  final bool enableHapticFeedback;

  /// Create a copy with modifications
  VStoryTheme copyWith({
    VColorScheme? colorScheme,
    VTypography? typography,
    VIconTheme? iconTheme,
    double? borderRadius,
    double? elevation,
    Duration? animationDuration,
    double? progressBarHeight,
    double? progressBarSpacing,
    double? headerHeight,
    double? footerHeight,
    double? replyInputHeight,
    double? tapZoneWidth,
    bool? enableShadows,
    bool? enableRippleEffect,
    bool? enableHapticFeedback,
  }) {
    return VStoryTheme(
      colorScheme: colorScheme ?? this.colorScheme,
      typography: typography ?? this.typography,
      iconTheme: iconTheme ?? this.iconTheme,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      animationDuration: animationDuration ?? this.animationDuration,
      progressBarHeight: progressBarHeight ?? this.progressBarHeight,
      progressBarSpacing: progressBarSpacing ?? this.progressBarSpacing,
      headerHeight: headerHeight ?? this.headerHeight,
      footerHeight: footerHeight ?? this.footerHeight,
      replyInputHeight: replyInputHeight ?? this.replyInputHeight,
      tapZoneWidth: tapZoneWidth ?? this.tapZoneWidth,
      enableShadows: enableShadows ?? this.enableShadows,
      enableRippleEffect: enableRippleEffect ?? this.enableRippleEffect,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
    );
  }

  /// Default light theme
  static VStoryTheme light() {
    return VStoryTheme(
      colorScheme: VColorScheme.light,
      typography: VTypography.defaultTypography(textColor: Colors.black),
      iconTheme: VIconTheme.light,
    );
  }

  /// Default dark theme
  static VStoryTheme dark() {
    return VStoryTheme(
      typography: VTypography.defaultTypography(),
      colorScheme: VColorScheme.dark,
    );
  }

  /// WhatsApp-style theme
  static VStoryTheme whatsapp() {
    return VStoryTheme(
      colorScheme: const VColorScheme(
        primary: Color(0xFF075E54),
        secondary: Color(0xFF25D366),
      ),
      typography: VTypography.defaultTypography(),
      iconTheme: VIconTheme.dark,
    );
  }

  /// Instagram-style theme
  static VStoryTheme instagram() {
    return VStoryTheme(
      colorScheme: const VColorScheme(
        primary: Color(0xFFE4405F),
        secondary: Color(0xFF833AB4),
      ),
      typography: VTypography.defaultTypography(),
      iconTheme: VIconTheme.dark,
      borderRadius: 12,
    );
  }
}
