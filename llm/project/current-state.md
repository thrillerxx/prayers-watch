Purpose: Canonical snapshot of Divinity Prayers Watch v1 — scope, RC, paths, behavior, and operational rules.

# Divinity Prayers Watch App — Current State

This project is a native Apple Watch app built in Swift / SwiftUI in Xcode. The app is focused on Rosary and prayer playback on watchOS, with a prayer library, spoken prayer flow, Auto mode, pacing controls, and a cleaner watch-first UI.

The current goal has been to get **v1 stable, readable, and reliable** on Apple Watch before adding anything bigger.

---

## What v1 Is

v1 is currently scoped as:

- **EN only**
- Deterministic prayer content loading
- Rosary flow with mysteries and core prayers
- Prayer Library with playable prayers
- Single active audio session
- Readable watch UI
- Basic automated watch UI coverage
- Release candidate tags pinned to known good commits

## What Is Explicitly Out of Scope for v1

- Spanish
- Mystery Picker redesign / day-based mystery defaults
- New schema expansion beyond what is already needed
- Big feature changes beyond stabilization and small UX polish

---

## Canonical Repo and Working Location

**Canonical repo/worktree:**

```
/home/car/dev/prayers-watch
```

This is the repo that should be treated as the **source of truth** going forward.

**Primary IDE / dev environment:** We use **Cursor** for this project now. Agents and runbooks should assume Cursor as the editing and agent context (not another IDE or workspace tool).

**Stale workspace (do not use):**

```
/home/car/.openclaw/workspace/prayers-watch
```

That older workspace was confirmed to be stale / wrong for current work and **should not be used** for active development.

---

## Current Validated RC Line

- **Tag:** `rosary-watch-en-final-ui-rc`
- **Commit:** `405490ed` (tag target)

That is the RC you should think of as the **current pinned baseline** for the project.

There are newer branches / older stale work references floating around; the safest thing is:

**Use the canonical repo at `/home/car/dev/prayers-watch` and pin to tag `rosary-watch-en-final-ui-rc` unless we intentionally decide to move forward from there.**

---

## Build Environment

This is a **macOS / Xcode** project targeting watchOS Simulator and real Apple Watch deployment.

**Core environment pieces:**

- Xcode on the MacBook Air
- watchOS Simulator
- Swift / SwiftUI
- Git / GitHub remote
- Tailscale access path to the MacBook Air
- OpenClaw / omarchy access used to orchestrate or SSH into the Mac environment

**Important operational detail:** The assistant/agent can only do Mac-specific work when it has an actual path to the Mac, either by:

- the Mac node being connected in OpenClaw, or
- SSH from omarchy to the MacBook Air

Mac-specific work (Xcode builds, simulator runs, audio capture, BlackHole setup) **must happen on the MacBook Air**.

---

## Project Structure and Important Files

**Canonical prayer content file:**

```
prayers/prayers Watch App/rosary_prayers_en.json
```

This is the main deterministic English content source for the Watch app.

**Important Swift files (stabilization and UI work):**

- `prayers/prayers Watch App/RosaryView.swift`
- `prayers/prayers Watch App/PrayerLibraryView.swift`
- `prayers/prayers Watch App/ContentView.swift`
- `prayers/prayers Watch App/AppSettings.swift`
- `prayers/prayers Watch App/SettingsView.swift`
- `prayers/prayers Watch App/RosaryScript.swift`
- `prayers/prayers Watch App/prayersApp.swift`

**UI test file:**

- `prayers Watch AppUITests/prayers_Watch_AppUITests.swift`

**Docs added during release prep:**

- Release doc and QA / release markdown in repo docs.

---

## Content State

**English content:** Complete in the canonical JSON. A placeholder/empty-string search on the canonical content file came back clean (BAD_COUNT = 0): no "...", "..", or empty strings where actual prayer text should be.

**Core prayers included:** Sign of the Cross, Apostles' Creed, Our Father, Hail Mary, Glory Be, Hail Holy Queen, Rosary Prayer, Fatima Prayer.

**Mystery sets:** Joyful, Luminous, Sorrowful, Glorious — each with 1–5 entries (title + meditation).

**Additional devotional prayers:** Memorare, Angelus, Act of Contrition, Eternal Rest.

**Library filtering:** The Prayer Library is intentionally filtered so metadata rows (mystery set titles, title-only metadata) do not show as selectable prayers.

---

## Playback and Audio Behavior

**Single audio session:** Only one prayer audio session can be active at a time. If the user starts another prayer while one is playing, the current one stops and the new one begins.

**Transport behavior:** Stop and Play/Pause controls were moved into the content area instead of crowding the top toolbar. Watch UI was simplified to reduce collisions and cramped layout; some redundant controls were removed.

**Rosary flow:** Progression works with Auto mode and pacing controls. To reduce race conditions when Auto mode was playing and the user tapped Next rapidly, the UI was simplified and **Next was removed from Rosary** to lower complexity. Silent Hail Mary counter is visible on screen during Hail Mary steps but is not spoken by TTS.

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

**Current key tag:** `rosary-watch-en-final-ui-rc` → `405490ed` — the most important checkpoint. Earlier RC tags exist for intermediate stabilization; unless bisecting, the final UI RC is the one that matters.

---

## Screenshots and Temporary Artifacts

Screenshots during UI test and polish work were commonly saved under `/tmp/screenshots/` (e.g. Rosary, prayer detail, home, library while playing, small/large watch). These are useful for review but `/tmp` is not permanent; preserve by copying into repo docs or a shared folder if needed.

---

## Audio Capture Status

**Current state:** Audio capture/export was **not yet completed** in the canonical flow. Blockers were operational (Mac node/access inconsistent, agent in wrong repo copies, capture not done on correct RC line). **Audio capture run / exported MP3 is still a next step**, not a completed deliverable.

---

## Where Things Are Saved

| What | Path |
|------|------|
| Canonical code and content | `/home/car/dev/prayers-watch` |
| Canonical English prayer JSON | `/home/car/dev/prayers-watch/prayers/prayers Watch App/rosary_prayers_en.json` |
| UI tests | `/home/car/dev/prayers-watch/prayers Watch AppUITests/prayers_Watch_AppUITests.swift` |
| Temporary logs/screenshots | `/tmp/uitest.log`, `/tmp/uitest-results.xcresult`, `/tmp/screenshots/...` |
| **Stale workspace (avoid)** | `/home/car/.openclaw/workspace/prayers-watch` |

---

## Where We Are Right Now

v1 is in a **strong RC state**:

- EN content is complete
- UI is much cleaner than before
- Rosary flow is simpler and more stable
- Library filtering is improved
- Single-session audio behavior is in place
- Headless watch UI tests are passing
- Final UI RC tag exists and is pinned

The most important thing is a **clean baseline** instead of chaos.

---

## What's Next

1. **Freeze v1 scope** — No Spanish, mystery picker redesign, or schema expansion right now.
2. **Run final real-device or simulator sanity pass** on the tagged RC: Rosary playback, Auto pacing, Back, Play/Pause, Stop, Library selection mid-playback, long text readability.
3. **Complete audio capture on the correct RC** — On MacBook Air, tag `rosary-watch-en-final-ui-rc` (commit `405490ed`), canonical repo; BlackHole or other audio routing on the Mac if needed.
4. **Preserve artifacts if needed** — Move screenshots, xcresults, or audio out of `/tmp`.
5. **Prepare distribution** — After final sanity checks, internal distribution / TestFlight prep.

---

## Recommended Instruction for Agents

- **Use** `/home/car/dev/prayers-watch`
- **Pin to** `rosary-watch-en-final-ui-rc` / `405490ed`
- **Do not** start Spanish
- **Do not** start Mystery Picker
- **Do not** work from stale workspace copies
- **Do not** drift into unrelated branches or older commits

---

## One-Line Summary

**Divinity Prayers Watch** is now at a stable EN-only Apple Watch RC, built in Swift/SwiftUI, with deterministic prayer content from `rosary_prayers_en.json`, cleaned-up watch UI, stable single-session prayer playback, passing headless watch UI tests, and the current pinned release candidate at **rosary-watch-en-final-ui-rc** → **405490ed**.
