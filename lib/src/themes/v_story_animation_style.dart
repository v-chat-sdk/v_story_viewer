import 'package:flutter/material.dart';

/// Styling configuration for animations in story viewer.
class VStoryAnimationStyle {
  /// Duration for story transitions
  final Duration transitionDuration;
  
  /// Curve for story transitions
  final Curve transitionCurve;
  
  /// Duration for progress animations
  final Duration progressDuration;
  
  /// Curve for progress animations
  final Curve progressCurve;
  
  /// Duration for reaction animations
  final Duration reactionDuration;
  
  /// Curve for reaction animations
  final Curve reactionCurve;
  
  /// Duration for reply animations
  final Duration replyDuration;
  
  /// Curve for reply animations
  final Curve replyCurve;
  
  /// Duration for fade animations
  final Duration fadeDuration;
  
  /// Curve for fade animations
  final Curve fadeCurve;
  
  /// Duration for scale animations
  final Duration scaleDuration;
  
  /// Curve for scale animations
  final Curve scaleCurve;
  
  /// Whether to enable spring physics
  final bool useSpringPhysics;
  
  /// Spring physics configuration
  final SpringDescription? springDescription;
  
  /// Creates an animation style
  const VStoryAnimationStyle({
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionCurve = Curves.easeInOut,
    this.progressDuration = const Duration(milliseconds: 200),
    this.progressCurve = Curves.linear,
    this.reactionDuration = const Duration(milliseconds: 800),
    this.reactionCurve = Curves.elasticOut,
    this.replyDuration = const Duration(milliseconds: 250),
    this.replyCurve = Curves.easeOutCubic,
    this.fadeDuration = const Duration(milliseconds: 200),
    this.fadeCurve = Curves.easeIn,
    this.scaleDuration = const Duration(milliseconds: 200),
    this.scaleCurve = Curves.easeInOut,
    this.useSpringPhysics = false,
    this.springDescription,
  });
  
  /// Creates standard animations
  factory VStoryAnimationStyle.standard() {
    return const VStoryAnimationStyle();
  }
  
  /// Creates smooth animations
  factory VStoryAnimationStyle.smooth() {
    return const VStoryAnimationStyle(
      transitionDuration: Duration(milliseconds: 400),
      transitionCurve: Curves.easeInOutCubic,
      progressCurve: Curves.easeInOut,
      reactionCurve: Curves.easeOutBack,
      replyCurve: Curves.easeInOutCubic,
    );
  }
  
  /// Creates bouncy animations
  factory VStoryAnimationStyle.bouncy() {
    return const VStoryAnimationStyle(
      transitionCurve: Curves.bounceOut,
      reactionCurve: Curves.bounceOut,
      replyCurve: Curves.elasticOut,
      scaleCurve: Curves.elasticOut,
      useSpringPhysics: true,
    );
  }
  
  /// Creates Material 3 animations
  factory VStoryAnimationStyle.material3() {
    return const VStoryAnimationStyle(
      transitionDuration: Duration(milliseconds: 350),
      transitionCurve: Curves.easeInOutCubicEmphasized,
      progressCurve: Curves.easeInOutCubicEmphasized,
      reactionCurve: Curves.easeOutCubic,
      replyCurve: Curves.easeInOutCubicEmphasized,
      fadeCurve: Curves.easeInOutCubicEmphasized,
    );
  }
  
  /// Creates Cupertino animations
  factory VStoryAnimationStyle.cupertino() {
    return const VStoryAnimationStyle(
      transitionDuration: Duration(milliseconds: 350),
      transitionCurve: Curves.easeInOutCubic,
      progressCurve: Curves.linear,
      reactionCurve: Curves.easeOutCubic,
      replyCurve: Curves.easeInOutCubic,
      useSpringPhysics: true,
    );
  }
  
  /// Creates fast animations
  factory VStoryAnimationStyle.fast() {
    return const VStoryAnimationStyle(
      transitionDuration: Duration(milliseconds: 150),
      progressDuration: Duration(milliseconds: 100),
      reactionDuration: Duration(milliseconds: 400),
      replyDuration: Duration(milliseconds: 150),
      fadeDuration: Duration(milliseconds: 100),
      scaleDuration: Duration(milliseconds: 100),
    );
  }
  
  /// Creates slow animations
  factory VStoryAnimationStyle.slow() {
    return const VStoryAnimationStyle(
      transitionDuration: Duration(milliseconds: 500),
      progressDuration: Duration(milliseconds: 300),
      reactionDuration: Duration(milliseconds: 1200),
      replyDuration: Duration(milliseconds: 400),
      fadeDuration: Duration(milliseconds: 300),
      scaleDuration: Duration(milliseconds: 300),
    );
  }
  
  /// Creates no animations (instant)
  factory VStoryAnimationStyle.none() {
    return const VStoryAnimationStyle(
      transitionDuration: Duration.zero,
      progressDuration: Duration.zero,
      reactionDuration: Duration.zero,
      replyDuration: Duration.zero,
      fadeDuration: Duration.zero,
      scaleDuration: Duration.zero,
      transitionCurve: Curves.linear,
      progressCurve: Curves.linear,
      reactionCurve: Curves.linear,
      replyCurve: Curves.linear,
      fadeCurve: Curves.linear,
      scaleCurve: Curves.linear,
    );
  }
}