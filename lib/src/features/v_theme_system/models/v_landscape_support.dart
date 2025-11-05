import 'package:flutter/material.dart';

import 'v_responsive_utils.dart';
import 'v_size_tokens.dart';
import 'v_spacing_tokens.dart';

/// Landscape orientation support utilities
class VLandscapeSupport {
  const VLandscapeSupport();

  /// Get responsive height based on orientation
  static double getOrientationHeight(
    BuildContext context, {
    required double portraitHeight,
    required double landscapeHeight,
  }) {
    if (VResponsiveUtils.isLandscape(context)) {
      return landscapeHeight;
    }
    return portraitHeight;
  }

  /// Get responsive spacing based on orientation
  static double getOrientationSpacing(
    BuildContext context, {
    required double portraitSpacing,
    required double landscapeSpacing,
  }) {
    if (VResponsiveUtils.isLandscape(context)) {
      return landscapeSpacing;
    }
    return portraitSpacing;
  }

  /// Get header height with landscape support
  static double getHeaderHeight(BuildContext context) {
    if (VResponsiveUtils.isLandscape(context)) {
      return VSizeTokens.headerHeightMobile;
    }
    return VResponsiveUtils.getHeaderHeight(context);
  }

  /// Get footer height with landscape support
  static double getFooterHeight(BuildContext context) {
    if (VResponsiveUtils.isLandscape(context)) {
      return VSizeTokens.footerHeightMobile;
    }
    return VResponsiveUtils.getFooterHeight(context);
  }

  /// Get progress bar arrangement for landscape
  static bool shouldDisplayProgressBarsHorizontally(BuildContext context) {
    return VResponsiveUtils.isLandscape(context) &&
        VResponsiveUtils.isDesktop(context);
  }

  /// Get responsive padding for landscape
  static EdgeInsets getLandscapeAwarePadding(
    BuildContext context, {
    required double portraitHorizontal,
    required double portraitVertical,
    required double landscapeHorizontal,
    required double landscapeVertical,
  }) {
    if (VResponsiveUtils.isLandscape(context)) {
      return EdgeInsets.symmetric(
        horizontal: landscapeHorizontal,
        vertical: landscapeVertical,
      );
    }
    return EdgeInsets.symmetric(
      horizontal: portraitHorizontal,
      vertical: portraitVertical,
    );
  }

  /// Get safe area with landscape awareness
  static EdgeInsets getLandscapeSafeArea(BuildContext context) {
    final safeAreaTop = VResponsiveUtils.getSafeAreaTop(context);
    final safeAreaBottom = VResponsiveUtils.getSafeAreaBottom(context);
    final safeAreaLeft = VResponsiveUtils.getSafeAreaLeft(context);
    final safeAreaRight = VResponsiveUtils.getSafeAreaRight(context);

    if (VResponsiveUtils.isLandscape(context)) {
      return EdgeInsets.only(
        top: safeAreaTop,
        bottom: safeAreaBottom,
        left: safeAreaLeft + VSpacingTokens.lg,
        right: safeAreaRight + VSpacingTokens.lg,
      );
    }
    return EdgeInsets.only(
      top: safeAreaTop + VSpacingTokens.sm,
      bottom: safeAreaBottom,
      left: VSpacingTokens.lg,
      right: VSpacingTokens.lg,
    );
  }

  /// Check if should use compact layout for landscape
  static bool shouldUseCompactLayout(BuildContext context) {
    return VResponsiveUtils.isLandscape(context) &&
        !VResponsiveUtils.isDesktop(context);
  }

  /// Get responsive flex values for landscape
  static int getResponsiveFlex(
    BuildContext context, {
    required int portraitFlex,
    required int landscapeFlex,
  }) {
    if (VResponsiveUtils.isLandscape(context)) {
      return landscapeFlex;
    }
    return portraitFlex;
  }

  /// Get layout direction for landscape
  static Axis getLayoutAxis(BuildContext context) {
    if (VResponsiveUtils.isLandscape(context) &&
        VResponsiveUtils.isDesktop(context)) {
      return Axis.horizontal;
    }
    return Axis.vertical;
  }

  /// Get responsive max width for landscape
  static double getMaxWidthLandscape(BuildContext context) {
    final screenHeight = VResponsiveUtils.getScreenHeight(context);

    if (VResponsiveUtils.isLandscape(context)) {
      return screenHeight - 100;
    }
    return VResponsiveUtils.getMaxContentWidth(context);
  }
}

/// OrientationBuilder wrapper for easy landscape support
class VOrientationBuilder extends StatelessWidget {
  const VOrientationBuilder({
    required this.portraitBuilder,
    this.landscapeBuilder,
    this.key,
  });

  final WidgetBuilder portraitBuilder;
  final WidgetBuilder? landscapeBuilder;
  final Key? key;

  @override
  Widget build(BuildContext context) {
    final isLandscape = VResponsiveUtils.isLandscape(context);
    if (isLandscape && landscapeBuilder != null) {
      return landscapeBuilder!(context);
    }
    return portraitBuilder(context);
  }
}
