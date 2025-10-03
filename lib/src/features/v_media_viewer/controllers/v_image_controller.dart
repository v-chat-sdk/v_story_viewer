import '../../v_cache_manager/controllers/v_cache_controller.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_image_story.dart';
import '../models/v_media_callbacks.dart';
import 'v_base_media_controller.dart';

/// Controller for image story display
///
/// Handles image loading with caching support through VCacheController.
/// Images are preloaded using the cache controller, and actual rendering
/// is handled by CachedNetworkImage widget in the UI layer.
class VImageController extends VBaseMediaController {
  VImageController({
    VMediaCallbacks? callbacks,
    VCacheController? cacheController,
  })  : _cacheController = cacheController,
        super(callbacks: callbacks);

  final VCacheController? _cacheController;

  @override
  Future<void> loadMedia(VBaseStory story) async {
    if (story is! VImageStory) {
      throw ArgumentError('VImageController requires VImageStory');
    }

    // If cache controller is provided, preload the image
    if (_cacheController != null && story.media.networkUrl != null) {
      // Subscribe to progress updates
      final subscription = _cacheController!.progressStream.listen((progress) {
        if (progress.url == story.media.networkUrl) {
          updateProgress(progress.progress);
        }
      });

      try {
        // Preload image file through cache
        await _cacheController!.getFile(story.media);
      } finally {
        // Clean up subscription
        await subscription.cancel();
      }
    }

    // Image is ready (actual rendering happens in widget via cached_network_image)
  }

  // Image is static - no pause/resume needed (use default implementations)
}
