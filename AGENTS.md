# Agent Rules — Prayers Watch (Divinity)

You are working on **Prayers Watch (Divinity)**: a watchOS + companion iOS SwiftUI app for Catholic prayers and a guided Rosary.

Canonical clone: this repository. GitHub: `thrillerxx/prayers-watch`.  
Bundle IDs: `com.divinityapp.prayers` (iOS) and `com.divinityapp.prayers.watchkitapp`.

Do **not** use archived copies, `divinity-app-work`, or `divinity-repo` as the working tree.

---

## Machine split (non-negotiable)

| Where | What you do |
| --- | --- |
| **Omarchy (this Linux box)** | Edit, git, docs, `llm/` workflows, push to GitHub. Never Xcode, Simulator, Docker Compose, `npm run dev`, or SSH into the personal MacBook Pro. |
| **GitHub** | Source of truth. Handoff between Omarchy and the operator Mac. |
| **MacBook Pro (operator only)** | Pull from GitHub, Xcode, Simulator, signing, install to the paired iPhone + Watch. Agents do **not** Remote-Login, `scp`, or run `remote_mac_xcode.sh` against this laptop. |
| **iPhone + Apple Watch** | Pairing, Developer Mode, human QA. Tailscale on the phone does **not** let Omarchy install the Watch app. |

A macOS VM on Omarchy is not supported (Intel Xeon host; Xcode requires Apple hardware).

Private hostnames, Tailscale IPs, and SSH targets live in **local** notes (`OMARCHY_ENVIRONMENT.md` / oce-notes), never in this repo.

Default runbook: `llm/workflows/github-airgap.md`. Optional dedicated builder (not the personal laptop): `llm/workflows/omarchy-mac-loop.md`.

---

## Product rules

- Default branch is **`main`**. The tag `rosary-watch-en-final-ui-rc` (`21fde32`) is a known-good snapshot for regression, not a freeze on current work.
- v1 stays **English-only**. Do not start Spanish, mystery-picker redesign, or schema expansion unless explicitly assigned.
- One canonical prayer payload: `prayers/prayers Watch App/rosary_prayers_en.json`. Never add a second `prayers.json` / duplicate resource name to the Watch target.
- Single audio session: starting a new prayer or Rosary step stops the current one.
- Keep the app **free** (ICEL Mass Responses licensing). See `docs/licensing/mass-responses-licensing.md`.
- Prefer small SwiftUI views, value types, explicit errors. Files under ~500 lines. PascalCase Swift files.

Planning source of truth: `llm/project/` (`project-overview.md`, `current-state.md`, `design-rules.md`, `project-rules.md`).  
Runbooks: `llm/workflows/`.

---

## How to change code

1. Read the existing Swift file before editing it.
2. Match nearby style. Do not drive-by refactor.
3. After Watch UI or playback changes, update or extend `prayers Watch AppUITests` when the flow is automatable.
4. Record non-trivial behavior in `llm/implementation/`.
5. Push to GitHub when asked. Tell the operator the branch/SHA to pull in Xcode. Do not SSH to their MacBook Pro.

---

## Test matrix (what agents cannot skip telling the human)

Omarchy **cannot** flash or launch this app. Real-device testing needs:

1. Watch paired to **one** iPhone (the daily driver is fine). A second phone can run the iOS companion only — not the Watch.
2. Same Apple Account / Developer team that will sign `com.divinityapp.prayers`.
3. Developer Mode on the **paired** iPhone and Watch.
4. Operator pulls GitHub on the MacBook Pro; `prayers/Signing.local.xcconfig` (gitignored Team ID) stays on that Mac.
5. The **paired** iPhone connected to **the MacBook Pro** (USB the first time), not to Omarchy.

Full checklists: `llm/workflows/real-device-install.md` and `llm/workflows/real-device-qa.md`.
