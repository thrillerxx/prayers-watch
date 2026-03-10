# Prayers Watch (Divinity)

A watchOS (and companion iOS) app for Catholic prayers and guided Rosary. Built with Swift and SwiftUI. Project planning and conventions are in **`llm/`** — see [llm/project/setup.md](llm/project/setup.md) and [llm/project/project-overview.md](llm/project/project-overview.md).

## Current Scope (v1 RC)
- **In scope:** English-only prayer content, Rosary flow, prayer library playback, settings, watch-first UI polish, and baseline watch UI tests.
- **Out of scope:** Spanish localization, mystery picker redesign, and schema expansion beyond the current v1 data model.
- **Release baseline:** `rosary-watch-en-final-ui-rc` (peeled commit `21fde32`).

## Features
- **Rosary** — Guided Rosary with mysteries and steps; optional text-to-speech (play/pause/stop).
- **Prayer Library** — Browse prayers, read full text, and speak aloud with shared transport controls.
- **Settings** — User preferences (e.g. speech, display).
- **Watch-first** — Layout and interactions tuned for watchOS (marquee for long titles, compact controls).

## Open in Xcode
- **Project:** `prayers/prayers.xcodeproj`
- **Watch scheme:** `prayers Watch App`

## Run (watchOS Simulator)
1. Open `prayers/prayers.xcodeproj`.
2. Select scheme **prayers Watch App**.
3. Choose a Watch Simulator device.
4. Run (⌘R).

### CLI build
```bash
cd /home/car/dev/prayers-watch/prayers
xcodebuild -project prayers.xcodeproj -scheme "prayers Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm),OS=26.2' \
  -configuration Debug build
```
Adjust simulator `name` and `OS` to match your installed runtimes.

## Conventions and docs
- **Source of truth:** All project definition, phases, and runbooks live in **`llm/`** ([thrillerxx/new-project-boilerplate](https://github.com/thrillerxx/new-project-boilerplate)).
- **Local dev:** Full runbook in [llm/workflows/dev-env-local.md](llm/workflows/dev-env-local.md).
- **Agents:** See [AGENTS.md](AGENTS.md) for AI-assistant rules and project structure.

## Notes
- **Complications:** Require a Widget Extension target (WidgetKit) in Xcode.
- **Real device:** Requires signing and a paired Apple Watch.
- **TTS:** On Simulator, speech may be muted; test on device for reliable audio.
