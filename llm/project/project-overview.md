Purpose: Canonical project definition for Prayers Watch — purpose, scope, audience, features, and guardrails.

# Project Overview — Prayers Watch

## Snapshot
- **Project:** Prayers Watch (Divinity)
- **Type:** watchOS (and companion iOS) app for Catholic prayers and guided Rosary
- **Approach:** Documentation-first, iterative delivery; single source of truth in `llm/`
- **Model:** Native Swift/SwiftUI; bundled JSON for prayer content; text-to-speech for guided prayer

## Mission & Outcomes
Deliver a simple, reliable watch and phone experience for praying the Rosary and browsing a prayer library. Users can follow the Rosary step-by-step with optional spoken guidance, or read and listen to individual prayers. Success means: clear navigation on a small screen, correct liturgical content, and a calm, focused UI suitable for prayer.

## Core Objectives
- **Guided Rosary:** Full Rosary with mysteries, steps, and optional TTS (play/pause/stop).
- **Prayer Library:** List of prayers with detail view and speak/listen.
- **Watch-first:** Layout and interactions optimized for watchOS (e.g. marquee for long titles, compact controls).
- **Single canonical data:** One bundled prayer/rosary resource (e.g. `rosary_prayers_en.json`) as source of truth; no server dependency.
- **Settings:** User preferences (e.g. TTS, language) where applicable.

## Audience & Personas
- **Catholic users** who pray the Rosary or common prayers on the go.
- **Watch wearers** who want prayer content and guidance on the wrist.
- **Anyone** seeking a minimal, respectful prayer app without accounts or ads.

## Delivery Roadmap (high level)
- **Setup:** Xcode project, watch + iOS targets, minimal shell (nav: Rosary, Prayer Library, Settings).
- **MVP:** Rosary flow with mysteries/steps and TTS; Prayer Library load + detail + speak; shared speech state; bundled JSON.
- **Later:** Polish (accessibility, localization), complications (WidgetKit), optional review/hardening.

## Architecture & Stack
- **Platforms:** watchOS (primary), iOS companion.
- **UI:** SwiftUI; NavigationStack; list/detail and Rosary step UIs.
- **Data:** Bundled JSON (`rosary_prayers_en.json`); `PrayerStore` for loading; `Prayer`/catalog models.
- **Speech:** `AVSpeechSynthesizer` via shared `SpeechManager` (singleton); play/pause/stop; optional rate/language.
- **Storage:** No server; optional local preferences (UserDefaults) for settings.

## Constraints & Risks
- **Content accuracy:** Prayer text must be liturgically appropriate; source and review process matter.
- **Single bundle:** One canonical JSON per locale/version to avoid duplicate or conflicting copies.
- **Simulator TTS:** Speech may be muted or behave differently than on device; document and test on real hardware.
- **Watch space:** Small screen; avoid clutter; long titles use marquee or truncation by design.

## v1 Scope (Current Baseline)
- **In scope for v1:** EN only; deterministic prayer content loading; Rosary flow with mysteries and core prayers; Prayer Library with playable prayers; single active audio session; readable watch UI; basic automated watch UI coverage; release candidate tags pinned to known good commits.
- **Out of scope for v1:** Spanish; Mystery Picker redesign / day-based mystery defaults; new schema expansion beyond what is already needed; big feature changes beyond stabilization and small UX polish.

For the **pinned RC, canonical paths, build environment, and operational rules**, see **`llm/project/current-state.md`**.

## Success Criteria
- **Setup:** App runs on Watch Simulator and device; build/lint from CLI and Xcode.
- **MVP:** User can complete a full Rosary with optional TTS; browse and speak prayers from the library; transport (play/pause/stop) consistent across Rosary and Library.
- **Ongoing:** Docs in `llm/` stay the source of truth; new features align with project-rules and phases.
