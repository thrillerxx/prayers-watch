# Prayers-Watch

A simple watchOS prayer + rosary app (SwiftUI).

**Agents / automation:** read **`docs/agent-environment.md`** (SSH to Mac, Xcode Simulator, Homebrew PATH, BlackHole, canonical paths). The full tailnet reference on omarchy is **`/home/car/.openclaw/workspace/OPENCLAW_ENVIRONMENT.md`** (§5 prayers-watch).

## Open in Xcode

- Project: `prayers/prayers.xcodeproj`
- Watch scheme: `prayers Watch App`

## Run (watchOS Simulator)

1. Open `prayers/prayers.xcodeproj`
2. Select scheme **prayers Watch App**
3. Choose a Watch Simulator device
4. Run

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

## Complications (Watch Face Widget)

The `PrayersComplications` Widget Extension is wired into the project. After building, you can add the "Divinity" complication to any watch face for quick app access.

## Real-Device Signing

Simulator builds use `CODE_SIGNING_ALLOWED=NO`. For real Apple Watch deployment:

1. Copy `prayers/Signing.local.xcconfig.example` to `prayers/Signing.local.xcconfig`
2. Fill in your Apple Developer Team ID
3. In Xcode, set each target's signing team, or use the remote script:

```bash
SIGN=1 DEVELOPMENT_TEAM=YOUR_TEAM_ID bash scripts/remote_mac_xcode.sh
```

Requirements:
- Active Apple Developer Program membership ($99/year)
- Paired Apple Watch connected to the Mac
- Automatic signing will create provisioning profiles for all targets

## Licensing

Mass Responses text is from The Roman Missal (ICEL). See `docs/licensing/mass-responses-licensing.md` for details. The app includes the required ICEL copyright notice. Keep the app **free** to avoid royalty obligations.
