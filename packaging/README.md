# Linux packaging

NAHPU ships three Linux artifacts on every `v*` tag: a `.tar.gz`, a `.deb`, and a signed `.rpm`,
plus a snap from a separate job. The `.deb` and `.rpm` are both produced by
[nFPM](https://nfpm.goreleaser.com) from the single `nfpm.yaml` in this directory.

## Layout

| File | Purpose |
| --- | --- |
| `nfpm.yaml` | The package definition for both formats. |
| `build.sh` | Builds both packages locally from an existing Flutter bundle. |
| `com.hhandika.nahpu.desktop` | Launcher entry. The snap uses `snap/gui/nahpu.desktop` instead, because its `Icon=` has to be snap-relative. |
| `com.hhandika.nahpu.metainfo.xml` | AppStream metadata, shared with the snap. Release notes live here. |
| `scripts/` | `postinstall` and `postremove` cache refreshes. |

The icon is shared with the snap at `snap/gui/nahpu.png` rather than duplicated here.

## Building locally

```sh
flutter build linux --release
packaging/build.sh
```

Packages land in `dist/` as `nahpu-Linux-x86_64.deb` and `nahpu-Linux-x86_64.rpm`. The filenames are
deliberately stable — nahpu.app links to them through `releases/latest/download/`, which cannot
resolve a versioned name. The version itself lives in the package metadata, where `dpkg -I` and
`rpm -qip` report it; `build.sh` derives it from `pubspec.yaml`, so `1.0.1+103` becomes version
`1.0.1`, package revision `103`.

To build a signed `.rpm`, point `NFPM_RPM_SIGNING_KEY` at an ASCII-armored private key and put its
passphrase in `NFPM_RPM_PASSPHRASE`. With both unset the `.rpm` is simply unsigned.

## Install layout

The Flutter runner is linked with `RPATH=$ORIGIN/lib` and finds `data/` through `/proc/self/exe`, so
the bundle is installed as one intact tree:

```
/opt/nahpu/{nahpu,data/,lib/}
/usr/bin/nahpu -> /opt/nahpu/nahpu
/usr/share/applications/com.hhandika.nahpu.desktop
/usr/share/icons/hicolor/512x512/apps/com.hhandika.nahpu.png
/usr/share/metainfo/com.hhandika.nahpu.metainfo.xml
```

Splitting the bundle across `/usr/bin` and `/usr/lib`, or copying the executable to `/usr/bin`
instead of symlinking it, breaks library and asset resolution.

Everything under `/opt/nahpu/lib` — `librust_lib_nahpu.so`, `libsqlite3.so`, `libpdfium.so`, the mdk
media libraries, `libc++.so.1` — is private to the bundle and never reaches a system linker path.

## Dependencies

Only the libraries the runner links directly are declared. `record_linux` additionally shells out to
`parecord` and `ffmpeg` by bare name, so both are needed for audio recording:

- **deb** — hard `Depends`, since `ffmpeg` and `pulseaudio-utils` are both in Debian and Ubuntu main.
- **rpm** — weak `Recommends`, since `ffmpeg` proper lives in RPM Fusion rather than Fedora and the
  media package names diverge across Fedora, RHEL, and openSUSE. A hard `Requires` would make the
  `.rpm` uninstallable on a stock Fedora system.

The deb declares GTK and GLib as `libgtk-3-0 | libgtk-3-0t64` alternations so one package installs
across both the pre- and post-`t64` naming eras.

## glibc floor

CI builds on `ubuntu-22.04`, which sets a glibc 2.35 floor: Ubuntu 22.04+, Debian 12+, Fedora 36+,
and RHEL/Rocky 9+. Building on a newer runner would bind the packages to a newer glibc and fail at
launch on those distributions with a loader error rather than a dependency error.
