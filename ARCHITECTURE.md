# V Story Viewer - Improved Architecture Documentation

This document outlines the comprehensive architecture improvements implemented in v_story_viewer to enhance code readability, maintainability, and developer experience.

## Table of Contents

1. [Overview](#overview)
2. [Core Architecture Principles](#core-architecture-principles)
3. [Readability Improvements](#readability-improvements)
4. [New Architecture Components](#new-architecture-components)
5. [Implementation Examples](#implementation-examples)
6. [Migration Guide](#migration-guide)
7. [Best Practices](#best-practices)

## Overview

The v_story_viewer package has undergone significant architectural improvements focused on:

- **Type Safety**: Using Result patterns and sealed classes
- **Semantic Clarity**: Named constants and semantic widgets
- **Error Handling**: Comprehensive validation and error recovery
- **State Management**: Predictable state machines
- **Developer Experience**: Better APIs and debugging tools

## Core Architecture Principles

### 1. Result Pattern for Error Handling

Instead of nullable returns or exceptions, we use a type-safe Result pattern:

```dart
// Before: Nullable with unclear error states
VBaseStory? storyAt(int index) =>
    index >= 0 && index < stories.length ? stories[index] : null;

// After: Explicit Result with detailed errors
VStoryResult<VBaseStory> storyAt(int index) {
  if (index < 0 || index >= stories.length) {
    return VStoryFailure(
      VStoryError.indexOutOfBounds(
        'Story index $index is out of bounds. Valid range: 0-${stories.length - 1}',
      ),
    );
  }
  return VStorySuccess(stories[index]);
}

// Usage with pattern matching
final result = storyGroup.storyAt(2);
switch (result) {
  case VStorySuccess(value: final story):
    displayStory(story);
  case VStoryFailure(error: final error):
    showError(error.message);
}
```

### 2. Semantic Constants

All magic numbers and hardcoded values are centralized in semantic constants:

```dart
// Before: Magic numbers scattered throughout code
Timer.periodic(const Duration(milliseconds: 60), callback);
Container(height: 2.0, color: Colors.white.withOpacity(0.3));

// After: Semantic constants with clear meaning
Timer.periodic(VStoryAnimationConstants.legacyFrameInterval, callback);
Container(
  height: VStoryDimensionConstants.progressBarHeight,
  color: VStoryColors.progressBarInactive,
);
```

### 3. Semantic Color Scheme

Consistent color usage with semantic naming:

```dart
class VStoryColors {
  // Semantic overlay colors
  static const Color overlayBackground = Color(0xB3000000); // Black 70%
  static const Color loadingOverlayBackground = Color(0xB3000000);
  static const Color errorOverlayBackground = Color(0xE6000000); // Black 90%

  // Progress bar colors
  static const Color progressBarActive = white;
  static const Color progressBarInactive = Color(0x4DFFFFFF); // White 30%

  // Text colors by context
  static const Color primaryText = white;
  static const Color secondaryText = Color(0xCCFFFFFF); // White 80%
}
```

### 4. Navigation Service

Centralized navigation logic with comprehensive boundary handling:

```dart
class VStoryNavigationService {
  VNavigationResult calculateNextPosition({
    required int currentGroupIndex,
    required int currentStoryIndex,
  }) {
    // Comprehensive validation and boundary checking
    // Returns semantic navigation results
  }
}

// Usage
final result = navigationService.calculateNextPosition(
  currentGroupIndex: 0,
  currentStoryIndex: 2,
);

switch (result) {
  case VNavigationNextGroup(groupIndex: final g, storyIndex: final s):
    navigateToGroup(g, s);
  case VNavigationCompleted():
    handleCompletion();
  // ... handle other cases
}
```

### 5. Validation Service

Fluent validation chains for comprehensive error checking:

```dart
final validationResult = VStoryValidationService.validate()
  .storyGroups(groups)
  .initialIndexes(groupIndex, storyIndex)
  .gestureConfig(gestureConfig)
  .cacheConfig(cacheConfig)
  .build();

if (validationResult.hasErrors) {
  for (final error in validationResult.errors) {
    print('Validation Error [${error.code}]: ${error.message}');
  }
}
```

## Readability Improvements

### 1. Semantic Widgets

Replace verbose nested widgets with semantic components:

```dart
// Before: Verbose nested widgets
ColoredBox(
  color: Colors.black.withOpacity(0.7),
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          value: progress,
          color: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.3),
        ),
        const SizedBox(height: 5),
        Text('Loading...', style: TextStyle(color: Colors.white)),
      ],
    ),
  ),
);

// After: Semantic widgets with clear intent
VLoadingOverlay(
  progress: progress,
  message: 'Loading...',
)
```

### 2. State Machine

Predictable state management with compile-time safety:

```dart
sealed class VStoryViewerState {
  // Computed properties for readability
  bool get canNavigate => switch (this) {
    VIdleState() => true,
    VPlayingState() => true,
    VPausedState() => true,
    VLoadingState() => false,
    VNavigatingState() => false,
    VErrorState() => false,
  };
}

// Usage with state transitions
final stateMachine = VStoryStateMachine();
stateMachine.transitionTo(
  VPlayingState(
    position: VStoryPosition(groupIndex: 0, storyIndex: 0),
    progress: 0.0,
    startTime: DateTime.now(),
  ),
  reason: 'Story playback started',
);
```

### 3. Type-Safe Navigation

Explicit navigation direction handling:

```dart
enum VStoryNavigationDirection {
  previous('previous'),
  next('next');
}

// Usage becomes self-documenting
_handleNavigation(VStoryNavigationDirection.next);
```

## New Architecture Components

### Core Constants (`src/core/constants/`)

- **VStoryConstants**: Animation, timing, and performance constants
- **VStoryColors**: Semantic color scheme with context-aware naming
- **VStoryDimensionConstants**: UI dimensions and spacing values

### Core Models (`src/core/models/`)

- **VStoryResult**: Type-safe Result pattern for error handling
- **VStoryNavigation**: Navigation direction enums and position tracking
- **VStoryStateMachine**: Comprehensive state machine implementation

### Core Services (`src/core/services/`)

- **VStoryNavigationService**: Centralized navigation logic and calculations
- **VStoryValidationService**: Fluent validation chains for configuration

### Core Widgets (`src/core/widgets/`)

- **VSemanticWidgets**: Reusable semantic UI components
- **VLoadingOverlay**: Consistent loading state presentation
- **VErrorOverlay**: Standardized error display with retry functionality

## Implementation Examples

### Basic Usage with Improved Architecture

```dart
class MyStoryViewer extends StatefulWidget {
  @override
  State<MyStoryViewer> createState() => _MyStoryViewerState();
}

class _MyStoryViewerState extends State<MyStoryViewer> {
  late VStoryNavigationService _navigationService;
  late VStoryStateMachine _stateMachine;

  @override
  void initState() {
    super.initState();
    _initializeWithValidation();
  }

  void _initializeWithValidation() {
    // Create story groups with validation
    final storyGroupsResult = _createValidatedStoryGroups();

    switch (storyGroupsResult) {
      case VStorySuccess(value: final groups):
        _navigationService = VStoryNavigationService(storyGroups: groups);
        _stateMachine = VStoryStateMachine();

        // Validate complete configuration
        final validation = VStoryValidationService.validate()
          .storyGroups(groups)
          .initialIndexes(groups, 0, 0)
          .gestureConfig(_createGestureConfig())
          .build();

        if (validation.hasErrors) {
          _handleValidationErrors(validation.errors);
          return;
        }

        _startStoryViewer(groups);

      case VStoryFailure(error: final error):
        _showError(error.message);
    }
  }

  VStoryResult<List<VStoryGroup>> _createValidatedStoryGroups() {
    try {
      final groups = [/* create groups */];

      // Validate each group
      for (final group in groups) {
        final validation = group.validate();
        if (validation.isFailure) {
          return validation.map((_) => groups);
        }
      }

      return VStorySuccess(groups);
    } catch (e) {
      return VStoryFailure(
        VStoryError.unknown(message: 'Failed to create groups: $e'),
      );
    }
  }
}
```

### Custom Error Handling

```dart
void _handleStoryViewerError(VStoryError error) {
  _stateMachine.transitionTo(
    VErrorState(
      error: error,
      previousState: _stateMachine.currentState,
      occurredAt: DateTime.now(),
    ),
    reason: 'Story viewer error occurred',
  );

  // Show appropriate UI based on error type
  switch (error) {
    case VNetworkError():
      _showNetworkErrorDialog();
    case VMediaError():
      _showMediaErrorDialog();
    case VConfigurationError():
      _showConfigurationErrorDialog();
  }
}
```

### Navigation with Services

```dart
void _navigateToStory(VStoryNavigationDirection direction) {
  final currentPos = _stateMachine.currentState.currentPosition;
  if (currentPos == null) return;

  final result = direction == VStoryNavigationDirection.next
    ? _navigationService.calculateNextPosition(
        currentGroupIndex: currentPos.groupIndex,
        currentStoryIndex: currentPos.storyIndex,
      )
    : _navigationService.calculatePreviousPosition(
        currentGroupIndex: currentPos.groupIndex,
        currentStoryIndex: currentPos.storyIndex,
      );

  _handleNavigationResult(result);
}

void _handleNavigationResult(VNavigationResult result) {
  switch (result) {
    case VNavigationWithinGroup(groupIndex: final g, storyIndex: final s):
    case VNavigationNextGroup(groupIndex: final g, storyIndex: final s):
    case VNavigationPreviousGroup(groupIndex: final g, storyIndex: final s):
      _transitionToStory(g, s);

    case VNavigationCompleted():
      _handleAllStoriesCompleted();

    case VNavigationAtBeginning():
      _showFeedback('Already at the beginning');

    case VNavigationFailed(reason: final reason):
      _showError('Navigation failed: $reason');
  }
}
```

## Migration Guide

### From Legacy to Improved Architecture

#### 1. Replace Magic Numbers

```dart
// Before
Timer.periodic(const Duration(milliseconds: 60), callback);

// After
Timer.periodic(VStoryAnimationConstants.legacyFrameInterval, callback);
```

#### 2. Use Result Pattern

```dart
// Before
VBaseStory? story = storyGroup.storyAtOrNull(index);
if (story != null) {
  // handle story
}

// After
final result = storyGroup.storyAt(index);
switch (result) {
  case VStorySuccess(value: final story):
    // handle story
  case VStoryFailure(error: final error):
    // handle error
}
```

#### 3. Replace Custom Widgets

```dart
// Before
Container(
  color: Colors.black.withOpacity(0.7),
  child: Center(
    child: CircularProgressIndicator(),
  ),
);

// After
VLoadingOverlay(progress: 0.5, message: 'Loading...')
```

#### 4. Use Navigation Service

```dart
// Before - Direct index manipulation
currentStoryIndex++;
if (currentStoryIndex >= stories.length) {
  currentGroupIndex++;
  currentStoryIndex = 0;
}

// After - Service-based navigation
final result = navigationService.calculateNextPosition(
  currentGroupIndex: currentGroupIndex,
  currentStoryIndex: currentStoryIndex,
);
// Handle result with pattern matching
```

## Best Practices

### 1. Always Use Result Pattern

```dart
// Good: Explicit error handling
VStoryResult<VBaseStory> loadStory(String id) {
  try {
    final story = _findStoryById(id);
    return VStorySuccess(story);
  } catch (e) {
    return VStoryFailure(VStoryError.storyNotFound(id));
  }
}

// Avoid: Silent failures with nulls
VBaseStory? loadStoryNullable(String id) {
  try {
    return _findStoryById(id);
  } catch (e) {
    return null; // Lost error context!
  }
}
```

### 2. Use Semantic Constants

```dart
// Good: Self-documenting constants
Container(
  height: VStoryDimensionConstants.progressBarHeight,
  decoration: BoxDecoration(
    color: VStoryColors.progressBarActive,
    borderRadius: BorderRadius.circular(
      VStoryDimensionConstants.smallBorderRadius,
    ),
  ),
);

// Avoid: Magic numbers
Container(
  height: 2.0,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(4.0),
  ),
);
```

### 3. Validate Early and Comprehensively

```dart
// Good: Comprehensive upfront validation
void initializeStoryViewer() {
  final validation = VStoryValidationService.validate()
    .storyGroups(_storyGroups)
    .initialIndexes(_initialGroupIndex, _initialStoryIndex)
    .gestureConfig(_gestureConfig)
    .build();

  if (validation.hasErrors) {
    _handleValidationErrors(validation.errors);
    return;
  }

  _proceedWithInitialization();
}

// Avoid: Scattered validation checks
void initializeStoryViewer() {
  if (_storyGroups.isEmpty) throw Exception('Empty groups');
  // Start initialization...
  if (_initialGroupIndex < 0) throw Exception('Invalid index');
  // Continue...
}
```

### 4. Use State Machine for Complex State

```dart
// Good: Predictable state transitions
final stateMachine = VStoryStateMachine();
if (stateMachine.currentState.canNavigate) {
  stateMachine.transitionTo(
    VNavigatingState(/* ... */),
    reason: 'User navigation request',
  );
}

// Avoid: Boolean flag soup
bool _isNavigating = false;
bool _isLoading = false;
bool _isPaused = false;
// Complex logic to manage these flags...
```

### 5. Prefer Semantic Widgets

```dart
// Good: Semantic intent
VErrorOverlay(
  message: 'Failed to load story',
  onRetry: _retryLoading,
)

// Avoid: Generic widgets with unclear purpose
Container(
  color: Colors.red.withOpacity(0.8),
  child: Column(
    children: [
      Icon(Icons.error),
      Text('Failed to load story'),
      ElevatedButton(
        onPressed: _retryLoading,
        child: Text('Retry'),
      ),
    ],
  ),
)
```

## Conclusion

The improved architecture provides:

- **Better Developer Experience**: Clear APIs, comprehensive validation, and detailed error messages
- **Enhanced Maintainability**: Semantic naming, centralized constants, and focused services
- **Improved Type Safety**: Result patterns, sealed classes, and compile-time checking
- **Consistent UI**: Semantic widgets and color schemes
- **Predictable Behavior**: State machines and validated transitions

These improvements make the v_story_viewer package more robust, easier to understand, and simpler to extend while maintaining backward compatibility through deprecation warnings and legacy method support.
