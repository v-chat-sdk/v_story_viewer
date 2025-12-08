import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Custom painter for drawing segmented ring around story circles
/// Each segment has its own color based on seen state (WhatsApp style)
class CircleRingPainter extends CustomPainter {
  final List<bool> segmentSeenStates;
  final Color unseenColor;
  final Color seenColor;
  final double strokeWidth;
  final double segmentGap;
  static const int _maxVisibleSegments = 20;
  late final Paint _unseenPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..color = unseenColor;
  late final Paint _seenPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..color = seenColor;
  CircleRingPainter({
    required this.segmentSeenStates,
    this.unseenColor = const Color(0xFF4CAF50),
    this.seenColor = const Color(0xFF808080),
    this.strokeWidth = 3.0,
    this.segmentGap = 0.08,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final segmentCount = segmentSeenStates.length;
    if (segmentCount == 0) return;
    if (segmentCount == 1) {
      _drawSolidRing(canvas, center, radius, rect, segmentSeenStates[0]);
    } else if (segmentCount > _maxVisibleSegments) {
      final allSeen = segmentSeenStates.every((s) => s);
      _drawSolidRing(canvas, center, radius, rect, allSeen);
    } else {
      _drawSegments(canvas, center, radius, rect);
    }
  }

  void _drawSolidRing(
      Canvas canvas, Offset center, double radius, Rect rect, bool isSeen) {
    canvas.drawCircle(center, radius, isSeen ? _seenPaint : _unseenPaint);
  }

  void _drawSegments(Canvas canvas, Offset center, double radius, Rect rect) {
    final segmentCount = segmentSeenStates.length;
    final totalGapAngle = segmentGap * segmentCount;
    final availableAngle = 2 * math.pi - totalGapAngle;
    final segmentAngle = availableAngle / segmentCount;
    final startAngle = -math.pi / 2;
    for (int i = 0; i < segmentCount; i++) {
      final angle = startAngle + i * (segmentAngle + segmentGap);
      final isSeen = segmentSeenStates[i];
      canvas.drawArc(
          rect, angle, segmentAngle, false, isSeen ? _seenPaint : _unseenPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CircleRingPainter oldDelegate) {
    return !listEquals(oldDelegate.segmentSeenStates, segmentSeenStates) ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.segmentGap != segmentGap ||
        oldDelegate.unseenColor != unseenColor ||
        oldDelegate.seenColor != seenColor;
  }
}
