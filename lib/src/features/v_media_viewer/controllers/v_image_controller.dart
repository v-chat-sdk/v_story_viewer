import '../../v_cache_manager/controllers/v_cache_controller.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_image_story.dart';
import 'v_base_media_controller.dart';

/// Controller for image story display
///
/// Handles image loading with caching support through VCacheController.
/// Images are preloaded using the cache controller, and actual rendering
/// is handled by CachedNetworkImage widget in the UI layer.
class VImageController extends VBaseMediaController {
  VImageController({required VCacheController cacheController, super.callbacks})
    : _cacheController = cacheController;

  final VCacheController _cacheController;

  @override
  Future<void> loadMedia(VBaseStory story) async {
    if (story is! VImageStory) {
      throw ArgumentError('VImageController requires VImageStory');
    }

    // Trigger cache download for network images
    // Progress tracking happens in VStoryViewer via global stream listener
    if (story.media.networkUrl != null) {
      await _cacheController.getFile(story.media, story.id);
    }

    // Image is ready (actual rendering happens in widget via cached_network_image)
  }

  // Image is static - no pause/resume needed (use default implementations)
}
