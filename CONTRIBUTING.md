# Contributing to v_story_viewer

Thank you for your interest in contributing to v_story_viewer! We welcome contributions from the community. This document provides guidelines and instructions for contributing.

## Code of Conduct

Please be respectful and constructive in all interactions with other contributors.

## Getting Started

### Prerequisites

- Flutter SDK: `>=3.0.0`
- Dart SDK: `^3.9.0`

### Setup Development Environment

```bash
# Clone the repository
git clone https://github.com/hatemragap/v_story_viewer.git
cd v_story_viewer

# Get dependencies
flutter pub get

# Run tests
flutter test

# Run linting
flutter analyze

# Format code
dart format .
```

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

- Follow the existing code style and conventions
- Keep changes focused and atomic
- Add tests for new features
- Update documentation if needed

### 3. Code Quality Standards

#### Naming Conventions

- **Classes**: PascalCase with `V` prefix (e.g., `VStoryViewer`)
- **Methods/Functions**: camelCase (e.g., `startProgress()`)
- **Variables**: camelCase (e.g., `isViewing`)
- **Constants**: camelCase with `const` (e.g., `const int maxRetries = 3`)
- **Private members**: Leading underscore (e.g., `_internalState`)

#### Code Organization

- One class per file
- Organize files by feature (e.g., `v_story_viewer/`, `v_media_viewer/`)
- Keep functions/methods under 50 lines when possible
- Use meaningful variable and function names

#### Documentation

- Add doc comments for all public APIs
- Use `///` for documentation comments
- Include examples for complex features
- Update README.md for significant changes

#### Tests

- Write unit tests for controllers and business logic
- Write widget tests for UI components
- Aim for >80% code coverage
- Place tests in `test/` directory mirroring source structure

### 4. Linting and Formatting

```bash
# Run analyzer
flutter analyze

# Format code
dart format .

# Run tests
flutter test
```

All code must pass static analysis and formatting checks.

### 5. Commit Messages

Use clear, descriptive commit messages:

```
feat: add new feature description

- Detail about the change
- Another detail if needed

docs: update documentation for X
fix: resolve issue with Y
refactor: improve performance of Z
```

### 6. Submit a Pull Request

- Push your branch to your fork
- Create a pull request against the main repository
- Provide a clear description of changes
- Link any related issues
- Wait for code review

## Architecture Guidelines

### Feature Communication Pattern

Features communicate through **callback-based mediator pattern**:

1. Define callback interfaces in `models/` folder
2. Controllers accept callbacks via constructor injection
3. VStoryViewer orchestrator wires all callbacks
4. Features never reference each other directly

Example:
```dart
// Define callbacks
class VProgressCallbacks {
  final VoidCallback? onStoryComplete;
  const VProgressCallbacks({this.onStoryComplete});
}

// Controller accepts callbacks
class VProgressController extends ChangeNotifier {
  final VProgressCallbacks _callbacks;

  void triggerComplete() {
    _callbacks.onStoryComplete?.call();
  }
}
```

### Performance Considerations

- Use `const` constructors wherever possible
- Prefer `StatelessWidget` over `StatefulWidget`
- Extract complex UI into separate widgets
- Use `LinearProgressIndicator` for progress (built-in optimization)
- Implement proper disposal in controllers

### Memory Management

- Always dispose of controllers and streams
- Implement `dispose()` in StatefulWidgets
- Remove listeners when components unmount
- Cache expensive computations using `late final`

## Testing Guidelines

### Unit Tests

```dart
test('controller performs action', () {
  final controller = VTestController();
  controller.performAction();
  expect(controller.state, equals(expectedState));
  controller.dispose();
});
```

### Widget Tests

```dart
testWidgets('widget displays correctly', (tester) async {
  await tester.pumpWidget(TestApp(child: TestWidget()));
  expect(find.byType(TestWidget), findsOneWidget);
});
```

### Test Structure

```
test/
├── features/
│   ├── v_story_viewer/
│   │   ├── controllers/
│   │   └── widgets/
│   └── [other features]/
└── helpers/
    └── [test helpers]
```

## Reporting Issues

### Bug Reports

Include:
- Flutter version: `flutter --version`
- Device/OS information
- Steps to reproduce
- Expected vs actual behavior
- Code snippet if applicable
- Error logs/stack traces

### Feature Requests

Include:
- Clear description of the feature
- Use case and motivation
- Proposed API (if possible)
- Potential impact on existing code

## Documentation

### API Documentation

- Document all public classes and methods
- Provide usage examples for complex APIs
- Update API.md for significant changes

### README Updates

Update README.md if you:
- Add new features
- Change public APIs
- Modify configuration
- Update requirements

## Code Review Process

Contributions will be reviewed for:

1. **Functionality**: Does it work as intended?
2. **Code Quality**: Does it follow style guidelines?
3. **Documentation**: Are changes well-documented?
4. **Tests**: Are there sufficient tests?
5. **Performance**: Are there any performance concerns?
6. **Compatibility**: Does it maintain backwards compatibility?

## Merge Policy

PRs will be merged when:

- ✅ All tests pass
- ✅ Code analysis shows no issues
- ✅ At least one maintainer approves
- ✅ No conflicts with main branch
- ✅ Documentation is updated

## Release Process

Releases are handled by maintainers following semantic versioning:

- **Major**: Breaking changes (1.0.0)
- **Minor**: New features (1.1.0)
- **Patch**: Bug fixes (1.0.1)

Update CHANGELOG.md with:
- New features
- Bug fixes
- Breaking changes
- Deprecations

## Questions?

- Check existing issues and discussions
- Create a new discussion for questions
- Review the architecture documentation in `requirements/`

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to v_story_viewer! 🎉
