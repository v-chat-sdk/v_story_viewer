import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_text_story.dart';
import '../models/v_media_callbacks.dart';
import 'v_base_media_controller.dart';

/// Controller for text story display
///
/// Text stories are synchronous and require no loading time.
/// This controller validates the text content and immediately signals ready state.
class VTextController extends VBaseMediaController {
  VTextController({
    super.callbacks,
  });

  @override
  Future<void> loadMedia(VBaseStory story) async {
    if (story is! VTextStory) {
      throw ArgumentError('VTextController requires VTextStory');
    }

    // Validate text content
    if (story.text.isEmpty) {
      throw ArgumentError('Text story cannot be empty');
    }

    // Text is synchronous - immediately ready
    // Actual rendering happens in widget layer
  }

  // Text is static - no pause/resume needed (use default implementations)
}
