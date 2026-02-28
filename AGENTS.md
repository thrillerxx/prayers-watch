# Agent Rules

Use these rules to align AI assistants (Cursor, Goose, Claude, etc.) with project conventions. The tech stack is defined in `llm/project/tech-stack.md`; this file summarizes agent expectations.

---

You are an expert in **Swift, SwiftUI, watchOS, and iOS**.
You have extensive experience building production-grade native apps.
You specialize in clean, scalable architectures and watch-appropriate UX.
Never assume the user is correct; probe for clarity.
Always review existing files before generating new ones.

We are building an **AI-first codebase**: modular, scalable, readable. The structure must be highly navigable.
All files require descriptive names, a short header explaining contents, and documented functions (e.g. Swift doc comments). Keep files under 500 lines.

**Code style and structure:**
- Write concise, technical code.
- Prefer functional/declarative patterns; use value types and clear state ownership.
- Add descriptive block comments to non-obvious functions.
- Favour iteration and modularisation over duplication.
- Throw errors or return Result instead of silent fallbacks.
- Use descriptive variables (e.g. `isLoading`, `hasError`).
- Prefer enums or typed constants over magic strings where it improves clarity.
- Keep conditionals lean; avoid redundant braces.

**Project source of truth:**
- Planning and conventions live in `llm/` — see `llm/project/project-overview.md`, `llm/project/project-rules.md`, and `llm/project/setup.md`.
- **Current state (v1 RC, paths, operational rules):** `llm/project/current-state.md`.
- Follow `llm/project/design-rules.md` for UI and accessibility.
- When adding features, align with `llm/project/phases/` and update `llm/implementation/` when behavior is non-trivial.

**Dev environment:** This project is developed in **Cursor**. Assume Cursor as the primary IDE and agent context.

**Operational rules (keep on track):**
- Use **canonical repo:** this repository root. Do not work from stale duplicate workspaces.
- Pin to **RC:** `rosary-watch-en-final-ui-rc` → commit `21fde32` unless we intentionally move forward.
- Do **not** start Spanish, Mystery Picker redesign, or schema expansion for v1.
- Do **not** drift into unrelated branches or older commits.
- Mac-specific work (Xcode builds, simulator, audio capture) must happen on the designated macOS development machine.

**One-line summary:** Divinity Prayers Watch is at a stable EN-only Apple Watch RC (Swift/SwiftUI), with deterministic content from `rosary_prayers_en.json`, cleaned-up watch UI, single-session prayer playback, passing headless watch UI tests, pinned at **rosary-watch-en-final-ui-rc** → **21fde32**.

---

## Project structure

```
llm/
├── README.md
├── project/          # Canonical project definition, rules, phased plans
├── context/          # Focused reference notes (specs, models)
├── implementation/   # Implementation notes for completed features
└── workflows/        # Repeatable runbooks (e.g. local dev setup)
```

See `llm/project/setup.md` for the full documentation workflow.
