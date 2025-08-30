#!/opt/homebrew/bin/fish

set DART_FRB "lib/src/rust/frb_generated.dart"
set DART_FRB_IO "lib/src/rust/frb_generated.io.dart"
set DART_FRB_WEB "lib/src/rust/frb_generated.web.dart"
set RUST_FRB_IO "rust/src/frb_generated.io.rs"
set RUST_FRB "rust/src/frb_generated.rs"
set RUST_FRB_WEB "rust/src/frb_generated.web.rs"

echo "Removing old FRB files"
rm -f $DART_FRB $DART_FRB_IO $DART_FRB_WEB $RUST_FRB $RUST_FRB_IO $RUST_FRB_WEB

echo "Cleaning up flutter project"
flutter clean

echo "Updating Rust dependencies"
cd rust
cargo update
cd ..

echo "Updating FRB"
cargo install 'flutter_rust_bridge_codegen@^2.11.1'

echo "Updating Dart dependencies"
flutter pub upgrade

echo "Generating FRB for Dart"
flutter_rust_bridge_codegen generate

echo "Running Dart fix"
dart fix --apply

echo "Checking Rust code"
cd rust
cargo check
cd ..