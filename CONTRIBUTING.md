# Contributing to Nahpu

First off, thank you for considering contributing to Nahpu! It's people like you that make Nahpu such a great tool.

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Rust toolchain](https://www.rust-lang.org/tools/install)
- [Flutter rust bridge](https://github.com/fzyzcjy/flutter_rust_bridge)

### Installation

1. **Clone the repository:**

   ```sh
   git clone https://github.com/hhandika/nahpu.git
   cd nahpu
   ```

2. **Install Dart dependencies:**

   ```sh
   flutter pub get
   ```

3. **Setup Flutter Rust Bridge:**

   This project uses `flutter_rust_bridge` to integrate Rust code with Flutter. You will need to install the code generator to work with the Rust part of the project.

   ```sh
   cargo install flutter_rust_bridge_codegen
   ```

4. **Build the Rust library and generate code (optional):**

   Rust bindings live in rust/. After changing any Rust code (see [Rust API section](#rust-api)), regenerate the bridge code:

   ```sh
   flutter_rust_bridge_codegen --generate
   ```

You can skip the manual cargo build; Flutter will build the Rust library when needed.

### Running the App

Once you have installed the dependencies, you can run the app:

```sh
flutter run
```

### Code Generation

This project uses code generation for models and providers. If you change any of the files in `lib/src/services/` or `lib/src/database/`, you will need to run the following command to regenerate the generated files:

```sh
flutter pub run build_runner build --delete-conflicting-outputs
```

If you change the Rust code in `rust/src/api`, you will need to regenerate the bridge code:

```sh
python scripts.py frb --generate
```

## Troubleshooting

Here are some common issues and their solutions:

- **`flutter_rust_bridge_codegen` not found:**
  - **Cause:** The `flutter_rust_bridge_codegen` is not in your `PATH`.
  - **Solution:** Make sure you have installed it with `cargo install flutter_rust_bridge_codegen` and that the cargo bin directory is in your `PATH`.
- **Error on macOS: `flutter_rust_bridge_codegen` fails with "Please supply one or more path/to/llvm..."**
  - **Cause:** The code generator cannot find your LLVM installation.
  - **Solution:** Install LLVM with Homebrew (`brew install llvm`).
- **Error on Android: `android context was not initialized`**
  - **Cause:** The Dart VM loads the Rust library differently than a standard Android JVM application, skipping the initialization of the NDK context.
  - **Solution:** This is a known interaction quirk. Ensure your setup follows the official `flutter_rust_bridge` examples, as they contain workarounds for this.
- **Error on iOS TestFlight: `store_dart_post_cobject` not found**
  - **Cause:** Xcode may be stripping necessary symbols from the final release build.
  - **Solution:** In Xcode, navigate to the build settings for the `native-staticlib` target. Under the "Deployment" section, set "Strip Linked Product" to "No" and "Strip Style" to "Debugging Symbols".

## Project Structure

- `lib/`: Main application code.
  - `screens/`: UI for each screen.
  - `services/`: Business logic.
  - `src/`: Models, providers, and other core functionality.
  - `styles/`: App-wide themes and styles.
- `rust/`: Rust code for the native library.
- `website/`: Docusaurus documentation website.
- `android/`, `ios/`, `linux/`, `macos/`, `windows/`: Platform-specific code.
- `scripts/`: Build and utility scripts.

## Rust API

Rust bindings live in rust/. That directory must contain only Flutter-facing bridge code layered on the [NAHPU Core API](https://github.com/nahpu/nahpu_api). Review that API first to understand available models and functions.

Include only:

- Wrapper functions and types exported via flutter_rust_bridge
- Glue: type conversions, error/result mapping, async helpers
- Minimal (de)serialization required for the bridge

Do not add core business logic, domain models, or substantial algorithms here. Contribute those to the NAHPU Core API repository, then update/regenerate the bindings in this project. This separation keeps codebases clean and enables reuse of core logic in other integrations (e.g., Python, R).

## Submitting Contributions

We use the fork-and-pull-request workflow.

1. **Fork** the repository on GitHub.
2. **Clone** your fork to your local machine.
3. Create a **new branch** for your changes.
4. **Make your changes** and commit them with clear messages.
5. **Push** your changes to your fork.
6. Open a **pull request** from your fork to the main Nahpu repository.

We appreciate contributions of all kinds, including bug fixes, new features, and documentation improvements.
