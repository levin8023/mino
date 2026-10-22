#!/bin/bash
# SPDX-License-Identifier: MIT
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
CONFIGURATION="${CONFIGURATION:-release}"
ARCH="${ARCH:-native}"
APP="$ROOT/build/Mino.app"
export CLANG_MODULE_CACHE_PATH="$ROOT/.build/clang-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$ROOT/.build/swift-cache"
mkdir -p "$ROOT/.build" "$ROOT/build"
ARGS=(--product Mino --configuration "$CONFIGURATION" --build-system native --disable-sandbox --cache-path "$ROOT/.build/cache" --config-path "$ROOT/.build/config" --security-path "$ROOT/.build/security")
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
if [[ "$ARCH" == "universal" ]]; then
    for TARGET_ARCH in arm64 x86_64; do
        swift build "${ARGS[@]}" --arch "$TARGET_ARCH"
        BIN_DIR="$(swift build "${ARGS[@]}" --arch "$TARGET_ARCH" --show-bin-path)"
        cp "$BIN_DIR/Mino" "$ROOT/build/Mino-$TARGET_ARCH"
    done
    lipo -create "$ROOT/build/Mino-arm64" "$ROOT/build/Mino-x86_64" -output "$APP/Contents/MacOS/Mino"
elif [[ "$ARCH" != "native" ]]; then
    echo "ARCH must be native or universal" >&2
    exit 1
else
    swift build "${ARGS[@]}"
    BIN_DIR="$(swift build "${ARGS[@]}" --show-bin-path)"
    cp "$BIN_DIR/Mino" "$APP/Contents/MacOS/Mino"
fi
cp Resources/Info.plist "$APP/Contents/Info.plist"
cp Resources/PrivacyInfo.xcprivacy "$APP/Contents/Resources/PrivacyInfo.xcprivacy"
swift -module-cache-path "$ROOT/.build/icon-cache" Scripts/generate-icon.swift "$ROOT/build/AppIcon.iconset"
iconutil -c icns "$ROOT/build/AppIcon.iconset" -o "$APP/Contents/Resources/AppIcon.icns"
plutil -lint "$APP/Contents/Info.plist" "$APP/Contents/Resources/PrivacyInfo.xcprivacy"
IDENTITY="${SIGN_IDENTITY:--}"
if [[ "$IDENTITY" == "-" ]]; then
    codesign --force --sign - "$APP"
else
    codesign --force --options runtime --timestamp --sign "$IDENTITY" "$APP"
fi
codesign --verify --strict --verbose=2 "$APP"
echo "Built: $APP ($ARCH)"
