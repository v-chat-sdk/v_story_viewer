import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A widget that displays the user's avatar.
class VUserAvatar extends StatelessWidget {
  /// Creates a new instance of [VUserAvatar].
  const VUserAvatar({
    required this.avatarUrl,
    this.radius = 24.0,
    super.key,
  });

  /// The URL of the user's avatar.
  final String? avatarUrl;

  /// The radius of the avatar.
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      backgroundImage: avatarUrl != null ? CachedNetworkImageProvider(avatarUrl!) : null,
      child: avatarUrl == null
          ? Icon(
              Icons.person,
              size: radius,
              color: Colors.white,
            )
          : null,
    );
  }
}
