/// Navigation models and enums for v_story_viewer
///
/// Provides type-safe navigation direction handling and position tracking
/// for better code readability and maintainability.
library v_story_navigation;

import 'package:flutter/foundation.dart';

/// Represents the direction of story navigation
enum VStoryNavigationDirection {
  /// Navigate to the previous story
  previous('previous'),

  /// Navigate to the next story
  next('next');

  const VStoryNavigationDirection(this.value);

  /// String representation of the direction
  final String value;

  @override
  String toString() => 'VStoryNavigationDirection.$value';
}

/// Represents the result of a navigation calculation
sealed class VNavigationResult {
  const VNavigationResult();

  /// Navigation stays within the current group
  const factory VNavigationResult.withinGroup({
    required int groupIndex,
    required int storyIndex,
  }) = VNavigationWithinGroup;

  /// Navigation moves to the next group
  const factory VNavigationResult.nextGroup({
    required int groupIndex,
    required int storyIndex,
  }) = VNavigationNextGroup;

  /// Navigation moves to the previous group
  const factory VNavigationResult.previousGroup({
    required int groupIndex,
    required int storyIndex,
  }) = VNavigationPreviousGroup;

  /// All stories have been completed
  const factory VNavigationResult.completed() = VNavigationCompleted;

  /// Navigation is at the beginning (cannot go previous)
  const factory VNavigationResult.atBeginning() = VNavigationAtBeginning;

  /// Navigation failed due to invalid state
  const factory VNavigationResult.failed(String reason) = VNavigationFailed;
}

/// Navigation result for staying within current group
class VNavigationWithinGroup extends VNavigationResult {
  const VNavigationWithinGroup({
    required this.groupIndex,
    required this.storyIndex,
  });

  final int groupIndex;
  final int storyIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VNavigationWithinGroup &&
          groupIndex == other.groupIndex &&
          storyIndex == other.storyIndex;

  @override
  int get hashCode => Object.hash(groupIndex, storyIndex);

  @override
  String toString() =>
      'VNavigationWithinGroup(groupIndex: $groupIndex, storyIndex: $storyIndex)';
}

/// Navigation result for moving to next group
class VNavigationNextGroup extends VNavigationResult {
  const VNavigationNextGroup({
    required this.groupIndex,
    required this.storyIndex,
  });

  final int groupIndex;
  final int storyIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VNavigationNextGroup &&
          groupIndex == other.groupIndex &&
          storyIndex == other.storyIndex;

  @override
  int get hashCode => Object.hash(groupIndex, storyIndex);

  @override
  String toString() =>
      'VNavigationNextGroup(groupIndex: $groupIndex, storyIndex: $storyIndex)';
}

/// Navigation result for moving to previous group
class VNavigationPreviousGroup extends VNavigationResult {
  const VNavigationPreviousGroup({
    required this.groupIndex,
    required this.storyIndex,
  });

  final int groupIndex;
  final int storyIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VNavigationPreviousGroup &&
          groupIndex == other.groupIndex &&
          storyIndex == other.storyIndex;

  @override
  int get hashCode => Object.hash(groupIndex, storyIndex);

  @override
  String toString() =>
      'VNavigationPreviousGroup(groupIndex: $groupIndex, storyIndex: $storyIndex)';
}

/// Navigation result indicating all stories are completed
class VNavigationCompleted extends VNavigationResult {
  const VNavigationCompleted();

  @override
  bool operator ==(Object other) => other is VNavigationCompleted;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'VNavigationCompleted()';
}

/// Navigation result indicating at the beginning
class VNavigationAtBeginning extends VNavigationResult {
  const VNavigationAtBeginning();

  @override
  bool operator ==(Object other) => other is VNavigationAtBeginning;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'VNavigationAtBeginning()';
}

/// Navigation result indicating failure
class VNavigationFailed extends VNavigationResult {
  const VNavigationFailed(this.reason);

  final String reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VNavigationFailed && reason == other.reason;

  @override
  int get hashCode => reason.hashCode;

  @override
  String toString() => 'VNavigationFailed(reason: $reason)';
}

/// Represents the current position in the story navigation
@immutable
class VStoryPosition {
  const VStoryPosition({required this.groupIndex, required this.storyIndex})
    : assert(groupIndex >= 0, 'Group index must be non-negative'),
      assert(storyIndex >= 0, 'Story index must be non-negative');

  /// Creates an initial position (first story of first group)
  const VStoryPosition.initial() : groupIndex = 0, storyIndex = 0;

  /// Index of the current story group
  final int groupIndex;

  /// Index of the current story within the group
  final int storyIndex;

  /// Creates a copy of this position with updated values
  VStoryPosition copyWith({int? groupIndex, int? storyIndex}) {
    return VStoryPosition(
      groupIndex: groupIndex ?? this.groupIndex,
      storyIndex: storyIndex ?? this.storyIndex,
    );
  }

  /// Checks if this position is at the beginning of a group
  bool get isAtGroupBeginning => storyIndex == 0;

  /// Returns a string representation suitable for debugging
  String get debugString => 'Group $groupIndex, Story $storyIndex';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VStoryPosition &&
          groupIndex == other.groupIndex &&
          storyIndex == other.storyIndex;

  @override
  int get hashCode => Object.hash(groupIndex, storyIndex);

  @override
  String toString() =>
      'VStoryPosition(groupIndex: $groupIndex, storyIndex: $storyIndex)';
}

/// Extension methods for navigation results
extension VNavigationResultExtensions on VNavigationResult {
  /// Returns true if navigation was successful
  bool get isSuccessful => switch (this) {
    VNavigationWithinGroup() => true,
    VNavigationNextGroup() => true,
    VNavigationPreviousGroup() => true,
    VNavigationCompleted() => true,
    VNavigationAtBeginning() => false,
    VNavigationFailed() => false,
  };

  /// Returns true if navigation indicates completion
  bool get isCompleted => this is VNavigationCompleted;

  /// Returns true if navigation is blocked
  bool get isBlocked =>
      this is VNavigationAtBeginning || this is VNavigationFailed;

  /// Gets the target position if navigation was successful
  VStoryPosition? get targetPosition => switch (this) {
    VNavigationWithinGroup(groupIndex: final g, storyIndex: final s) =>
      VStoryPosition(groupIndex: g, storyIndex: s),
    VNavigationNextGroup(groupIndex: final g, storyIndex: final s) =>
      VStoryPosition(groupIndex: g, storyIndex: s),
    VNavigationPreviousGroup(groupIndex: final g, storyIndex: final s) =>
      VStoryPosition(groupIndex: g, storyIndex: s),
    _ => null,
  };

  /// Gets the failure reason if navigation failed
  String? get failureReason => switch (this) {
    VNavigationFailed(reason: final reason) => reason,
    VNavigationAtBeginning() => 'Already at the beginning',
    _ => null,
  };
}
