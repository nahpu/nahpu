#!/bin/sh
# Refresh the desktop and icon caches so the launcher entry appears without a
# session restart. Both tools are optional: a headless install has neither, and
# dpkg triggers or rpm file triggers already cover the desktop environments
# that ship them.
set -e

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications || true
fi

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
fi
