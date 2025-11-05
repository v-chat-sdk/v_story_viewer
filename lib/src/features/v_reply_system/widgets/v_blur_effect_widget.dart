import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/v_blur_effect.dart';

/// Animated blur effect widget for overlaying content
class VAnimatedBlurEffect extends StatefulWidget {
  const VAnimatedBlurEffect({
    required this.child,
    required this.showBlur,
    this.config = const VBlurEffectConfig(),
    super.key,
  });

  /// The child widget to apply blur effect to
  final Widget child;

  /// Whether to show the blur effect
  final bool showBlur;

  /// Configuration for blur effect
  final VBlurEffectConfig config;

  @override
  State<VAnimatedBlurEffect> createState() => _VAnimatedBlurEffectState();
}

class _VAnimatedBlurEffectState extends State<VAnimatedBlurEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.config.animationDuration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _blurAnimation = Tween<double>(
      begin: 0,
      end: widget.config.blurSigmaX,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.showBlur && widget.config.enableBlur) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(VAnimatedBlurEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showBlur != widget.showBlur) {
      if (widget.showBlur && widget.config.enableBlur) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Skip blur on mobile platforms if webOnly is enabled
    if (widget.config.webOnly && !kIsWeb) {
      return widget.child;
    }

    if (!widget.config.enableBlur) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_blurAnimation, _opacityAnimation]),
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Blurred child
            if (_blurAnimation.value > 0)
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _blurAnimation.value,
                    sigmaY: _blurAnimation.value,
                  ),
                  child: child,
                ),
              )
            else
              child!,

            // Dark overlay
            if (_opacityAnimation.value > 0)
              Container(
                color: Colors.black.withValues(
                  alpha: widget.config.overlayOpacity * _opacityAnimation.value,
                ),
              ),
          ],
        );
      },
      child: widget.child,
    );
  }
}

/// Simple blur overlay component for web platform
class VBlurOverlay extends StatelessWidget {
  const VBlurOverlay({
    required this.child,
    required this.overlayOpacity,
    this.blurSigmaX = 8,
    this.blurSigmaY = 8,
    this.onTap,
    super.key,
  });

  /// The child widget to apply blur effect to
  final Widget child;

  /// Opacity of the dark overlay
  final double overlayOpacity;

  /// X-axis blur sigma
  final double blurSigmaX;

  /// Y-axis blur sigma
  final double blurSigmaY;

  /// Callback when overlay is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Only show on web
    if (!kIsWeb) {
      return child;
    }

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred content
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigmaX, sigmaY: blurSigmaY),
            child: child,
          ),

          // Dark overlay
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.black.withValues(alpha: overlayOpacity),
            ),
          ),
        ],
      ),
    );
  }
}

/// Builder for creating blur effects with custom configuration
class VBlurEffectBuilder {
  /// Create an animated blur effect widget
  static Widget animatedBlur({
    required Widget child,
    required bool showBlur,
    VBlurEffectConfig config = const VBlurEffectConfig(),
  }) {
    return VAnimatedBlurEffect(
      child: child,
      showBlur: showBlur,
      config: config,
    );
  }

  /// Create a simple blur overlay
  static Widget simpleBlur({
    required Widget child,
    required bool showBlur,
    VBlurEffectConfig config = const VBlurEffectConfig(),
    VoidCallback? onOverlayTap,
  }) {
    if (!showBlur || !config.enableBlur) {
      return child;
    }

    return VBlurOverlay(
      overlayOpacity: config.overlayOpacity,
      blurSigmaX: config.blurSigmaX,
      blurSigmaY: config.blurSigmaY,
      onTap: onOverlayTap,
      child: child,
    );
  }

  /// Create a subtle preset blur effect
  static Widget subtle({required Widget child, required bool showBlur}) {
    return VAnimatedBlurEffect(
      child: child,
      showBlur: showBlur,
      config: VBlurEffectPresets.subtle,
    );
  }

  /// Create a standard preset blur effect
  static Widget standard({required Widget child, required bool showBlur}) {
    return VAnimatedBlurEffect(child: child, showBlur: showBlur);
  }

  /// Create a strong preset blur effect
  static Widget strong({required Widget child, required bool showBlur}) {
    return VAnimatedBlurEffect(
      child: child,
      showBlur: showBlur,
      config: VBlurEffectPresets.strong,
    );
  }

  /// Create a heavy preset blur effect
  static Widget heavy({required Widget child, required bool showBlur}) {
    return VAnimatedBlurEffect(
      child: child,
      showBlur: showBlur,
      config: VBlurEffectPresets.heavy,
    );
  }
}
