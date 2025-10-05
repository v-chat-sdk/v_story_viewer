import 'package:flutter/material.dart';

import '../controllers/v_reaction_controller.dart';

/// Widget that displays reaction animation overlay
class VReactionAnimation extends StatefulWidget {
  const VReactionAnimation({
    required this.controller,
    super.key,
  });

  final VReactionController controller;

  @override
  State<VReactionAnimation> createState() => _VReactionAnimationState();
}

class _VReactionAnimationState extends State<VReactionAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.controller.config.animationDuration,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_animationController);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(_animationController);

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.3),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    widget.controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (widget.controller.isAnimating) {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        if (!widget.controller.isAnimating) {
          return const SizedBox.shrink();
        }

        return Center(
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Text(
                  widget.controller.config.reactionType,
                  style: TextStyle(
                    fontSize: widget.controller.config.iconSize,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
