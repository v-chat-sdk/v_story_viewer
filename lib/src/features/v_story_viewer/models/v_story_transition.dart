import 'package:flutter/material.dart';

/// Enum for transition direction
enum VTransitionDirection { forward, backward }

/// Enum for transition type
enum VTransitionType { slide, fade, zoom }

/// Configuration for story transition animations
@immutable
class VTransitionConfig {
  const VTransitionConfig({
    this.type = VTransitionType.fade,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
    this.enableTransitions = true,
  });

  /// Type of transition animation (slide, fade, zoom)
  final VTransitionType type;

  /// Duration of the transition animation
  final Duration duration;

  /// Animation curve for smooth transitions
  final Curve curve;

  /// Enable/disable all transitions
  final bool enableTransitions;

  VTransitionConfig copyWith({
    VTransitionType? type,
    Duration? duration,
    Curve? curve,
    bool? enableTransitions,
  }) {
    return VTransitionConfig(
      type: type ?? this.type,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      enableTransitions: enableTransitions ?? this.enableTransitions,
    );
  }
}

/// Custom page route with slide transition
class VSlidePageRoute<T> extends PageRouteBuilder<T> {
  VSlidePageRoute({
    required WidgetBuilder pageBuilder,
    required super.transitionDuration,
    required Curve curve,
    VTransitionDirection direction = VTransitionDirection.forward,
    super.settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) =>
             pageBuilder(context),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final offset = direction == VTransitionDirection.forward
               ? const Offset(1, 0)
               : const Offset(-1, 0);

           return SlideTransition(
             position: animation.drive(
               Tween(
                 begin: offset,
                 end: Offset.zero,
               ).chain(CurveTween(curve: curve)),
             ),
             child: child,
           );
         },
       );
}

/// Custom page route with fade transition
class VFadePageRoute<T> extends PageRouteBuilder<T> {
  VFadePageRoute({
    required WidgetBuilder pageBuilder,
    required super.transitionDuration,
    required Curve curve,
    super.settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) =>
             pageBuilder(context),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return FadeTransition(
             opacity: animation.drive(
               Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: curve)),
             ),
             child: child,
           );
         },
       );
}

/// Custom page route with zoom transition
class VZoomPageRoute<T> extends PageRouteBuilder<T> {
  VZoomPageRoute({
    required WidgetBuilder pageBuilder,
    required super.transitionDuration,
    required Curve curve,
    super.settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) =>
             pageBuilder(context),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return ScaleTransition(
             scale: animation.drive(
               Tween<double>(
                 begin: 0.8,
                 end: 1,
               ).chain(CurveTween(curve: curve)),
             ),
             child: FadeTransition(
               opacity: animation.drive(
                 Tween<double>(
                   begin: 0,
                   end: 1,
                 ).chain(CurveTween(curve: curve)),
               ),
               child: child,
             ),
           );
         },
       );
}

/// Builder for creating page routes with configured transitions
class VStoryPageRouteBuilder {
  /// Create a page route with the configured transition type
  static PageRoute<T> buildRoute<T>({
    required WidgetBuilder pageBuilder,
    required VTransitionConfig config,
    VTransitionDirection direction = VTransitionDirection.forward,
    RouteSettings? settings,
  }) {
    if (!config.enableTransitions) {
      return MaterialPageRoute(builder: pageBuilder, settings: settings);
    }

    return switch (config.type) {
      VTransitionType.slide => VSlidePageRoute<T>(
        pageBuilder: pageBuilder,
        direction: direction,
        transitionDuration: config.duration,
        curve: config.curve,
        settings: settings,
      ),
      VTransitionType.fade => VFadePageRoute<T>(
        pageBuilder: pageBuilder,
        transitionDuration: config.duration,
        curve: config.curve,
        settings: settings,
      ),
      VTransitionType.zoom => VZoomPageRoute<T>(
        pageBuilder: pageBuilder,
        transitionDuration: config.duration,
        curve: config.curve,
        settings: settings,
      ),
    };
  }
}

/// Extension for easy transition direction determination
extension VTransitionDirectionExt on int {
  /// Get transition direction based on story index change
  VTransitionDirection getDirection(int previousIndex) {
    return this > previousIndex
        ? VTransitionDirection.forward
        : VTransitionDirection.backward;
  }
}
