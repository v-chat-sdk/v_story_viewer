import 'package:flutter/material.dart';

/// Typography configuration for story viewer
@immutable
class VTypography {
  const VTypography({
    this.headline1,
    this.headline2,
    this.headline3,
    this.headline4,
    this.headline5,
    this.headline6,
    this.subtitle1,
    this.subtitle2,
    this.body1,
    this.body2,
    this.caption,
    this.button,
    this.overline,
    this.storyText,
    this.userName,
    this.timestamp,
    this.replyHint,
    this.errorText,
  });

  /// Default typography
  factory VTypography.defaultTypography({Color textColor = Colors.white}) {
    return VTypography(
      headline1: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headline2: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headline3: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headline4: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headline5: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headline6: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      subtitle1: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      subtitle2: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      body1: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      body2: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      caption: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textColor.withValues(alpha: 0.7),
      ),
      button: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 1.25,
      ),
      overline: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 1.5,
      ),
      storyText: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.5,
      ),
      userName: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      timestamp: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textColor.withValues(alpha: 0.7),
      ),
      replyHint: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor.withValues(alpha: 0.5),
        fontStyle: FontStyle.italic,
      ),
      errorText: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFFCF6679),
      ),
    );
  }

  /// Headline 1 style
  final TextStyle? headline1;

  /// Headline 2 style
  final TextStyle? headline2;

  /// Headline 3 style
  final TextStyle? headline3;

  /// Headline 4 style
  final TextStyle? headline4;

  /// Headline 5 style
  final TextStyle? headline5;

  /// Headline 6 style
  final TextStyle? headline6;

  /// Subtitle 1 style
  final TextStyle? subtitle1;

  /// Subtitle 2 style
  final TextStyle? subtitle2;

  /// Body 1 style
  final TextStyle? body1;

  /// Body 2 style
  final TextStyle? body2;

  /// Caption style
  final TextStyle? caption;

  /// Button style
  final TextStyle? button;

  /// Overline style
  final TextStyle? overline;

  /// Story text style
  final TextStyle? storyText;

  /// User name style
  final TextStyle? userName;

  /// Timestamp style
  final TextStyle? timestamp;

  /// Reply hint style
  final TextStyle? replyHint;

  /// Error text style
  final TextStyle? errorText;

  /// Create a copy with modifications
  VTypography copyWith({
    TextStyle? headline1,
    TextStyle? headline2,
    TextStyle? headline3,
    TextStyle? headline4,
    TextStyle? headline5,
    TextStyle? headline6,
    TextStyle? subtitle1,
    TextStyle? subtitle2,
    TextStyle? body1,
    TextStyle? body2,
    TextStyle? caption,
    TextStyle? button,
    TextStyle? overline,
    TextStyle? storyText,
    TextStyle? userName,
    TextStyle? timestamp,
    TextStyle? replyHint,
    TextStyle? errorText,
  }) {
    return VTypography(
      headline1: headline1 ?? this.headline1,
      headline2: headline2 ?? this.headline2,
      headline3: headline3 ?? this.headline3,
      headline4: headline4 ?? this.headline4,
      headline5: headline5 ?? this.headline5,
      headline6: headline6 ?? this.headline6,
      subtitle1: subtitle1 ?? this.subtitle1,
      subtitle2: subtitle2 ?? this.subtitle2,
      body1: body1 ?? this.body1,
      body2: body2 ?? this.body2,
      caption: caption ?? this.caption,
      button: button ?? this.button,
      overline: overline ?? this.overline,
      storyText: storyText ?? this.storyText,
      userName: userName ?? this.userName,
      timestamp: timestamp ?? this.timestamp,
      replyHint: replyHint ?? this.replyHint,
      errorText: errorText ?? this.errorText,
    );
  }
}
