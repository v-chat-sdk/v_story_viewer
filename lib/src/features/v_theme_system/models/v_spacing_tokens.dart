/// Design tokens for consistent spacing throughout the application
/// Uses a base unit of 4dp with multipliers for a clean scale
class VSpacingTokens {
  const VSpacingTokens();

  /// Extra small spacing (4px) - Used for tight layouts
  static const double xs = 4;

  /// Small spacing (8px) - Used for small gaps and padding
  static const double sm = 8;

  /// Medium spacing (12px) - Used for component internal spacing
  static const double md = 12;

  /// Standard spacing (16px) - Default spacing between components
  static const double lg = 16;

  /// Large spacing (24px) - Used for major sections
  static const double xl = 24;

  /// Extra large spacing (32px) - Used for page-level spacing
  static const double xxl = 32;

  /// Header padding vertical
  static const double headerPaddingVertical = lg;

  /// Header padding horizontal
  static const double headerPaddingHorizontal = lg;

  /// Progress bar spacing (vertical gap between bars)
  static const double progressBarGap = 4;

  /// Progress bar padding horizontal
  static const double progressBarPaddingHorizontal = lg;

  /// Reply input padding
  static const double replyInputPadding = md;

  /// Footer padding vertical
  static const double footerPaddingVertical = lg;

  /// Footer padding horizontal
  static const double footerPaddingHorizontal = lg;

  /// Story actions padding
  static const double actionsPadding = md;

  /// Content margin horizontal
  static const double contentMarginHorizontal = lg;

  /// Safe area padding (notch compensation)
  static const double safeAreaPadding = lg;

  /// Dialog padding
  static const double dialogPadding = xl;

  /// Card padding
  static const double cardPadding = lg;

  /// Button padding vertical
  static const double buttonPaddingVertical = md;

  /// Button padding horizontal
  static const double buttonPaddingHorizontal = lg;

  /// Icon spacing (between icon and text)
  static const double iconSpacing = md;

  /// List item spacing
  static const double listItemSpacing = md;

  /// Section spacing
  static const double sectionSpacing = xl;
}
