# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The v_story_viewer is a Flutter package for WhatsApp/Instagram-style story viewing with comprehensive gesture controls, media support, and cross-platform compatibility. The package uses a modern architecture with dependency injection and unidirectional data flow patterns.

## Build & Development Commands

```bash
# Get dependencies
flutter pub get

# Run tests
flutter test

# Run specific test file
flutter test test/features/v_story_viewer/controllers/v_story_controller_test.dart

# Analyze code
flutter analyze

# Check formatting
dart format --set-exit-if-changed .

# Run example app
cd example && flutter run

# Build APK (for testing compilation)
cd example && flutter build apk

# Generate coverage report
flutter test --coverage
```

## Architecture

### Core Architecture Pattern

The package uses a **Controller-Provider-Widget** architecture with dependency injection:

1. **Provider Layer**: InheritedWidget-based providers (VControllerProvider, VDataProvider) manage controller registry and data flow
2. **Orchestration Layer**: VStoryViewer acts as the main orchestrator, coordinating all feature controllers through its internal controller hierarchy
3. **Feature Layer**: Specialized controllers for each feature (progress, media, gestures, etc.) communicate via callbacks
4. **Widget Layer**: Stateless widgets access controllers through providers and rebuild reactively

### Key Design Principles

- **Unidirectional Data Flow**: Data flows from controllers → providers → widgets
- **Callback-Based Mediator Pattern**: Features communicate via typed callbacks through an orchestrator
    - Each feature defines callback interfaces (e.g., `VProgressCallbacks`, `VGestureCallbacks`)
    - Controllers receive callbacks via constructor injection
    - Orchestrator wires all callbacks and manages feature coordination
    - Features have NO direct references to each other (complete separation)
    - See `requirements/feature_communication_architecture.md` for detailed implementation
- **Single Responsibility**: Each controller handles one specific aspect (progress, media, gestures, etc.)
- **Dependency Injection**: All dependencies explicitly injected through constructors via VControllerFactory
- **Type Safety**: Sealed classes for story types, no dynamic types in APIs

### Feature Organization

The codebase uses **feature-based architecture** under `lib/src/features/`. Each feature is self-contained:

```
feature_folder/
├── controllers/     # Feature-specific controllers
├── widgets/         # Feature-specific widgets
├── models/          # Feature data models (including callbacks)
├── utils/           # Feature utilities
└── views/           # Feature screens/pages
```

**Available Features:**
- **v_story_viewer**: **Main orchestrator** - Coordinates all feature controllers and manages story viewing lifecycle
- **v_progress_bar**: Progress indicators using Flutter's LinearProgressIndicator
- **v_gesture_detector**: Gesture handling with tap zones and swipe detection
- **v_media_viewer**: Media display for images, videos, text, and custom content
- **v_cache_manager**: Media caching with flutter_cache_manager integration
- **v_reply_system**: Reply functionality with keyboard handling
- **v_story_actions**: Story action buttons (share, save, etc.)
- **v_story_header**: User info and timestamp display
- **v_story_footer**: Caption and metadata display
- **v_theme_system**: Centralized theme management
- **v_localization**: Internationalization support
- **v_error_handling**: Error states and recovery
- **v_story_models**: Core data models (VStoryGroup, VBaseStory, etc.)
- **v_story_state_manager**: Global state coordination

## Critical Implementation Notes

### Feature Communication Pattern

Features communicate using **Callback-Based Mediator Pattern**:

```dart
// Example: Progress completion flow
VProgressController
  → callbacks.onStoryComplete()
  → VStoryViewer._handleStoryComplete()
  → VMediaController.loadStory()
  → callbacks.onMediaReady()
  → VStoryViewer._handleMediaReady()
  → VProgressController.startProgress()
```

**Key Rules:**
1. Features define callback interfaces in `models/` (e.g., `VProgressCallbacks`)
2. Controllers accept callbacks via constructor injection
3. **VStoryViewer (main orchestrator)** creates all controllers and wires their callbacks
4. Features NEVER reference each other directly
5. All inter-feature communication flows through VStoryViewer orchestrator

### Controller Lifecycle

Controllers are created once by VControllerFactory and disposed in reverse dependency order. **VStoryViewer (main orchestrator)** manages all feature controllers through callbacks set up in `_setupControllerConnections()`.

### Media Loading Pattern

```dart
// Media loading flow:
// 1. VStoryViewer (orchestrator) requests media load
// 2. VMediaController checks cache via VCacheController
// 3. Downloads if needed, shows progress
// 4. Invokes onMediaReady callback
// 5. VStoryViewer triggers VProgressController to start progress animation
```

### Navigation State Management

Navigation is thread-safe using `_isNavigating` flag to prevent concurrent navigation. Stories are tracked by group and story indices in VDataNotifier.

### Performance Optimizations

- Single video controller instance with init/dispose per story
- LinearProgressIndicator for efficient progress animation
- Selective widget rebuilds using AnimatedBuilder with specific listenables
- Provider caching to reduce context lookups

## Testing Strategy

### Test Organization

Tests mirror the source structure under `test/features/`. Each controller has unit tests, widgets have widget tests, and complete flows have integration tests.

### Testing Feature Communication

When testing controllers with callbacks:

```dart
// Test controller in isolation with mock callbacks
test('progress controller calls onComplete when animation finishes', () {
  var completeCalled = false;

  final controller = VProgressController(
    storyCount: 3,
    callbacks: VProgressCallbacks(
      onStoryComplete: () => completeCalled = true,
    ),
  );

  // Simulate story completion
  controller.startProgress(Duration(milliseconds: 100));
  await tester.pumpAndSettle();

  expect(completeCalled, isTrue);
});
```

### Mock Pattern

Use MockControllerBundle to create mock controllers with configurable callbacks for testing controller interactions.

## Package Dependencies

Core dependencies (from pubspec.yaml):
- **flutter_cache_manager: ^3.4.1** - Media caching
- **video_player: ^2.10.0** - Video playback
- **v_platform: ^2.1.4** - Cross-platform file handling
- **cached_network_image: ^3.4.1** - Image caching

## Linting & Code Quality

The project uses strict linting with:
- **leancode_lint** for base rules
- **dart_code_linter** for complexity metrics
- **custom_lint** for additional checks

Key metrics enforced:
- Cyclomatic complexity: max 20
- Number of parameters: max 4
- Maximum nesting level: 5

## Common Development Tasks

### Adding a New Feature

1. **Create feature folder** under `lib/src/features/v_[feature_name]/`
2. **Define callback interface** in `models/v_[feature]_callbacks.dart`:
   ```dart
   class VFeatureCallbacks {
     final VoidCallback? onEvent;
     final void Function(String data)? onDataEvent;
     const VFeatureCallbacks({this.onEvent, this.onDataEvent});
   }
   ```
3. **Create controller** in `controllers/v_[feature]_controller.dart`:
   ```dart
   class VFeatureController extends ChangeNotifier {
     VFeatureController({VFeatureCallbacks? callbacks})
       : _callbacks = callbacks ?? const VFeatureCallbacks();

     final VFeatureCallbacks _callbacks;

     void triggerEvent() {
       _callbacks.onEvent?.call();
     }
   }
   ```
4. **Wire in VStoryViewer** - Add controller creation and callback wiring in VStoryViewer (main orchestrator)
5. **Create widgets** in `widgets/` folder
6. **Add tests** mirroring feature structure under `test/features/`

### Adding a New Controller to Existing Feature

1. Create controller in `lib/src/features/[feature]/controllers/`
2. Accept callbacks via constructor if needed for inter-feature communication
3. Add to VControllerBundle if part of main orchestration
4. Wire dependencies in VControllerFactory
5. Set up callbacks in orchestrator's `_setupControllerConnections()`

### Adding a New Story Type

1. Extend VBaseStory abstract class
2. Create corresponding viewer widget
3. Add case handling in VMediaController
4. Update VDurationController for duration logic

### Implementing Custom UI

1. Use VCustomStory for arbitrary Flutter widgets
2. Maintain gesture controls by wrapping in VGestureDetector
3. Access theme via VControllerProvider.of(context).themeController

## Requirements & Design Documents

Key documents in `requirements/`:
- **requirements.md**: Full feature requirements with acceptance criteria (19 major requirements)
- **design.md**: Feature-based architecture and folder structure specifications
- **feature_communication_architecture.md**: Callback-based mediator pattern implementation guide

The package implements 19 major requirements including media types, gestures, lifecycle management, customization, and cross-platform support.



### Cross-Platform File Handling

All file operations use `v_platform` package for unified handling:
- Network URLs
- Asset paths
- File paths
- Bytes data


## Implementation Guidelines

### When Adding Features

1. Check requirements in `requirements/requirements.md` for specifications
2. Review design decisions in `requirements/design.md`
3. Follow task breakdown in `requirements/tasks.md` if it exists
4. Ensure new code follows V-prefix naming convention
5. Implement proper disposal in controllers to prevent memory leaks
6. Use the existing error model hierarchy for error handling
7. Maintain one class per file structure
8. write high maintainable code and testable code

### Performance Considerations

- Use `const` constructors wherever possible
- Prefer `StatelessWidget` over `StatefulWidget`
- Extract complex UI into separate widgets


## Story Types & Usage

### Available Story Types

```dart
// Image Story
VImageStory(
  id: 'unique_id',
  url: 'https://example.com/image.jpg',
  duration: const Duration(seconds: 5),
  caption: 'Optional caption',
etc ...
)

// Video Story
VVideoStory(
  id: 'unique_id',
  url: 'https://example.com/video.mp4',
  caption: 'Optional caption',
)

// Text Story
VTextStory(
  id: 'unique_id',
  text: 'Story content',
  backgroundColor: Colors.blue,
  duration: const Duration(seconds: 3),
)

// Custom Story
VCustomStory(
  id: 'unique_id',
  duration: const Duration(seconds: 5),
  builder: (context) => CustomWidget(),
)
```

## Important Project Files

- **Requirements**: `requirements/requirements.md` - Feature specifications and acceptance criteria
- **Design Document**: `requirements/design.md` - Architecture decisions, state machines, and user flows
- **Example Apps**: `example/lib/` - Various implementation examples for testing
- **Main Export**: `lib/v_story_viewer.dart` - Public API surface

# AI Agent Directives: Flutter Development Standards

**Objective:** To ensure the highest quality, performance, and maintainability of the generated Flutter code, you must strictly adhere to the following rules and guidelines for every task. These are non-negotiable.

---

### 1. Development Approach
- Complete each task with working, testable code.
- Ensure no task leaves orphaned or unused code.
- **V-Prefix Naming:** All public APIs must follow the `V` prefix naming convention.
- **File Separation:** Maintain a strict separation of one class per file. **Each Flutter class or widget must be in its own separate `.dart` file.**
- Use abstract classes for enhanced type safety where applicable.
- Follow Flutter best practices for building widgets and structuring code.
- **Single Responsibility:** Adhere to the single responsibility principle—each class should do only one thing.
- Prefer composition to inheritance where possible.
- **Resource Management:** Implement `dispose()` methods for all controllers and streams to prevent memory leaks.
- Use `const` constructors wherever possible for performance optimization.

### 2. Widget Building Guidelines
- Always use `const` for widgets that do not change.
- Prefer `StatelessWidget` when state is not needed.
- Extract complex widget trees into separate, smaller widget classes.
- Use `Key` types appropriately for widget identity and performance.
- Only use `AutomaticKeepAliveClientMixin` when absolutely necessary.
- Avoid deep widget nesting by extracting UI into methods or separate widgets.
- Use `Builder` widgets to obtain the correct `BuildContext` when needed.
- **Never call `setState()` during a build method.**
- Cache expensive computations using `late final` or other memoization techniques.

### 3. State Management Rules
- Controllers should extend `ChangeNotifier`, not manage multiple `ValueNotifier`s.
- Call `notifyListeners()` only after the state has actually changed.
- **Always dispose of controllers in the widget's `dispose()` method.**
- Use `WidgetsBindingObserver` to handle app lifecycle events.
- Avoid rebuilding the entire widget tree; use targeted rebuilds for efficiency.
- Implement proper error states within your controllers.
- Never expose mutable state directly; use getters to provide read-only access.

# Flutter Build and Test Rule

When working on Flutter projects:
- Do not build APKs or run the app during `flutter build` or `flutter test`, as they take too much time.
- Instead, use only `flutter analyze` or the Dart analyzer to quickly check and fix code issues.
- The goal is to ensure rapid iteration by relying solely on static analysis rather than full builds or test runs.
