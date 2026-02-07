# Complication / Widget Extension Scaffold

This folder contains *ready-to-copy* WidgetKit code for a watchOS complication.

## How to wire it up (Xcode UI required)

1. Open `prayers/prayers.xcodeproj`
2. File > New > Target…
3. Choose **watchOS > Widget Extension**
4. Name it something like `PrayersComplications`
5. Make sure it’s added to the watch app
6. In the new extension target, replace the generated widget Swift file(s) with:
   - `ComplicationScaffold/PrayersComplications.swift`

Then build/run and you should be able to add the complication on the watch face.

## Why scaffold?

A Widget Extension target modifies the `.pbxproj`, which is easiest/safer in Xcode than hand-editing.
