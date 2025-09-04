import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Styling configuration for story action menus.
/// 
/// Defines the appearance of action buttons, menus,
/// and interactive elements.
class VStoryActionStyle {
  /// Icon color for action buttons
  final Color iconColor;
  
  /// Background color for action buttons
  final Color backgroundColor;
  
  /// Icon size for action buttons
  final double iconSize;
  
  /// Padding for action buttons
  final EdgeInsets padding;
  
  /// Border radius for action buttons
  final BorderRadius borderRadius;
  
  /// Elevation for action buttons
  final double elevation;
  
  /// Text style for action labels
  final TextStyle? textStyle;
  
  /// Hover color for action buttons
  final Color? hoverColor;
  
  /// Pressed color for action buttons
  final Color? pressedColor;
  
  /// Disabled color for action buttons
  final Color? disabledColor;
  
  /// Border for action buttons
  final Border? border;
  
  /// Shadow for action buttons
  final List<BoxShadow>? shadows;
  
  /// Spacing between action items
  final double spacing;
  
  /// Animation duration for interactions
  final Duration animationDuration;
  
  /// Whether to show ripple effect
  final bool showRipple;
  
  /// Custom icon widget builder
  final Widget Function(IconData icon, Color color, double size)? iconBuilder;
  
  /// Creates an action style configuration
  const VStoryActionStyle({
    required this.iconColor,
    required this.backgroundColor,
    this.iconSize = 24.0,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.elevation = 0,
    this.textStyle,
    this.hoverColor,
    this.pressedColor,
    this.disabledColor,
    this.border,
    this.shadows,
    this.spacing = 8.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.showRipple = true,
    this.iconBuilder,
  });
  
  /// Creates a light theme action style
  factory VStoryActionStyle.light() {
    return const VStoryActionStyle(
      iconColor: Colors.white,
      backgroundColor: Colors.black26,
      iconSize: 24.0,
      padding: EdgeInsets.all(12),
      borderRadius: BorderRadius.all(Radius.circular(8)),
      showRipple: true,
    );
  }
  
  /// Creates a dark theme action style
  factory VStoryActionStyle.dark() {
    return const VStoryActionStyle(
      iconColor: Colors.white,
      backgroundColor: Colors.black54,
      iconSize: 24.0,
      padding: EdgeInsets.all(12),
      borderRadius: BorderRadius.all(Radius.circular(8)),
      elevation: 2,
      shadows: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
  
  /// Creates an action style from Material 3 color scheme
  factory VStoryActionStyle.fromColorScheme(ColorScheme colorScheme) {
    return VStoryActionStyle(
      iconColor: colorScheme.onSurface,
      backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
      iconSize: 24.0,
      padding: const EdgeInsets.all(12),
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      hoverColor: colorScheme.primary.withValues(alpha: 0.1),
      pressedColor: colorScheme.primary.withValues(alpha: 0.2),
      disabledColor: colorScheme.onSurface.withValues(alpha: 0.38),
      textStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 14,
      ),
      elevation: 1,
    );
  }
  
  /// Creates a Cupertino-style action style
  factory VStoryActionStyle.cupertino() {
    return const VStoryActionStyle(
      iconColor: CupertinoColors.white,
      backgroundColor: CupertinoColors.darkBackgroundGray,
      iconSize: 22.0,
      padding: EdgeInsets.all(10),
      borderRadius: BorderRadius.all(Radius.circular(10)),
      showRipple: false,
      animationDuration: Duration(milliseconds: 150),
    );
  }
  
  /// Creates a transparent action style
  factory VStoryActionStyle.transparent() {
    return const VStoryActionStyle(
      iconColor: Colors.white,
      backgroundColor: Colors.transparent,
      iconSize: 28.0,
      padding: EdgeInsets.all(8),
      borderRadius: BorderRadius.all(Radius.circular(24)),
      showRipple: true,
      hoverColor: Colors.white10,
      pressedColor: Colors.white24,
    );
  }
  
  /// Creates an outlined action style
  factory VStoryActionStyle.outlined({
    Color borderColor = Colors.white,
    Color iconColor = Colors.white,
  }) {
    return VStoryActionStyle(
      iconColor: iconColor,
      backgroundColor: Colors.transparent,
      iconSize: 24.0,
      padding: const EdgeInsets.all(12),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      border: Border.all(color: borderColor, width: 1),
      showRipple: true,
    );
  }
  
  /// Creates a filled action style
  factory VStoryActionStyle.filled({
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return VStoryActionStyle(
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      iconSize: 24.0,
      padding: const EdgeInsets.all(12),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      elevation: 2,
      shadows: [
        BoxShadow(
          color: backgroundColor.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  /// Creates a copy with modified fields
  VStoryActionStyle copyWith({
    Color? iconColor,
    Color? backgroundColor,
    double? iconSize,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    double? elevation,
    TextStyle? textStyle,
    Color? hoverColor,
    Color? pressedColor,
    Color? disabledColor,
    Border? border,
    List<BoxShadow>? shadows,
    double? spacing,
    Duration? animationDuration,
    bool? showRipple,
    Widget Function(IconData icon, Color color, double size)? iconBuilder,
  }) {
    return VStoryActionStyle(
      iconColor: iconColor ?? this.iconColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      iconSize: iconSize ?? this.iconSize,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      textStyle: textStyle ?? this.textStyle,
      hoverColor: hoverColor ?? this.hoverColor,
      pressedColor: pressedColor ?? this.pressedColor,
      disabledColor: disabledColor ?? this.disabledColor,
      border: border ?? this.border,
      shadows: shadows ?? this.shadows,
      spacing: spacing ?? this.spacing,
      animationDuration: animationDuration ?? this.animationDuration,
      showRipple: showRipple ?? this.showRipple,
      iconBuilder: iconBuilder ?? this.iconBuilder,
    );
  }
  
  /// Builds an icon widget with the style
  Widget buildIcon(IconData icon, {bool disabled = false}) {
    final color = disabled ? (disabledColor ?? iconColor.withValues(alpha: 0.38)) : iconColor;
    
    if (iconBuilder != null) {
      return iconBuilder!(icon, color, iconSize);
    }
    
    return Icon(
      icon,
      color: color,
      size: iconSize,
    );
  }
  
  /// Gets the button decoration
  BoxDecoration getDecoration({bool isHovered = false, bool isPressed = false}) {
    Color bgColor = backgroundColor;
    
    if (isPressed && pressedColor != null) {
      bgColor = pressedColor!;
    } else if (isHovered && hoverColor != null) {
      bgColor = hoverColor!;
    }
    
    return BoxDecoration(
      color: bgColor,
      borderRadius: borderRadius,
      border: border,
      boxShadow: shadows,
    );
  }
  
  /// Creates an action button widget
  Widget buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? label,
    bool disabled = false,
  }) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: borderRadius,
        splashFactory: showRipple ? null : NoSplash.splashFactory,
        child: AnimatedContainer(
          duration: animationDuration,
          padding: padding,
          decoration: getDecoration(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildIcon(icon, disabled: disabled),
              if (label != null) ...[
                SizedBox(width: spacing),
                Text(
                  label,
                  style: textStyle ?? TextStyle(
                    color: disabled 
                      ? (disabledColor ?? iconColor.withValues(alpha: 0.38))
                      : iconColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    
    if (elevation > 0) {
      return PhysicalModel(
        elevation: elevation,
        borderRadius: borderRadius,
        color: backgroundColor,
        child: button,
      );
    }
    
    return button;
  }
}