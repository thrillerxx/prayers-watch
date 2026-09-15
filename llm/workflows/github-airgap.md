Purpose: Default daily loop — edit on Omarchy, hand off through GitHub, operator builds on the Mac. No SSH to the personal MacBook Pro.

# GitHub air gap (daily loop)

Omarchy never controls the personal MacBook Pro. No Remote Login, no `MAC_HOST`, no `scripts/remote_mac_xcode.sh` against that laptop.

```
Omarchy (edit, git)  --push-->  GitHub  --pull-->  MacBook Pro (Xcode, Watch)
         ▲                                              │
         └──────── Watch / Simulator feedback ──────────┘
```

A macOS VM on Omarchy is **not** the path. This host is Intel Xeon Linux. Xcode and the watchOS SDK require **Apple hardware**. Apple’s license does not allow macOS as a guest on this box.

## Agent (Omarchy)

1. Edit `/home/car/.openclaw/workspace/prayers-watch` (this clone).
2. Commit only when asked. Push to `origin` (`thrillerxx/prayers-watch`) only when asked.
3. After a push, point the operator at the **branch + SHA** and the copy-paste block below.
4. Optional smoke: `gh run list --repo thrillerxx/prayers-watch` / `gh run watch` for `.github/workflows/xcode-watch-ci.yml` (Simulator on GitHub’s Mac runners). That is CI, not device install.
5. Wait for Watch or Simulator notes, then iterate.

Do **not** SSH to the MacBook Pro. If a build is needed beyond CI, say so and wait.

## Operator (MacBook Pro)

One-time:

```bash
git clone git@github.com:thrillerxx/prayers-watch.git ~/dev/prayers-watch
# or File → Clone in Xcode
```

Copy `prayers/Signing.local.xcconfig.example` → `prayers/Signing.local.xcconfig` and put the Team ID in it (gitignored).

Each time there is a new push (replace `EXPECTED_SHA` with the SHA the agent gave you):

```bash
cd ~/dev/prayers-watch
git fetch origin
git switch main
git pull --ff-only
git rev-parse --short HEAD   # must match EXPECTED_SHA
open prayers/prayers.xcodeproj
```

Then in Xcode:

1. Scheme **prayers Watch App**.
2. Destination: Watch Simulator, or the paired Watch (iPhone plugged into this Mac).
3. Run (⌘R).
4. Device install: [real-device-install.md](real-device-install.md). QA: [real-device-qa.md](real-device-qa.md).

Signing stays on the Mac (`prayers/Signing.local.xcconfig`).

## What to send back

After a run, a short note is enough: SHA, Simulator vs Watch, screen (home / Rosary now-playing / Library / Mass / Settings), and what looked wrong. That is the next edit on Omarchy.

## If you later want agent-run Xcode

That needs **separate Apple hardware**, not a VM here and not the personal laptop:

- A Mac Mini (or similar) on the desk, **or**
- A rented Mac (MacStadium / AWS EC2 Mac / similar)

Only then would `scripts/remote_mac_xcode.sh` be allowed, and only against that dedicated builder. See [omarchy-mac-loop.md](omarchy-mac-loop.md).
