# Repository Guidelines

## Project Structure & Module Organization
The core package lives in `lib/`, with public exports in `lib/v_story_viewer.dart` and implementation details in `lib/src/` (models, widgets, controllers, painters, transitions, utils). The `example/` app is the primary manual testbed. Unit tests are in `test/`, README assets live in `images/`, and `build/` contains generated artifacts.

## Build, Test, and Development Commands
- `flutter pub get` installs dependencies for the package and example app.
- `flutter analyze` runs static analysis using `analysis_options.yaml`.
- `flutter test` runs the `flutter_test` suite in `test/`.
- `cd example && flutter run -d <device>` runs the demo app for UI verification.

## Coding Style & Naming Conventions
Follow standard Dart/Flutter style: 2-space indentation, `UpperCamelCase` for types, `lowerCamelCase` for members, and `snake_case` filenames. Keep story types as sealed model classes and render via switch expressions when adding new story variants. Prefer Flutter built-ins for UI primitives (e.g., `LinearProgressIndicator`, `Slider`) unless there is a clear need to replace them.

## Testing Guidelines
Use `flutter_test` and place tests under `test/` with `*_test.dart` names. Add coverage for model logic (expiry, sorting, seen state) and any new behavior introduced in `lib/src/`.

## Commit & Pull Request Guidelines
Commit messages follow Conventional Commits as seen in history (e.g., `feat: add parser`, `docs: update README`, `chore: bump version`). PRs should include a brief description, linked issues when relevant, test results (`flutter analyze`, `flutter test`), and screenshots/GIFs for UI changes in the `example/` app. Update `CHANGELOG.md` for user-facing changes.

## Scope & Architecture Notes
This package focuses on UI and local state only; avoid adding backend/network service layers. Story expiry is 24 hours, and filtering lives in the story group model, so new features should preserve that behavior.
