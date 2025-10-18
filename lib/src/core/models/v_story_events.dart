import 'package:flutter/foundation.dart';

import '../../features/v_story_models/models/v_base_story.dart';

/// Base class for all story viewer events
@immutable
abstract class VStoryEvent {
  const VStoryEvent({required this.story});

  final VBaseStory story;
}

/// Event fired when progress bar completes
@immutable
class VProgressCompleteEvent extends VStoryEvent {
  const VProgressCompleteEvent({required this.barIndex, required super.story});

  final int barIndex;
}

/// Event fired when media finishes loading
@immutable
class VMediaReadyEvent extends VStoryEvent {
  const VMediaReadyEvent({required super.story});
}

/// Event fired when media fails to load
@immutable
class VMediaErrorEvent extends VStoryEvent {
  const VMediaErrorEvent({required this.error, required super.story});

  final String error;
}

/// Event fired when video duration becomes known
@immutable
class VDurationKnownEvent extends VStoryEvent {
  const VDurationKnownEvent({required this.duration, required super.story});

  final Duration duration;
}

/// Event fired when user reacts (double tap)
@immutable
class VReactionSentEvent extends VStoryEvent {
  const VReactionSentEvent({required this.reactionType, required super.story});

  final String reactionType;
}

/// Event fired when story pause state changes
@immutable
class VStoryPauseStateChangedEvent extends VStoryEvent {
  const VStoryPauseStateChangedEvent({
    required this.isPaused,
    required super.story,
  });

  final bool isPaused;
}

/// Event fired when reply input focus changes
@immutable
class VReplyFocusChangedEvent extends VStoryEvent {
  const VReplyFocusChangedEvent({required this.hasFocus, required super.story});

  final bool hasFocus;
}
