Purpose: Optional SSH Xcode runner on a dedicated Apple Mac — never the personal MacBook Pro.

# Dedicated builder Mac (optional)

Default handoff is [github-airgap.md](github-airgap.md). This runbook is only for a **dedicated** Apple machine the operator names (Mac Mini, cloud Mac). It is **not** for the personal MacBook Pro.

## Forbidden

- SSH / Remote Login / `MAC_HOST` aimed at the operator’s personal laptop
- macOS VMs on Omarchy (Intel Linux) — Xcode is not licensed or supported there
- Using this script because “the MacBook is on Tailscale”

## When this is allowed

The operator has said, in this session, that a **named dedicated builder** exists and agents may SSH to it.

```bash
export MAC_HOST='you@dedicated-builder'   # never the personal laptop
cd /path/to/prayers-watch
scripts/remote_mac_xcode.sh
```

The script pushes the current branch, syncs that Mac’s clone to `origin/<branch>`, then `xcodebuild` for `prayers Watch App` with `-sdk watchsimulator`.

```bash
RUN_TESTS=0 scripts/remote_mac_xcode.sh
PUSH_FIRST=0 scripts/remote_mac_xcode.sh
DESTINATION='platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' \
  scripts/remote_mac_xcode.sh
```

Dirty Omarchy tree: the builder still compiles the **last pushed commit**.

## CI (no extra Mac)

`.github/workflows/xcode-watch-ci.yml` on `macos-latest` is the agent-visible Simulator check. It does not replace Watch QA on hardware.
