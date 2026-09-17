Purpose: Pin the operator-approved Rosary voice and spoken scripture build.

# Liked voice snapshot (2026-09-16)

Tag **`rosary-voice-liked`** → commit **`dcb8a3c`**.

Operator-approved Watch speech: eight ElevenLabs VoiceBanks plus **Apple Voice**; speeds Very Slow / Slow / Normal / Fast; decade announces **1st–5th Decade**; full scripture citations (Mark for Luminous 3; Matthew 3:13–17 for Luminous 1). Verse bodies stay RSV-style. Cover-only now-playing unchanged.

This does **not** replace `rosary-liked` (`9bb27c4`), which stays the sequence / now-playing / bead-indicator restore.

Restore this speech build:

```bash
git fetch origin --tags
git switch --detach rosary-voice-liked
```
