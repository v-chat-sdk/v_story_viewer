import 'package:flutter/material.dart';

import '../models/v_story_error.dart';

/// Widget for displaying error messages
class VErrorDisplay extends StatelessWidget {
  const VErrorDisplay({
    required this.error,
    this.onRetry,
    this.onDismiss,
    super.key,
  });

  /// Error to display
  final VStoryError error;

  /// Callback when retry button is tapped
  final VoidCallback? onRetry;

  /// Callback when dismiss button is tapped
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error.message,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (onRetry != null || onDismiss != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onDismiss != null)
                  TextButton(
                    onPressed: onDismiss,
                    child: const Text('Dismiss'),
                  ),
                if (onRetry != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
