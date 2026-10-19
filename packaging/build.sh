#!/usr/bin/env bash
# Build the NAHPU .deb and .rpm from an existing Linux release bundle.
#
# Usage, from the repository root:
#   flutter build linux --release
#   packaging/build.sh
#
# The .rpm is signed only when NFPM_RPM_SIGNING_KEY points at an armored RSA
# private key, with its passphrase in NFPM_RPM_PASSPHRASE. Leave both unset
# for an unsigned local build.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

case "$(uname -m)" in
    x86_64 | amd64) arch="x86_64" flutter_arch="x64" nfpm_arch="amd64" ;;
    aarch64 | arm64) arch="arm64" flutter_arch="arm64" nfpm_arch="arm64" ;;
    *)
        echo "error: unsupported architecture $(uname -m)." >&2
        exit 1
        ;;
esac

bundle="build/linux/${flutter_arch}/release/bundle"
if [[ ! -x "${bundle}/nahpu" ]]; then
    echo "error: ${bundle}/nahpu not found. Run 'flutter build linux --release' first." >&2
    exit 1
fi

# cargo's release profile keeps debug info, so the library is roughly 45 MB
# until it is stripped.
if [[ -f "${bundle}/lib/librust_lib_nahpu.so" ]]; then
    strip --strip-unneeded "${bundle}/lib/librust_lib_nahpu.so"
fi

# Mirror how the release workflow derives both halves of the package version.
pubspec_version="$(awk '/^version:/ {print $2; exit}' pubspec.yaml)"
export NAHPU_VERSION="${NAHPU_VERSION:-${pubspec_version%%+*}}"
export NAHPU_BUILD_NUMBER="${NAHPU_BUILD_NUMBER:-${pubspec_version##*+}}"
export NFPM_RPM_SIGNING_KEY="${NFPM_RPM_SIGNING_KEY:-}"
export NFPM_ARCH="${nfpm_arch}"

# nfpm.yaml reads the bundle from a fixed path, since nFPM cannot expand
# variables in `src`.
rm -rf build/linux/package
mkdir -p build/linux/package
cp -a "${bundle}" build/linux/package/bundle

# Stable filenames, matching the release workflow and the download links on
# nahpu.app. The version stays in the package metadata.
mkdir -p dist
nfpm package -f packaging/nfpm.yaml -p deb -t "dist/nahpu-Linux-${arch}.deb"
nfpm package -f packaging/nfpm.yaml -p rpm -t "dist/nahpu-Linux-${arch}.rpm"

ls -lh dist
