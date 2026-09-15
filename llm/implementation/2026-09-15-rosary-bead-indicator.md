Purpose: Replace Rosary Forward with a read-only bead-position indicator (three DEBUG styles for operator comparison).

# Rosary bead indicator (2026-09-15)

- **Forward / Next removed** from now-playing transport; manual skip forward is not offered (Auto-advance in Settings unchanged).
- **`RosaryBeadPosition`** maps `index` + `steps` to opening / decade / closing bead semantics.
- **`RosaryBeadIndicator`** styles: A decade strip (default in Release), B chain glyph, C medallion + compact text.
- **DEBUG:** Settings → Developer → Bead indicator picker; long-press the indicator on the Rosary player to cycle A/B/C.
- **Fallback unchanged:** `rosary-complete-liked` (`631b00f`) until the operator picks a style and asks to tag a new snapshot.

After the operator picks A, B, or C on 42mm/46mm simulators: remove unused styles and the DEBUG switcher in a follow-up change.
