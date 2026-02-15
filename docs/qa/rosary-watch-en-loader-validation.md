# QA: Rosary Watch EN prayer JSON loader validation

## Scope
Validate the watchOS app deterministically loads the **English** Rosary core prayers JSON from a single, uniquely named bundled resource.

## Root cause summary
The repo contained **multiple JSON resources** with overlapping names (e.g. multiple `prayers.json` variants). `Bundle.main.url(forResource:"prayers", withExtension:"json")` can resolve ambiguously when duplicates exist in the bundle inputs, leading to the app parsing an unintended payload and throwing runtime JSON errors (e.g. “Unterminated string in JSON at position …”).

## Deterministic loader fix summary
- Introduced a uniquely named canonical resource: `rosary_prayers_en.json`.
- Updated `PrayerStore.load()` to load **only** `rosary_prayers_en.json` (no heuristic selection).
- Added DEBUG-only duplicate detection: counts bundle matches for `rosary_prayers_en.json` and asserts if >1.

## Duplicate resource cleanup summary
- Removed legacy `prayers.json` duplicates from the watch app sources so the bundle contains a single, unambiguous prayer resource.

## Evidence (trimmed)
Runtime probe captured from the watch simulator app container:

```
[PrayerStore] Probe: starting
[PrayerStore] Resolved: /Users/thrillerx/Library/Developer/CoreSimulator/Devices/E28019DD-F968-4087-8E1D-0A9DC2BA44D5/data/Containers/Bundle/Application/F6BC396B-D3F0-42BC-920B-641C052C1F61/prayers Watch App.app/rosary_prayers_en.json | Bytes: 1685
[PrayerStore] Decode: OK
[PrayerStore] Entries: 9
[PrayerStore] Probe: done
```

## Probe commits (temporary, reverted)
- Probe commit (adds DEBUG-only startup load + evidence capture): `0efefb0`
- Revert commit (restores pre-probe behavior): `4491e7c`

## Current stable commit line
- Stable HEAD on `main` after probe revert: `4491e7c`

## Regression guard
`PrayerStore.load()` contains a DEBUG assertion that fails fast if multiple `rosary_prayers_en.json` matches are present in the bundle.

## Follow-up (explicitly out of scope)
TODO: Add Spanish prayer content + selection (ES rollout) in a separate work item; do not expand scope of the current EN-only deterministic loader validation.
