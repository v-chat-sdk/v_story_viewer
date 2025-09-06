# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**v_story_viewer** is a Flutter package that provides WhatsApp/Instagram-style story viewing functionality. The package focuses exclusively on story viewing (not creation) with comprehensive gesture controls, media support, and cross-platform compatibility.

## Key Commands

### Build & Test
```bash
# Build example app for Android (verify compilation only)
cd example && flutter build apk --debug

# Build for iOS  
cd example && flutter build ios

# Run the example app
cd example && flutter run

# Analyze code for issues
flutter analyze

# Format code
dart format lib/

# Check for dependency updates
flutter pub outdated

# Upgrade dependencies
flutter pub upgrade
```

### Development Flow
```bash
# After making changes to the package
cd example
flutter pub get  # Update package dependency
flutter run      # Test changes in example app

# Run specific example
flutter run -t lib/simple_example.dart  # Minimal implementation
flutter run -t lib/integration_test.dart  # Integration tests
flutter run -t lib/horizontal_swipe_example.dart  # Swipe navigation

# Clean build artifacts
flutter clean
```

## Architecture & Code Structure

### Core Design Principles

1. **V-Prefix Naming**: All public classes use `V` prefix (e.g., `VStoryController`, `VStoryViewer`)
2. **ID-Based Navigation**: Never use array indexes for navigation - always use unique story IDs
3. **Sealed Classes**: Story types use sealed classes (`VBaseStory`) for type safety and compile-time validation
4. **File Organization**: One class per file - no multiple classes in single files
5. **Fail Gracefully**: Every network operation and file access must have fallback behavior - no crashes

### Package Architecture

The package follows a modular architecture with clear separation:

- **Models** (`lib/src/models/`): Data structures using sealed classes
  - `VBaseStory`: Sealed class hierarchy for story types
  - `VStoryGroup`: Story collection per user
  - `VStoryState`: Playback state management
  
- **Controllers** (`lib/src/controllers/`): State management
  - `VStoryController`: Main controller extending ChangeNotifier
  - Handles lifecycle, navigation, and playback
  
- **Services** (`lib/src/services/`): Business logic
  - `VCacheManager`: Media caching with progress streaming
  - `VMemoryManager`: Video controller lifecycle
  - `VStorageAdapter`: Cross-platform persistence
  
- **Widgets** (`lib/src/widgets/`): UI components
  - `VStoryViewer`: Main widget entry point
  - `VStoryContent`: Content rendering
  - `VStoryProgressBar`: Progress indicators using step_progress package
  
- **Utils** (`lib/src/utils/`): Utilities
  - `VPlatformHandler`: Cross-platform file handling via v_platform
  - `VDurationCalculator`: Story duration logic
  - `VGestureZones`: Touch zone detection

### State Management Pattern

The package uses ChangeNotifier pattern with specific lifecycle:
```dart
Initial → Loading → Playing → Completed
         ↓           ↓
       Error      Paused
```

### Key Implementation Rules

1. **Progress Always Resets**: When navigating between stories, progress must reset to 0
2. **Pause on Background**: Stories automatically pause when app goes to background (via WidgetsBindingObserver)
3. **Memory Management**: Video controllers limited to 10 cached instances (_maxVideoCacheCount)
4. **Performance Targets**: 60 FPS animations, <50MB memory, <100ms transitions
5. **Error Model Hierarchy**: Use specific error types (VNetworkError, VCacheError, VMediaLoadError, etc.) for precise error handling
6. **Controller Disposal**: Always check _isDisposed flag before operations in controllers

### Cross-Platform File Handling

All file operations use `v_platform` package for unified handling:
- Network URLs
- Asset paths  
- File paths
- Bytes data

### Dependencies

Critical dependencies that must be maintained:
- `flutter_cache_manager: ^3.4.1` - Media caching
- `v_platform: ^2.1.4` - Cross-platform file handling
- `video_player: ^2.10.0` - Video playback
- `step_progress: ^2.6.2` - Progress indicators

## Implementation Guidelines

### When Adding Features

1. Check requirements in `requirements/requirements.md` for specifications
2. Review design decisions in `requirements/design.md` 
3. Follow task breakdown in `requirements/tasks.md` if it exists
4. Ensure new code follows V-prefix naming convention
5. Implement proper disposal in controllers to prevent memory leaks
6. Use the existing error model hierarchy for error handling
7. Maintain one class per file structure

### Performance Considerations

- Use `const` constructors wherever possible
- Prefer `StatelessWidget` over `StatefulWidget`
- Extract complex UI into separate widgets
- Implement lazy loading for media content
- Cache video controllers (max 3 instances)

### Error Handling

All network operations and file access must:
- Have try-catch blocks
- Provide fallback behavior
- Never crash - graceful degradation only
- Use exponential backoff for retries

### Testing Strategy

The package is verified through the example application (`example/lib/`):
- `mock_data.dart`: Test data generation
- `story_viewer_page.dart`: Full feature demonstration
- `integration_test.dart`: Integration testing scenarios
- `simple_example.dart`: Minimal implementation example
- `horizontal_swipe_example.dart`: Horizontal swipe navigation demonstration

**Note**: Do not write tests unless explicitly requested


## Story Types & Usage

### Available Story Types

```dart
// Image Story
VImageStory(
  id: 'unique_id',
  url: 'https://example.com/image.jpg',
  duration: const Duration(seconds: 5),
  caption: 'Optional caption',
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
- Use sealed classes for enhanced type safety where applicable.
- Follow Flutter best practices for building widgets and structuring code.
- **Single Responsibility:** Adhere to the single responsibility principle—each class should do only one thing.
- Prefer composition over inheritance where possible.
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
