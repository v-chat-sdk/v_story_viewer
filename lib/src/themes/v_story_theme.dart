import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'v_story_progress_style.dart';
import 'v_story_action_style.dart';
import 'v_story_reply_style.dart';
import 'v_story_header_style.dart';
import 'v_story_footer_style.dart';
import 'v_story_text_style.dart';
import 'v_story_animation_style.dart';

/// Comprehensive theming system for story viewer.
/// 
/// Provides complete customization of colors, fonts, sizes,
/// and styles for all story viewer components.
class VStoryTheme {
  /// Background color for the story viewer
  final Color backgroundColor;
  
  /// Overlay color for gradients and shadows
  final Color overlayColor;
  
  /// Primary color for interactive elements
  final Color primaryColor;
  
  /// Accent color for highlights and emphasis
  final Color accentColor;
  
  /// Error color for error states
  final Color errorColor;
  
  /// Surface color for cards and overlays
  final Color surfaceColor;
  
  /// Text color for primary text
  final Color textColor;
  
  /// Text color for secondary/muted text
  final Color secondaryTextColor;
  
  /// Progress bar styling
  final VStoryProgressStyle progressStyle;
  
  /// Action menu styling
  final VStoryActionStyle actionStyle;
  
  /// Reply system styling
  final VStoryReplyStyle replyStyle;
  
  /// Header styling
  final VStoryHeaderStyle headerStyle;
  
  /// Footer styling
  final VStoryFooterStyle footerStyle;
  
  /// Text story styling
  final VStoryTextStyle textStyle;
  
  /// Animation styling
  final VStoryAnimationStyle animationStyle;
  
  /// Border radius for UI elements
  final BorderRadius borderRadius;
  
  /// Elevation for cards and overlays
  final double elevation;
  
  /// Default padding for UI elements
  final EdgeInsets padding;
  
  /// Default margin for UI elements
  final EdgeInsets margin;
  
  /// Font family for text
  final String? fontFamily;
  
  /// Whether to use Material Design 3
  final bool useMaterial3;
  
  /// Whether to use Cupertino design on iOS
  final bool useCupertinoOnIOS;
  
  /// Creates a custom story theme
  VStoryTheme({
    this.backgroundColor = Colors.black,
    this.overlayColor = const Color(0x99000000),
    this.primaryColor = Colors.white,
    this.accentColor = Colors.blue,
    this.errorColor = Colors.red,
    this.surfaceColor = const Color(0xFF1E1E1E),
    this.textColor = Colors.white,
    this.secondaryTextColor = const Color(0xB3FFFFFF),
    VStoryProgressStyle? progressStyle,
    VStoryActionStyle? actionStyle,
    VStoryReplyStyle? replyStyle,
    VStoryHeaderStyle? headerStyle,
    VStoryFooterStyle? footerStyle,
    VStoryTextStyle? textStyle,
    VStoryAnimationStyle? animationStyle,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.elevation = 4.0,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.fontFamily,
    this.useMaterial3 = true,
    this.useCupertinoOnIOS = true,
  }) : progressStyle = progressStyle ?? VStoryProgressStyle(
         activeColor: Colors.white,
         inactiveColor: Colors.white.withValues(alpha: 0.3),
       ),
       actionStyle = actionStyle ?? VStoryActionStyle(
         iconColor: Colors.white,
         backgroundColor: const Color(0x99000000),
       ),
       replyStyle = replyStyle ?? VStoryReplyStyle(
         backgroundColor: const Color(0xFF1E1E1E),
         textColor: Colors.white,
         hintTextColor: Colors.white60,
         sendButtonColor: Colors.blue,
       ),
       headerStyle = headerStyle ?? VStoryHeaderStyle(
         usernameStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
         timestampStyle: const TextStyle(color: Colors.white60, fontSize: 12),
       ),
       footerStyle = footerStyle ?? VStoryFooterStyle(
         textStyle: const TextStyle(color: Colors.white),
         iconColor: Colors.white,
         backgroundColor: const Color(0x99000000),
       ),
       textStyle = textStyle ?? VStoryTextStyle(
         contentStyle: const TextStyle(color: Colors.white, fontSize: 24),
         backgroundColor: Colors.black,
       ),
       animationStyle = animationStyle ?? VStoryAnimationStyle.standard();
  
  /// Creates a default light theme
  factory VStoryTheme.light() {
    return VStoryTheme(
      backgroundColor: Colors.black,
      overlayColor: Colors.black54,
      primaryColor: Colors.blue,
      accentColor: Colors.blueAccent,
      errorColor: Colors.red,
      surfaceColor: Colors.white,
      textColor: Colors.white,
      secondaryTextColor: Colors.white70,
      progressStyle: VStoryProgressStyle.light(),
      actionStyle: VStoryActionStyle.light(),
      replyStyle: VStoryReplyStyle.light(),
      headerStyle: VStoryHeaderStyle.light(),
      footerStyle: VStoryFooterStyle.light(),
      textStyle: VStoryTextStyle.light(),
      animationStyle: VStoryAnimationStyle.standard(),
    );
  }
  
  /// Creates a default dark theme
  factory VStoryTheme.dark() {
    return VStoryTheme(
      backgroundColor: Colors.black,
      overlayColor: Colors.black87,
      primaryColor: Colors.blueGrey,
      accentColor: Colors.tealAccent,
      errorColor: Colors.redAccent,
      surfaceColor: const Color(0xFF1E1E1E),
      textColor: Colors.white,
      secondaryTextColor: Colors.white60,
      progressStyle: VStoryProgressStyle.dark(),
      actionStyle: VStoryActionStyle.dark(),
      replyStyle: VStoryReplyStyle.dark(),
      headerStyle: VStoryHeaderStyle.dark(),
      footerStyle: VStoryFooterStyle.dark(),
      textStyle: VStoryTextStyle.dark(),
      animationStyle: VStoryAnimationStyle.smooth(),
    );
  }
  
  /// Creates a theme with custom progress bar style
  factory VStoryTheme.withProgressBar({
    VStoryProgressStyle? progressBarTheme,
  }) {
    return VStoryTheme(
      progressStyle: progressBarTheme ?? VStoryProgressStyle(
        activeColor: Colors.white,
        inactiveColor: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }
  
  /// Creates a Material Design 3 theme from ThemeData
  factory VStoryTheme.fromMaterial3(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    return VStoryTheme(
      backgroundColor: colorScheme.surface,
      overlayColor: colorScheme.onSurface.withValues(alpha: 0.54),
      primaryColor: colorScheme.primary,
      accentColor: colorScheme.secondary,
      errorColor: colorScheme.error,
      surfaceColor: colorScheme.surfaceContainerHighest,
      textColor: colorScheme.onSurface,
      secondaryTextColor: colorScheme.onSurfaceVariant,
      progressStyle: VStoryProgressStyle.fromColorScheme(colorScheme),
      actionStyle: VStoryActionStyle.fromColorScheme(colorScheme),
      replyStyle: VStoryReplyStyle.fromColorScheme(colorScheme),
      headerStyle: VStoryHeaderStyle.fromTextTheme(textTheme, colorScheme),
      footerStyle: VStoryFooterStyle.fromTextTheme(textTheme, colorScheme),
      textStyle: VStoryTextStyle.fromTextTheme(textTheme, colorScheme),
      animationStyle: VStoryAnimationStyle.material3(),
      fontFamily: textTheme.bodyLarge?.fontFamily,
      useMaterial3: true,
    );
  }
  
  /// Creates a Cupertino theme
  factory VStoryTheme.cupertino({
    CupertinoThemeData? cupertinoTheme,
    Brightness brightness = Brightness.dark,
  }) {
    final isDark = brightness == Brightness.dark;
    final primaryColor = cupertinoTheme?.primaryColor ?? CupertinoColors.systemBlue;
    
    return VStoryTheme(
      backgroundColor: isDark ? CupertinoColors.black : CupertinoColors.white,
      overlayColor: isDark ? Colors.black54 : Colors.white54,
      primaryColor: primaryColor,
      accentColor: CupertinoColors.activeBlue,
      errorColor: CupertinoColors.systemRed,
      surfaceColor: isDark ? CupertinoColors.darkBackgroundGray : CupertinoColors.systemBackground,
      textColor: isDark ? CupertinoColors.white : CupertinoColors.black,
      secondaryTextColor: CupertinoColors.secondaryLabel,
      progressStyle: VStoryProgressStyle.cupertino(primaryColor),
      actionStyle: VStoryActionStyle.cupertino(),
      replyStyle: VStoryReplyStyle.cupertino(),
      headerStyle: VStoryHeaderStyle.cupertino(),
      footerStyle: VStoryFooterStyle.cupertino(),
      textStyle: VStoryTextStyle.cupertino(),
      animationStyle: VStoryAnimationStyle.cupertino(),
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      fontFamily: '.SF Pro Text',
      useCupertinoOnIOS: true,
    );
  }
  
  /// Creates a WhatsApp-style theme
  factory VStoryTheme.whatsapp() {
    const whatsappGreen = Color(0xFF25D366);
    const whatsappDark = Color(0xFF075E54);
    
    return VStoryTheme(
      backgroundColor: Colors.black,
      overlayColor: Colors.black54,
      primaryColor: whatsappGreen,
      accentColor: whatsappGreen,
      errorColor: Colors.red,
      surfaceColor: const Color(0xFF1F2C34),
      textColor: Colors.white,
      secondaryTextColor: Colors.white70,
      progressStyle: VStoryProgressStyle(
        activeColor: whatsappGreen,
        inactiveColor: Colors.white30,
        height: 3,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        spacing: 4,
        radius: 1.5,
      ),
      actionStyle: VStoryActionStyle(
        iconColor: Colors.white,
        backgroundColor: Colors.black54,
        iconSize: 24,
        padding: const EdgeInsets.all(12),
      ),
      replyStyle: VStoryReplyStyle(
        backgroundColor: whatsappDark,
        textColor: Colors.white,
        hintTextColor: Colors.white54,
        sendButtonColor: whatsappGreen,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      headerStyle: VStoryHeaderStyle.light(),
      footerStyle: VStoryFooterStyle.light(),
      textStyle: VStoryTextStyle.light(),
      animationStyle: VStoryAnimationStyle.standard(),
    );
  }
  
  /// Creates an Instagram-style theme
  factory VStoryTheme.instagram() {
    const instagramPurple = Color(0xFF833AB4);
    const instagramPink = Color(0xFFF56040);
    
    return VStoryTheme(
      backgroundColor: Colors.black,
      overlayColor: Colors.black54,
      primaryColor: instagramPink,
      accentColor: instagramPurple,
      errorColor: Colors.red,
      surfaceColor: const Color(0xFF262626),
      textColor: Colors.white,
      secondaryTextColor: Colors.white70,
      progressStyle: VStoryProgressStyle(
        activeColor: Colors.white,
        inactiveColor: Colors.white30,
        height: 2,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        spacing: 4,
        radius: 1,
      ),
      actionStyle: VStoryActionStyle(
        iconColor: Colors.white,
        backgroundColor: Colors.transparent,
        iconSize: 28,
        padding: const EdgeInsets.all(8),
      ),
      replyStyle: VStoryReplyStyle(
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        hintTextColor: Colors.white54,
        sendButtonColor: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(22)),
        borderColor: Colors.white24,
      ),
      headerStyle: VStoryHeaderStyle.light(),
      footerStyle: VStoryFooterStyle.light(),
      textStyle: VStoryTextStyle.light(),
      animationStyle: VStoryAnimationStyle.bouncy(),
    );
  }
  
  /// Creates a copy with modified fields
  VStoryTheme copyWith({
    Color? backgroundColor,
    Color? overlayColor,
    Color? primaryColor,
    Color? accentColor,
    Color? errorColor,
    Color? surfaceColor,
    Color? textColor,
    Color? secondaryTextColor,
    VStoryProgressStyle? progressStyle,
    VStoryActionStyle? actionStyle,
    VStoryReplyStyle? replyStyle,
    VStoryHeaderStyle? headerStyle,
    VStoryFooterStyle? footerStyle,
    VStoryTextStyle? textStyle,
    VStoryAnimationStyle? animationStyle,
    BorderRadius? borderRadius,
    double? elevation,
    EdgeInsets? padding,
    EdgeInsets? margin,
    String? fontFamily,
    bool? useMaterial3,
    bool? useCupertinoOnIOS,
  }) {
    return VStoryTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      overlayColor: overlayColor ?? this.overlayColor,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      errorColor: errorColor ?? this.errorColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      textColor: textColor ?? this.textColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      progressStyle: progressStyle ?? this.progressStyle,
      actionStyle: actionStyle ?? this.actionStyle,
      replyStyle: replyStyle ?? this.replyStyle,
      headerStyle: headerStyle ?? this.headerStyle,
      footerStyle: footerStyle ?? this.footerStyle,
      textStyle: textStyle ?? this.textStyle,
      animationStyle: animationStyle ?? this.animationStyle,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      fontFamily: fontFamily ?? this.fontFamily,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      useCupertinoOnIOS: useCupertinoOnIOS ?? this.useCupertinoOnIOS,
    );
  }
  
  /// Applies the theme to a widget
  static VStoryTheme of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_VStoryThemeInherited>();
    return inherited?.theme ?? VStoryTheme.light();
  }
}

/// Inherited widget for providing theme to descendants
class VStoryThemeProvider extends StatelessWidget {
  /// The theme to provide
  final VStoryTheme theme;
  
  /// The child widget
  final Widget child;
  
  /// Creates a theme provider
  const VStoryThemeProvider({
    super.key,
    required this.theme,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return _VStoryThemeInherited(
      theme: theme,
      child: child,
    );
  }
}

/// Internal inherited widget
class _VStoryThemeInherited extends InheritedWidget {
  /// The theme
  final VStoryTheme theme;
  
  /// Creates the inherited widget
  const _VStoryThemeInherited({
    required this.theme,
    required super.child,
  });
  
  @override
  bool updateShouldNotify(_VStoryThemeInherited oldWidget) {
    return theme != oldWidget.theme;
  }
}