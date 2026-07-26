# Repository Guidelines

## Project Structure & Module Organization

The package API is exported from `lib/v_story_viewer.dart`; keep implementation details under `lib/src/`. Source is grouped by responsibility: `models/`, `controllers/`, `widgets/`, `painters/`, `transitions/`, and `utils/`. Package tests live in `test/`. Use `example/` as the runnable integration and visual test app, with demo screens in `example/lib/`. README images belong in `images/`, while design notes are kept in `ai/`. Do not edit generated platform registrants or files under `build/`.

## Build, Test, and Development Commands

- `flutter pub get` installs package dependencies.
- `flutter analyze` applies the rules from `analysis_options.yaml` and `flutter_lints`.
- `flutter test` runs the package test suite.
- `dart format lib test example/lib example/test` formats maintained Dart sources.
- `cd example && flutter pub get && flutter run -d <device>` launches the demo for manual UI, gesture, media, and platform checks.
- `flutter test --coverage` creates a local coverage report when assessing larger changes.

## Coding Style & Naming Conventions

Use idiomatic, null-safe Dart with 2-space indentation. Name types with `UpperCamelCase`, members with `lowerCamelCase`, and files with `snake_case.dart`. Prefer `const` constructors, immutable configuration objects, and focused widgets. Keep public types documented and exported through `lib/v_story_viewer.dart`; avoid exposing internal helpers. Preserve the sealed story-model design and exhaustive switch handling when adding a story variant. Reuse Flutter primitives and existing dependencies before introducing packages.

## Testing Guidelines

Use `flutter_test`. Name files `*_test.dart`, group tests by public type or widget, and write behavior-focused test names such as `sortedStories puts unseen first`. Cover model rules, controller state transitions, error paths, and changed widget interactions. Add or update example-app widget tests for integration behavior. No numeric coverage gate is configured, but changed logic should have regression coverage.

## Commit & Pull Request Guidelines

Follow the repository’s Conventional Commit style: `feat:`, `fix:`, `docs:`, or `chore:` followed by a concise imperative summary. Pull requests should explain behavior and compatibility impact, link relevant issues, list validation commands, and include screenshots or GIFs for visual changes. Update `README.md` and `CHANGELOG.md` for user-facing API or behavior changes.

## Scope & Safety

This package owns story UI and local state, not backend services. Preserve the 24-hour expiry, seen-state callback ownership, and cross-platform behavior. Never commit credentials, local environment files, generated output, or device-specific data.
