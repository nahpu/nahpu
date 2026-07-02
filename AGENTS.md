# Repository Guidelines

## Project Structure & Module Organization

NAHPU is a Flutter app with a Rust layer exposed through Flutter Rust Bridge. Dart code lives in `lib/`: screens in `lib/screens/`, services/providers in `lib/services/`, styling in `lib/styles/`, and generated bridge Dart in `lib/src/rust/`. Rust wrappers live in `rust/src/api/`; keep core logic in the upstream NAHPU Core API. Tests are in `test/` and `integration_test/`. Assets are under `assets/`; platforms are in `android/`, `ios/`, `linux/`, `macos/`, `web/`, and `windows/`.

## Build, Test, and Development Commands

- `flutter pub get`: install dependencies.
- `flutter run`: run locally.
- `flutter analyze`: run analyzer rules.
- `flutter test`: run unit/widget tests.
- `flutter test integration_test`: run integration tests.
- `flutter pub run build_runner build --delete-conflicting-outputs`: regenerate code.
- `python scripts.py frb --generate`: regenerate bridge bindings after `rust/src/api` edits.
- `python scripts.py frb --check`: run `cargo check` in `rust/`.

## Coding Style & Naming Conventions

Use Dart formatting with 2-space indentation; run `dart format lib test integration_test`. Follow `flutter_lints` and `custom_lint`; avoid suppressing lints. Name Dart files in `snake_case.dart` and classes/widgets in `PascalCase`. Do not hand-edit generated files.

## Flutter Best Practices

Keep widgets small, composable, and feature-local under `lib/screens/`; screens should be thin UI wrappers only. Put business logic and reusable logic in `lib/services/`, and reusable UI in `lib/screens/shared/`. Do not place UI code in service layers. Prefer `const` constructors, immutable models, and Riverpod providers over mutable global state. Keep `build` methods side-effect free; perform IO, database, and bridge work in services/providers. Guard async UI updates with `context.mounted` after `await`. Use `lib/styles/` theme values.

## Testing Guidelines

Add focused `*_test.dart` files beside related coverage in `test/`. Prefer service tests for import/export, persistence, validation, and migrations; add widget tests for regressions. Run integration tests for startup, navigation, platform IO, or Rust bridge changes.

## Commit & Pull Request Guidelines

Git history uses short imperative commits such as `Fix overflow issues.` Keep commits scoped. Pull requests target `dev`, explain user-visible changes, list tests, link issues, and include screenshots for UI changes. Mention generated code, Rust bridge regeneration, or platform-specific testing.

## Agent-Specific Instructions

Preserve user changes and avoid unrelated refactors. Always write the product name as `NAHPU`. Agents must not create commits, branches, pushes, or pull requests; leave Git and submissions under the user's full control. After Rust bridge API edits, regenerate bindings and verify Dart analysis plus `cargo check`. Add assets to `pubspec.yaml` only when needed.
