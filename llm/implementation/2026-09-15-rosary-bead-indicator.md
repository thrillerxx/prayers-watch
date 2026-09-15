Purpose: Replace Rosary Forward with a read-only bead-position indicator (three DEBUG styles for operator comparison).

# Rosary bead indicator (2026-09-15)

- **Forward / Next removed** from now-playing transport; manual skip forward is not offered (Auto-advance in Settings unchanged).
- **`RosaryBeadPosition`** maps `index` + `steps` to opening / decade / closing bead semantics.
- **`RosaryBeadIndicator`:** decade dots (style A) only; B/C removed after operator review.
- **Settings → Rosary → Bead indicator:** persists `AppSettings.beadIndicatorStyleKey` (single option “Decade dots” today; add cases to `RosaryBeadIndicatorStyle` when more layouts ship).
- **Fallback unchanged:** `rosary-complete-liked` (`631b00f`) until a new liked snapshot is tagged.
