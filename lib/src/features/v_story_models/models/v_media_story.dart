import 'package:flutter/foundation.dart';
import 'package:v_platform/v_platform.dart';

import 'v_base_story.dart';

/// Base abstract class for media-based stories (image, video)
@immutable
abstract class VMediaStory extends VBaseStory {
  const VMediaStory({
    required super.id,
    required super.createdAt,
    required super.storyType,
    super.duration,
    super.isViewed,
    super.isReacted,
    super.metadata,
  });

  /// Media file containing the resource
  VPlatformFile get media;

  @override
  VMediaStory copyWith({
    String? id,
    VPlatformFile? media,
    Duration? duration,
    DateTime? createdAt,
    bool? isViewed,
    bool? isReacted,
    Map<String, dynamic>? metadata,
  });
}
