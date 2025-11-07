import 'package:flutter/foundation.dart';

/// Engagement indicators for a story
@immutable
class VEngagementData {
  const VEngagementData({
    this.viewCount = 0,
    this.reactionCount = 0,
    this.shareCount = 0,
    this.commentCount = 0,
    this.topReactions = const [],
  });

  /// Number of views
  final int viewCount;

  /// Total reaction count
  final int reactionCount;

  /// Number of shares
  final int shareCount;

  /// Number of comments
  final int commentCount;

  /// Top emoji reactions (limited to 5)
  final List<String> topReactions;

  /// Create a copy with modifications
  VEngagementData copyWith({
    int? viewCount,
    int? reactionCount,
    int? shareCount,
    int? commentCount,
    List<String>? topReactions,
  }) {
    return VEngagementData(
      viewCount: viewCount ?? this.viewCount,
      reactionCount: reactionCount ?? this.reactionCount,
      shareCount: shareCount ?? this.shareCount,
      commentCount: commentCount ?? this.commentCount,
      topReactions: topReactions ?? this.topReactions,
    );
  }

  /// Total engagement count
  int get totalEngagement =>
      viewCount + reactionCount + shareCount + commentCount;

  /// Whether there is any engagement data
  bool get hasEngagement => totalEngagement > 0;

  /// Whether there are reactions to display
  bool get hasReactions => topReactions.isNotEmpty;
}
