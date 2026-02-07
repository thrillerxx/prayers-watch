# Prayers-Watch

A simple watchOS prayer + rosary app (SwiftUI).

## Open in Xcode

- Project: `prayers/prayers.xcodeproj`
- Watch scheme: `prayers Watch App`

## Run (watchOS Simulator)

1. Open `prayers/prayers.xcodeproj`
2. Select scheme **prayers Watch App**
3. Choose a Watch Simulator device
4. Run

### CLI build

```bash
cd prayers
xcodebuild -project prayers.xcodeproj -scheme "prayers Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm),OS=26.2' \
  -configuration Debug build
```

## Notes / Next

- Complications require adding a Widget Extension target (WidgetKit) in Xcode.
- Real-device runs require signing + a paired Apple Watch.
