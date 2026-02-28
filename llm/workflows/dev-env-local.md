Purpose: Runbook to set up and validate the local dev environment for Prayers Watch (Xcode, watchOS/iOS).

# Local Dev Environment (Workflow)

Use this workflow when a contributor (human or agent) needs to build and run the project locally.

## Prerequisites
- **Xcode** (current or recent version supporting the project’s deployment targets).
- **macOS** (required for Xcode and watchOS/iOS simulators).
- Optional: **xcode-select** CLI tools if using `xcodebuild` from terminal.

## Open in Xcode
1. Clone the repo and open the project:
   - Project file: `prayers/prayers.xcodeproj`
2. Select the **Watch App** scheme: **prayers Watch App** (or the main app scheme for iOS).
3. Choose a destination (e.g. **Apple Watch Series 11 (46mm)** or current simulator).
4. Run (⌘R).

## CLI build (watchOS Simulator)
From repo root:
```bash
cd prayers
xcodebuild -project prayers.xcodeproj -scheme "prayers Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm),OS=26.2' \
  -configuration Debug build
```
Adjust `name` and `OS` to match your installed simulators (`xcrun simctl list devices`).

## Key schemes and targets
- **prayers Watch App** — primary watchOS app (Rosary, Prayer Library, Settings).
- Main app target — companion iOS app if present; use its scheme for phone simulator.

## Environment and config
- No `.env` required for basic run; prayer data is bundled (`rosary_prayers_en.json`).
- For real device: configure signing in Xcode (team, provisioning).

## Health checks
- Project opens in Xcode without errors.
- **prayers Watch App** builds and runs in Watch Simulator.
- Main list shows Rosary, Prayer Library, Settings; tapping each opens the corresponding screen.
- Prayer Library loads prayers from bundle (no “No prayers found” unless data missing); Rosary shows steps and TTS works (device may be needed for reliable TTS).

## Troubleshooting
- **Duplicate resource:** Ensure only one `rosary_prayers_en.json` (or canonical file) is in the Watch App target; remove duplicates from Copy Bundle Resources.
- **Scheme not found:** Confirm scheme is shared (Project → Manage Schemes → check “Shared”).
- **Simulator not found:** Run `xcrun simctl list devices` and pick a valid `name` and `OS` for `-destination`.
- **TTS silent on Simulator:** Expected on some setups; test on real Watch for speech.

## Maintenance
Update this workflow when schemes, destinations, or build steps change. Add separate runbooks (e.g. release, TestFlight) under `llm/workflows/` as needed.
