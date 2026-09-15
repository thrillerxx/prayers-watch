Purpose: Index of repeatable runbooks for Prayers Watch (Divinity).

# Workflows

Default loop: [github-airgap.md](github-airgap.md) — edit on Omarchy, push GitHub, operator pulls on the MacBook Pro, reports Watch/Simulator notes, repeat. No SSH to that laptop. Agent rules: [AGENTS.md](../../AGENTS.md).

| Runbook | When to use |
| --- | --- |
| [github-airgap.md](github-airgap.md) | **Default daily loop.** Omarchy → GitHub → operator Mac / Watch. |
| [dev-env-local.md](dev-env-local.md) | Open the Xcode project and run Simulator on a Mac (operator). |
| [omarchy-mac-loop.md](omarchy-mac-loop.md) | Unused unless a **dedicated** Apple builder is named. Never the personal laptop. |
| [real-device-install.md](real-device-install.md) | Pair a wiped Watch, sign, install iOS + Watch apps from Xcode. |
| [real-device-qa.md](real-device-qa.md) | Human QA on the physical Watch after install. |
| [v1-sanity-pass.md](v1-sanity-pass.md) | Simulator sanity on the Mac after a pull (RC tag if comparing). |
| [audio-capture-export.md](audio-capture-export.md) | Record TTS audio on the Mac (BlackHole / Simulator). |

Private SSH hosts and Tailscale IPs are **not** in this repo. Use local environment notes on Omarchy.
