# Mass Responses Text -- Licensing Assessment

## Source material

The file `prayers/prayers Watch App/mass_responses_en.txt` contains excerpts from **The Roman Missal, Third Edition** (English translation).

Copyright holder: **International Commission on English in the Liturgy Corporation (ICEL)**

The file already includes the attribution line from the source PDF:
> Excerpts from the English translation of The Roman Missal © 2011, International Committee on English in the Liturgy, Inc. All rights reserved.

Note: the correct corporate name used in current ICEL policy documents is "International **Commission** on English in the Liturgy **Corporation**" with a copyright year of **2010**. The "2011 / Committee" variant appears in the FAITHCatholic source PDF. Either form is acceptable per ICEL guidance, but aligning to the canonical form is recommended.

## ICEL policy summary (as of April 2026)

Source: <https://icelweb.org/copyright.htm> and <https://www.icelweb.org/PubPolicy.PDF>

### No royalty or permission required when ALL of these conditions are met:

1. The publication is **not produced by a publishing firm**.
2. The publication is **not sold** (no fee charged to access).
3. The appropriate **ICEL copyright notice** appears on the cover, inside cover, or title page.
4. The **official texts are followed exactly** (verbatim, including capitalization and punctuation).

### Royalty or flat fee IS required when:

- The publication is **produced for sale** (books, apps sold for money, CDs, electronic media, etc.).
- The publisher is a publishing firm.

### Internet / electronic distribution:

ICEL allows reproduction on non-commercial sites without written permission, provided:

1. No fee is charged to access the content.
2. Proper ICEL copyright acknowledgment appears.
3. Texts are followed exactly.

## Assessment for Divinity (prayers-watch)

| Criterion | Status |
|---|---|
| Produced by a publishing firm? | No -- personal/independent project |
| Sold for money? | TBD -- depends on App Store pricing |
| Copyright notice included? | Partially -- the FAITHCatholic attribution is in the text file, but needs refinement |
| Texts followed exactly? | Mostly -- minor OCR artifacts exist (e.g. `P riest` with space) from the source PDF |

## Recommendations

### Required before shipping:

1. **Fix OCR artifacts** in `mass_responses_en.txt` to match official text exactly:
   - `P riest` -> `Priest`
   - `P eople` -> `People`
   - `P EOP LE` -> `People`
   - `oR` -> `Or`
   - Remove the `www.FAITHCatholic.com` footer line (not part of the liturgical text)

2. **Add canonical ICEL copyright notice** to the app. Display it either:
   - At the bottom of the Mass Responses screen, or
   - In a dedicated "About / Attributions" section in Settings

   Recommended text:
   > Excerpts from the English translation of The Roman Missal © 2010, International Commission on English in the Liturgy Corporation. All rights reserved.

3. **Keep the app free** (no purchase price). This removes the royalty obligation entirely.

### If you want to charge for the app:

- Contact ICEL directly at **permission@eliturgy.org** to request a license.
- ICEL grants non-exclusive licenses; the fee varies.
- USCCB policy page: <https://www.usccb.org/committees/divine-worship/policies/copyright-permissions-requirements>

### Optional but recommended:

- Contact **permission@eliturgy.org** for explicit written confirmation even for free distribution, to have documentation on file.
- The Apostles' Creed text also appears in the file (after the source attribution). This is also ICEL-translated and covered by the same copyright notice.

## Status

- [ ] Fix OCR artifacts in mass_responses_en.txt
- [ ] Add ICEL copyright notice to the app UI
- [ ] Confirm app pricing model (free = no license needed)
- [ ] (Optional) Email permission@eliturgy.org for written confirmation
