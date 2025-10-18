import 'package:flutter/foundation.dart';

import '../../../core/models/v_story_events.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_viewer/utils/v_story_event_manager.dart';
import '../models/v_reaction_config.dart';

/// Controller for managing story reactions
/// Uses event-based communication via VStoryEventManager singleton
class VReactionController extends ChangeNotifier {
  VReactionController({
    VReactionConfig? config,
  }) : _config = config ?? const VReactionConfig();

  final VReactionConfig _config;

  bool _isAnimating = false;
  VBaseStory? _currentStory;

  /// Get config
  VReactionConfig get config => _config;

  /// Check if reaction is animating
  bool get isAnimating => _isAnimating;

  /// Set current story for reaction context
  void setCurrentStory(VBaseStory story) {
    _currentStory = story;
  }

  /// Trigger reaction animation and send reaction
  void triggerReaction() {
    if (!_config.enabled || _isAnimating || _currentStory == null) {
      return;
    }

    _isAnimating = true;
    notifyListeners();

    // Emit reaction sent event
    VStoryEventManager.instance.enqueue(
      VReactionSentEvent(
        reactionType: _config.reactionType,
        story: _currentStory!,
      ),
    );

    // Animation will complete after duration in widget
    Future.delayed(_config.animationDuration, () {
      _isAnimating = false;
      notifyListeners();
    });
  }

  /// Reset reaction state
  void reset() {
    _isAnimating = false;
    _currentStory = null;
    notifyListeners();
  }
}
