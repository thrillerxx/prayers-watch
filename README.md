# Prayers Watch (Divinity)

A watchOS (and companion iOS) app for Catholic prayers and guided Rosary. Built with Swift and SwiftUI. Project planning and conventions are in **`llm/`** — see [llm/project/setup.md](llm/project/setup.md) and [llm/project/project-overview.md](llm/project/project-overview.md).

## Current Scope (v1 RC)
- **In scope:** English-only prayer content, Rosary flow, prayer library playback, settings, watch-first UI polish, and baseline watch UI tests.
- **Out of scope:** Spanish localization, mystery picker redesign, and schema expansion beyond the current v1 data model.
- **Release baseline:** `rosary-watch-en-final-ui-rc` (peeled commit `21fde32`).

## Features
- **Rosary** — Guided Rosary with mysteries and steps; optional text-to-speech (play/pause/stop).
- **Prayer Library** — Browse prayers, read full text, and speak aloud with shared transport controls.
- **Settings** — User preferences (e.g. speech, display).
- **Watch-first** — Layout and interactions tuned for watchOS (marquee for long titles, compact controls).

**Agents / automation:** read **`docs/agent-environment.md`** (Xcode on macOS, Simulator, Homebrew PATH, BlackHole). Keep private hostnames, VPN addresses, and personal paths in **local** notes—not in this repo.

## Open in Xcode
- **Project:** `prayers/prayers.xcodeproj`
- **Watch scheme:** `prayers Watch App`

## Run (watchOS Simulator)
1. Open `prayers/prayers.xcodeproj`.
2. Select scheme **prayers Watch App**.
3. Choose a Watch Simulator device.
4. Run (⌘R).

### CLI build

Use **`-sdk watchsimulator`** so the product is a Simulator build (see `docs/agent-environment.md`).

```bash
cd prayers
xcodebuild -project prayers.xcodeproj \
  -target "prayers Watch App" \
  -sdk watchsimulator \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm),OS=26.2' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```
Adjust simulator `name` and `OS` to match your installed runtimes.

## Conventions

- **Project docs:** Phases and runbooks live under **`llm/`** (see links at top).
- **Agents:** [AGENTS.md](AGENTS.md) — AI-assistant rules and repo layout.

## Complications (Watch Face Widget)

The `PrayersComplications` Widget Extension is wired into the project. After building, you can add the "Divinity" complication to any watch face for quick app access.

## Real-Device Signing

Simulator builds use `CODE_SIGNING_ALLOWED=NO`. For real Apple Watch deployment:

1. Copy `prayers/Signing.local.xcconfig.example` to `prayers/Signing.local.xcconfig`
2. Fill in your Apple Developer Team ID
3. In Xcode, set each target's signing team, or use the remote script:

```bash
MAC_HOST=you@your-mac SIGN=1 DEVELOPMENT_TEAM=YOUR_TEAM_ID bash scripts/remote_mac_xcode.sh
```

Requirements:
- Active Apple Developer Program membership ($99/year)
- Paired Apple Watch connected to the Mac
- Automatic signing will create provisioning profiles for all targets

## Licensing

Mass Responses text is from The Roman Missal (ICEL). See `docs/licensing/mass-responses-licensing.md` for details. The app includes the required ICEL copyright notice. Keep the app **free** to avoid royalty obligations.
