import '../models/v_story_item.dart';
import '../models/v_story_music.dart';

/// Resolves the single duration used by the story progress timeline.
///
/// An explicit [VStoryItem.duration] always takes precedence over a duration
/// reported by the content widget.
class StoryDurationResolver {
  const StoryDurationResolver._();

  static Duration resolve({
    required VStoryItem story,
    required Duration fallbackDuration,
    Duration? contentDuration,
    Duration? musicSourceDuration,
  }) {
    final content = story.duration ?? contentDuration ?? fallbackDuration;
    final music = story.music;
    if (music == null) return content;

    final clipDuration = music.resolveClipDuration(musicSourceDuration);
    if (clipDuration == null) return content;

    return switch (music.durationPolicy) {
      VStoryMusicDurationPolicy.keepStoryDuration => content,
      VStoryMusicDurationPolicy.matchMusicClip => clipDuration,
      VStoryMusicDurationPolicy.shortest =>
        content <= clipDuration ? content : clipDuration,
    };
  }
}
