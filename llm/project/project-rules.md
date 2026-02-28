Purpose: Coding standards, directory structure, and workflow expectations for Prayers Watch.

# Project Rules

## Directory Structure
- **App entry and shared UI:** Under `prayers/` (or equivalent app folder); Watch App in a dedicated target folder (e.g. `prayers Watch App/`).
- **Canonical data:** Single prayer/rosary JSON in the Watch App bundle (e.g. `rosary_prayers_en.json`); loaded via `PrayerStore` or equivalent; no duplicate resource names.
- **Docs:** All planning and runbooks in `llm/` — `llm/project/` for overview, flows, tech, design, rules, phases; `llm/context/` for references; `llm/implementation/` for implementation notes; `llm/workflows/` for runbooks (e.g. local dev).
- **Tests:** Unit/UI tests in the standard Xcode test targets; keep tests next to the code they cover conceptually.

## Naming Conventions
- **Files:** PascalCase for Swift (e.g. `RosaryView.swift`, `PrayerStore.swift`); kebab-case for docs and config (e.g. `project-overview.md`).
- **Types:** Descriptive names; views suffixed with `View`, managers with `Manager`, stores with `Store`.
- **Resources:** One canonical name per content type (e.g. `rosary_prayers_en`); avoid multiple files with the same base name in the bundle.

## Code Organisation
- **Views:** Prefer small, focused views; extract subviews (e.g. marquee, transport row) into private structs or separate files; keep files under ~500 lines.
- **State:** Shared services as ObservableObject (e.g. `SpeechManager.shared`); `@StateObject` at ownership root, `@ObservedObject` in children; avoid duplicating speech state.
- **Data loading:** Load from bundle in a dedicated store or helper; throw or return Result on failure; surface errors in UI (e.g. "No prayers found" or error message).
- **Pure logic:** Prefer free functions or static methods for pure logic (e.g. step index, mystery index); keep side effects in managers or view actions.

## Documentation
- **File header:** Each Swift file has a short comment or doc at the top explaining its role (or a one-line purpose for docs).
- **Public API:** Document public functions and types (e.g. Swift doc comments) where behavior is non-obvious.
- **llm/:** Every doc in `llm/` starts with a one-line "Purpose:"; keep each file under 500 lines; update when behavior or decisions change.

## Development Workflow
- **Build:** Use Xcode or `xcodebuild`; see `llm/workflows/dev-env-local.md` for scheme, destination, and commands.
- **Before commit:** Build succeeds; no duplicate resource warnings; run tests if present.
- **Changes:** Align new features with `llm/project/phases/` and `project-rules.md`; add or update `llm/implementation/` notes for non-trivial behavior.
- **Agents:** When using AI assistants, attach relevant `llm/project/` docs and `AGENTS.md` so outputs stay consistent with this repo.

## Quality Expectations
- **Modular:** Reusable components (e.g. transport, marquee) shared where it makes sense.
- **Readable:** Descriptive names, clear control flow; avoid deep nesting.
- **Explicit errors:** Prefer throwing or returning errors over silent fallbacks; show user-facing message when load or speech fails.
- **Navigable:** New contributors and agents can find project definition in `llm/project/`, runbooks in `llm/workflows/`, and current behavior in `llm/implementation/`.
