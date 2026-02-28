Purpose: Step-by-step sanity pass checklist for Divinity Prayers Watch v1 on the pinned RC line.

# v1 Sanity Pass (RC)

## Preconditions
- Canonical repo: this repository root.
- Check out the pinned RC tag/commit (do not run this on a random HEAD unless explicitly intended).
- Use Xcode on the designated macOS development machine.

## 0) Confirm you are on the correct baseline
From repo root:
- `git status -sb` (must be clean)
- `git describe --tags --always --dirty`
- `git rev-parse HEAD`

Record:
- tag (if any)
- commit SHA
- date (`git log -1 --format=%ci`)

## 1) Build + launch (Simulator)
1. Open the Xcode workspace/project.
2. Select an Apple Watch simulator target (at minimum: 40mm + 49mm if available).
3. Build & Run.

Pass criteria:
- App launches without crash.
- First render occurs < 5s.

## 2) Rosary flow (manual)
### Entry
- Open Rosary.
- Confirm nav title and step title are readable on both 40mm and 49mm.

### Playback
- Start playback.
- Verify Play/Pause toggles correctly.
- Verify Stop stops and resets expected UI state.

### Auto mode + pacing
- Enable Auto mode.
- Try at least two speech speed presets.
- Adjust pause-between-parts (if present).

Pass criteria:
- No overlapping speech.
- No stuck state when toggling Play/Pause repeatedly.
- Step progression in Auto mode feels deliberate (no rapid skipping).

### Navigation
- Back out of Rosary and re-enter.

Pass criteria:
- State resets or resumes as intended (document observed behavior).

## 3) Prayer Library (manual)
- Open Prayer Library.
- Confirm metadata-only rows are not selectable (filtering).
- Start a prayer.
- While it is playing, start a different prayer.

Pass criteria:
- Only one active session: starting a new prayer stops the previous one.
- UI remains readable and controls do not collide.

## 4) Settings (manual)
- Open Settings.
- Change speech speed.
- Return to Rosary/Library and confirm behavior reflects settings.

Pass criteria:
- Settings persist for the session (and across app relaunch if expected).

## 5) Automated watch UI tests
Run the UI tests target.

Pass criteria:
- Tests pass.
- If tests write screenshots to `/tmp/screenshots`, preserve any new useful ones.

## 6) Artifact preservation
If anything is saved under `/tmp` (screenshots, xcresult):
- Copy into a durable location (e.g. repo `docs/` or a timestamped folder under `artifacts/`).

## Output (what to report back)
- Baseline: tag/commit/date
- Simulator devices used
- Pass/fail summary per section
- Any screenshots or logs saved + their paths
