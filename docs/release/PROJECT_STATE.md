# prayers-watch — Project State

## Canonical repo/worktree
- This repository (any clone path).
- Xcode project: `prayers/prayers.xcodeproj`
- Watch app source folder: `prayers/prayers Watch App`

## Validated release candidate (RC)
- Tag: `rosary-watch-en-final-ui-rc`
- Commit: `21fde32`
- Rule: treat `21fde32` as the validated baseline. Do not advance scope from `main` until explicitly assigned.

## Non-RC work (WIP branches)
- `feature/mass-responses` @ `3f950cc`
  - Adds a new main-menu entry: “Mass Responses & Prayers”
  - Backed by `mass_responses_en.txt` extracted from a PDF.
  - Note: text appears to be from the Roman Missal (ICEL 2011). Confirm licensing before shipping.

## macOS build/capture runner
- Use **Xcode** on macOS; SSH target and paths are **local/private** (not documented in-repo).
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
