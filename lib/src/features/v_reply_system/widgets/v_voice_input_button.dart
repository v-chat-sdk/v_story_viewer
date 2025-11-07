import 'package:flutter/material.dart';

import '../models/v_voice_input.dart';

/// Button widget for initiating voice input
class VVoiceInputButton extends StatefulWidget {
  const VVoiceInputButton({
    required this.onVoiceInput,
    this.onError,
    this.stateNotifier,
    this.config = const VVoiceInputConfig(),
    this.size = 48,
    this.enabled = true,
    super.key,
  });

  /// Callback when voice input is recognized
  final void Function(String transcript) onVoiceInput;

  /// Callback when error occurs
  final void Function(VVoiceInputErrorType error)? onError;

  /// State notifier for tracking voice input state
  final VVoiceInputStateNotifier? stateNotifier;

  /// Configuration for voice input
  final VVoiceInputConfig config;

  /// Size of the button
  final double size;

  /// Whether the button is enabled
  final bool enabled;

  @override
  State<VVoiceInputButton> createState() => _VVoiceInputButtonState();
}

class _VVoiceInputButtonState extends State<VVoiceInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(VVoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stateNotifier?.isListening ?? false) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleVoiceInput() {
    if (!widget.enabled || !widget.config.enableVoiceInput) {
      return;
    }

    widget.stateNotifier?.updateState(VVoiceInputState.listening);
    _pulseController.repeat(reverse: true);

    // Simulate voice input (in real implementation, use speech_to_text package)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _pulseController.stop();
        widget.stateNotifier?.updateState(VVoiceInputState.recognized);
        widget.onVoiceInput('Your speech text here');
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            widget.stateNotifier?.updateState(VVoiceInputState.idle);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isListening = widget.stateNotifier?.isListening ?? false;

    return ScaleTransition(
      scale: isListening ? _pulseAnimation : AlwaysStoppedAnimation(1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.enabled ? _handleVoiceInput : null,
          borderRadius: BorderRadius.circular(widget.size / 2),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isListening
                  ? Colors.red.withValues(alpha: 0.2)
                  : Colors.blue.withValues(alpha: 0.1),
              border: Border.all(
                color: isListening ? Colors.red : Colors.blue,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                isListening ? Icons.mic : Icons.mic_none,
                color: isListening ? Colors.red : Colors.blue,
                size: widget.size * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Display widget for showing voice input results
class VVoiceInputResult extends StatelessWidget {
  const VVoiceInputResult({required this.result, this.onDismiss, super.key});

  /// Voice recognition result to display
  final VVoiceRecognitionResult result;

  /// Callback when result is dismissed
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    if (result.hasError) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                result.errorDescription ?? result.error ?? 'Unknown error',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            if (onDismiss != null)
              GestureDetector(
                onTap: onDismiss,
                child: const Icon(Icons.close, color: Colors.red, size: 16),
              ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.text,
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
                if (result.confidenceScore > 0)
                  Text(
                    'Confidence: ${(result.confidenceScore * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close, color: Colors.grey, size: 16),
            ),
        ],
      ),
    );
  }
}

/// Indicator showing voice input state
class VVoiceInputStateIndicator extends StatelessWidget {
  const VVoiceInputStateIndicator({required this.state, super.key});

  /// Current voice input state
  final VVoiceInputState state;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (state) {
      VVoiceInputState.idle => (Icons.mic_none, 'Ready', Colors.grey),
      VVoiceInputState.initializing => (
        Icons.settings,
        'Initializing...',
        Colors.orange,
      ),
      VVoiceInputState.listening => (Icons.mic, 'Listening...', Colors.red),
      VVoiceInputState.processing => (
        Icons.hourglass_bottom,
        'Processing...',
        Colors.blue,
      ),
      VVoiceInputState.recognized => (
        Icons.check_circle,
        'Recognized',
        Colors.green,
      ),
      VVoiceInputState.error => (Icons.error, 'Error', Colors.red),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}
