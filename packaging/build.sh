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

bundle="build/linux/x64/release/bundle"
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

mkdir -p dist
nfpm package -f packaging/nfpm.yaml -p deb \
    -t "dist/nahpu_${NAHPU_VERSION}-${NAHPU_BUILD_NUMBER}_amd64.deb"
nfpm package -f packaging/nfpm.yaml -p rpm \
    -t "dist/nahpu-${NAHPU_VERSION}-${NAHPU_BUILD_NUMBER}.x86_64.rpm"

ls -lh dist
