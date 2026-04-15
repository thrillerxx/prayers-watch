#!/usr/bin/env bash
# Run ON the MacBook Air (or via: ssh user@mac bash -s < scripts/mac_watch_42mm_run.sh)
# Syncs to origin/main first (same as mac_watch_46mm_run.sh) so builds aren’t stale.
set -euo pipefail
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

REPO="${MAC_REPO_DIR:-$HOME/dev/prayers-watch}"
WATCH_UDID="${WATCH_42MM_UDID:-4A9C74D0-B1B4-4A3E-8F7F-04311C57BE53}"
BUNDLE="com.divinityapp.prayers.watchkitapp"
DEST='platform=watchOS Simulator,name=Apple Watch Series 11 (42mm),OS=26.2'

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

xcrun simctl boot "$WATCH_UDID" 2>/dev/null || true
xcrun simctl uninstall "$WATCH_UDID" "$BUNDLE" 2>/dev/null || true
xcrun simctl install "$WATCH_UDID" "$APP_PATH"
xcrun simctl launch "$WATCH_UDID" "$BUNDLE"

open -a Simulator
osascript -e 'tell application "Simulator" to activate' 2>/dev/null || true

SHOT_DIR="$REPO/prayers/artifacts/mac-visible"
mkdir -p "$SHOT_DIR"
sleep 2
xcrun simctl io "$WATCH_UDID" screenshot "$SHOT_DIR/mac-watch-42mm-after-run.png"

echo "[mac_watch_42mm_run] done — $(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo 'no-git')"
echo "[mac_watch_42mm_run] screenshot: $SHOT_DIR/mac-watch-42mm-after-run.png"
