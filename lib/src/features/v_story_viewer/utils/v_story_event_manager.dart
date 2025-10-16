import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';

import '../../../core/models/v_story_events.dart';

/// Manages story events with ordered processing and priority handling
///
/// Replaces callback hell by:
/// 1. Centralizing all event handling in one place
/// 2. Processing events sequentially (no concurrent callbacks)
/// 3. Supporting event priorities (critical events first)
/// 4. Providing clean error handling and logging
class VStoryEventManager {
  /// Create event manager with optional custom event bus
  VStoryEventManager({EventBus? eventBus})
      : _eventBus = eventBus ?? EventBus(),
        _eventQueue = [];

  final EventBus _eventBus;
  final List<_QueuedEvent> _eventQueue;
  bool _isProcessing = false;

  /// Handler for processing events
  Future<void> Function(VStoryEvent event)? _eventHandler;

  /// Subscribe to specific event type
  StreamSubscription<T> on<T extends VStoryEvent>(void Function(T) handler) {
    return _eventBus.on<T>().listen(handler);
  }

  /// Enqueue event for processing with optional priority
  /// Higher priority = processed earlier
  Future<void> enqueue(VStoryEvent event, {int priority = 0}) async {
    _eventQueue..add(_QueuedEvent(event, priority))
    ..sort((a, b) => b.priority.compareTo(a.priority));

    if (!_isProcessing) {
      await _processQueue();
    }
  }

  /// Set the event handler for centralized event processing
  void setEventHandler(Future<void> Function(VStoryEvent) handler) {
    _eventHandler = handler;
  }

  /// Process all queued events sequentially
  Future<void> _processQueue() async {
    _isProcessing = true;
    while (_eventQueue.isNotEmpty) {
      final queued = _eventQueue.removeAt(0);
      try {
        // Call centralized handler if set
        if (_eventHandler != null) {
          await _eventHandler!(queued.event);
        }
        // Broadcast event on event bus
        _eventBus.fire(queued.event);

        // Wait for event to complete before next
        await Future.delayed(Duration.zero);
      } catch (e, stackTrace) {
        debugPrintStack(
          label: 'Error processing event: ${queued.event.runtimeType}',
          stackTrace: stackTrace,
        );
        debugPrint('Event error: $e');
      }
    }
    _isProcessing = false;
  }

  /// Clear all pending events
  void clear() {
    _eventQueue.clear();
  }

  /// Dispose and clean up resources
  void dispose() {
    _eventQueue.clear();
    _isProcessing = false;
  }

  /// Get priority for event type (higher = earlier)
  static int getPriority(VStoryEvent event) {
    return switch (event) {
      VMediaErrorEvent() => 100, // Critical - errors first
      VMediaReadyEvent() => 90, // High - ready state
      VProgressCompleteEvent() => 80, // Medium-high - progress
      VDurationKnownEvent() => 70, // Medium - duration
      VNavigateToGroupEvent() => 60, // Medium
      VNavigateToNextStoryEvent() => 60, // Medium
      VNavigateToPreviewsStoryEvent() => 60, // Medium
      VStoryPauseStateChangedEvent() => 50, // Medium-low
      VReactionSentEvent() => 40, // Low - reactions
      VCarouselScrollStateChangedEvent() => 30, // Low - scroll
      VMediaLoadingProgressEvent() => 20, // Very low - progress updates
      _ => 10, // Default - lowest priority
    };
  }
}

/// Internal wrapper for queued events with priority
class _QueuedEvent {
  _QueuedEvent(this.event, int? priority)
      : priority = priority ?? VStoryEventManager.getPriority(event);

  final VStoryEvent event;
  final int priority;
}
