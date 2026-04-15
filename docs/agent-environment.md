# Agent environment — prayers-watch (watchOS)

This file is **in-repo** so anyone with the GitHub clone knows how **builds, SSH, and audio** work. **Do not** put private hostnames, VPN IPs, or personal home-directory paths in this repo—keep those in local shell config or a private notes doc.

## Canonical sources of truth

| What | Where |
| --- | --- |
| **Git / development** | Your clone of this repository (any path). |
| **Private infra** | If you use a shared Linux + Mac setup, keep SSH targets, Tailscale IPs, and non-portable paths in **local** documentation (not committed here). |

If something conflicts, prefer **`README.md`**, then this file.

## Apple Watch builds (macOS)

Xcode and the **watchOS Simulator** run on **macOS**, not on Linux CI unless you provide your own runners.

- **SSH:** use your own `user@host` (e.g. Tailscale MagicDNS, or `hostname.local`).
- **Repo on Mac:** common convention is `~/dev/prayers-watch` (override with `MAC_REPO_DIR` when using `scripts/remote_mac_xcode.sh`).
- **Xcode:** `/Applications/Xcode.app` (CLI via `xcodebuild`).

### Why `-sdk watchsimulator` matters

Plain `xcodebuild` without **`-sdk watchsimulator`** can emit a **`Debug-watchos`** (device) product while you point `-destination` at the Simulator. Use **watchsimulator** when installing to the Simulator. See `scripts/remote_mac_xcode.sh`.

### Example CLI build (Simulator, no signing)

```bash
cd prayers
xcodebuild -project prayers.xcodeproj \
  -target "prayers Watch App" \
  -sdk watchsimulator \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (42mm)' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Install the app from **`prayers/build/Debug-watchsimulator/prayers Watch App.app`** with `xcrun simctl install` / `launch`, or run from Xcode.

### UI/UX capture for agents (screenshots + video)

Agents without a GUI cannot see the Simulator. To produce **PNGs + optional mp4** on the Mac:

- **Runbook:** `docs/ui-capture.md`
- **Script:** `scripts/capture_watch_ui_flow.sh` (run on the Mac; sets `PRAYERS_UI_CAPTURE=1` and writes under `prayers/artifacts/ui-capture/<timestamp>/`).
- **Tools:** `xcodebuild` + UITest `testUIReferenceFlowCapture`; optional `RECORD_VIDEO=1` uses `xcrun simctl io <UDID> recordVideo`; **`xcbeautify`** (`brew install xcbeautify`) for readable logs; **`ffmpeg`** optional for GIFs from PNGs.
- Sync artifact folders back to your dev machine (e.g. `scp`) if an agent should inspect images in the workspace.

## Homebrew on the Mac (`/opt/homebrew`)

In **non-interactive SSH**, `brew` and tools are **not** on `PATH` until:

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Then e.g. **`ffmpeg`**, **`rg`** (ripgrep), **`SwitchAudioSource`** are available.

## BlackHole and “hearing” audio

**BlackHole 2ch** is a **virtual audio device** on macOS. It lets you **route** or **record** system/simulator audio into tools like **ffmpeg**. It does **not** stream sound into Cursor or an LLM session.

To **verify** audio, produce a **file** on the Mac (e.g. `wav`/`mp3` under your repo’s `artifacts/audio/` or a path you choose) and inspect duration/levels—or have a human listen locally.

## Linux dev hosts

- **`rg` (ripgrep)** is often available.
- **Swift / Xcode** are **not** typical on Linux; do watch builds on macOS.

## Related docs

- `README.md` — open project, CLI build, signing, licensing.
- `docs/ui-capture.md` — Simulator screenshot/video capture for UX review.
- `docs/licensing/mass-responses-licensing.md` — Mass Responses text.
- `docs/design/mystery-art-ai-prompts.md` — mystery art + UI notes.
