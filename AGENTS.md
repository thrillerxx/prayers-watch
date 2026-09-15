# Agent Rules — Prayers Watch (Divinity)

You are working on **Prayers Watch (Divinity)**: a watchOS + companion iOS SwiftUI app for Catholic prayers and a guided Rosary.

On Omarchy the clone is `/home/car/.openclaw/workspace/prayers-watch`. GitHub: `thrillerxx/prayers-watch`.  
Bundle IDs: `com.divinityapp.prayers` (iOS) and `com.divinityapp.prayers.watchkitapp`.

Do **not** use archived copies, `divinity-app-work`, or `divinity-repo` as the working tree.

---

## Daily loop (default)

This is how we work now. Full runbook: `llm/workflows/github-airgap.md`.

```
Omarchy (edit, git)  --push-->  GitHub  --pull-->  MacBook Pro (Xcode, Watch)
```

1. Edit this clone. Never Xcode, Simulator, Docker Compose, or `npm run dev` on Omarchy.
2. Commit only when asked. Push only when asked.
3. After a push, give the operator the **branch + SHA** and the pull block from `github-airgap.md`. Do not SSH, `scp`, or run `scripts/remote_mac_xcode.sh` against the personal MacBook Pro.
4. Operator pulls on the Mac, opens `prayers/prayers.xcodeproj`, runs scheme **prayers Watch App**, installs to Simulator or the paired Watch.
5. Iterate from Watch / Simulator feedback. Real-device steps: `llm/workflows/real-device-install.md` and `llm/workflows/real-device-qa.md`.

Agent-visible Apple check: GitHub Actions `.github/workflows/xcode-watch-ci.yml` (`gh run list` / `gh run watch`). That is Simulator CI, not a device install.

A macOS VM on Omarchy is not supported (Intel Xeon host; Xcode requires Apple hardware). There is no dedicated builder Mac unless the operator names one in-session (`llm/workflows/omarchy-mac-loop.md`).

Private hostnames, Tailscale IPs, and SSH targets live in **local** notes (`OMARCHY_ENVIRONMENT.md` / oce-notes), never in this repo.

---

## Machine split (non-negotiable)

| Where | What you do |
| --- | --- |
| **Omarchy** | Edit, git, docs, `llm/` workflows, push to GitHub. |
| **GitHub** | Source of truth. Handoff between Omarchy and the operator Mac. |
| **MacBook Pro (operator only)** | Pull, Xcode, Simulator, signing, install to the paired iPhone + Watch. |
| **iPhone + Apple Watch** | Pairing, Developer Mode, human QA. Tailscale on a phone does **not** let Omarchy install the Watch app. Watch pairing is 1:1 with the daily-driver iPhone. |

---

## Product rules

- Default branch is **`main`**. Current liked Rosary now-playing layout: tag **`rosary-nowplaying-liked`** (`ad3bf36`). Older regression snapshot: tag **`rosary-watch-en-final-ui-rc`** (`21fde32`) — not a freeze on current work.
- v1 stays **English-only**. Do not start Spanish, mystery-picker redesign, or schema expansion unless explicitly assigned. Small UX / product updates on `main` are in scope when the operator asks.
- Home: Rosary, Prayer Library, Mass Responses, Settings. Mass Responses stays in-app and **free** (ICEL). See `docs/licensing/mass-responses-licensing.md`.
- One canonical prayer payload: `prayers/prayers Watch App/rosary_prayers_en.json`. Never add a second `prayers.json` / duplicate resource name to the Watch target.
- Single audio session: starting a new prayer or Rosary step stops the current one. Rosary session state lives in `RosarySessionController` (survives navigation / mini-player). Speech is `SpeechManager.shared`.
- **Do not** put SwiftUI `VideoPlayer` in `AppShell` or `RosaryView`. On watchOS it becomes a Now Playing container and parks the 102pt mystery cover on the chin. Cover placement is a layout problem, not a video problem.
- Prefer small SwiftUI views, value types, explicit errors. Files under ~500 lines. PascalCase Swift files.

Planning source of truth: `llm/project/` (`project-overview.md`, `current-state.md`, `design-rules.md`, `project-rules.md`).  
Runbooks: `llm/workflows/`.

---

## How to change code

1. Read the existing Swift file before editing it.
2. Match nearby style. Do not drive-by refactor.
3. After Watch UI or playback changes, update or extend `prayers Watch AppUITests` when the flow is automatable.
4. Record non-trivial behavior in `llm/implementation/`.
5. Push to GitHub when asked. Tell the operator the branch/SHA to pull in Xcode.

---

## Test matrix (what agents cannot skip telling the human)

Omarchy **cannot** flash or launch this app. Real-device testing needs:

1. Watch paired to **one** iPhone (the daily driver). A second phone can run the iOS companion only — not the Watch.
2. Same Apple Account / Developer team that will sign `com.divinityapp.prayers`.
3. Developer Mode on the **paired** iPhone and Watch.
4. Operator pulls GitHub on the MacBook Pro; `prayers/Signing.local.xcconfig` (gitignored Team ID) stays on that Mac.
5. The **paired** iPhone connected to **the MacBook Pro** (USB the first time), not to Omarchy.
