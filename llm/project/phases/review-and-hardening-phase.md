Purpose: Optional phase for review, accessibility, and release readiness.

# Review and Hardening Phase

## Goals
- Review MVP against project overview and design rules; fix gaps.
- Harden for release: accessibility, edge cases, and basic release checklist.
- Document any remaining constraints and open questions.

## Inputs
- `llm/project/project-overview.md`
- `llm/project/tech-stack.md`
- `llm/project/project-rules.md`
- `llm/project/design-rules.md`
- `llm/implementation/` notes as relevant

## Scope
- **In scope:** Accessibility (labels, Dynamic Type, VoiceOver, reduce motion); error and edge-case handling; content review (prayer text); release steps and versioning; optional tests for critical paths.
- **Out of scope:** New features; backend; full localization unless scoped separately.

## Steps
1. **Accessibility pass**
   - Add or refine accessibility labels and hints for Rosary and Prayer Library; ensure VoiceOver order is logical.
   - Verify Dynamic Type and reduce motion (e.g. marquee fallback); document in design-rules if needed.
2. **Edge cases and errors**
   - Empty or malformed JSON; missing voice; speech interrupted by system; document behavior and surface user-facing messages where appropriate.
3. **Content and liturgical review**
   - Confirm prayer/rosary text source and any review process; note in project-overview or implementation.
4. **Release checklist**
   - Version and build number; TestFlight or App Store steps if applicable; document in `llm/workflows/` (e.g. release or build runbook).
5. **Docs and exit**
   - Update `llm/implementation/` and README with release-related notes; list open questions or future work.

## Exit Criteria
- Accessibility improvements applied and documented.
- Known edge cases and errors documented; user-facing behavior is clear.
- Release path (e.g. archive, TestFlight) documented; versioning approach stated.
- Optional: basic regression or smoke test for Rosary and Library flows.
