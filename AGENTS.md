# Repository Guidelines

## Project Structure & Module Organization

Nahpu is a Flutter app with a Rust layer exposed through Flutter Rust Bridge. Main Dart code lives in `lib/`: feature screens in `lib/screens/`, services and providers in `lib/services/`, styling in `lib/styles/`, and generated bridge Dart in `lib/src/rust/`. Rust bridge wrappers live in `rust/src/api/`; keep core logic in the upstream Nahpu Core API. Tests are in `test/`, with integration coverage in `integration_test/`. Assets are under `assets/`. Platform projects are in `android/`, `ios/`, `linux/`, `macos/`, `web/`, and `windows/`.

## Build, Test, and Development Commands

- `flutter pub get`: install Dart and Flutter dependencies.
- `flutter run`: run the app on the selected device.
- `flutter analyze`: run analyzer rules from `analysis_options.yaml`.
- `flutter test`: run unit and widget tests in `test/`.
- `flutter test integration_test`: run integration tests.
- `flutter pub run build_runner build --delete-conflicting-outputs`: regenerate Dart code after model, provider, or database changes.
- `python scripts.py frb --generate`: regenerate Flutter Rust Bridge bindings after edits in `rust/src/api`.
- `python scripts.py frb --check`: run `cargo check` in `rust/`.
- `python scripts.py build --apk` or `--macos`: build release artifacts.

## Coding Style & Naming Conventions

Use Dart formatting with 2-space indentation; run `dart format lib test integration_test` before larger submissions. The project includes `flutter_lints` and `custom_lint`; avoid suppressing lints unless documented. Name Dart files in `snake_case.dart`, classes and widgets in `PascalCase`, and providers/services with clear feature prefixes. Do not hand-edit generated bridge files or migration schemas.

## Testing Guidelines

Add focused tests beside related coverage in `test/`, using `*_test.dart` filenames. Prefer service-level tests for import/export, persistence, validation, and migrations; add widget tests for UI regressions. Run `flutter test` before PRs, and run integration tests when changing startup, navigation, platform IO, or Rust bridge behavior.

## Commit & Pull Request Guidelines

Git history uses short imperative commits such as `Fix overflow issues.` or `Update dependencies.` Keep commits scoped. Pull requests should target `dev`, explain the user-visible change, list test commands, link issues when applicable, and include screenshots or recordings for UI changes. Mention generated-code steps, Rust bridge regeneration, or platform-specific testing.

## Agent-Specific Instructions

Preserve user changes and avoid unrelated refactors. Agents must not create commits, branches, pushes, or pull requests; leave all Git and submission actions under the user's full control. When editing Rust bridge APIs, regenerate bindings and verify Dart analysis plus `cargo check`. Add assets to `pubspec.yaml` only when needed.
