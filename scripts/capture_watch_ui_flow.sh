#!/usr/bin/env bash
# Run on the Mac (not omarchy). Captures Watch Simulator UX for agents: PNG sequence + optional H.264 video.
#
# Usage:
#   ./scripts/capture_watch_ui_flow.sh
#   RECORD_VIDEO=1 ./scripts/capture_watch_ui_flow.sh
#   DESTINATION='platform=watchOS Simulator,name=Apple Watch Series 11 (42mm),OS=26.2' ./scripts/capture_watch_ui_flow.sh
#
# Requires: Xcode, watchOS Simulator; Homebrew `xcbeautify` recommended (prettier logs).
# Optional: `eval "$(brew shellenv)"` so `ffmpeg` / `xcbeautify` resolve (script does this for Homebrew).

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script must run on macOS (Xcode + Simulator)." >&2
  exit 1
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STAMP="$(date +%Y-%m-%d_%H%M%S)"
OUT="${OUT:-$ROOT/prayers/artifacts/ui-capture/$STAMP}"
mkdir -p "$OUT/screenshots"

export PRAYERS_UI_CAPTURE=1
export PRAYERS_UI_CAPTURE_DIR="$OUT/screenshots"

DESTINATION="${DESTINATION:-platform=watchOS Simulator,name=Apple Watch Series 11 (42mm),OS=26.2}"

pick_watch_udid() {
  xcrun simctl list devices available | sed -n '/Apple Watch Series 11 (42mm)/p' | grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}' | head -1
}

UDID="$(pick_watch_udid)"
if [[ -z "$UDID" ]]; then
  echo "Could not find Apple Watch Series 11 (42mm) simulator UDID." >&2
  exit 1
fi

echo "[capture] Output: $OUT"
echo "[capture] Watch UDID: $UDID"
echo "[capture] DESTINATION=$DESTINATION"

xcrun simctl boot "$UDID" 2>/dev/null || true
open -a Simulator 2>/dev/null || true

RECORD_PID=""
if [[ "${RECORD_VIDEO:-0}" == "1" ]]; then
  echo "[capture] Starting simctl recordVideo (SIGINT when tests finish)..."
  xcrun simctl io "$UDID" recordVideo --codec=h264 --force "$OUT/flow.mp4" 2>"$OUT/recordVideo.stderr.log" &
  RECORD_PID=$!
  sleep 3
fi

cd "$ROOT/prayers"

# Test target name in Xcode is "prayers Watch AppUITests" (spaces); class is prayers_Watch_AppUITests.
ONLY_TEST='-only-testing:prayers Watch AppUITests/prayers_Watch_AppUITests/testUIReferenceFlowCapture'

set +e
if command -v xcbeautify >/dev/null 2>&1; then
  xcodebuild test \
    -project prayers.xcodeproj \
    -scheme prayers-watch-uitests \
    -sdk watchsimulator \
    -destination "$DESTINATION" \
    "$ONLY_TEST" \
    CODE_SIGNING_ALLOWED=NO \
    -resultBundlePath "$OUT/ui-capture.xcresult" \
    2>&1 | tee "$OUT/xcodebuild.log" | xcbeautify
else
  xcodebuild test \
    -project prayers.xcodeproj \
    -scheme prayers-watch-uitests \
    -sdk watchsimulator \
    -destination "$DESTINATION" \
    "$ONLY_TEST" \
    CODE_SIGNING_ALLOWED=NO \
    -resultBundlePath "$OUT/ui-capture.xcresult" \
    2>&1 | tee "$OUT/xcodebuild.log"
fi
XC=$?
set -e

if [[ -n "${RECORD_PID:-}" ]]; then
  kill -INT "$RECORD_PID" 2>/dev/null || true
  wait "$RECORD_PID" 2>/dev/null || true
  if [[ -f "$OUT/flow.mp4" ]]; then
    echo "[capture] Video: $OUT/flow.mp4"
  fi
fi

if command -v ffmpeg >/dev/null 2>&1 && compgen -G "$OUT/screenshots/*.png" >/dev/null; then
  echo "[capture] Optional GIF (requires sorted PNGs):"
  echo "  ffmpeg -y -framerate 1 -pattern_type glob -i \"$OUT/screenshots/*.png\" -vf format=yuv420p \"$OUT/flow.gif\""
fi

echo "[capture] Screenshots: $OUT/screenshots/"
echo "[capture] xcodebuild exit: $XC"
exit "$XC"
