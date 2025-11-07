import 'package:flutter/material.dart';

import '../models/v_story_transition.dart';

/// Widget that applies smooth transitions when story changes
class VStoryTransitionWrapper extends StatelessWidget {
  const VStoryTransitionWrapper({
    required this.child,
    required this.storyId,
    required this.transitionConfig,
    super.key,
  });

  /// The story content to display with transition
  final Widget child;

  /// Unique identifier for the story (used as key for AnimatedSwitcher)
  final String storyId;

  /// Configuration for transition animation
  final VTransitionConfig transitionConfig;

  @override
  Widget build(BuildContext context) {
    if (!transitionConfig.enableTransitions) {
      return child;
    }

    return AnimatedSwitcher(
      duration: transitionConfig.duration,
      reverseDuration: transitionConfig.duration,
      switchInCurve: transitionConfig.curve,
      switchOutCurve: transitionConfig.curve,
      transitionBuilder: (child, animation) {
        return switch (transitionConfig.type) {
          VTransitionType.slide => _buildSlideTransition(child, animation),
          VTransitionType.fade => _buildFadeTransition(child, animation),
          VTransitionType.zoom => _buildZoomTransition(child, animation),
        };
      },
      child: KeyedSubtree(key: ValueKey(storyId), child: child),
    );
  }

  /// Build slide transition
  Widget _buildSlideTransition(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .animate(
            CurvedAnimation(parent: animation, curve: transitionConfig.curve),
          ),
      child: child,
    );
  }

  /// Build fade transition (smooth fade in/out)
  Widget _buildFadeTransition(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: animation, curve: transitionConfig.curve),
      ),
      child: child,
    );
  }

  /// Build zoom transition with fade
  Widget _buildZoomTransition(Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1).animate(
        CurvedAnimation(parent: animation, curve: transitionConfig.curve),
      ),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}
