# nahpu <img src="assets/web/nahpu-logo.svg" alt="nahpu logo" align="right" width="150"/>

[![Nahpu-Tests](https://github.com/hhandika/nahpu/workflows/Nahpu-Tests/badge.svg)](https://github.com/hhandika/nahpu/actions/workflows/test.yml)
[![LoC](https://tokei.rs/b1/github/hhandika/nahpu?category=code)](https://github.com/XAMPPRocky/tokei)
[![GitHub last commit](https://img.shields.io/github/last-commit/hhandika/nahpu)](https://github.com/hhandika/nahpu/commits/main)
[![GitHub license](https://img.shields.io/github/license/hhandika/nahpu)](https://github.com/hhandika/nahpu/blob/main/LICENSE)

NAHPU (NAtural History Project Utility) is a cross-platform application designed for cataloging ntiatural history specimens. It modernizes data recording and management for field and museum work.

Visit our website to learn more: [nahpu.app](https://nahpu.app).

## Getting Started

To get started with Nahpu, follow the installation instructions and first-use guidelines in the [Get Started](https://nahpu.app/get-started/).

## Key Features

- **Cross-Platform:** Use Nahpu on Android, iOS, Windows, macOS, and Linux.
- **Field and Museum Ready:** Designed for both field data collection and museum curation workflows.
- **Rich Data Capture:** Record a wide range of specimen data, including images, measurements, and collection details.
- **Data Export:** Export your data to CSV and other formats for use in other applications.
- **Offline First:** Works offline; we plan to allow syncing your data when you have an internet connection.

## Supported Catalog Formats

- Birds 🦅
- Mammals 🐿️
- Herpetofauna (in development) 🐍
- Fishes (in development) 🐠
- Paleo Vertebrates (planned) 🦣

Builds for other platforms are attached to each [release](https://github.com/nahpu/nahpu/releases).

## Technologies Used

The NAHPU project's main challenges are the multi-platform nature of the application and ensuring the app works under the constraint of mobile devices in remote field conditions. Some of key technologies used to overcome these challenges include:

- **[Flutter](https://flutter.dev/):** For the cross-platform user interface.
- **[Rust](https://www.rust-lang.org/):** For performance-critical native code, integrated with [Flutter Rust Bridge](https://cjycode.com/flutter_rust_bridge/).
- **[Drift](https://drift.simonbinder.eu/):** For the local [SQLite](https://www.sqlite.org/) project database.
- **[redb](https://www.redb.org/):** For user configuration and export preset storage through the NAHPU API.
- **[Riverpod](https://riverpod.dev/):** For state management.
- **[Typst](https://typst.app/):** For the template system that powers NAHPU document exports.

Many other open source libraries were used in the development of NAHPU. A full list of these libraries can be found in the app manifests in [NAHPU](https://github.com/nahpu/nahpu/) and [NAHPU_API](https://github.com/nahpu/nahpu_api/) repositories.

## Contributing

We welcome contributions from the community! Whether you're a developer, a designer, or a user, you can help make Nahpu better.

Please read our [CONTRIBUTING.md](CONTRIBUTING.md) file for details on how to get started with setting up the project and our contribution guidelines.

## License

Nahpu is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Acknowledgements

NAHPU is a collaborative project among museum and computer scientists. Many people have contributed code, feedback, translations, and field testing along the way. The full list of team members, past contributors, and acknowledgments is on the [NAHPU team page](/teams).

Funding and institutional support for this project are listed on the [NAHPU home page](/#funding).
