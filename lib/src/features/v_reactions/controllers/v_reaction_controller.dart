import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/models/v_story_events.dart';
import '../../v_story_models/models/v_base_story.dart';
import '../../v_story_viewer/utils/v_story_event_manager.dart';
import '../models/v_reaction_config.dart';

/// Controller for managing story reactions
/// Uses event-based communication via VStoryEventManager singleton
class VReactionController extends ChangeNotifier {
  VReactionController({VReactionConfig? config})
    : _config = config ?? const VReactionConfig();

  final VReactionConfig _config;
  bool _isAnimating = false;
  VBaseStory? _currentStory;
  bool _isDisposed = false;
  final List<Timer> _timers = [];

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
    if (!_config.enabled ||
        _isAnimating ||
        _currentStory == null ||
        _isDisposed) {
      return;
    }
    _isAnimating = true;
    notifyListeners();
    VStoryEventManager.instance.enqueue(
      VReactionSentEvent(
        reactionType: _config.reactionType,
        story: _currentStory!,
      ),
    );
    late final Timer timer;
    timer = Timer(_config.animationDuration, () {
      if (!_isDisposed) {
        _isAnimating = false;
        notifyListeners();
      }
      _timers.removeWhere((t) => t == timer);
    });
    _timers.add(timer);
  }

  /// Reset reaction state
  void reset() {
    _isAnimating = false;
    _currentStory = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    super.dispose();
  }
}
