Purpose: Template for drafting any project phase.

# Phase Template

Use this file as a scaffold when drafting a new phase. Replace placeholders and keep the plan specific, shippable, and short.

## Goals
- [One sentence on what this phase delivers and why it matters.]

## Inputs
- `llm/project/project-overview.md`
- `llm/project/user-flow.md`
- `llm/project/tech-stack.md`
- `llm/project/project-rules.md`

## Scope
- In scope:
- Out of scope:

## Steps (per feature)
1. **Context** — Summarize requirements and key constraints.
2. **Implementation** — Implement to satisfy the phase goals.
3. **Verification** — Run tests / manual checks; update `llm/implementation/` as needed.

## Exit Criteria
- [Core behavior matches phase goals.]
- [Relevant docs updated.]

## Suggested Agent Prompt
```
Create or update [phase-name].md using @llm/project/project-overview.md, @llm/project/user-flow.md, @llm/project/tech-stack.md, @llm/project/project-rules.md.
Keep scope tight and list 3–5 actionable steps per feature.
```
