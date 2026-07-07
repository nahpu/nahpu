# Repository Guidelines

## Project Structure & Module Organization

NAHPU is a Flutter app with Rust via Flutter Rust Bridge. Dart lives in `lib/`: screens in `lib/screens/`, services/providers in `lib/services/`, styling in `lib/styles/`, and generated bridge Dart in `lib/src/rust/`. Rust wrappers live in `rust/src/api/`; keep core logic upstream. Tests are in `test/` and `integration_test/`. Assets are under `assets/`; platforms are `android/`, `ios/`, `linux/`, `macos/`, `web/`, and `windows/`.

## Build, Test, and Development Commands

- `flutter analyze`: analyze.
- `flutter test`: test.
- `flutter pub run build_runner build --delete-conflicting-outputs`: codegen.
- `flutter_rust_bridge generate`: bridge codegen.
- `cargo check`: check rust code in `rust/`.
- `cargo clippy`: Rust linting.

## Coding Style & Naming Conventions

Use 2-space Dart formatting; run `dart format lib test integration_test`. Follow `flutter_lints` and `custom_lint`. Name Dart files in `snake_case.dart` and classes/widgets in `PascalCase`.

## Rust Best Practices

Keep Rust code, comments, and docstrings to 100 characters per line; wrap long signatures cleanly. Follow `rustfmt` and Rust API Guidelines. Prefer `struct` plus `impl` over loose globals. In `impl` blocks, put `pub fn` methods first and private helpers last. Use `?`, pattern matching, references over clones, and no `.unwrap()` unless justified. Use `snake_case` for functions/variables, `PascalCase` for types/traits/enums, and `SCREAMING_SNAKE_CASE` for constants.

## Flutter Best Practices

Keep screens as thin UI wrappers under `lib/screens/`. Put business logic in `lib/services/` and reusable UI in `lib/screens/shared/`. Do not place UI in services or return widgets from helpers; create widget classes. In widget classes, only `@override` methods go before `build`; keep `build` near the top and helpers below. Prefer `const`, immutable models, and Riverpod over mutable globals. Keep `build` side-effect free; do IO, database, and bridge work in services/providers. Guard async UI updates with `context.mounted`. Use theme values.

## Testing Guidelines

Add focused `*_test.dart` files in `test/`. Prefer service tests for import/export, persistence, validation, and migrations; add widget tests for regressions. Run integration tests for startup, navigation, IO, or bridge changes.

## Agent-Specific Instructions

Preserve user changes and avoid unrelated refactors. Always write the product name as `NAHPU`. Agents must not create commits, branches, pushes, or pull requests; leave Git under user control. After bridge API edits, regenerate bindings and verify analysis plus `cargo check` and `cargo clippy`. Add assets to `pubspec.yaml` only when needed.
