import 'package:flutter/material.dart';

import '../../v_theme_system/models/v_spacing_tokens.dart';
import '../models/v_error_recovery_state.dart';

/// Widget for displaying error with retry button
class VErrorRecoveryWidget extends StatelessWidget {
  const VErrorRecoveryWidget({
    required this.errorState,
    this.onRetry,
    super.key,
  });

  /// Error recovery state
  final VErrorRecoveryState errorState;

  /// Callback when retry button is pressed
  final VoidCallback? onRetry;

  /// Get error icon based on error code
  IconData _getErrorIcon() {
    if (errorState.error == null) return Icons.error;
    final code = errorState.error!.code;
    switch (code) {
      case 'NETWORK_ERROR':
        return Icons.wifi_off;
      case 'TIMEOUT':
        return Icons.schedule;
      case 'NOT_FOUND':
        return Icons.image_not_supported;
      case 'PERMISSION_DENIED':
        return Icons.lock;
      default:
        return Icons.error_outline;
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage() {
    if (errorState.error == null) return 'An error occurred';
    final code = errorState.error!.code;
    switch (code) {
      case 'NETWORK_ERROR':
        return 'Network error. Check your connection.';
      case 'TIMEOUT':
        return 'The request timed out. Please try again.';
      case 'NOT_FOUND':
        return 'Story not found or deleted.';
      case 'PERMISSION_DENIED':
        return 'You don\'t have permission to view this story.';
      default:
        return errorState.error!.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.red.withValues(alpha: 0.2),
      padding: EdgeInsets.all(VSpacingTokens.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                _getErrorIcon(),
                color: Colors.red,
                size: 24,
              ),
              SizedBox(width: VSpacingTokens.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.red,
                          ),
                    ),
                    SizedBox(height: VSpacingTokens.xs),
                    Text(
                      _getErrorMessage(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (errorState.isErrorRetryable) ...[
            SizedBox(height: VSpacingTokens.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (errorState.remainingRetries > 0)
                  Text(
                    'Retries left: ${errorState.remainingRetries}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white70,
                        ),
                  )
                else
                  Text(
                    'Max retries reached',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                if (errorState.canRetry)
                  ElevatedButton.icon(
                    onPressed: errorState.isRetrying ? null : onRetry,
                    icon: errorState.isRetrying
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          )
                        : const Icon(Icons.refresh, size: 16),
                    label: Text(
                      errorState.isRetrying ? 'Retrying...' : 'Retry',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: VSpacingTokens.md,
                        vertical: VSpacingTokens.xs,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
