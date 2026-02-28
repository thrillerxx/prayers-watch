Purpose: Technology choices and conventions for Prayers Watch (watchOS / iOS, Swift, SwiftUI).

# Tech Stack

## Primary Choices
- **Language:** Swift 5+
- **UI:** SwiftUI (declarative; shared between watchOS and iOS where applicable).
- **Platforms:** watchOS (primary), iOS (companion); single Xcode project with shared code and app targets.
- **Speech:** AVFoundation — `AVSpeechSynthesizer` and `AVSpeechSynthesisVoice`; delegate for completion/callbacks.
- **Data:** Bundled JSON (e.g. `rosary_prayers_en.json`); `Codable` models; single canonical resource per locale to avoid duplicates.
- **Persistence:** UserDefaults for settings (e.g. speech rate, language); no backend or cloud sync in scope.
- **Build:** Xcode; `xcodebuild` for CLI (see `llm/workflows/dev-env-local.md`).

## Alternatives & Trade-offs
- **SwiftUI vs UIKit:** SwiftUI for consistency and less code on watch; use UIKit only if a needed API has no SwiftUI path.
- **Single JSON vs multiple files:** Single canonical file simplifies loading and avoids duplicate-resource bugs; split by locale (e.g. `rosary_prayers_en.json`) if we add more languages.
- **TTS:** System TTS only; no custom voices or offline packs in MVP — document simulator vs device behavior.

## Conventions
- **Targets:** Clearly named (e.g. "prayers Watch App", main app); shared code in a target both platforms depend on.
- **Resources:** One canonical prayer/rosary JSON; reference it from `PrayerStore` or equivalent; no duplicate filenames in bundle.
- **State:** ObservableObject for shared services (e.g. `SpeechManager`); `@StateObject` in root, `@ObservedObject` in children; avoid redundant copies.
- **Navigation:** NavigationStack + NavigationLink; keep depth shallow on watch (list → detail, Rosary steps).
- **Accessibility:** Labels and hints for buttons and steps; support Dynamic Type and reduce motion where applicable (see design-rules).

## Pitfalls to Avoid
- Multiple copies of the same JSON in the bundle (causes ambiguous load); assert or guard in DEBUG.
- Holding strong references to AVSpeechSynthesizer delegate across unrelated views; use a single shared manager.
- Large view files; extract subviews (e.g. marquee, transport row) into private structs or separate files; keep files under ~500 lines.
- Blocking the main thread on file decode; keep JSON small and loading synchronous from bundle is acceptable; for large data consider async.
