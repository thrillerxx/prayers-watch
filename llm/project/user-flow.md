Purpose: User journeys and key states for Prayers Watch (Rosary, Prayer Library, Settings).

# User Flow

Maps the primary personas through the app. Reference for UI and feature scope.

## Persona: Rosary prayer (watch)
- **Entry:** Open app → main list (Rosary, Prayer Library, Settings).
- **Rosary path:** Tap "Rosary" → choose mystery set (if offered) → see current mystery and step (e.g. "First Sorrowful — Our Father").
- **Actions:** Advance step (next bead), play/pause/stop speech; optional back to change mystery or exit.
- **States:** Idle, speaking, paused; step index and mystery index drive displayed text and TTS.
- **Exit:** Navigate back to list or leave app; state can persist or reset by product choice.

## Persona: Prayer library user (watch or phone)
- **Entry:** Open app → main list → "Prayer Library".
- **Browse:** List of prayers (titles); filter out metadata-only entries (e.g. mystery titles) so only prayable items show.
- **Detail:** Tap a prayer → full text; optional "Speak" to start TTS.
- **Transport:** If speaking, play/pause and stop available (shared with Rosary); consistent UX across Library and Rosary.
- **Exit:** Back to list or home.

## Persona: Settings user
- **Entry:** Main list → "Settings".
- **Actions:** Adjust preferences (e.g. speech rate, voice/locale, Rosary options). Persist via UserDefaults or equivalent.
- **Exit:** Back to list; settings apply to next Rosary or Library session.

## Key Transitions
- **List ↔ Rosary:** List → Rosary (enter flow); Rosary → back (exit to list).
- **List ↔ Prayer Library:** List → Library (list); Library → detail (read/speak); detail → back (list).
- **List ↔ Settings:** List ↔ Settings; no modal blocking main list.
- **Speech:** Single global speech state; starting a new utterance (Rosary or Library) stops any current one; play/pause/stop shared.

## Decision Points
- Mystery selection: before starting Rosary or at first step (product decision).
- TTS on/off: per session or global setting (Settings).
- After last step: show completion state; option to restart or go back.
