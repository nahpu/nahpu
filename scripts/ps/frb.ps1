Remove-Item -r ./lib/src/rust/api/frb_*
Remove-Item -r ./rust/src/frb_*

Write-Output "Cleaning Flutter build files"
flutter clean

Write-Output "Updating Rust dependencies"
Set-Location rust
cargo update
Set-Location ..

Write-Output "Updating FRB"
cargo install 'flutter_rust_bridge_codegen@^2.11.1'

Write-Output "Updating Dart dependencies"
flutter pub upgrade

Write-Output "Generating FRB for Dart"
flutter_rust_bridge_codegen generate

Write-Output "Running Dart fix"
dart fix --apply

Write-Output "Check Rust code"
Set-Location rust
cargo check
Set-Location ..