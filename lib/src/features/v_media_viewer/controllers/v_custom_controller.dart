import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_custom_story.dart';
import '../models/v_media_callbacks.dart';
import 'v_base_media_controller.dart';

/// Controller for custom widget stories
///
/// Custom stories use user-provided builder functions to render arbitrary widgets.
/// No loading is required as the builder is invoked synchronously by the widget layer.
class VCustomController extends VBaseMediaController {
  VCustomController({
    VMediaCallbacks? callbacks,
  }) : super(callbacks: callbacks);

  @override
  Future<void> loadMedia(VBaseStory story) async {
    if (story is! VCustomStory) {
      throw ArgumentError('VCustomController requires VCustomStory');
    }

    // Custom widgets are built by user-provided builder
    // No loading needed - immediately ready
    // The builder will be invoked in the widget layer
  }

  // Custom widgets handle their own pause/resume if needed (use default implementations)
}
