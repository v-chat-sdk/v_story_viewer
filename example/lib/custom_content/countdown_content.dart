import 'dart:async';
import 'package:flutter/material.dart';

class CountdownStoryContent extends StatefulWidget {
  final bool isPaused;
  final void Function(Duration? duration) onLoaded;
  const CountdownStoryContent({
    super.key,
    required this.isPaused,
    required this.onLoaded,
  });
  @override
  State<CountdownStoryContent> createState() => _CountdownStoryContentState();
}

class _CountdownStoryContentState extends State<CountdownStoryContent> {
  late Timer _timer;
  int _secondsRemaining = 10;
  bool _loaded = false;
  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loaded) {
        _loaded = true;
        widget.onLoaded(Duration(seconds: _secondsRemaining));
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!widget.isPaused && _secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'COMING SOON',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 4),
              ),
              child: Center(
                child: Text(
                  '$_secondsRemaining',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'New Feature Launch',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isPaused ? 'PAUSED' : 'Get ready!',
              style: TextStyle(
                color: widget.isPaused ? Colors.amber : Colors.white54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
