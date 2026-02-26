# Rosary Watch (EN) — QA RC

Tag: `rosary-watch-en-qa-rc`

## What’s included

### Content (EN-only)
- Single deterministic bundled content source: `rosary_prayers_en.json`.
- Core prayers:
  - Sign of the Cross (`sign_of_cross`)
  - Apostles’ Creed (`apostles_creed`)
  - Our Father (`our_father`)
  - Hail Mary (`hail_mary`)
  - Glory Be (`glory_be`)
  - Hail Holy Queen (`hail_holy_queen`)
  - Rosary Prayer (`rosary_prayer`)
  - Fatima Prayer (`fatima`)
- Added devotional prayers:
  - Memorare (`memorare`)
  - The Angelus (`angelus`)
  - Act of Contrition (`act_of_contrition`)
  - Eternal Rest (`eternal_rest`)
- Rosary mysteries fully populated for all sets (Joyful, Luminous, Sorrowful, Glorious): 1–5 title + meditation.

### Rosary playback + pacing
- One global speech session at a time (starting a new prayer interrupts current speech).
- Auto mode pacing:
  - Speech speed presets (incl. Very Slow).
  - Pause between parts (1–10s).
- Silent on-screen Hail Mary counter during decades (UI only, not spoken).
- Manual navigation:
  - Next/Back works even if speech is active; manual transitions stop current speech and advance immediately.
- Race hardening for Auto + rapid Next taps:
  - generation token guards stale callbacks
  - cancellable auto-advance task
  - re-entrancy guard + small debounce on Next

### Prayer Library
- Library lists only real prayable entries; excludes metadata/title-only rows:
  - excludes `mysteryset_*`
  - excludes `*_title` and `*_alt_title`
  - keeps meditations and core prayers
- Selecting a prayer while audio is active:
  - stops current playback immediately
  - starts the new prayer immediately

## How to run the headless watch UI tests

Scheme: `prayers-watch-uitests`

```bash
rm -rf /tmp/uitest-results.xcresult /tmp/uitest.log
xcodebuild test -project prayers.xcodeproj \
  -scheme prayers-watch-uitests \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (42mm)' \
  -resultBundlePath /tmp/uitest-results.xcresult \
  CODE_SIGNING_ALLOWED=NO > /tmp/uitest.log 2>&1 || (tail -n 120 /tmp/uitest.log; exit 1)

tail -n 80 /tmp/uitest.log
```

Tests included:
- Rosary: Auto + rapid Next spam (10 taps) should not freeze; should advance off the initial step.
- Library: selecting a new prayer interrupts current playback and shows the new prayer.

## Known limitations / TODOs
- EN-only for now; Spanish UI toggles removed/disabled in the stabilized watch app.
- UI tests are best-effort on Simulator; they validate navigation + non-freeze behavior, but do not verify actual audio output.
- Consider removing the legacy top-level `prayers Watch App/` directory after confirming nothing references it.
- Consider migrating `xcresulttool get` usage away from `--legacy` when convenient.

## Optional: TestFlight / internal distribution (no code changes)
- Open Xcode → Product → Archive.
- Distribute via TestFlight (internal group) after signing is configured.
- Use tag `rosary-watch-en-qa-rc` as the source commit for the build.
