# Remote Mac Build/Test Workflow

Canonical code repo (edit here):
- `/home/car/dev/prayers-watch` (Omarchy)

Canonical Xcode project (build/test here):
- `/Users/thrillerx/dev/prayers-watch/prayers/prayers.xcodeproj` (MacBook Air)

## One-command runner (from Omarchy)

```bash
cd /home/car/dev/prayers-watch
scripts/remote_mac_xcode.sh
```

What it does:
- Pushes current local branch to `origin`.
- SSHes to `thrillerx@thrillerxs-macbook-air`.
- Ensures Mac repo exists and points `origin` to the same remote URL as Omarchy.
- Switches Mac repo to the same branch and hard-resets to `origin/<branch>`.
- Runs watchOS build via `xcodebuild`.
- Runs tests via the default `prayers Watch App` scheme (override with `TEST_SCHEME=...`).

## Common usage

Build/test a specific branch:
```bash
scripts/remote_mac_xcode.sh feature/mass-responses
```

Build only (skip tests):
```bash
RUN_TESTS=0 scripts/remote_mac_xcode.sh
```

Do not auto-push first (use already-pushed commit):
```bash
PUSH_FIRST=0 scripts/remote_mac_xcode.sh
```

Use a different simulator destination:
```bash
DESTINATION='platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' scripts/remote_mac_xcode.sh
```

## Notes
- If local Omarchy changes are not committed/pushed, the Mac builds the latest pushed commit only.
- Script defaults can be overridden via env vars: `MAC_HOST`, `MAC_REPO_DIR`, `MAC_PROJECT_SUBDIR`, `PROJECT_FILE`, `BUILD_SCHEME`, `TEST_SCHEME`, `DESTINATION`, `RUN_TESTS`, `PUSH_FIRST`.
