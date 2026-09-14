# Remote Mac Build/Test Workflow

**Default:** GitHub air gap — Omarchy pushes, the operator pulls on their own Mac. See `llm/workflows/github-airgap.md`. Do **not** SSH to a personal laptop.

This script is only for a **dedicated** Apple builder the operator has named.

```bash
export MAC_HOST='you@dedicated-builder'
cd /path/to/your/prayers-watch/clone
scripts/remote_mac_xcode.sh
```

What it does:
- Pushes current local branch to `origin`.
- SSHs to **`MAC_HOST`**.
- Ensures the Mac repo exists and points `origin` at the same remote URL as the invoking clone.
- Switches the Mac repo to the same branch and hard-resets to `origin/<branch>`.
- Runs watch build via `xcodebuild` target `prayers Watch App`.
- Runs tests via default scheme `prayers-watch-uitests` (override with `TEST_SCHEME=...`).

## Common usage

```bash
scripts/remote_mac_xcode.sh feature/mass-responses
RUN_TESTS=0 scripts/remote_mac_xcode.sh
PUSH_FIRST=0 scripts/remote_mac_xcode.sh
DESTINATION='platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' \
  scripts/remote_mac_xcode.sh
```

## Notes
- If local changes are not committed/pushed, the Mac builds the latest pushed commit only.
- Override via env vars: `MAC_HOST`, `MAC_REPO_DIR`, `MAC_PROJECT_SUBDIR`, `PROJECT_FILE`, `BUILD_TARGET`, `TEST_SCHEME`, `DESTINATION`, `RUN_TESTS`, `PUSH_FIRST`, `SIGN`, `DEVELOPMENT_TEAM`.
