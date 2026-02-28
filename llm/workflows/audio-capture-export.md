Purpose: Runbook for capturing and exporting prayer audio from Divinity Prayers Watch v1 on the designated macOS development machine.

# Audio Capture + Export (RC)

## Goal
Produce clean exported audio files (e.g. MP3/WAV) for selected prayers / Rosary steps from the pinned RC baseline.

## Preconditions
- Must be executed on the designated **macOS development machine** (Xcode + simulator/route audio).
- Canonical repo: this repository root.
- Check out the pinned RC tag/commit.
- Decide capture target:
  - Simulator audio capture, or
  - Real-device capture (harder, but sometimes cleaner).

## 0) Baseline confirmation
From repo root:
- `git status -sb` (must be clean)
- `git describe --tags --always --dirty`
- `git rev-parse HEAD`

Record tag + SHA in the export folder name.

## 1) Pick capture method
### Option A — System audio routing (recommended)
Use a virtual audio device (e.g. BlackHole) to route app audio to a recorder.

Tools you can use:
- BlackHole (2ch)
- QuickTime Player (New Audio Recording)
- Audacity

High-level:
1. Install/enable BlackHole.
2. Set macOS audio output to a Multi-Output Device (Speakers + BlackHole) or route app audio appropriately.
3. Record via QuickTime/Audacity from the BlackHole input.

### Option B — Screen recording
Use Simulator screen recording if acceptable.

Tradeoff:
- Fast, but may include UI sounds/notifications and is harder to isolate clean audio.

## 2) Recording procedure
1. Launch app (Simulator or device).
2. Navigate to the target prayer.
3. Start recording.
4. Start playback.
5. Let it complete (or capture a known segment).
6. Stop recording.

## 3) Export + naming
Create an export folder (example):
- `artifacts/audio/<YYYY-MM-DD>/<tag-or-sha>/`

Export conventions:
- Use kebab-case filenames.
- Include language and prayer id/name.

Examples:
- `en-our-father.mp3`
- `en-hail-mary.mp3`
- `en-glory-be.mp3`

## 4) Post-processing (minimal)
- Trim leading/trailing silence.
- Normalize to a consistent loudness if needed.
- Avoid heavy noise reduction unless required.

## 5) Verification checklist
- No clipping
- No background system audio
- No double-play / overlapping sessions
- Duration matches expected spoken text

## 6) Preserve artifacts
Do **not** leave final outputs only in `/tmp`.
- Put final audio under `artifacts/audio/...`
- If you also generated screen recordings, save them under `artifacts/video/...`

## Output (what to report back)
- Baseline tag/SHA
- Capture method used
- Export folder path
- List of exported files
- Any issues (routing, drift, artifacts)
