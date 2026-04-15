# Remote Mac Build/Test Workflow

- **Edit code** in your canonical clone of this repo (any machine).
- **Build and test** with Xcode on **macOS** (local or via SSH).

## One-command runner (from a non-Mac dev host)

```bash
export MAC_HOST='you@your-mac'
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
- If local changes are not committed/pushed, the Mac builds the latest pushed commit only.
- Override via env vars: `MAC_HOST`, `MAC_REPO_DIR`, `MAC_PROJECT_SUBDIR`, `PROJECT_FILE`, `BUILD_TARGET`, `TEST_SCHEME`, `DESTINATION`, `RUN_TESTS`, `PUSH_FIRST`, `SIGN`, `DEVELOPMENT_TEAM`.
