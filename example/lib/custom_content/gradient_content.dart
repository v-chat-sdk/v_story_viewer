import 'package:flutter/material.dart';

class AnimatedGradientContent extends StatefulWidget {
  final bool isPaused;
  const AnimatedGradientContent({super.key, required this.isPaused});
  @override
  State<AnimatedGradientContent> createState() =>
      _AnimatedGradientContentState();
}

class _AnimatedGradientContentState extends State<AnimatedGradientContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant AnimatedGradientContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused) {
      _controller.stop();
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(const Color(0xFFEC4899), const Color(0xFF6366F1),
                    _controller.value)!,
                Color.lerp(const Color(0xFF6366F1), const Color(0xFF10B981),
                    _controller.value)!,
                Color.lerp(const Color(0xFF10B981), const Color(0xFFF59E0B),
                    _controller.value)!,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 64, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  'Animated Background',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isPaused
                      ? 'Animation Paused'
                      : 'Smooth gradient transitions',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
