/// User information displayed in story circles and viewer header.
///
/// Represents the owner of a [VStoryGroup]. Contains identity info
/// displayed in the story circle avatar and viewer header.
///
/// ## Example
/// ```dart
/// final user = VStoryUser(
///   id: 'user_123',
///   name: 'John Doe',
///   imageUrl: 'https://example.com/avatar.jpg',
/// );
/// ```
///
/// ## Equality
/// Two [VStoryUser] instances are equal if all three fields match:
/// [id], [name], and [imageUrl]. This ensures proper list deduplication
/// and state management.
///
/// ## Validation
/// - [id] must not be empty (used for deduplication and tracking)
/// - [name] must not be empty (displayed in UI)
/// - [imageUrl] can be any valid URL (empty strings will show fallback avatar)
class VStoryUser {
  /// Unique identifier for this user.
  ///
  /// Used for deduplication and tracking viewed stories.
  /// Must not be empty.
  final String id;

  /// Display name shown in story header and circle.
  ///
  /// Truncated with ellipsis if too long. Must not be empty.
  final String name;

  /// URL to user's avatar image.
  ///
  /// Displayed as circular avatar in story circle and header.
  /// Falls back to person icon if image fails to load.
  final String imageUrl;
  const VStoryUser({
    required this.id,
    required this.name,
    required this.imageUrl,
  })  : assert(id.length > 0, 'User id cannot be empty'),
        assert(name.length > 0, 'User name cannot be empty');
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VStoryUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          imageUrl == other.imageUrl;
  @override
  int get hashCode => Object.hash(id, name, imageUrl);
}
