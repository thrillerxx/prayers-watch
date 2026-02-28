Purpose: Visual language, accessibility, and component conventions for Prayers Watch.

# Design Rules

## Design Direction
- **Watch-first, calm, focused.** The app is used during prayer; avoid visual noise, respect small screens, and keep interactions simple and predictable.
- **Readable and listenable.** Text must be legible (Dynamic Type); TTS is a first-class path; transport controls (play/pause/stop) are consistent everywhere speech is used.

## Principles
- **Clarity over decoration.** Prioritize legible text and clear hierarchy; avoid unnecessary animation or busy backgrounds.
- **Consistent transport.** Play/pause/stop appear in the same conceptual place (e.g. top of content or sticky) in Rosary and Prayer Library when speech is active.
- **Respect system.** Use system fonts and semantic styles (e.g. `.headline`, `.body`); support Dynamic Type and accessibility labels.

## Color & Typography
- Prefer **system colors** and semantic styles (e.g. `.primary`, `.secondary`) so light/dark and accessibility work by default.
- **Typography:** System font; serif for titles/headings where it fits the tone (e.g. Rosary step title); body for prayer text; avoid custom fonts unless necessary for liturgy.
- **Accent:** Use `AccentColor` / asset for primary actions (e.g. play); keep palette minimal.

## Components & Patterns
- **Lists:** Standard List + NavigationLink for main nav and prayer list; compact rows on watch.
- **Rosary step:** Clear step title (marquee if long); prayer text; next/back and transport where applicable.
- **Transport row:** Play/pause (prominent) + stop; same component or pattern in Rosary and Library.
- **Long titles:** Marquee or single-line truncation; no overlapping with back button (safe insets).

## Spacing & Layout
- Use consistent padding (e.g. 8–16 pt) and avoid cramped tap targets; minimum touch target per platform (watch vs phone).
- **Navigation:** Shallow depth; back chevron and title never overlap (use safe area and content below nav title if needed).

## Accessibility
- **Labels:** Every interactive element has an accessibility label or hint where it adds clarity.
- **Dynamic Type:** Support scaled text; test with larger sizes.
- **Reduce Motion:** Respect system setting for animations (e.g. marquee); provide static fallback when appropriate.
- **VoiceOver:** Ensure order and labels make sense for full Rosary and prayer list navigation.

## Guardrails
- No auto-playing TTS without user action (play button or step advance).
- No modal or full-screen takeover unless necessary (e.g. completion); prefer inline state.
- Keep one canonical prayer/rosary data source; no conflicting or duplicate content in UI.
