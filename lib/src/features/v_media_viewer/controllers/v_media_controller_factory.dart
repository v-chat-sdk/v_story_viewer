import '../../v_cache_manager/controllers/v_cache_controller.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_custom_story.dart';
import '../../v_story_models/models/v_image_story.dart';
import '../../v_story_models/models/v_text_story.dart';
import '../../v_story_models/models/v_video_story.dart';
import '../models/v_media_callbacks.dart';
import 'v_base_media_controller.dart';
import 'v_custom_controller.dart';
import 'v_image_controller.dart';
import 'v_text_controller.dart';
import 'v_video_controller.dart';

/// Factory for creating appropriate media controllers based on story type
///
/// Uses pattern matching to select the correct controller implementation.
/// Each controller is optimized for its specific media type.
class VMediaControllerFactory {
  /// Create controller based on story type
  ///
  /// Returns the appropriate controller subclass for the story type:
  /// - VImageStory → VImageController (with caching)
  /// - VVideoStory → VVideoController (with video player)
  /// - VTextStory → VTextController (synchronous)
  /// - VCustomStory → VCustomController (builder pattern)
  ///
  /// Throws [ArgumentError] if story type is unknown.
  static VBaseMediaController createController({
    required VBaseStory story,
    required VCacheController  cacheController, VMediaCallbacks? callbacks,
  }) {
    return switch (story) {
      VImageStory() => VImageController(
        callbacks: callbacks,
        cacheController: cacheController,
      ),
      VVideoStory() => VVideoController(
          callbacks: callbacks,
        cacheController: cacheController,
      ),
      VTextStory() => VTextController(callbacks: callbacks),
      VCustomStory() => VCustomController(callbacks: callbacks),
      _ => throw ArgumentError('Unknown story type: ${story.runtimeType}'),
    };
  }
  var x;
}
