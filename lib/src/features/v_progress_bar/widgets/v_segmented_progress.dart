import 'package:flutter/material.dart';

import '../controllers/v_progress_controller.dart';
import '../models/v_progress_style.dart';

/// Segmented progress bar widget using LinearProgressIndicator
///
/// Displays progress for multiple bars with WhatsApp-style behavior:
/// - Completed bars show full progress (1.0)
/// - Current bar shows animating progress
/// - Future bars show empty progress (0.0)
class VSegmentedProgress extends StatelessWidget {
  const VSegmentedProgress({
    required this.controller,
    this.style = VProgressStyle.whatsapp,
    super.key,
  });

  /// Progress controller
  final VProgressController controller;

  /// Style configuration
  final VProgressStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Padding(
          padding: style.padding,
          child: Row(
            children: List.generate(
              controller.barCount,
              (index) {
                final isLast = index == controller.barCount - 1;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: isLast ? 0 : style.segmentSpacing,
                    ),
                    child: LinearProgressIndicator(
                      value: controller.getProgress(index),
                      backgroundColor: style.inactiveColor,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(style.activeColor),
                      minHeight: style.height,
                      borderRadius: style.borderRadius,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
