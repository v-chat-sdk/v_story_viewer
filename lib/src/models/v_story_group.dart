import 'v_story_item.dart';
import 'v_story_user.dart';

/// A collection of stories belonging to a single user.
///
/// Represents one user's story circle in the story list. Contains the user's
/// information and all their stories (both seen and unseen).
///
/// ## Key Features
/// - Automatic filtering of expired stories (24h+)
/// - Sorting: unseen stories appear before seen stories
/// - Story ring segmentation based on seen/unseen status
///
/// ## Example
/// ```dart
/// final group = VStoryGroup(
///   user: VStoryUser(
///     id: 'user123',
///     name: 'John Doe',
///     imageUrl: 'https://example.com/avatar.jpg',
///   ),
///   stories: [
///     VImageStory(url: '...', createdAt: DateTime.now(), isSeen: false),
///     VImageStory(url: '...', createdAt: DateTime.now(), isSeen: true),
///   ],
/// );
///
/// // Check if user has new stories
/// if (group.hasUnseenStories) {
///   // Show notification badge
/// }
/// ```
///
/// ## Story Ring Display
/// The [VStoryCircle] widget uses this group's data to display:
/// - Gradient ring for unseen segments
/// - Gray ring for seen segments
/// - Number of segments = number of valid stories (max 20 displayed)
class VStoryGroup {
  /// The user who owns these stories.
  final VStoryUser user;

  /// All stories in this group (may include expired stories).
  ///
  /// Use [validStories] to get only non-expired stories.
  /// Use [sortedStories] to get stories ordered for display (unseen first).
  ///
  /// **Note:** Must not be empty. Throws assertion error if empty.
  final List<VStoryItem> stories;
  const VStoryGroup({
    required this.user,
    required this.stories,
  }) : assert(stories.length > 0, 'Stories list cannot be empty');

  /// Returns only non-expired stories (less than 24 hours old).
  ///
  /// Stories older than 24 hours are filtered out automatically.
  List<VStoryItem> get validStories =>
      stories.where((story) => !story.isExpired).toList();

  /// Returns `true` if this group has at least one non-expired story.
  ///
  /// Use this to filter out groups with only expired stories:
  /// ```dart
  /// final activeGroups = groups.where((g) => g.hasValidStories).toList();
  /// ```
  bool get hasValidStories => validStories.isNotEmpty;

  /// Returns `true` if this group has at least one unseen story.
  ///
  /// Use to show notification badges or highlight story circles.
  bool get hasUnseenStories => validStories.any((s) => !s.isSeen);

  /// Number of unseen (non-expired) stories in this group.
  int get unseenCount => validStories.where((s) => !s.isSeen).length;

  /// Number of seen (non-expired) stories in this group.
  int get seenCount => validStories.where((s) => s.isSeen).length;

  /// Returns stories sorted for viewer display: unseen first, then seen.
  ///
  /// This is the order used by [VStoryViewer] when navigating through stories.
  /// Only includes non-expired stories.
  List<VStoryItem> get sortedStories {
    final valid = validStories;
    final unseen = valid.where((s) => !s.isSeen).toList();
    final seen = valid.where((s) => s.isSeen).toList();
    return [...unseen, ...seen];
  }

  /// Creates a copy with updated values.
  ///
  /// Performs a deep copy of the stories list to prevent mutation issues.
  VStoryGroup copyWith({
    VStoryUser? user,
    List<VStoryItem>? stories,
  }) {
    return VStoryGroup(
      user: user ?? this.user,
      stories: stories != null ? List.from(stories) : List.from(this.stories),
    );
  }
}
