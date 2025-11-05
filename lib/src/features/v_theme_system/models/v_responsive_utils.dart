import 'package:flutter/material.dart';

import 'v_size_tokens.dart';

/// Responsive device types
enum VDeviceType {
  mobile,
  foldable,
  tablet,
  desktop,
  tv,
}

/// Responsive design utilities for consistent behavior across devices
class VResponsiveUtils {
  const VResponsiveUtils();

  /// Get device type based on screen width
  static VDeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return getDeviceTypeFromWidth(width);
  }

  /// Get device type from width value directly
  static VDeviceType getDeviceTypeFromWidth(double width) {
    if (width < 500) return VDeviceType.mobile;
    if (width < 600) return VDeviceType.foldable;
    if (width < 1000) return VDeviceType.tablet;
    if (width < 1800) return VDeviceType.desktop;
    return VDeviceType.tv;
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == VDeviceType.mobile;

  /// Check if device is foldable
  static bool isFoldable(BuildContext context) =>
      getDeviceType(context) == VDeviceType.foldable;

  /// Check if device is tablet
  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == VDeviceType.tablet;

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == VDeviceType.desktop;

  /// Check if device is TV
  static bool isTV(BuildContext context) =>
      getDeviceType(context) == VDeviceType.tv;

  /// Check if in landscape orientation
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Check if in portrait orientation
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  /// Get screen width
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Get screen height
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Get safe area top padding (for notches)
  static double getSafeAreaTop(BuildContext context) =>
      MediaQuery.of(context).viewPadding.top;

  /// Get safe area bottom padding (for notches, home indicator)
  static double getSafeAreaBottom(BuildContext context) =>
      MediaQuery.of(context).viewPadding.bottom;

  /// Get safe area left padding
  static double getSafeAreaLeft(BuildContext context) =>
      MediaQuery.of(context).viewPadding.left;

  /// Get safe area right padding
  static double getSafeAreaRight(BuildContext context) =>
      MediaQuery.of(context).viewPadding.right;

  /// Check if device has notch/cutout
  static bool hasNotch(BuildContext context) =>
      getSafeAreaTop(context) > 0;

  /// Check if in dark mode
  static bool isDarkMode(BuildContext context) =>
      MediaQuery.of(context).platformBrightness == Brightness.dark;

  /// Get text scale for current device
  static double getTextScale(BuildContext context) =>
      MediaQuery.of(context).textScaleFactor;

  /// Get device pixel ratio
  static double getDevicePixelRatio(BuildContext context) =>
      MediaQuery.of(context).devicePixelRatio;

  /// Get responsive header height
  static double getHeaderHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    return switch (deviceType) {
      VDeviceType.mobile => VSizeTokens.headerHeightMobile,
      VDeviceType.foldable => VSizeTokens.headerHeightMobile,
      VDeviceType.tablet => VSizeTokens.headerHeightTablet,
      VDeviceType.desktop => VSizeTokens.headerHeightDesktop,
      VDeviceType.tv => VSizeTokens.headerHeightDesktop + 8.0,
    };
  }

  /// Get responsive footer height
  static double getFooterHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    return switch (deviceType) {
      VDeviceType.mobile => VSizeTokens.footerHeightMobile,
      VDeviceType.foldable => VSizeTokens.footerHeightMobile,
      VDeviceType.tablet => VSizeTokens.footerHeightTablet,
      VDeviceType.desktop => VSizeTokens.footerHeightDesktop,
      VDeviceType.tv => VSizeTokens.footerHeightDesktop + 8.0,
    };
  }

  /// Get responsive reply input height
  static double getReplyInputHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    return switch (deviceType) {
      VDeviceType.mobile => VSizeTokens.replyInputHeightMobile,
      VDeviceType.foldable => VSizeTokens.replyInputHeightMobile,
      VDeviceType.tablet => VSizeTokens.replyInputHeightTablet,
      VDeviceType.desktop => VSizeTokens.replyInputHeightDesktop,
      VDeviceType.tv => VSizeTokens.replyInputHeightDesktop + 4.0,
    };
  }

  /// Get responsive progress bar height
  static double getProgressBarHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    return switch (deviceType) {
      VDeviceType.mobile => VSizeTokens.progressBarHeightMobile,
      VDeviceType.foldable => VSizeTokens.progressBarHeightMobile,
      VDeviceType.tablet => VSizeTokens.progressBarHeightTablet,
      VDeviceType.desktop => VSizeTokens.progressBarHeightDesktop,
      VDeviceType.tv => VSizeTokens.progressBarHeightDesktop + 1.0,
    };
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context,
      {double mobileSize = 24.0,
      double tabletSize = 28.0,
      double desktopSize = 32.0}) {
    final deviceType = getDeviceType(context);
    return switch (deviceType) {
      VDeviceType.mobile => mobileSize,
      VDeviceType.foldable => mobileSize,
      VDeviceType.tablet => tabletSize,
      VDeviceType.desktop => desktopSize,
      VDeviceType.tv => desktopSize + 4.0,
    };
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    return switch (deviceType) {
      VDeviceType.mobile => VSizeTokens.buttonHeightMd,
      VDeviceType.foldable => VSizeTokens.buttonHeightMd,
      VDeviceType.tablet => VSizeTokens.buttonHeightLg,
      VDeviceType.desktop => VSizeTokens.buttonHeightLg,
      VDeviceType.tv => VSizeTokens.buttonHeightXl,
    };
  }

  /// Get responsive font size
  static double getFontSize(BuildContext context,
      {double mobileSize = 14.0,
      double tabletSize = 16.0,
      double desktopSize = 18.0}) {
    final deviceType = getDeviceType(context);
    return switch (deviceType) {
      VDeviceType.mobile => mobileSize,
      VDeviceType.foldable => mobileSize,
      VDeviceType.tablet => tabletSize,
      VDeviceType.desktop => desktopSize,
      VDeviceType.tv => desktopSize + 2.0,
    };
  }

  /// Get responsive max content width
  static double getMaxContentWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    final screenWidth = getScreenWidth(context);
    return switch (deviceType) {
      VDeviceType.mobile => screenWidth - 32.0,
      VDeviceType.foldable => screenWidth - 32.0,
      VDeviceType.tablet => VSizeTokens.maxContentWidthTablet,
      VDeviceType.desktop => VSizeTokens.maxContentWidthDesktop,
      VDeviceType.tv => VSizeTokens.maxContentWidthTv,
    };
  }

  /// Get responsive avatar size
  static double getAvatarSize(BuildContext context) {
    final deviceType = getDeviceType(context);
    return switch (deviceType) {
      VDeviceType.mobile => VSizeTokens.avatarSm,
      VDeviceType.foldable => VSizeTokens.avatarSm,
      VDeviceType.tablet => VSizeTokens.avatarMd,
      VDeviceType.desktop => VSizeTokens.avatarLg,
      VDeviceType.tv => VSizeTokens.avatarXl,
    };
  }

  /// Get safe area with content padding for header
  static EdgeInsets getHeaderSafeArea(BuildContext context) {
    final safeAreaTop = getSafeAreaTop(context);
    final deviceType = getDeviceType(context);
    final horizontalPadding = switch (deviceType) {
      VDeviceType.mobile => 16.0,
      VDeviceType.foldable => 16.0,
      VDeviceType.tablet => 24.0,
      VDeviceType.desktop => 32.0,
      VDeviceType.tv => 48.0,
    };
    return EdgeInsets.only(
      top: safeAreaTop,
      left: horizontalPadding,
      right: horizontalPadding,
    );
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom > 0;

  /// Get keyboard height
  static double getKeyboardHeight(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom;

  /// Get responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    final screenWidth = getScreenWidth(context);
    return switch (deviceType) {
      VDeviceType.mobile => screenWidth - 32.0,
      VDeviceType.foldable => screenWidth - 32.0,
      VDeviceType.tablet => VSizeTokens.dialogWidthTablet,
      VDeviceType.desktop => VSizeTokens.dialogWidthDesktop,
      VDeviceType.tv => 700.0,
    };
  }

  /// Get responsive dialog height ratio
  static double getDialogHeightRatio(BuildContext context) {
    final deviceType = getDeviceType(context);
    return switch (deviceType) {
      VDeviceType.mobile => VSizeTokens.dialogMaxHeightMobile,
      VDeviceType.foldable => VSizeTokens.dialogMaxHeightMobile,
      VDeviceType.tablet => VSizeTokens.dialogMaxHeightTablet,
      VDeviceType.desktop => VSizeTokens.dialogMaxHeightDesktop,
      VDeviceType.tv => 0.5,
    };
  }
}
