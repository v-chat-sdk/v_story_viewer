import '../../v_cache_manager/controllers/v_cache_controller.dart';
import '../../v_media_viewer/controllers/v_base_media_controller.dart';
import '../../v_media_viewer/controllers/v_media_controller_factory.dart';
import '../../v_progress_bar/controllers/v_progress_controller.dart';
import '../../v_progress_bar/models/v_progress_callbacks.dart';
import '../../v_reactions/controllers/v_reaction_controller.dart';
import '../../v_reactions/models/v_reaction_config.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_story_group.dart';
import '../controllers/v_story_navigation_controller.dart';

/// Initializes and creates feature controllers
///
/// VProgressController uses callbacks for isolation/reusability.
/// Other controllers communicate via VStoryEventManager singleton.
class VControllerInitializer {
  /// Create navigation controller
  static VStoryNavigationController createNavigationController({
    required List<VStoryGroup> storyGroups,
    required int initialGroupIndex,
    required int initialStoryIndex,
  }) {
    return VStoryNavigationController(
      storyGroups: storyGroups,
      initialGroupIndex: initialGroupIndex,
      initialStoryIndex: initialStoryIndex,
    );
  }

  /// Create progress controller with callbacks (isolated component)
  static VProgressController createProgressController({
    required int barCount,
    int? currentBar,
    VProgressCallbacks? callbacks,
  }) {
    final controller = VProgressController(
      barCount: barCount,
      callbacks: callbacks,
    );

    // Set initial cursor position if specified
    if (currentBar != null && currentBar >= 0 && currentBar < barCount) {
      controller.setCursorAt(currentBar);
    }

    return controller;
  }

  /// Create reaction controller (events auto-emitted to VStoryEventManager)
  static VReactionController createReactionController({
    VReactionConfig? config,
  }) {
    return VReactionController(config: config ?? const VReactionConfig());
  }

  /// Create media controller for story (events auto-emitted to VStoryEventManager)
  static VBaseMediaController createMediaController({
    required VBaseStory story,
    required VCacheController cacheController,
  }) {
    return VMediaControllerFactory.createController(
      story: story,
      cacheController: cacheController,
    );
  }
}
