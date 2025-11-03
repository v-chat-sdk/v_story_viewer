import 'package:flutter/material.dart';

/// Style configuration for progress bar
@immutable
class VProgressStyle {
  const VProgressStyle({
    this.height = 3.5,
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0x33FFFFFF),
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    this.borderRadius,
    this.segmentSpacing = 4,
    this.boxShadow,
  });

  /// Height of each progress segment
  final double height;

  /// Color for filled progress
  final Color activeColor;

  /// Color for unfilled background
  final Color inactiveColor;

  /// Padding around the entire progress bar
  final EdgeInsets padding;

  /// Border radius for progress segments
  final BorderRadius? borderRadius;

  /// Spacing between progress segments
  final double segmentSpacing;

  /// Shadow for progress bar glow effect
  final BoxShadow? boxShadow;

  /// WhatsApp-style dark theme
  static const VProgressStyle whatsapp = VProgressStyle();

  /// Instagram-style theme
  static const VProgressStyle instagram = VProgressStyle(
    height: 2.5,
    inactiveColor: Color(0x4DFFFFFF),
    segmentSpacing: 3,
  );

  VProgressStyle copyWith({
    double? height,
    Color? activeColor,
    Color? inactiveColor,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    double? segmentSpacing,
    BoxShadow? boxShadow,
  }) {
    return VProgressStyle(
      height: height ?? this.height,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      segmentSpacing: segmentSpacing ?? this.segmentSpacing,
      boxShadow: boxShadow ?? this.boxShadow,
    );
  }
}
