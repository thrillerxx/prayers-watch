Purpose: Canonical snapshot of Divinity Prayers Watch v1 — scope, tags, paths, behavior, and operational rules.

# Divinity Prayers Watch App — Current State

This project is a native Apple Watch app built in Swift / SwiftUI in Xcode. The app is focused on Rosary and prayer playback on watchOS, with a prayer library, Mass Responses, spoken prayer flow, Auto mode, pacing controls, and a cleaner watch-first UI.

v1 is **stable enough to iterate on `main`**. Small UX / product updates are in scope when assigned. Spanish, mystery-picker redesign, and schema expansion stay out unless explicitly assigned.

---

## What v1 Is

v1 is currently scoped as:

- **EN only**
- Deterministic prayer content loading
- Rosary flow with mysteries and core prayers
- Prayer Library with playable prayers
- Mass Responses (ICEL; app stays free)
- Single active audio session
- Readable watch UI, including liked Rosary now-playing cover layout
- Basic automated watch UI coverage
- Tags for liked layout and older RC snapshots

## What Is Explicitly Out of Scope for v1

- Spanish
- Mystery Picker redesign / day-based mystery defaults
- New schema expansion beyond what is already needed
- Big feature changes beyond stabilization and small UX polish

---

## Canonical Repo and Working Location

**Canonical repo/worktree:**

On Omarchy: `/home/car/.openclaw/workspace/prayers-watch`. GitHub `thrillerxx/prayers-watch` is the handoff.

**Primary IDE / dev environment:** **Cursor** on Omarchy for edits. Xcode on the operator Mac after a GitHub pull.

**Stale workspace (do not use):** older duplicate clones or archived copies of this project on any machine—verify `git remote` and `main` before working.

---

## Current Line vs Regression Snapshots

- **Develop on:** `main` (GitHub `thrillerxx/prayers-watch`).
- **Liked now-playing layout:** tag `rosary-nowplaying-liked` → `ad3bf36` (46mm Simulator layout the operator liked).
- **Older RC (regression only):** tag `rosary-watch-en-final-ui-rc` → peeled commit `21fde32` (annotated tag object `405490ed` — do not use as the code baseline).

**Baseline decision:**
- Daily work continues on `main`.
- Use `rosary-watch-en-final-ui-rc` / `21fde32` only when comparing against the March 2026 RC.
- Do not treat the RC tag as a freeze on current Watch UI.

Handoff is GitHub only (`llm/workflows/github-airgap.md`). Agents do not SSH to the personal MacBook Pro.

---

## Build Environment

This is a **macOS / Xcode** project targeting watchOS Simulator and real Apple Watch deployment.

**How work is split:**

- **Omarchy (Linux):** edit, git, docs. Never Xcode, Simulator, or a macOS VM.
- **GitHub:** source of truth. Push from Omarchy; pull on the Mac.
- **MacBook Pro (operator):** Xcode, Simulator, signing, install to the paired iPhone + Watch.
- **GitHub Actions** (`.github/workflows/xcode-watch-ci.yml`): agent-visible Simulator build/test. Not a device install.

Agents do **not** SSH, `scp`, or run `scripts/remote_mac_xcode.sh` against the personal laptop. There is no dedicated builder Mac unless the operator names one. See `AGENTS.md` and `llm/workflows/github-airgap.md`.

**Core environment pieces:**

- Xcode on the operator Mac
- watchOS Simulator
- Swift / SwiftUI
- Git / GitHub remote

The assistant cannot run Xcode. Simulator, device install, and audio capture happen on the operator Mac after a GitHub pull. Do not SSH to that laptop.

---

## Project Structure and Important Files

**Canonical prayer content file:**

```
prayers/prayers Watch App/rosary_prayers_en.json
```

This is the main deterministic English content source for the Watch app.

**Important Swift files:**

- `prayers/prayers Watch App/RosaryView.swift` — mystery picker + now-playing (no `VideoPlayer`)
- `prayers/prayers Watch App/RosarySessionController.swift` — rosary state that survives navigation
- `prayers/prayers Watch App/SpeechManager.swift` — single TTS session
- `prayers/prayers Watch App/PrayerLibraryView.swift`
- `prayers/prayers Watch App/MassResponsesView.swift`
- `prayers/prayers Watch App/ContentView.swift` — home: Rosary, Library, Mass Responses, Settings
- `prayers/prayers Watch App/AppSettings.swift` / `SettingsView.swift`
- `prayers/prayers Watch App/RosaryScript.swift`
- `prayers/prayers Watch App/prayersApp.swift` / `AppShell`

**UI test file:**

- `prayers Watch AppUITests/prayers_Watch_AppUITests.swift`

**Docs added during release prep:**

- Release doc and QA / release markdown in repo docs.

---

## Content State

**English content:** Complete in the canonical JSON. A placeholder/empty-string search on the canonical content file came back clean (BAD_COUNT = 0): no "...", "..", or empty strings where actual prayer text should be.

**Core prayers included:** Sign of the Cross, Apostles' Creed, Our Father, Hail Mary, Glory Be, Hail Holy Queen, Rosary Prayer, Fatima Prayer.

**Mystery sets:** Joyful, Luminous, Sorrowful, Glorious — each with 1–5 entries (announce + title + meditation) matching the Complete Rosary Prayer Guide. One set per session. Sunday defaults to Glorious except Advent/Lent (Sorrowful).

**Additional devotional prayers:** Memorare, Angelus, Act of Contrition, Eternal Rest.

**Library filtering:** The Prayer Library hides mystery-set metadata, titles, and announce rows so they are not selectable as standalone prayers.

---

## Playback and Audio Behavior

**Single audio session:** Only one prayer audio session can be active at a time. If the user starts another prayer while one is playing, the current one stops and the new one begins.

**Transport behavior:** Stop and Play/Pause controls were moved into the content area instead of crowding the top toolbar. Watch UI was simplified to reduce collisions and cramped layout; some redundant controls were removed.

**Rosary flow:** One mystery set per session, following the Complete Rosary Prayer Guide: opening prayers; five decades (announce, reflect, Our Father, ten Hail Marys, Glory Be, optional Fatima); Hail Holy Queen; concluding prayer; Sign of the Cross. Auto mode and speech-speed / pause settings still pace TTS. Decade Hail Marys can show a silent `1/10` counter (not spoken). Prev / play / next are on the now-playing transport.

**Settings and pacing:** Speech speed presets and pause-between-parts give Rosary playback more deliberate pacing in Auto mode. Speech speed options were made more distinct (including a slower option) during UI/pacing passes.

---

## UI and UX Work Completed

**Problems fixed over time:** Top bar overlap; toolbar icon/title collisions; scrunched transport controls; prayer detail text fighting with controls; Rosary controls taking too much vertical space; Prayer Library transport in awkward ways; duplicate/redundant UI (e.g. bottom Speak/Pause after top transport); "Rosary" and other extra labels; "Change Mystery" taking space when Back was enough.

**Current design direction:** Keep nav title; make controls smaller and more compact; move transport into the content area where needed; reduce redundant text; keep readability first on small watches; use simpler button layouts that fit 40mm and 49mm.

---

## Automated Testing Status

Headless watch UI tests were added and improved. They give basic automated proof that the app launches and important flows remain alive after UI changes. UI tests were strengthened to assert more than simple navigation and were updated as layout and control changes evolved.

**Current status:** Headless watch UI tests were passing on the current stabilized line during the final polish phase.

---

## Important Commits and Tags

**Current key tag:** `rosary-watch-en-final-ui-rc` → `21fde32` — the most important checkpoint. (Note: the annotated tag object SHA is `405490ed`, but the code baseline is the peeled commit `21fde32`.) Earlier RC tags exist for intermediate stabilization; unless bisecting, the final UI RC is the one that matters.

---

## Screenshots and Temporary Artifacts

Screenshots during UI test and polish work were commonly saved under a temporary screenshots directory. These are useful for review but temp storage is not permanent; preserve by copying into repo docs or a shared folder if needed.

---

## Audio Capture Status

**Current state:** Audio capture/export was **not yet completed** in the canonical flow. Blockers were operational (Mac node/access inconsistent, agent in wrong repo copies, capture not done on correct RC line). **Audio capture run / exported MP3 is still a next step**, not a completed deliverable.

---

## Where Things Are Saved

| What | Path |
|------|------|
| Canonical code and content | This repository (clone root) |
| Canonical English prayer JSON | `prayers/prayers Watch App/rosary_prayers_en.json` |
| UI tests | `prayers Watch AppUITests/prayers_Watch_AppUITests.swift` |
| Temporary logs/screenshots | `/tmp` and repo-local temp outputs unless explicitly preserved |
| **Stale workspace (avoid)** | Old duplicate paths on disk; always confirm you are in the intended clone. |

---

## Where We Are Right Now

v1 is **shippable-enough to iterate**:

- EN content is complete; Mass Responses is on the home screen
- Rosary now-playing cover layout is tagged `rosary-nowplaying-liked` (`ad3bf36`)
- Library filtering, single-session TTS, and headless watch UI tests are in place
- Daily loop is GitHub air gap (Omarchy edit → operator Mac / Watch)

Work continues on `main`. The March RC tag is for regression, not a freeze.

---

## What's Next

1. **Stay EN-only** — No Spanish, mystery picker redesign, or schema expansion unless assigned. Small UX / product updates on `main` are allowed when the operator asks.
2. **Daily loop** — `llm/workflows/github-airgap.md`: push from Omarchy, operator pulls SHA on the MacBook Pro, run Xcode / Watch, send notes back.
3. **Real-device install / QA** when hardware is in play — `llm/workflows/real-device-install.md` and `real-device-qa.md`. Watch stays paired to the daily-driver iPhone.
4. **Audio capture** still outstanding on the Mac (`llm/workflows/audio-capture-export.md`).
5. **Distribution** — TestFlight / internal after device QA on the current `main` line.

---

## Recommended Instruction for Agents

- **Use** `/home/car/.openclaw/workspace/prayers-watch` and `AGENTS.md`
- **Develop on** `main`; liked layout `rosary-nowplaying-liked` / `ad3bf36`; RC `21fde32` only for regression
- **Do not** start Spanish or Mystery Picker redesign
- **Do not** work from stale duplicate workspace copies
- **Do not** run Xcode or Simulator on Omarchy
- **Do not** SSH to the personal MacBook Pro
- **Do not** add `VideoPlayer` to `AppShell` / `RosaryView`

---

## One-Line Summary

**Divinity Prayers Watch** is an EN-only Apple Watch + iOS companion app (Swift/SwiftUI) with `rosary_prayers_en.json`, Mass Responses, single-session TTS, and a liked Rosary now-playing layout. Develop on **`main`**. Daily loop: **GitHub air gap**. Liked tag: **rosary-nowplaying-liked** → **ad3bf36**.
