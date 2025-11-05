import 'package:flutter/material.dart';

/// Configuration for the story footer
class VFooterConfig {
  const VFooterConfig({
    this.showCaption = true,
    this.showEngagementIndicators = true,
    this.maxCaptionLines = 3,
    this.captionTextStyle,
    this.metadataTextStyle,
    this.backgroundColor,
    this.showDivider = true,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.expandedHeight = 200.0,
    this.collapsedHeight = 60.0,
  });

  /// Whether to show the story caption
  final bool showCaption;

  /// Whether to show engagement indicators (views, reactions)
  final bool showEngagementIndicators;

  /// Maximum lines for caption before truncating
  final int maxCaptionLines;

  /// Text style for caption
  final TextStyle? captionTextStyle;

  /// Text style for metadata (timestamp, source)
  final TextStyle? metadataTextStyle;

  /// Background color for footer
  final Color? backgroundColor;

  /// Whether to show divider above footer
  final bool showDivider;

  /// Enable footer animations
  final bool enableAnimation;

  /// Duration for footer animations
  final Duration animationDuration;

  /// Height when footer is fully expanded
  final double expandedHeight;

  /// Height when footer is collapsed
  final double collapsedHeight;

  /// Create a copy with modifications
  VFooterConfig copyWith({
    bool? showCaption,
    bool? showEngagementIndicators,
    int? maxCaptionLines,
    TextStyle? captionTextStyle,
    TextStyle? metadataTextStyle,
    Color? backgroundColor,
    bool? showDivider,
    bool? enableAnimation,
    Duration? animationDuration,
    double? expandedHeight,
    double? collapsedHeight,
  }) {
    return VFooterConfig(
      showCaption: showCaption ?? this.showCaption,
      showEngagementIndicators:
          showEngagementIndicators ?? this.showEngagementIndicators,
      maxCaptionLines: maxCaptionLines ?? this.maxCaptionLines,
      captionTextStyle: captionTextStyle ?? this.captionTextStyle,
      metadataTextStyle: metadataTextStyle ?? this.metadataTextStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      showDivider: showDivider ?? this.showDivider,
      enableAnimation: enableAnimation ?? this.enableAnimation,
      animationDuration: animationDuration ?? this.animationDuration,
      expandedHeight: expandedHeight ?? this.expandedHeight,
      collapsedHeight: collapsedHeight ?? this.collapsedHeight,
    );
  }
}
