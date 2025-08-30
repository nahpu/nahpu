winget install -e --id LLVM.LLVM
cargo install flutter_rust_bridge_codegen@^2.11.1
cargo install cargo-ndk
rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android