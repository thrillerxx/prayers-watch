# Agent environment — prayers-watch (watchOS)

This file is **in-repo** so anyone with the GitHub clone (including agents without omarchy access) knows how **builds, SSH, and audio** work.

## Canonical sources of truth

| What | Where |
| --- | --- |
| **Git / development** | `omarchy` Linux host, repo path **`/home/car/.openclaw/workspace/prayers-watch`** (or your local clone). |
| **Full tailnet + OpenClaw reference** | On omarchy: **`/home/car/.openclaw/workspace/OPENCLAW_ENVIRONMENT.md`** — section **§5 prayers-watch** and **MacBook Air** notes (updated over time). |

If something conflicts, prefer **`OPENCLAW_ENVIRONMENT.md`** on omarchy, then this file, then `README.md`.

## Apple Watch builds (MacBook Air)

Xcode and the **watchOS Simulator** run on **ThrillerX’s MacBook Air**, not on omarchy.

- **Tailscale IP:** `100.81.139.50`
- **SSH user:** `thrillerx` (not `car`)

```bash
ssh thrillerx@100.81.139.50
```

- **Repo on Mac:** `/Users/thrillerx/dev/prayers-watch`
- **Xcode:** App at `/Applications/Xcode.app` (CLI via `xcodebuild`).

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

## Homebrew on the Mac (`/opt/homebrew`)

In **non-interactive SSH**, `brew` and tools are **not** on `PATH` until:

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Then e.g. **`ffmpeg`**, **`rg`** (ripgrep), **`SwitchAudioSource`** are available.

**Verified 2026-04-12:** **ripgrep** is installed (`brew install ripgrep`); **BlackHole 2ch** exists as HAL driver **`BlackHole2ch.driver`** and as Cask **`blackhole-2ch`**.

## BlackHole and “hearing” audio

**BlackHole 2ch** is a **virtual audio device** on macOS. It lets you **route** or **record** system/simulator audio into tools like **ffmpeg**. It does **not** stream sound into Cursor or an LLM session.

To **verify** audio, produce a **file** on the Mac (e.g. `wav`/`mp3` under `/Users/thrillerx/dev/prayers-watch/artifacts/audio/` or a path you choose) and inspect duration/levels—or have a human listen locally.

## omarchy (this Linux machine)

- **`rg` (ripgrep)** is available on typical omarchy images (e.g. `/usr/bin/rg`).
- **Swift / Xcode** are **not** here; do watch builds on the Mac.

## Related docs

- `README.md` — open project, CLI build, signing, licensing.
- `docs/licensing/mass-responses-licensing.md` — Mass Responses text.
- `docs/design/mystery-art-ai-prompts.md` — mystery art + UI notes.
