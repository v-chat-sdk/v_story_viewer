import 'package:flutter/material.dart';
import '../models/v_story_error.dart';
import '../models/v_network_error.dart';
import '../models/v_media_load_error.dart';
import '../models/v_controller_error.dart';
import '../models/v_cache_error.dart';
import '../models/v_permission_error.dart';
import '../models/v_timeout_error.dart';

/// Provides error recovery strategies and placeholder widgets
class VErrorRecovery {
  /// Build error placeholder widget
  static Widget buildErrorPlaceholder({
    required VStoryError error,
    VoidCallback? onRetry,
    Color? backgroundColor,
    TextStyle? textStyle,
    double? iconSize,
    EdgeInsetsGeometry? padding,
  }) {
    final bgColor = backgroundColor ?? Colors.black87;
    final style = textStyle ?? const TextStyle(
      color: Colors.white,
      fontSize: 14,
    );
    final icon = iconSize ?? 48;
    final contentPadding = padding ?? const EdgeInsets.all(24);
    
    return Container(
      color: bgColor,
      child: Center(
        child: Padding(
          padding: contentPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getErrorIcon(error),
                color: Colors.white70,
                size: icon,
              ),
              const SizedBox(height: 16),
              Text(
                error.userMessage,
                style: style,
                textAlign: TextAlign.center,
              ),
              if (error.isRetryable && onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build minimal error indicator
  static Widget buildMinimalError({
    required VStoryError error,
    VoidCallback? onTap,
    double size = 40,
  }) {
    return GestureDetector(
      onTap: error.isRetryable ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Icon(
          _getErrorIcon(error),
          color: Colors.white70,
          size: size * 0.6,
        ),
      ),
    );
  }
  

  
  /// Build loading placeholder with error fallback
  static Widget buildLoadingPlaceholder({
    VStoryError? error,
    VoidCallback? onRetry,
    String? loadingText,
    double indicatorSize = 50,
  }) {
    if (error != null) {
      return buildErrorPlaceholder(
        error: error,
        onRetry: onRetry,
      );
    }
    
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: indicatorSize,
              height: indicatorSize,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                strokeWidth: 3,
              ),
            ),
            if (loadingText != null) ...[
              const SizedBox(height: 16),
              Text(
                loadingText,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Get appropriate icon for error type
  static IconData _getErrorIcon(VStoryError error) {
    switch (error) {
      case VNetworkError():
        return Icons.wifi_off;
      case VMediaLoadError():
        return Icons.broken_image;
      case VControllerError():
        return Icons.play_disabled;
      case VCacheError():
        return Icons.storage;
      case VPermissionError():
        return Icons.lock;
      case VTimeoutError():
        return Icons.hourglass_empty;
      default:
        return Icons.error_outline;
    }
  }
  
  /// Build error notification widget
  static Widget buildErrorNotification({
    required VStoryError error,
    VoidCallback? onDismiss,
    Duration displayDuration = const Duration(seconds: 3),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getErrorIcon(error),
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      error.userMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (onDismiss != null)
                    IconButton(
                      onPressed: onDismiss,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}