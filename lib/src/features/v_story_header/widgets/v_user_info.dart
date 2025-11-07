import 'package:flutter/material.dart';
import '../../v_story_models/models/v_story_user.dart';

/// A widget that displays the user's information.
class VUserInfo extends StatelessWidget {
  /// Creates a new instance of [VUserInfo].
  const VUserInfo({required this.user, this.textStyle, super.key});

  /// The user to display information for.
  final VStoryUser user;

  /// The text style for the user's name.
  final TextStyle? textStyle;

  /// Calculate responsive font size based on screen width
  double _getResponsiveFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaler = MediaQuery.of(context).textScaler;

    // Mobile: 16sp, Tablet: 18sp, Desktop: 20sp
    double baseFontSize;
    if (screenWidth >= 1000) {
      baseFontSize = 20;
    } else if (screenWidth >= 600) {
      baseFontSize = 18;
    } else {
      baseFontSize = 16;
    }

    // Apply system text scale factor
    return textScaler.scale(baseFontSize);
  }

  @override
  Widget build(BuildContext context) {
    final responsiveFontSize = _getResponsiveFontSize(context);

    return Text(
      user.username,
      style:
          textStyle ??
          TextStyle(
            fontSize: responsiveFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
