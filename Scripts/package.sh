#!/bin/bash
# SPDX-License-Identifier: MIT
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
./Scripts/build.sh
VERSION="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' Resources/Info.plist)"
ARCH="${ARCH:-native}"
if [[ "$ARCH" == "native" ]]; then ARCH="$(uname -m)"; fi
mkdir -p dist
NAME="Mino-$VERSION-$ARCH"
ditto -c -k --sequesterRsrc --keepParent build/Mino.app "dist/$NAME.zip"
(
    cd dist
    shasum -a 256 "$NAME.zip" > "$NAME.zip.sha256"
)
echo "Packaged: dist/$NAME.zip"
