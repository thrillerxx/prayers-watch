Purpose: Runbook to generate baseline docs using the project/context/workflows layout.

# Project Setup Guide

Use this runbook to generate the documentation baseline before any coding. Complete each step in order—the outputs cascade into later prompts. All project docs live in `llm/project/`; supporting references go in `llm/context/`; repeatable runbooks go in `llm/workflows/`.

## Quick Start

- `llm/project/project-overview.md` is the most important document; keep it updated.
- Add focused references in `llm/context/` for specs or implementation notes you'll cite in prompts.
- Copy and adapt `llm/workflows/dev-env-local.md` for your stack.

## Phase 1 — Project Foundation

### Step 1 — Project Overview
- **Deliverable:** `llm/project/project-overview.md`
- **Capture:** purpose, goals, audience, primary features, guardrails.

### Step 2 — User Flow
- **Deliverable:** `llm/project/user-flow.md`
- **Capture:** end-to-end journey, major states, key actions per user persona.

### Step 3 — Tech Stack
- **Deliverable:** `llm/project/tech-stack.md`
- **Prompt:** Use project-overview and user-flow to recommend/confirm stack; list preferred technologies and alternatives.

### Step 4 — Stack Best Practices
- **Deliverable:** Update `llm/project/tech-stack.md` with usage notes, pitfalls, conventions.

## Phase 2 — Design Guidelines

### Step 5 — Design Principles
- **Deliverable:** `llm/project/design-rules.md` (research or inline summary).

### Step 6 — Design Rules
- **Deliverable:** `llm/project/design-rules.md` — principles, palette, typography, components, spacing, accessibility.

## Phase 3 — Project Rules

### Step 7 — Engineering Standards
- **Deliverable:** `llm/project/project-rules.md` — directory map, naming, documentation, workflow standards.

## Phase 4 — Development Enablement

### Step 8 — Agent Rules
- **Deliverable:** Sync into Cursor rules, `AGENTS.md`, and other agent handbooks.
- See `AGENTS.md` at repo root and the boilerplate agent rules.

### Step 9 — README Refresh
- **Deliverable:** Updated project README from project-overview, user-flow, tech-stack, project-rules.

## Phase 5 — Delivery Planning

### Step 10 — Phased Roadmap
- **Deliverables:** `llm/project/phases/setup-phase.md`, `mvp-phase.md`, optional follow-up phases.
- Each phase: scope, 3–5 actionable steps per feature, shippable.

### Step 11 — Review & Secure Checklist (Optional)
- **Deliverable:** `llm/project/phases/review-and-hardening-phase.md`.

## Phase 6 — Wrap-Up

### Step 12 — Documentation Audit
Confirm `llm/` contains: project-overview, user-flow, tech-stack, design-rules, project-rules, phases (README, phase-template, setup-phase, mvp-phase, optional review-and-hardening), context as needed, workflows (e.g. dev-env-local).

### Step 13 — Kickoff Prompt
Attach Agent Rules, setup-phase, tech-stack, project-overview, and dev-env workflow when starting development.

## Directory Quick Reference

```
llm/
├── README.md
├── project/
│   ├── setup.md
│   ├── current-state.md    # v1 RC, paths, operational rules, what's next
│   ├── project-overview.md
│   ├── user-flow.md
│   ├── tech-stack.md
│   ├── design-rules.md
│   ├── project-rules.md
│   └── phases/
│       ├── README.md
│       ├── phase-template.md
│       ├── setup-phase.md
│       ├── mvp-phase.md
│       └── review-and-hardening-phase.md (optional)
├── context/
├── implementation/
└── workflows/
```
