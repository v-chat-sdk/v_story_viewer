import 'package:flutter/foundation.dart';

/// User model representing the author of stories
@immutable
class VStoryUser {
  const VStoryUser({
    required this.id,
    required this.username,
    this.profilePicture,
    this.metadata,
  });

  factory VStoryUser.fromJson(Map<String, dynamic> json) {
    return VStoryUser(
      id: json['id'] as String,
      username: json['username'] as String,
      profilePicture: json['profilePicture'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Unique identifier for the user
  final String id;

  /// Display name of the user
  final String username;

  /// URL to the user's profile picture
  final String? profilePicture;

  /// Additional user metadata
  final Map<String, dynamic>? metadata;

  VStoryUser copyWith({
    String? id,
    String? username,
    String? profilePicture,
    Map<String, dynamic>? metadata,
  }) {
    return VStoryUser(
      id: id ?? this.id,
      username: username ?? this.username,
      profilePicture: profilePicture ?? this.profilePicture,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'profilePicture': profilePicture,
      'metadata': metadata,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VStoryUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'VStoryUser(id: $id, username: $username)';
}
