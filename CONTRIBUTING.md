# Contributing to Nahpu

First off, thank you for considering contributing to Nahpu! It's people like you that make Nahpu such a great tool.

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

* [Flutter SDK](https://flutter.dev/docs/get-started/install) (see `pubspec.yaml` for version constraints)
* [Rust toolchain](https://www.rust-lang.org/tools/install)

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

3. **Build the Rust library:**
    The Rust library is in the `rust` directory. It is built using a helper package in `rust_builder`.

    ```sh
    cd rust_builder
    flutter pub get
    cd ..
    ```

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

## Project Structure

* `lib/`: Main application code.
  * `screens/`: UI for each screen.
  * `services/`: Business logic.
  * `src/`: Models, providers, and other core functionality.
  * `styles/`: App-wide themes and styles.
* `rust/`: Rust code for the native library.
* `website/`: Docusaurus documentation website.
* `android/`, `ios/`, `linux/`, `macos/`, `windows/`: Platform-specific code.
* `scripts/`: Build and utility scripts.

## Submitting Contributions

We use the fork-and-pull-request workflow.

1. **Fork** the repository on GitHub.
2. **Clone** your fork to your local machine.
3. Create a **new branch** for your changes.
4. **Make your changes** and commit them with clear messages.
5. **Push** your changes to your fork.
6. Open a **pull request** from your fork to the main Nahpu repository.

We appreciate contributions of all kinds, including bug fixes, new features, and documentation improvements.
