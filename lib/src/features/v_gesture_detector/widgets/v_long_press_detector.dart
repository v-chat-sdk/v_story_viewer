// import 'package:flutter/material.dart';
//
// import '../models/v_gesture_config.dart';
// import 'v_gesture_callbacks.dart';
//
// /// Widget that detects long press for pause/resume functionality
// class VLongPressDetector extends StatelessWidget {
//   const VLongPressDetector({
//     required this.config,
//     required this.callbacks,
//     super.key,
//   });
//
//   final VGestureConfig config;
//   final VGestureCallbacks callbacks;
//
//   @override
//   Widget build(BuildContext context) {
//     if (!config.enableLongPress) {
//       return const SizedBox.shrink();
//     }
//
//     return GestureDetector(
//       onLongPressStart: (_) => callbacks.onLongPressStart?.call(),
//       onLongPressEnd: (_) => callbacks.onLongPressEnd?.call(),
//       onLongPressCancel: () => callbacks.onLongPressEnd?.call(),
//       behavior: HitTestBehavior.translucent,
//     );
//   }
// }
