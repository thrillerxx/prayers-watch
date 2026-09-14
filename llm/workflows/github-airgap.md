Purpose: Handoff from Omarchy to the operator Mac via GitHub only — no SSH to the personal MacBook Pro.

# GitHub air gap (default)

Omarchy never controls the personal MacBook Pro. No Remote Login, no `MAC_HOST`, no `scripts/remote_mac_xcode.sh` against that laptop.

```
Omarchy (edit, git)  --push-->  GitHub  --pull-->  MacBook Pro (Xcode, Watch)
```

A macOS VM on Omarchy is **not** the path. This host is Intel Xeon Linux. Xcode and the watchOS SDK require **Apple hardware**. Apple’s license does not allow macOS as a guest on this box.

## Agent (Omarchy)

1. Edit in this repository clone.
2. Commit only when asked. Push to `origin` (`thrillerxx/prayers-watch`).
3. Point the operator at the branch/SHA.
4. Optional smoke: `gh run list --repo thrillerxx/prayers-watch` / `gh run watch` for `.github/workflows/xcode-watch-ci.yml` (Simulator on GitHub’s Mac runners). That is CI, not device install.

Do **not** SSH to the MacBook Pro. If a build is needed beyond CI, say so and wait.

## Operator (MacBook Pro)

One-time:

```bash
git clone git@github.com:thrillerxx/prayers-watch.git ~/dev/prayers-watch
# or File → Clone in Xcode
```

Each time there is a new push:

1. `git pull` (or Xcode Source Control → Pull).
2. Open `prayers/prayers.xcodeproj`.
3. Scheme **prayers Watch App** → Simulator or the paired Watch.
4. Device install: [real-device-install.md](real-device-install.md).

Signing stays on the Mac (`prayers/Signing.local.xcconfig`, gitignored).

## If you later want agent-run Xcode

That needs **separate Apple hardware**, not a VM here and not the personal laptop:

- A Mac Mini (or similar) on the desk, **or**
- A rented Mac (MacStadium / AWS EC2 Mac / similar)

Only then would `scripts/remote_mac_xcode.sh` be allowed, and only against that dedicated builder. See [omarchy-mac-loop.md](omarchy-mac-loop.md).
