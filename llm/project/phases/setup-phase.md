Purpose: Setup phase — barebones but running watchOS/iOS app with minimal tooling and a thin vertical slice.

# Setup Phase

## Goals
- Establish the Xcode project, watch and iOS targets, and a minimal runnable app.
- Ship a thin vertical slice: open app → navigate to one screen (e.g. Rosary or Prayer Library) and see content or placeholder.
- Document the initial structure and conventions in `llm/` and README.

## Inputs
- `llm/project/project-overview.md`
- `llm/project/user-flow.md`
- `llm/project/tech-stack.md`
- `llm/project/project-rules.md`

## Scope
- **In scope:** Xcode project and schemes; Watch App + companion iOS targets; main list (Rosary, Prayer Library, Settings); one screen with real or stub content; single bundled JSON and load path; README and `llm/workflows/dev-env-local.md`.
- **Out of scope:** Full Rosary flow, full Prayer Library, TTS, polish, complications.

## Steps
1. **Repo and tooling**
   - Ensure project builds from Xcode and CLI (`xcodebuild`); document scheme and destination in `llm/workflows/dev-env-local.md`.
   - Add/update `.gitignore` for Xcode (e.g. `xcuserdata`, build products).
2. **App shell and navigation**
   - Main entry: NavigationStack with list linking to Rosary, Prayer Library, Settings.
   - Each destination: minimal view (title + placeholder or stub content).
3. **Thin vertical slice**
   - Add one canonical JSON (e.g. `rosary_prayers_en.json`) to Watch App bundle; implement `PrayerStore` (or equivalent) to load and decode; show prayer count or first prayer title on one screen to prove the pipeline.
4. **Docs and guardrails**
   - README: how to open project, select scheme, run on simulator/device.
   - `llm/implementation/`: short note on current structure (targets, data load) if helpful for future phases.

## Exit Criteria
- App runs on Watch Simulator (and optionally iOS Simulator) with main list and at least one screen showing data from bundled JSON.
- Build and run commands are documented in `llm/workflows/dev-env-local.md`.
- README reflects the current setup.
