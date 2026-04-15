Purpose: Record the March 19, 2026 RC sanity pass and audio artifact preservation run.

# RC Sanity + Audio Record (2026-03-19)

## Baseline decision
- Release-validation baseline remains pinned to tag `rosary-watch-en-final-ui-rc` (peeled commit `21fde32`).
- Active development continues on `main`.

## RC baseline confirmation (remote Mac)
- Host: private SSH target (macOS builder; not recorded in-repo)
- `git describe --tags --always --dirty`: `rosary-watch-en-final-ui-rc`
- `git rev-parse HEAD`: `21fde32a87b6830c791c1581e3cca9f7935fdc32`
- `git log -1 --format=%ci`: `2026-02-26 20:42:56 -0600`

## Sanity/build checks run on RC
- `xcodebuild build` passed for:
  - `Apple Watch Series 11 (42mm)`
  - `Apple Watch Ultra 3 (49mm)`
- `xcodebuild test` on RC with scheme `prayers Watch App` passed for the watch targets available in that scheme.
- Build logs and `xcresult` from this pass were kept **outside** the public tree (they embed machine-specific paths). Regenerate locally if needed.

## Mainline test stabilization verification
- Branch: `main` at commit `b63e72c`.
- Ran repeated remote UI test passes (`prayers-watch-uitests`) on `Apple Watch Series 11 (42mm)`.
- Result: passes across repeated runs after transport-flow test hardening.

## Audio artifacts (RC)
- Existing RC-correct audio capture artifacts were found on remote Mac and preserved into canonical repo:
  - `artifacts/audio/2026-03-19/rosary-watch-en-final-ui-rc_21fde32/watch-rc-audio.mp3`
  - `artifacts/audio/2026-03-19/rosary-watch-en-final-ui-rc_21fde32/watch-rc-audio.wav`
- `afinfo` (remote) reported:
  - MP3 duration: `119.688000 sec`
  - WAV duration: `119.642667 sec`

## Notes
- RC tag does not include the newer dedicated scheme name `prayers-watch-uitests`; for RC sanity runs use scheme `prayers Watch App`.
