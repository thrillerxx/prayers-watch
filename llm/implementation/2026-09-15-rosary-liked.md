Purpose: Pin the operator-approved Rosary (with bead indicator) as the restore point.

# Liked Rosary snapshot (2026-09-15)

Tag **`rosary-liked`** → commit **`9bb27c4`**.

Operator-approved Watch build: Complete Rosary Prayer Guide content, cover-only now-playing, decade-dots bead indicator (Forward removed), Settings → Rosary → Bead indicator for future styles.

Restore:

```bash
git fetch origin --tags
git switch --detach rosary-liked
```

Content-only ancestor: `rosary-complete-liked` (`631b00f`). Layout-only: `rosary-nowplaying-liked` (`ad3bf36`).
