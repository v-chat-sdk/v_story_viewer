import 'package:flutter/material.dart';

/// A widget that displays a formatted timestamp.
class VTimestamp extends StatelessWidget {
  /// Creates a new instance of [VTimestamp].
  const VTimestamp({
    required this.createdAt,
    this.textStyle,
    super.key,
  });

  /// The timestamp to display.
  final DateTime createdAt;

  /// The text style for the timestamp.
  final TextStyle? textStyle;

  String _formatTimeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatTimeAgo(createdAt),
      style: textStyle ??
          TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
    );
  }
}
