# prayers-watch — Project State

## Canonical repo/worktree
- Omarchy clone: `/home/car/.openclaw/workspace/prayers-watch`
- GitHub: `thrillerxx/prayers-watch`
- Xcode project: `prayers/prayers.xcodeproj`
- Watch app source folder: `prayers/prayers Watch App`

## Current line
- **Develop on:** `main`
- **Liked complete Rosary:** tag `rosary-complete-liked` → `631b00f`
- **Layout-only ancestor:** tag `rosary-nowplaying-liked` → `ad3bf36`
- **Older RC (regression only):** tag `rosary-watch-en-final-ui-rc` → `21fde32`
- Daily loop: `AGENTS.md` + `llm/workflows/github-airgap.md` (no SSH to the personal Mac)

## Mass Responses
Shipped on `main` (home item “Mass Responses”). Remote branch `feature/mass-responses` is historical. Text is from the Roman Missal (ICEL 2011); keep the app **free**. See `docs/licensing/mass-responses-licensing.md`.

## macOS build/capture (operator Mac)
- Pull GitHub, then use **Xcode** / `xcodebuild`. Agents do not SSH here.
- Watch sim devices observed historically: Apple Watch Series 11 (42mm/46mm), Ultra 3 (49mm), SE 3 (40mm/44mm)
- **BlackHole** (optional): virtual audio device for capturing simulator audio on macOS.

## Build command (watchOS Simulator)
```bash
cd ~/dev/prayers-watch/prayers
xcodebuild -project prayers.xcodeproj \
  -scheme "prayers Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (42mm)' \
  CODE_SIGNING_ALLOWED=NO \
  build
```
