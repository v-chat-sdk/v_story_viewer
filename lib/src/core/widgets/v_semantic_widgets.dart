/// Semantic wrapper widgets for better UI composition in v_story_viewer
///
/// These widgets provide semantic meaning and consistent styling
/// while reducing code duplication and improving readability.
library v_semantic_widgets;

import 'package:flutter/material.dart';

import '../constants/v_story_colors.dart';
import '../constants/v_story_constants.dart';

/// Base overlay widget for story content
///
/// Provides consistent overlay styling with semantic meaning.
/// Use this instead of raw ColoredBox for overlays.
class VStoryOverlay extends StatelessWidget {
  const VStoryOverlay({
    required this.child,
    this.opacity = VStoryColorConstants.overlayBackgroundOpacity,
    this.color = VStoryColors.black,
    super.key,
  });

  /// Child widget to display over the overlay
  final Widget child;

  /// Overlay opacity (0.0 to 1.0)
  final double opacity;

  /// Base overlay color
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color.withValues(alpha: opacity),
      child: child,
    );
  }
}

/// Loading overlay with progress indicator
///
/// Semantic widget specifically for loading states.
class VLoadingOverlay extends StatelessWidget {
  const VLoadingOverlay({
    required this.progress,
    this.message = VStoryTextConstants.defaultLoadingMessage,
    this.showProgress = true,
    super.key,
  });

  /// Loading progress (0.0 to 1.0)
  final double progress;

  /// Loading message to display
  final String message;

  /// Whether to show progress indicator
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return VStoryOverlay(
      child: VCenteredColumn(
        spacing: VStoryDimensionConstants.defaultBorderRadius,
        children: [
          if (showProgress)
            VProgressIndicator(
              progress: progress,
              theme: VProgressTheme.loading(),
            ),
          VStoryText.loading(message),
        ],
      ),
    );
  }
}

/// Error overlay with retry functionality
class VErrorOverlay extends StatelessWidget {
  const VErrorOverlay({
    required this.message,
    this.onRetry,
    this.retryText = VStoryTextConstants.defaultRetryMessage,
    super.key,
  });

  /// Error message to display
  final String message;

  /// Callback for retry action
  final VoidCallback? onRetry;

  /// Text for retry button
  final String retryText;

  @override
  Widget build(BuildContext context) {
    return VStoryOverlay(
      opacity: VStoryColorConstants.overlayBackgroundOpacity + 0.2,
      child: VCenteredColumn(
        spacing: VStoryDimensionConstants.largeBorderRadius,
        children: [
          Icon(
            Icons.error_outline,
            color: VStoryColors.errorPrimary,
            size: VStoryDimensionConstants.loadingIndicatorSize,
          ),
          VStoryText.error(message),
          if (onRetry != null)
            VRetryButton(text: retryText, onPressed: onRetry!),
        ],
      ),
    );
  }
}

/// Centered column with consistent spacing
///
/// Provides semantic centering with customizable spacing between children.
class VCenteredColumn extends StatelessWidget {
  const VCenteredColumn({
    required this.children,
    this.spacing = 0,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    super.key,
  });

  /// Child widgets to display
  final List<Widget> children;

  /// Spacing between children
  final double spacing;

  /// Main axis alignment
  final MainAxisAlignment mainAxisAlignment;

  /// Cross axis alignment
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1 && spacing > 0) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: spacedChildren,
    );
  }
}

/// Semantic progress indicator with theme support
class VProgressIndicator extends StatelessWidget {
  const VProgressIndicator({
    required this.progress,
    required this.theme,
    this.size = VStoryDimensionConstants.loadingIndicatorSize,
    super.key,
  });

  /// Progress value (0.0 to 1.0)
  final double progress;

  /// Progress indicator theme
  final VProgressTheme theme;

  /// Size of the progress indicator
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: progress < 1.0 ? progress : null,
        color: theme.activeColor,
        backgroundColor: theme.inactiveColor,
        strokeWidth: theme.strokeWidth,
      ),
    );
  }
}

/// Semantic text widgets for different contexts
class VStoryText extends StatelessWidget {
  const VStoryText._(
    this.text, {
    required this.style,
    this.textAlign = TextAlign.center,
    super.key,
  });

  /// Primary text for headers and important content
  const VStoryText.primary(
    String text, {
    TextAlign textAlign = TextAlign.center,
    Key? key,
  }) : this._(
         text,
         style: const TextStyle(
           color: VStoryColors.primaryText,
           fontSize: 16,
           fontWeight: FontWeight.w500,
         ),
         textAlign: textAlign,
         key: key,
       );

  /// Secondary text for subtitles and descriptions
  const VStoryText.secondary(
    String text, {
    TextAlign textAlign = TextAlign.center,
    Key? key,
  }) : this._(
         text,
         style: const TextStyle(
           color: VStoryColors.secondaryText,
           fontSize: 14,
         ),
         textAlign: textAlign,
         key: key,
       );

  /// Loading text with appropriate styling
  const VStoryText.loading(
    String text, {
    TextAlign textAlign = TextAlign.center,
    Key? key,
  }) : this._(
         text,
         style: const TextStyle(color: VStoryColors.primaryText, fontSize: 14),
         textAlign: textAlign,
         key: key,
       );

  /// Error text with error color
  const VStoryText.error(
    String text, {
    TextAlign textAlign = TextAlign.center,
    Key? key,
  }) : this._(
         text,
         style: const TextStyle(color: VStoryColors.errorPrimary, fontSize: 14),
         textAlign: textAlign,
         key: key,
       );

  /// Caption text for story captions
  const VStoryText.caption(
    String text, {
    TextAlign textAlign = TextAlign.start,
    Key? key,
  }) : this._(
         text,
         style: const TextStyle(
           color: VStoryColors.primaryText,
           fontSize: 14,
           height: 1.4,
         ),
         textAlign: textAlign,
         key: key,
       );

  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style, textAlign: textAlign);
  }
}

/// Semantic button for retry actions
class VRetryButton extends StatelessWidget {
  const VRetryButton({required this.text, required this.onPressed, super.key});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return VStoryButton(
      text: text,
      onPressed: onPressed,
      style: VButtonStyle.retry(),
    );
  }
}

/// Semantic story button with consistent styling
class VStoryButton extends StatelessWidget {
  const VStoryButton({
    required this.text,
    required this.onPressed,
    required this.style,
    super.key,
  });

  final String text;
  final VoidCallback onPressed;
  final VButtonStyle style;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: style.backgroundColor,
        foregroundColor: style.textColor,
        side: style.borderSide,
        padding: style.padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(style.borderRadius),
        ),
      ),
      child: Text(text),
    );
  }
}

/// Semantic container for story content sections
class VStorySection extends StatelessWidget {
  const VStorySection({
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius = VStoryDimensionConstants.defaultBorderRadius,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}

/// Semantic spacer for consistent spacing
class VStorySpacer extends StatelessWidget {
  const VStorySpacer.small({super.key})
    : height = VStoryDimensionConstants.smallBorderRadius,
      width = VStoryDimensionConstants.smallBorderRadius;

  const VStorySpacer.medium({super.key})
    : height = VStoryDimensionConstants.defaultBorderRadius,
      width = VStoryDimensionConstants.defaultBorderRadius;

  const VStorySpacer.large({super.key})
    : height = VStoryDimensionConstants.largeBorderRadius,
      width = VStoryDimensionConstants.largeBorderRadius;

  const VStorySpacer.custom({this.height = 0, this.width = 0, super.key});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, width: width);
  }
}

/// Theme classes for consistent styling
class VProgressTheme {
  const VProgressTheme({
    required this.activeColor,
    required this.inactiveColor,
    required this.strokeWidth,
  });

  final Color activeColor;
  final Color inactiveColor;
  final double strokeWidth;

  static VProgressTheme loading() => const VProgressTheme(
    activeColor: VStoryColors.loadingIndicatorPrimary,
    inactiveColor: VStoryColors.loadingIndicatorSecondary,
    strokeWidth: 3.0,
  );

  static VProgressTheme progress() => const VProgressTheme(
    activeColor: VStoryColors.progressBarActive,
    inactiveColor: VStoryColors.progressBarInactive,
    strokeWidth: VStoryDimensionConstants.progressBarHeight,
  );
}

class VButtonStyle {
  const VButtonStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.borderSide,
    required this.padding,
    required this.borderRadius,
  });

  final Color backgroundColor;
  final Color textColor;
  final BorderSide borderSide;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  static VButtonStyle retry() => VButtonStyle(
    backgroundColor: VStoryColors.errorPrimary,
    textColor: VStoryColors.white,
    borderSide: BorderSide.none,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    borderRadius: VStoryDimensionConstants.defaultBorderRadius,
  );

  static VButtonStyle action() => VButtonStyle(
    backgroundColor: VStoryColors.actionButtonBackground,
    textColor: VStoryColors.primaryText,
    borderSide: const BorderSide(
      color: VStoryColors.actionButtonBorder,
      width: 1,
    ),
    padding: const EdgeInsets.all(12),
    borderRadius: VStoryDimensionConstants.defaultBorderRadius,
  );
}

/// Semantic safe area wrapper
class VStorySafeArea extends StatelessWidget {
  const VStorySafeArea({
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    super.key,
  });

  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }
}

/// Semantic gesture detector wrapper
class VStoryGestureArea extends StatelessWidget {
  const VStoryGestureArea({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      child: child,
    );
  }
}
