import 'dart:ui';

import 'package:flutter/material.dart';

/// Builder for loading overlay with progress indicator and blurred background
class VLoadingOverlayBuilder {
  const VLoadingOverlayBuilder._();

  static Widget build(double progress) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.3),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress,
                  color: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  strokeWidth: 5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
