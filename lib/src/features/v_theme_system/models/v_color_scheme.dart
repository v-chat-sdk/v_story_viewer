import 'package:flutter/material.dart';

/// Color scheme for story viewer
@immutable
class VColorScheme {
  const VColorScheme({
    this.primary = const Color(0xFF2196F3),
    this.secondary = const Color(0xFF03DAC6),
    this.background = Colors.black,
    this.surface = const Color(0xFF121212),
    this.error = const Color(0xFFCF6679),
    this.onPrimary = Colors.white,
    this.onSecondary = Colors.black,
    this.onBackground = Colors.white,
    this.onSurface = Colors.white,
    this.onError = Colors.black,
    this.progressBackground = Colors.white30,
    this.progressForeground = Colors.white,
    this.headerBackground = Colors.transparent,
    this.footerBackground = Colors.transparent,
    this.overlayBackground = Colors.black54,
    this.shimmerBase = Colors.grey,
    this.shimmerHighlight = Colors.white,
  });

  /// Primary color
  final Color primary;

  /// Secondary color
  final Color secondary;

  /// Background color
  final Color background;

  /// Surface color
  final Color surface;

  /// Error color
  final Color error;

  /// Color on primary
  final Color onPrimary;

  /// Color on secondary
  final Color onSecondary;

  /// Color on background
  final Color onBackground;

  /// Color on surface
  final Color onSurface;

  /// Color on error
  final Color onError;

  /// Progress bar background color
  final Color progressBackground;

  /// Progress bar foreground color
  final Color progressForeground;

  /// Header background color
  final Color headerBackground;

  /// Footer background color
  final Color footerBackground;

  /// Overlay background color
  final Color overlayBackground;

  /// Shimmer base color
  final Color shimmerBase;

  /// Shimmer highlight color
  final Color shimmerHighlight;

  /// Create a copy with modifications
  VColorScheme copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? error,
    Color? onPrimary,
    Color? onSecondary,
    Color? onBackground,
    Color? onSurface,
    Color? onError,
    Color? progressBackground,
    Color? progressForeground,
    Color? headerBackground,
    Color? footerBackground,
    Color? overlayBackground,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return VColorScheme(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      error: error ?? this.error,
      onPrimary: onPrimary ?? this.onPrimary,
      onSecondary: onSecondary ?? this.onSecondary,
      onBackground: onBackground ?? this.onBackground,
      onSurface: onSurface ?? this.onSurface,
      onError: onError ?? this.onError,
      progressBackground: progressBackground ?? this.progressBackground,
      progressForeground: progressForeground ?? this.progressForeground,
      headerBackground: headerBackground ?? this.headerBackground,
      footerBackground: footerBackground ?? this.footerBackground,
      overlayBackground: overlayBackground ?? this.overlayBackground,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  /// Default light theme
  static const VColorScheme light = VColorScheme(
    background: Colors.white,
    surface: Color(0xFFF5F5F5),
    error: Color(0xFFB00020),
    onBackground: Colors.black,
    onSurface: Colors.black,
    onError: Colors.white,
    progressBackground: Colors.black26,
    progressForeground: Colors.black,
    headerBackground: Colors.white,
    footerBackground: Colors.white,
    overlayBackground: Colors.black26,
    shimmerBase: Color(0xFFE0E0E0),
    shimmerHighlight: Color(0xFFF5F5F5),
  );

  /// Default dark theme
  static const VColorScheme dark = VColorScheme(
    shimmerBase: Color(0xFF424242),
    shimmerHighlight: Color(0xFF616161),
  );
}
