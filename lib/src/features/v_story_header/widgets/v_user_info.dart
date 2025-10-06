import 'package:flutter/material.dart';
import '../../v_story_models/models/v_story_user.dart';

/// A widget that displays the user's information.
class VUserInfo extends StatelessWidget {
  /// Creates a new instance of [VUserInfo].
  const VUserInfo({
    required this.user,
    this.textStyle,
    super.key,
  });

  /// The user to display information for.
  final VStoryUser user;

  /// The text style for the user's name.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Text(
      user.username,
      style: textStyle ??
          const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
    );
  }
}
