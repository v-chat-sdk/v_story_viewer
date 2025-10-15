import 'package:flutter/foundation.dart';

import '../../v_cache_manager/controllers/v_cache_controller.dart';
import '../../v_media_viewer/controllers/v_base_media_controller.dart';
import '../../v_media_viewer/controllers/v_media_controller_factory.dart';
import '../../v_media_viewer/models/v_media_callbacks.dart';
import '../../v_progress_bar/controllers/v_progress_controller.dart';
import '../../v_progress_bar/models/v_progress_callbacks.dart';
import '../../v_reactions/controllers/v_reaction_controller.dart';
import '../../v_reactions/models/v_reaction_callbacks.dart';
import '../../v_reactions/models/v_reaction_config.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_models/models/v_story_group.dart';
import '../controllers/v_story_navigation_controller.dart';

/// Initializes and creates feature controllers
///
/// Centralizes controller creation logic with proper callback wiring.
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

  /// Create progress controller with callbacks
  static VProgressController createProgressController({
    required int barCount,
    required void Function(int) onBarComplete,
  }) {
    return VProgressController(
      barCount: barCount,
      callbacks: VProgressCallbacks(onBarComplete: onBarComplete),
    );
  }

  /// Create reaction controller with callbacks
  static VReactionController createReactionController({
    required void Function(VBaseStory, String) onReactionSent,
  }) {
    return VReactionController(
      config: const VReactionConfig(),
      callbacks: VReactionCallbacks(onReactionSent: onReactionSent),
    );
  }

  /// Create media controller for story
  static VBaseMediaController createMediaController({
    required VBaseStory story,
    required VCacheController cacheController,
    required VoidCallback onMediaReady,
    required void Function(String str) onMediaError,
    required void Function(Duration time) onDurationKnown,
    void Function(double value)? onLoadingProgress,
  }) {
    return VMediaControllerFactory.createController(
      story: story,
      cacheController: cacheController,
      callbacks: VMediaCallbacks(
        onLoadingProgress: onLoadingProgress,
        onMediaReady: onMediaReady,
        onMediaError: onMediaError,
        onDurationKnown: onDurationKnown,
      ),
    );
  }
}
