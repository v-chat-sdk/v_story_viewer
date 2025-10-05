// import 'package:flutter/material.dart';
//
// import '../models/v_gesture_config.dart';
// import 'v_gesture_callbacks.dart';
//
// /// Widget that creates tap zones for navigation
// class VTapZones extends StatelessWidget {
//   const VTapZones({
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
//     if (!config.enableTapNavigation) {
//       return const SizedBox.shrink();
//     }
//
//     final size = MediaQuery.of(context).size;
//
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         // Left tap zone for previous story
//         Align(
//           alignment: Alignment.centerLeft,
//           child: SizedBox(
//             width: size.width * config.leftTapZoneWidth,
//             height: size.height,
//             child: GestureDetector(
//               onTap: callbacks.onTapPrevious,
//               behavior: HitTestBehavior.translucent,
//             ),
//           ),
//         ),
//
//         // Right tap zone for next story
//         Align(
//           alignment: Alignment.centerRight,
//           child: SizedBox(
//             width: size.width * config.rightTapZoneWidth,
//             height: size.height,
//             child: GestureDetector(
//               onTap: callbacks.onTapNext,
//               behavior: HitTestBehavior.translucent,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
