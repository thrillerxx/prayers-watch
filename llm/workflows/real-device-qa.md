Purpose: Manual QA checklist for Divinity on a physical Apple Watch.

# Real-device QA

Use after [real-device-install.md](real-device-install.md). Simulator TTS and layout lie; this pass is the one that counts.

Record: git SHA (`git rev-parse --short HEAD`), Watch model/size, watchOS version, iPhone model/iOS.

## Launch

- [ ] App icon present on the Watch (and iOS companion on the phone).
- [ ] First paint under a few seconds; no crash loop on the Apple logo.
- [ ] Home shows Rosary, Prayer Library, Mass Responses, Settings; titles readable.

## Rosary

- [ ] Open Rosary; mystery picker then now-playing; titles readable on the smallest face you care about.
- [ ] Mystery cover sits in the band **above** the transport (not parked on the chin).
- [ ] Play / Pause toggles; Stop clears the session.
- [ ] Auto mode advances without overlapping speech (Auto lives in Settings).
- [ ] Two speech-speed presets; pause-between-parts feels deliberate.
- [ ] Back to home and re-enter does not leave a zombie TTS session.

## Prayer Library

- [ ] List loads real prayers (not “No prayers found”).
- [ ] Metadata-only rows are not tappable.
- [ ] Start one prayer, then another: only the new one speaks.
- [ ] Long text scrolls; controls do not cover the last lines.

## Settings + icons

- [ ] Speech speed change applies to the next playback.
- [ ] Alternate app icons (if offered) sync to Watch and iOS without crash.

## Complications (optional)

- [ ] Add the Divinity complication; tap opens the app.

## Audio

- [ ] Watch not in Silent Mode (or confirm haptics-only if that is expected).
- [ ] Spoken Hail Mary counter stays on screen and is **not** spoken.

## Fail / capture

If something breaks, note the screen and SHA. On the Mac, a Simulator capture is extra evidence (`docs/ui-capture.md`) but does not replace this list.

For RC comparison only, also follow [v1-sanity-pass.md](v1-sanity-pass.md) on tag `rosary-watch-en-final-ui-rc`.
