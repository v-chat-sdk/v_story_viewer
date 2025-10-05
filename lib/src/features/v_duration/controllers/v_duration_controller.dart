import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_image_story.dart';
import '../../v_story_models/models/v_text_story.dart';
import '../../v_story_models/models/v_video_story.dart';
import '../models/v_duration_config.dart';
import '../utils/v_wpm_calculator.dart';

/// Controller for calculating story durations
class VDurationController {
  VDurationController({
    VDurationConfig? config,
  }) : _config = config ?? const VDurationConfig();

  final VDurationConfig _config;

  /// Get configuration
  VDurationConfig get config => _config;

  /// Calculate duration for a story
  ///
  /// Priority:
  /// 1. Story-specific duration (if set)
  /// 2. Type-specific calculation (WPM for text, video duration, etc.)
  /// 3. Default duration from config
  Duration calculateDuration(VBaseStory story) {
    // If story has explicit duration, use it
    if (story.duration != null) {
      return story.duration!;
    }

    // Calculate based on story type
    if (story is VTextStory) {
      return VWpmCalculator.calculateReadingDuration(
        text: story.text,
        wordsPerMinute: _config.wordsPerMinute,
        minDuration: _config.minTextDuration,
        maxDuration: _config.maxTextDuration,
      );
    } else if (story is VVideoStory) {
      // Video duration comes from video metadata
      // Fallback to default if not available
      return story.duration ?? _config.defaultImageDuration;
    } else if (story is VImageStory) {
      return _config.defaultImageDuration;
    }

    // Fallback for custom or unknown story types
    return _config.defaultImageDuration;
  }

  /// Batch calculate durations for multiple stories
  Map<String, Duration> calculateDurations(List<VBaseStory> stories) {
    return {
      for (final story in stories) story.id: calculateDuration(story),
    };
  }
}
