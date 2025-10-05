import 'package:flutter/foundation.dart';

import '../../v_story_models/models/v_base_story.dart';
import '../models/v_reaction_callbacks.dart';
import '../models/v_reaction_config.dart';

/// Controller for managing story reactions
class VReactionController extends ChangeNotifier {
  VReactionController({
    VReactionConfig? config,
    VReactionCallbacks? callbacks,
  })  : _config = config ?? const VReactionConfig(),
        _callbacks = callbacks ?? const VReactionCallbacks();

  final VReactionConfig _config;
  final VReactionCallbacks _callbacks;

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
    _callbacks.onReactionAnimationStart?.call();
    notifyListeners();

    // Send reaction callback
    _callbacks.onReactionSent?.call(_currentStory!, _config.reactionType);

    // Animation will complete after duration in widget
    Future.delayed(_config.animationDuration, () {
      _isAnimating = false;
      _callbacks.onReactionAnimationComplete?.call();
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
