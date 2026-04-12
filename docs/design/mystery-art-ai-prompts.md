# Mystery art (AI) — prompts, checklist & export spec

This document captures **agreed product decisions** for Spotify-inspired polish, **20 full-bleed images** (one per individual mystery), and a **repeatable AI workflow** using **public-domain Catholic art only as inspiration** (style/mood/composition — do not reproduce copyrighted paintings pixel-for-pixel).

## Consolidated UI decisions (reference)

| Topic | Decision |
| --- | --- |
| Scope | Spotify-style polish **everywhere** (Rosary, Mass Responses, Library, Settings, complications where applicable). |
| Hero layout | **Full-bleed art (A)** with text and controls overlaid (gradient/scrim for legibility). |
| Prayer text | **Single scroll**; **only the active step line** is **bold + full opacity**; other lines **dimmed**. |
| Typography | **OFL fonts** bundled: e.g. **Cinzel** (titles/chrome), **Cormorant** (body prayer) — see repo `LICENSE` / About screen for attribution. |
| Default theme | **Marian blue** accent. |
| Theme settings | **5–8 named presets** (no free RGB sliders). |
| Mini-player | **Yes**: when browsing **Library** or **Mass**, show a **bottom bar** for the active session; **tap → return** to now playing. |
| Mystery art | **20 PNGs generated** and added to **Asset Catalog** (`joyful_1` … `luminous_5`); prompts below remain for **regeneration** or style tweaks. |
| Accessibility | **Polished**: prefer **readable contrast** and **materials** when allowed; when **Reduce Transparency** / **Increase Contrast** are on, swap to **solid scrims**, **stronger dividers**, and **higher-contrast text** (Spotify-like clarity, not washed-out). |
| Minimum watch | **Series 6+** (performance assumptions for full-bleed images). |

## Asset count: 20 mysteries (not 4 sets)

The app enum `RosaryMystery` names the **four sets**. Art is keyed per **individual mystery** (five per set) → **20 files**.

Suggested **asset basename** (snake_case, matches JSON/content style):

`joyful_1` … `joyful_5`, `sorrowful_1` … `sorrowful_5`, `glorious_1` … `glorious_5`, `luminous_1` … `luminous_5`

### Mystery titles (for prompts & QA)

**Joyful** — `joyful_1` The Annunciation · `joyful_2` The Visitation · `joyful_3` The Nativity · `joyful_4` The Presentation · `joyful_5` The Finding in the Temple  

**Sorrowful** — `sorrowful_1` The Agony in the Garden · `sorrowful_2` The Scourging · `sorrowful_3` The Crowning with Thorns · `sorrowful_4` The Carrying of the Cross · `sorrowful_5` The Crucifixion  

**Glorious** — `glorious_1` The Resurrection · `glorious_2` The Ascension · `glorious_3` The Descent of the Holy Spirit · `glorious_4` The Assumption · `glorious_5` The Coronation  

**Luminous** — `luminous_1` The Baptism in the Jordan · `luminous_2` The Wedding at Cana · `luminous_3` The Proclamation of the Kingdom · `luminous_4` The Transfiguration · `luminous_5` The Institution of the Eucharist  

## Aspect ratio & resolution (watch-first)

**Ratio:** **4:5 portrait** (width × height).  
**Why:** Apple Watch screens are **taller than wide**; full-bleed `aspectFill` will crop left/right or top/bottom depending on device. **4:5** keeps a **vertical focal subject** (figure or scene) centered so crops stay balanced on 41–49 mm watches.

**Pixel size:** **1536 × 1920 px** (single scale; divisible by 8). Export **PNG** or **WebP** (WebP preferred for size if Xcode pipeline supports it without quality loss).

**Safe composition:** Keep **faces, crosses, and main narrative action** in the **middle 60%** vertically; avoid critical detail in the **extreme top 15%** and **bottom 25%** (headers, progress, transport chrome).

**Look:** Moody but **not gloomy**; **soft golden rim light** or **candlelit** acceptable; **no modern elements**; **no text** in the image.

## Global negative prompts (append to every generation)

- No text, letters, watermarks, logos, UI, frames, or borders  
- No anachronistic clothing or objects  
- No gore for shock value (Sorrowful mysteries: dignified, restrained)  
- Do not copy or closely imitate one specific famous painting; **inspired by** traditional sacred art only  

## Master prompt template (fill `TITLE` and `MOOD`)

```text
Vertical sacred art for Catholic prayer app, full-bleed background. Subject: MYSTERY_TITLE — SCENE_DESCRIPTION in the tradition of European sacred art (Renaissance / Baroque influence), oil painting look, soft natural brushwork, reverent, dignified. Single clear focal scene, balanced composition for vertical crop. Color palette: deep shadows, warm highlights, subtle Marian blues and golds where appropriate. MYSTERY_MOOD. No text, no watermark, no frame. Photorealistic HDR photography excluded; painterly only.
```

## Per-mystery prompt seeds & checklist

Use **one row per asset**. Status: ☐ not started ☐ generated ☐ reviewed ☐ exported `basename.png`

### Joyful

| ID | Scene focus (customize MASTER) | Mood notes |
| --- | --- | --- |
| joyful_1 | Annunciation: Angel Gabriel and Mary at the moment of “Fiat”; lily or dove optional | humble wonder, soft light |
| joyful_2 | Visitation: Mary and Elizabeth embrace | joy, intimacy |
| joyful_3 | Nativity: Infant, Mary, Joseph, stable — gentle night | peace, warmth |
| joyful_4 | Presentation: Temple, Simeon or presentation gesture | solemn, light |
| joyful_5 | Finding in Temple: Young Jesus among teachers; Mary and Joseph approaching | relief, teaching |

### Sorrowful

| ID | Scene focus | Mood notes |
| --- | --- | --- |
| sorrowful_1 | Agony in the Garden: Jesus prays; cup suggested | heavy, still night |
| sorrowful_2 | Scourging at the pillar | restrained, no gratuitous violence |
| sorrowful_3 | Crowning with thorns | sorrow, dignity |
| sorrowful_4 | Carrying the Cross: Via Dolorosa | endurance, compassion |
| sorrowful_5 | Crucifixion: Wide composition, crosses on hill | sacred stillness, hope hinted |

### Glorious

| ID | Scene focus | Mood notes |
| --- | --- | --- |
| glorious_1 | Resurrection: Empty tomb or risen Christ in light | dawn, victory |
| glorious_2 | Ascension: Christ rising toward light, disciples below | upward motion |
| glorious_3 | Pentecost: Mary and apostles, flame symbols | gathering light |
| glorious_4 | Assumption: Mary lifted toward heaven | grace, glory |
| glorious_5 | Coronation: Mary crowned | heavenly court, regal |

### Luminous

| ID | Scene focus | Mood notes |
| --- | --- | --- |
| luminous_1 | Baptism in the Jordan: Jesus and John | water, light breaking |
| luminous_2 | Wedding at Cana: Jars, feast hint | joy, abundance |
| luminous_3 | Proclamation / call to conversion: Jesus teaching crowds or healing | clarity, invitation |
| luminous_4 | Transfiguration: Jesus radiant; Moses and Elijah suggested | brilliant, awe |
| luminous_5 | Last Supper / Eucharist: Bread and cup, gathered apostles | solemn, intimate |

## Export checklist (each file)

- ☐ Named `basename.png` (or `.webp`) matching table above  
- ☐ **1536 × 1920**, 4:5 portrait  
- ☐ Subject centered; safe margins respected  
- ☐ No text artifacts (re-generate if any)  
- ☐ File size reasonable (< ~600 KB WebP or < ~1.5 MB PNG if possible)  
- ☐ Visual pass at **watch thumbnail scale** (legible silhouette, not muddy)  

## Suggested theme presets (for implementation)

Implement as named bundles (accent, secondary label, scrim gradient stops) — exact values TBD in code:

1. **Marian** (default) — blue accent, cool scrim  
2. **Roman** — deep crimson accent, warm scrim  
3. **Desert / Lent** — violet or dusty purple  
4. **Easter** — white/gold accent, bright scrim  
5. **Pentecost** — flame gold / red accent  
6. **Ordinary** — soft teal or sage (calm)  
7. **Night prayer** — near-black base, silver-blue accent  
8. **High contrast** — pairs with accessibility settings  

## Generated assets (in repo)

Twenty images were **AI-generated** from the prompts above, saved into the watch target **Asset Catalog** as:

- `prayers/prayers Watch App/Assets.xcassets/joyful_1.imageset` … `joyful_5.imageset`
- `sorrowful_1` … `sorrowful_5`, `glorious_1` … `glorious_5`, `luminous_1` … `luminous_5`

Use in SwiftUI as `Image("joyful_1")` etc. **Implemented:** `MysteryArt.assetName(mystery:stepIndex:steps:)` maps the current **decade (1–5)** + set key to the asset name; `RosaryView` uses it as a full-bleed hero with gradient scrim and themed chrome (`AppColorTheme`).

## Mass Responses

Use the **same** visual language and theme tokens as Rosary. **Mass-specific** hero art can be a **second batch** later (e.g. one per major section); this document covers **Rosary mysteries only** unless expanded.

## License & attribution

- Bundled **Cormorant** / **Cinzel**: retain **SIL OFL** notices in app credits.  
- **AI images**: treat as **app assets**; do not claim historical authenticity; optional “Artwork generated for Divinity” in About if desired.
