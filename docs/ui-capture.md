# Watch UI capture for agents (screenshots + video)

Use this when you need **visual evidence** of Simulator UX (flows, regressions, design review). The agent on **omarchy** cannot see your screen; artifacts must be **files** (PNGs, mp4) on the **Mac** or synced back to the repo.

## Requirements (MacBook Air)

- Xcode + watchOS Simulator (same as `docs/agent-environment.md`).
- Repo path: `/Users/thrillerx/dev/prayers-watch`.
- **Homebrew** on `PATH` (non-interactive SSH):

  ```bash
  eval "$(/opt/homebrew/bin/brew shellenv)"
  ```

- Recommended: **`xcbeautify`** — `brew install xcbeautify` (cleaner `xcodebuild` logs).
- Optional: **`ffmpeg`** — `brew install ffmpeg` (GIF assembly from PNGs).

## One-command capture

From the **Mac** (Terminal or SSH session with GUI / Simulator available):

```bash
cd /Users/thrillerx/dev/prayers-watch
git pull origin main
chmod +x scripts/capture_watch_ui_flow.sh
./scripts/capture_watch_ui_flow.sh
```

Output directory:

- `prayers/artifacts/ui-capture/<timestamp>/screenshots/*.png` — ordered frames (`01_home_divinity`, …).
- `prayers/artifacts/ui-capture/<timestamp>/xcodebuild.log`
- `prayers/artifacts/ui-capture/<timestamp>/ui-capture.xcresult` — test bundle.

### Video (Simulator display)

```bash
RECORD_VIDEO=1 ./scripts/capture_watch_ui_flow.sh
```

Produces `flow.mp4` (H.264) via `xcrun simctl io <Watch-UDID> recordVideo` for the **Apple Watch Series 11 (42mm)** simulator. Recording stops when the test run ends (script sends SIGINT to finalize the movie).

### Environment variables (UITest)

| Variable | Purpose |
| --- | --- |
| `PRAYERS_UI_CAPTURE=1` | Enables `testUIReferenceFlowCapture` (otherwise skipped in full test runs). |
| `PRAYERS_UI_CAPTURE_DIR` | Directory for PNGs; the script sets this under `artifacts/ui-capture/`. |

Other UITests still write to `/tmp/screenshots` unless `PRAYERS_UI_CAPTURE_DIR` is set (when set, **all** `writeScreenshot` calls in that process use it).

## Optional: GIF from PNGs

After capture, on the Mac with `ffmpeg`:

```bash
ffmpeg -y -framerate 1 -pattern_type glob -i 'prayers/artifacts/ui-capture/<stamp>/screenshots/*.png' \
  -vf format=yuv420p prayers/artifacts/ui-capture/<stamp>/flow.gif
```

## Manual screenshot (no test)

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
UDID=$(xcrun simctl list devices booted | grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}' | head -1)
xcrun simctl io "$UDID" screenshot /tmp/watch.png
```

## Keeping docs in sync

Update **`docs/agent-environment.md`** and omarchy **`OPENCLAW_ENVIRONMENT.md`** (§5 prayers-watch) when capture paths or prerequisites change.
