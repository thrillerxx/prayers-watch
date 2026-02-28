Purpose: MVP phase — core user value: full Rosary with TTS and Prayer Library with speak.

# MVP Phase

## Goals
- Deliver the primary user flows: guided Rosary (mysteries, steps, play/pause/stop TTS) and Prayer Library (list, detail, speak).
- Single shared speech manager and consistent transport UX across Rosary and Library.
- Quality baseline: no duplicate bundle resources; clear error handling for load failures.

## Inputs
- `llm/project/project-overview.md`
- `llm/project/user-flow.md`
- `llm/project/tech-stack.md`
- `llm/project/project-rules.md`
- `llm/project/design-rules.md`

## Scope
- **In scope:** Full Rosary flow (mystery sets, steps, next/back); TTS for Rosary and Library; shared `SpeechManager`; transport (play/pause/stop) in both flows; Prayer Library list + detail + speak; single canonical JSON; Settings stub or minimal prefs; watch-appropriate layout (e.g. marquee for long titles).
- **Out of scope:** Localization, complications, extensive accessibility audit, backend.

## Steps
1. **Rosary flow**
   - Model: mystery set, mystery index, step index; data from canonical JSON.
   - UI: current mystery and step title (marquee if needed); prayer text; next/previous; transport row when speaking.
   - Wire TTS: speak current step text; on finish advance or complete; play/pause/stop.
2. **Prayer Library**
   - List: load prayers from same JSON; filter to prayable entries only; show titles.
   - Detail: full text; speak button; show transport when speech active (shared with Rosary).
3. **Shared speech and transport**
   - Single `SpeechManager` (ObservableObject); start new utterance stops current one; same transport component or pattern in Rosary and Library.
4. **Data and robustness**
   - Assert or guard single copy of canonical JSON in bundle (DEBUG); clear error state in UI if load fails.
5. **Docs**
   - Update README with MVP capabilities; add `llm/implementation/` note for rosary-and-speech and prayer-data if useful.

## Exit Criteria
- User can complete a full Rosary with optional TTS and use play/pause/stop.
- User can open Prayer Library, tap a prayer, read and speak it, with same transport behavior.
- No duplicate `rosary_prayers_en.json` in bundle; load errors surfaced in UI.
- `llm/workflows/dev-env-local.md` and README match current behavior.
