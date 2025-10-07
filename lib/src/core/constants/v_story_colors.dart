/// Semantic color constants for v_story_viewer package
///
/// This file provides a centralized color scheme with semantic naming
/// to improve code readability and consistency across the package.
library v_story_colors;

import 'package:flutter/material.dart';

/// Semantic color scheme for v_story_viewer
class VStoryColors {
  VStoryColors._();

  // Base colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  // Story viewer background
  static const Color storyViewerBackground = black;

  // Overlay colors
  static const Color overlayBackground = Color(
    0xB3000000,
  ); // Black with 70% opacity
  static const Color loadingOverlayBackground = Color(0xB3000000);
  static const Color errorOverlayBackground = Color(
    0xE6000000,
  ); // Black with 90% opacity
  static const Color headerOverlayBackground = Color(
    0x4D000000,
  ); // Black with 30% opacity
  static const Color footerOverlayBackground = Color(
    0x80000000,
  ); // Black with 50% opacity

  // Progress bar colors
  static const Color progressBarActive = white;
  static const Color progressBarInactive = Color(
    0x4DFFFFFF,
  ); // White with 30% opacity
  static const Color progressBarBackground = Color(
    0x1AFFFFFF,
  ); // White with 10% opacity

  // Text colors
  static const Color primaryText = white;
  static const Color secondaryText = Color(
    0xCCFFFFFF,
  ); // White with 80% opacity
  static const Color tertiaryText = Color(0x99FFFFFF); // White with 60% opacity
  static const Color disabledText = Color(0x66FFFFFF); // White with 40% opacity

  // Loading indicator colors
  static const Color loadingIndicatorPrimary = white;
  static const Color loadingIndicatorSecondary = Color(
    0x4DFFFFFF,
  ); // White with 30% opacity

  // Error colors
  static const Color errorPrimary = Color(0xFFFF5252); // Red A200
  static const Color errorSecondary = Color(0xFFFFCDD2); // Red 100
  static const Color errorBackground = Color(
    0x33FF5252,
  ); // Red with 20% opacity

  // Success colors
  static const Color successPrimary = Color(0xFF4CAF50); // Green 500
  static const Color successSecondary = Color(0xFFC8E6C9); // Green 100
  static const Color successBackground = Color(
    0x334CAF50,
  ); // Green with 20% opacity

  // Warning colors
  static const Color warningPrimary = Color(0xFFFF9800); // Orange 500
  static const Color warningSecondary = Color(0xFFFFE0B2); // Orange 100
  static const Color warningBackground = Color(
    0x33FF9800,
  ); // Orange with 20% opacity

  // Gesture feedback colors
  static const Color tapFeedback = Color(0x1AFFFFFF); // White with 10% opacity
  static const Color longPressFeedback = Color(
    0x33FFFFFF,
  ); // White with 20% opacity
  static const Color swipeFeedback = Color(
    0x26FFFFFF,
  ); // White with 15% opacity

  // Reply system colors
  static const Color replyInputBackground = Color(
    0x80000000,
  ); // Black with 50% opacity
  static const Color replyInputBorder = Color(
    0x4DFFFFFF,
  ); // White with 30% opacity
  static const Color replyInputFocusedBorder = white;
  static const Color replyTextColor = white;
  static const Color replyHintColor = Color(
    0x99FFFFFF,
  ); // White with 60% opacity

  // Reaction colors
  static const Color reactionBackground = Color(
    0x80000000,
  ); // Black with 50% opacity
  static const Color reactionBorder = Color(
    0x33FFFFFF,
  ); // White with 20% opacity
  static const Color reactionSelectedBackground = Color(
    0xB3FFFFFF,
  ); // White with 70% opacity

  // Action button colors
  static const Color actionButtonBackground = Color(
    0x80000000,
  ); // Black with 50% opacity
  static const Color actionButtonBorder = Color(
    0x33FFFFFF,
  ); // White with 20% opacity
  static const Color actionButtonIcon = white;
  static const Color actionButtonDisabledIcon = Color(
    0x66FFFFFF,
  ); // White with 40% opacity

  // Focus and selection colors
  static const Color focusRing = Color(0xFFFFFFFF); // White
  static const Color selectionHighlight = Color(
    0x33FFFFFF,
  ); // White with 20% opacity

  // Carousel specific colors
  static const Color carouselBackground = black;
  static const Color carouselPageIndicator = Color(
    0x4DFFFFFF,
  ); // White with 30% opacity
  static const Color carouselActivePageIndicator = white;

  // Shadow colors
  static const Color textShadow = Color(0x80000000); // Black with 50% opacity
  static const Color dropShadow = Color(0x33000000); // Black with 20% opacity
  static const Color elevationShadow = Color(
    0x1F000000,
  ); // Black with 12% opacity

  // Border colors
  static const Color defaultBorder = Color(
    0x33FFFFFF,
  ); // White with 20% opacity
  static const Color focusedBorder = white;
  static const Color errorBorder = Color(0xFFFF5252); // Red A200
  static const Color disabledBorder = Color(
    0x1AFFFFFF,
  ); // White with 10% opacity
}

/// Color utilities for dynamic color calculations
class VStoryColorUtils {
  VStoryColorUtils._();

  /// Creates a color with specified opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Creates a semi-transparent version of a color
  static Color transparent50(Color color) => color.withValues(alpha: 0.5);
  static Color transparent30(Color color) => color.withValues(alpha: 0.3);
  static Color transparent20(Color color) => color.withValues(alpha: 0.2);
  static Color transparent10(Color color) => color.withValues(alpha: 0.1);

  /// Lightens a color by mixing it with white
  static Color lighten(Color color, double amount) {
    return Color.lerp(color, Colors.white, amount) ?? color;
  }

  /// Darkens a color by mixing it with black
  static Color darken(Color color, double amount) {
    return Color.lerp(color, Colors.black, amount) ?? color;
  }

  /// Gets contrasting text color for a given background
  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? VStoryColors.black : VStoryColors.white;
  }

  /// Checks if a color is considered light
  static bool isLightColor(Color color) {
    return color.computeLuminance() > 0.5;
  }

  /// Checks if a color is considered dark
  static bool isDarkColor(Color color) {
    return !isLightColor(color);
  }

  /// Creates a color scheme for a given primary color
  static Map<String, Color> createColorScheme(Color primary) {
    return {
      'primary': primary,
      'primaryLight': lighten(primary, 0.3),
      'primaryDark': darken(primary, 0.3),
      'secondary': Color.lerp(primary, VStoryColors.white, 0.7) ?? primary,
      'background': VStoryColors.black,
      'surface': VStoryColors.overlayBackground,
      'onPrimary': getContrastingTextColor(primary),
      'onSecondary': VStoryColors.black,
      'onBackground': VStoryColors.white,
      'onSurface': VStoryColors.white,
    };
  }
}

/// Theme-aware color provider
class VStoryThemeColors {
  VStoryThemeColors._();

  /// Gets appropriate colors for light theme
  static Map<String, Color> get lightTheme => {
    'background': Colors.white,
    'surface': Colors.grey[100]!,
    'primaryText': Colors.black87,
    'secondaryText': Colors.black54,
    'overlay': Colors.black54,
    'progressActive': Colors.blue,
    'progressInactive': Colors.grey[300]!,
    'error': Colors.red[600]!,
    'success': Colors.green[600]!,
    'warning': Colors.orange[600]!,
  };

  /// Gets appropriate colors for dark theme (default for stories)
  static Map<String, Color> get darkTheme => {
    'background': VStoryColors.storyViewerBackground,
    'surface': VStoryColors.overlayBackground,
    'primaryText': VStoryColors.primaryText,
    'secondaryText': VStoryColors.secondaryText,
    'overlay': VStoryColors.overlayBackground,
    'progressActive': VStoryColors.progressBarActive,
    'progressInactive': VStoryColors.progressBarInactive,
    'error': VStoryColors.errorPrimary,
    'success': VStoryColors.successPrimary,
    'warning': VStoryColors.warningPrimary,
  };

  /// Gets colors based on brightness
  static Map<String, Color> forBrightness(Brightness brightness) {
    return brightness == Brightness.light ? lightTheme : darkTheme;
  }
}
