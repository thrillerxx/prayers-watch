#!/usr/bin/env bash
# Run ON the MacBook Air (or via: ssh thrillerx@100.81.139.50 bash -s < scripts/mac_watch_46mm_run.sh)
set -euo pipefail
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

REPO="${MAC_REPO_DIR:-$HOME/dev/prayers-watch}"
WATCH_UDID="${WATCH_46MM_UDID:-E28019DD-F968-4087-8E1D-0A9DC2BA44D5}"
BUNDLE="com.divinityapp.prayers.watchkitapp"
DEST='platform=watchOS Simulator,name=Apple Watch Series 11 (46mm),OS=26.2'

cd "$REPO"
git fetch origin
git reset --hard origin/main

cd "$REPO/prayers"
APP_PATH="$REPO/prayers/build/Debug-watchsimulator/prayers Watch App.app"

xcodebuild -project prayers.xcodeproj \
  -target "prayers Watch App" \
  -sdk watchsimulator \
  -destination "$DEST" \
  CODE_SIGNING_ALLOWED=NO \
  -configuration Debug \
  clean build

xcrun simctl uninstall "$WATCH_UDID" "$BUNDLE" 2>/dev/null || true
xcrun simctl install "$WATCH_UDID" "$APP_PATH"
xcrun simctl launch "$WATCH_UDID" "$BUNDLE"

open -a Simulator
osascript -e 'tell application "Simulator" to activate' 2>/dev/null || true

# Simulator framebuffer (works over SSH); see docs/ui-capture.md — Manual screenshot
SHOT_DIR="$REPO/prayers/artifacts/mac-visible"
mkdir -p "$SHOT_DIR"
sleep 2
xcrun simctl io "$WATCH_UDID" screenshot "$SHOT_DIR/mac-watch-46mm-after-run.png"

echo "[mac_watch_46mm_run] done — $(git -C "$REPO" rev-parse --short HEAD)"
echo "[mac_watch_46mm_run] screenshot: $SHOT_DIR/mac-watch-46mm-after-run.png"
