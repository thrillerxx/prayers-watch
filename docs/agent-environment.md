# Agent environment — prayers-watch (watchOS)

This file is **in-repo** so anyone with the GitHub clone knows how **builds and audio** work. **Do not** put private hostnames, VPN IPs, or personal home-directory paths in this repo.

If something conflicts, prefer **`AGENTS.md`**, then `llm/workflows/github-airgap.md`, then this file.

## Canonical sources of truth

| What | Where |
| --- | --- |
| **Git / development** | This repository. On Omarchy: `/home/car/.openclaw/workspace/prayers-watch`. |
| **Handoff** | Push from Omarchy → GitHub → operator pulls on the Mac. |
| **Private infra** | SSH targets, Tailscale IPs, and non-portable paths stay in **local** notes, not here. |

## Daily loop

See `llm/workflows/github-airgap.md`. Agents do **not** SSH to the personal MacBook Pro. GitHub Actions (`.github/workflows/xcode-watch-ci.yml`) is the agent-visible Simulator check.

Optional `scripts/remote_mac_xcode.sh` is only for a **dedicated** Apple builder the operator names. Never point `MAC_HOST` at the personal laptop. See `llm/workflows/omarchy-mac-loop.md`.

## Apple Watch builds (macOS)

Xcode and the **watchOS Simulator** run on **macOS** (the operator Mac after `git pull`).

- **Repo on Mac:** common convention is `~/dev/prayers-watch`.
- **Xcode:** `/Applications/Xcode.app` (CLI via `xcodebuild`).

### Why `-sdk watchsimulator` matters

Plain `xcodebuild` without **`-sdk watchsimulator`** can emit a **`Debug-watchos`** (device) product while you point `-destination` at the Simulator. Use **watchsimulator** when installing to the Simulator.

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

Agents without a GUI cannot see the Simulator. Produce **PNGs + optional mp4** on the Mac, then commit or copy artifacts into the repo if the agent should inspect them:

- **Runbook:** `docs/ui-capture.md`
- **Script:** `scripts/capture_watch_ui_flow.sh` (run on the Mac; sets `PRAYERS_UI_CAPTURE=1` and writes under `prayers/artifacts/ui-capture/<timestamp>/`).
- **Tools:** `xcodebuild` + UITest `testUIReferenceFlowCapture`; optional `RECORD_VIDEO=1` uses `xcrun simctl io <UDID> recordVideo`; **`xcbeautify`** (`brew install xcbeautify`) for readable logs; **`ffmpeg`** optional for GIFs from PNGs.

Do not `scp` artifacts off the personal laptop from Omarchy.

## Homebrew on the Mac (`/opt/homebrew`)

In a **non-interactive** Mac shell, `brew` and tools are **not** on `PATH` until:

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Then e.g. **`ffmpeg`**, **`rg`** (ripgrep), **`SwitchAudioSource`** are available.

## BlackHole and “hearing” audio

**BlackHole 2ch** is a **virtual audio device** on macOS. It lets you **route** or **record** system/simulator audio into tools like **ffmpeg**. It does **not** stream sound into Cursor or an LLM session.

To **verify** audio, produce a **file** on the Mac (e.g. `wav`/`mp3` under `artifacts/audio/`) and inspect duration/levels—or have a human listen locally.

## Linux dev hosts

- **`rg` (ripgrep)** is often available.
- **Swift / Xcode** are **not** typical on Linux; do watch builds on macOS.

## Related docs

- `AGENTS.md` — agent operating rules and daily loop.
- `llm/workflows/README.md` — GitHub air gap, real-device install/QA.
- `README.md` — open project, CLI build, signing, licensing.
- `docs/ui-capture.md` — Simulator screenshot/video capture for UX review.
- `docs/licensing/mass-responses-licensing.md` — Mass Responses text.
- `docs/design/mystery-art-ai-prompts.md` — mystery art + UI notes.
