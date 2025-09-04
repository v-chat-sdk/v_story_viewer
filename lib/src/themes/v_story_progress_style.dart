import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Styling configuration for story progress indicators.
/// 
/// Defines the appearance of progress bars including colors,
/// sizes, spacing, and animation properties.
class VStoryProgressStyle {
  /// Color for active/completed progress segments
  final Color activeColor;
  
  /// Color for inactive/pending progress segments
  final Color inactiveColor;
  
  /// Height of the progress bar
  final double height;
  
  /// Padding around the progress bar container
  final EdgeInsets padding;
  
  /// Spacing between individual progress segments
  final double spacing;
  
  /// Border radius for progress segments
  final double radius;
  
  /// Animation duration for progress updates
  final Duration animationDuration;
  
  /// Animation curve for progress updates
  final Curve animationCurve;
  
  /// Whether to show segment dividers
  final bool showDividers;
  
  /// Color for segment dividers
  final Color? dividerColor;
  
  /// Width of segment dividers
  final double dividerWidth;
  
  /// Whether to animate progress bar appearance
  final bool animateAppearance;
  
  /// Delay before starting progress animation
  final Duration startDelay;
  
  /// Shadow for progress bars
  final List<BoxShadow>? shadows;
  
  /// Border for progress container
  final Border? border;
  
  /// Background color for progress container
  final Color? backgroundColor;
  
  /// Creates a progress style configuration
  const VStoryProgressStyle({
    required this.activeColor,
    required this.inactiveColor,
    this.height = 3.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    this.spacing = 4.0,
    this.radius = 1.5,
    this.animationDuration = const Duration(milliseconds: 0),
    this.animationCurve = Curves.easeInOut,
    this.showDividers = false,
    this.dividerColor,
    this.dividerWidth = 1.0,
    this.animateAppearance = true,
    this.startDelay = Duration.zero,
    this.shadows,
    this.border,
    this.backgroundColor,
  });
  
  /// Creates a light theme progress style
  factory VStoryProgressStyle.light() {
    return const VStoryProgressStyle(
      activeColor: Colors.white,
      inactiveColor: Color(0x4DFFFFFF),
      height: 3.0,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      spacing: 4.0,
      radius: 1.5,
    );
  }
  
  /// Creates a dark theme progress style
  factory VStoryProgressStyle.dark() {
    return const VStoryProgressStyle(
      activeColor: Colors.white,
      inactiveColor: Color(0x33FFFFFF),
      height: 3.0,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      spacing: 4.0,
      radius: 1.5,
      shadows: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
  
  /// Creates a progress style from Material 3 color scheme
  factory VStoryProgressStyle.fromColorScheme(ColorScheme colorScheme) {
    return VStoryProgressStyle(
      activeColor: colorScheme.primary,
      inactiveColor: colorScheme.onSurface.withValues(alpha: 0.3),
      height: 4.0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      spacing: 4.0,
      radius: 2.0,
      animationCurve: Curves.easeInOutCubic,
    );
  }
  
  /// Creates a Cupertino-style progress bar
  factory VStoryProgressStyle.cupertino(Color primaryColor) {
    return VStoryProgressStyle(
      activeColor: primaryColor,
      inactiveColor: CupertinoColors.systemGrey5,
      height: 2.5,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      spacing: 3.0,
      radius: 1.25,
      animationCurve: Curves.easeInOutCubic,
      animationDuration: const Duration(milliseconds: 0),
    );
  }
  
  /// Creates a minimal progress style
  factory VStoryProgressStyle.minimal() {
    return const VStoryProgressStyle(
      activeColor: Colors.white,
      inactiveColor: Colors.transparent,
      height: 2.0,
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      spacing: 2.0,
      radius: 0,
      showDividers: false,
      animateAppearance: false,
    );
  }
  
  /// Creates a bold progress style
  factory VStoryProgressStyle.bold() {
    return const VStoryProgressStyle(
      activeColor: Colors.white,
      inactiveColor: Color(0x33FFFFFF),
      height: 5.0,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      spacing: 6.0,
      radius: 2.5,
      shadows: [
        BoxShadow(
          color: Colors.black38,
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    );
  }
  
  /// Creates a gradient progress style
  factory VStoryProgressStyle.gradient({
    required List<Color> activeGradientColors,
    Color inactiveColor = const Color(0x33FFFFFF),
  }) {
    // Note: Gradient implementation would be handled in the widget
    return VStoryProgressStyle(
      activeColor: activeGradientColors.first,
      inactiveColor: inactiveColor,
      height: 4.0,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      spacing: 4.0,
      radius: 2.0,
    );
  }
  
  /// Creates a copy with modified fields
  VStoryProgressStyle copyWith({
    Color? activeColor,
    Color? inactiveColor,
    double? height,
    EdgeInsets? padding,
    double? spacing,
    double? radius,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? showDividers,
    Color? dividerColor,
    double? dividerWidth,
    bool? animateAppearance,
    Duration? startDelay,
    List<BoxShadow>? shadows,
    Border? border,
    Color? backgroundColor,
  }) {
    return VStoryProgressStyle(
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      showDividers: showDividers ?? this.showDividers,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerWidth: dividerWidth ?? this.dividerWidth,
      animateAppearance: animateAppearance ?? this.animateAppearance,
      startDelay: startDelay ?? this.startDelay,
      shadows: shadows ?? this.shadows,
      border: border ?? this.border,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
  
  /// Applies the style to create a container decoration
  BoxDecoration? getContainerDecoration() {
    if (backgroundColor == null && border == null && shadows == null) {
      return null;
    }
    
    return BoxDecoration(
      color: backgroundColor,
      border: border,
      boxShadow: shadows,
      borderRadius: BorderRadius.circular(radius),
    );
  }
  
  /// Gets the effective divider color
  Color getEffectiveDividerColor() {
    return dividerColor ?? inactiveColor;
  }
}