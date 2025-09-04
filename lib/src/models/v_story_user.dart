import 'package:v_platform/v_platform.dart' as v_platform;

/// Represents a user who creates and shares stories.
/// 
/// This model contains user profile information including
/// name, avatar, and optional metadata for extensibility.
class VStoryUser {
  /// Unique identifier for the user
  final String id;
  
  /// Display name of the user
  final String name;
  
  /// Optional avatar image file for the user
  final v_platform.VPlatformFile? avatarFile;
  
  /// Additional metadata for custom user properties
  final Map<String, dynamic> metadata;
  
  /// Creates a story user with profile information
  const VStoryUser({
    required this.id,
    required this.name,
    this.avatarFile,
    this.metadata = const {},
  });
  
  /// Factory constructor for creating a user from a URL avatar
  factory VStoryUser.fromUrl({
    required String id,
    required String name,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) {
    return VStoryUser(
      id: id,
      name: name,
      avatarFile: avatarUrl != null
          ? v_platform.VPlatformFile.fromUrl(networkUrl: avatarUrl)
          : null,
      metadata: metadata ?? {},
    );
  }
  
  /// Factory constructor for creating a user from a local avatar path
  factory VStoryUser.fromPath({
    required String id,
    required String name,
    String? avatarPath,
    Map<String, dynamic>? metadata,
  }) {
    return VStoryUser(
      id: id,
      name: name,
      avatarFile: avatarPath != null
          ? v_platform.VPlatformFile.fromPath(fileLocalPath: avatarPath)
          : null,
      metadata: metadata ?? {},
    );
  }
  
  /// Factory constructor for creating a user from an asset avatar
  factory VStoryUser.fromAsset({
    required String id,
    required String name,
    String? avatarAsset,
    Map<String, dynamic>? metadata,
  }) {
    return VStoryUser(
      id: id,
      name: name,
      avatarFile: avatarAsset != null
          ? v_platform.VPlatformFile.fromAssets(assetsPath: avatarAsset)
          : null,
      metadata: metadata ?? {},
    );
  }
  
  /// Whether the user has an avatar
  bool get hasAvatar => avatarFile != null;
  
  /// Convenience getter for accessing the avatar URL from avatarFile
  String? get avatarUrl => avatarFile?.networkUrl;
  
  /// Convenience getter for accessing the avatar asset path from avatarFile
  String? get avatarAsset => avatarFile?.assetsPath;
  
  /// Gets a value from metadata by key
  T? getMetadata<T>(String key) {
    return metadata[key] as T?;
  }
  
  /// Creates a copy of this user with updated fields
  VStoryUser copyWith({
    String? id,
    String? name,
    v_platform.VPlatformFile? avatarFile,
    Map<String, dynamic>? metadata,
  }) {
    return VStoryUser(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarFile: avatarFile ?? this.avatarFile,
      metadata: metadata ?? this.metadata,
    );
  }
  
  @override
  String toString() => 'VStoryUser(id: $id, name: $name)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VStoryUser && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}