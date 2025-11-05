import 'package:flutter/material.dart';

/// Design tokens for consistent sizing throughout the application
@immutable
class VSizeTokens {
  const VSizeTokens();

  // Icon Sizes
  static const double iconXs = 16;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;
  static const double iconXxl = 64;

  // Button Sizes
  static const double buttonHeightSm = 32;
  static const double buttonHeightMd = 40;
  static const double buttonHeightLg = 48;
  static const double buttonHeightXl = 56;

  static const double buttonIconSizeSm = 16;
  static const double buttonIconSizeMd = 20;
  static const double buttonIconSizeLg = 24;

  // Component Heights
  static const double headerHeightMobile = 56;
  static const double headerHeightTablet = 60;
  static const double headerHeightDesktop = 64;

  static const double footerHeightMobile = 56;
  static const double footerHeightTablet = 60;
  static const double footerHeightDesktop = 64;

  static const double replyInputHeightMobile = 48;
  static const double replyInputHeightTablet = 52;
  static const double replyInputHeightDesktop = 56;

  static const double progressBarHeightMobile = 2;
  static const double progressBarHeightTablet = 3;
  static const double progressBarHeightDesktop = 4;

  // Avatar Sizes
  static const double avatarXs = 24;
  static const double avatarSm = 32;
  static const double avatarMd = 40;
  static const double avatarLg = 48;
  static const double avatarXl = 64;

  // Content Widths
  static const double maxContentWidthMobile = 400;
  static const double maxContentWidthTablet = 600;
  static const double maxContentWidthDesktop = 700;
  static const double maxContentWidthTv = 900;

  // Dialog/Modal Sizes
  static const double dialogWidthMobile = double.infinity;
  static const double dialogWidthTablet = 500;
  static const double dialogWidthDesktop = 600;

  static const double dialogMaxHeightMobile = 0.8;
  static const double dialogMaxHeightTablet = 0.7;
  static const double dialogMaxHeightDesktop = 0.6;

  // Bottom Sheet Sizes
  static const double bottomSheetHeightMobile = 0.6;
  static const double bottomSheetHeightTablet = 0.5;
  static const double bottomSheetHeightDesktop = 0.4;

  // Divider Heights
  static const double dividerHeight = 1;
  static const double dividerHeightThick = 2;

  // Radius/Border
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  static const double radiusCircle = 100;

  // Input Field Heights
  static const double inputFieldHeightSm = 32;
  static const double inputFieldHeightMd = 40;
  static const double inputFieldHeightLg = 48;

  // Tap Target Minimum
  static const double tapTargetMin = 48;

  // Card/Surface Sizes
  static const double cardWidthSm = 150;
  static const double cardWidthMd = 250;
  static const double cardWidthLg = 350;
}
