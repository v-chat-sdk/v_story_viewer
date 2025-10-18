import 'package:v_platform/v_platform.dart';

import '../../v_cache_manager/controllers/v_cache_controller.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_image_story.dart';
import 'v_base_media_controller.dart';

/// Controller for image story display
///
/// Handles image loading with caching support through VCacheController.
/// Exposes cached file for efficient rendering in the UI layer.
class VImageController extends VBaseMediaController {
  VImageController({required VCacheController cacheController})
    : _cacheController = cacheController;

  final VCacheController _cacheController;
  VPlatformFile? _cachedMedia;

  /// Get the cached media file if available
  VPlatformFile? get cachedMedia => _cachedMedia;

  @override
  Future<void> loadMedia(VBaseStory story) async {
    if (story is! VImageStory) {
      throw ArgumentError('VImageController requires VImageStory');
    }

    _cachedMedia = story.media;
    if (story.media.networkUrl != null) {
      final cachedFile = await _cacheController.getFile(story.media, story.id);
      if (cachedFile != null) {
        _cachedMedia = cachedFile;
      }
    }

    notifyListeners();
  }

  // Image is static - no pause/resume needed (use default implementations)
}
