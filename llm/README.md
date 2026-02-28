Purpose: Explain the llm/ docs workspace and its project/context/workflows structure.

# LLM Docs Workspace

This folder is the source of truth for project planning and repeatable guidance used by humans and agents. It follows a four-part structure: `project/`, `context/`, `implementation/`, and `workflows/`.

## Structure

```
llm/
├── README.md                  # You are here — how this workspace works
├── project/                   # Canonical project plan and phases
│   ├── setup.md               # Start here — complete setup walkthrough
│   ├── project-overview.md    # Your project definition
│   ├── user-flow.md           # User journeys and states
│   ├── tech-stack.md          # Technology choices and conventions
│   ├── design-rules.md        # Visual language, accessibility, components
│   ├── project-rules.md       # Coding standards and workflows
│   └── phases/                # Iterative delivery plans
│       ├── README.md
│       ├── phase-template.md
│       ├── setup-phase.md
│       ├── mvp-phase.md
│       ├── review-and-hardening-phase.md (optional)
│       └── [additional-phase].md (optional)
├── context/                   # Focused, reusable references for implementation
├── implementation/            # Notes on what the app currently does and how
└── workflows/                 # Repeated operational runbooks
```

## Folder Intent

- **project/** — Product plan: overview, user flows, tech stack, design rules, engineering standards, phased roadmap.
- **context/** — Tight, implementation-oriented briefs (e.g. protocol summaries, domain models).
- **implementation/** — Documentation about what the app currently does and how it is implemented.
- **workflows/** — Runbooks you execute consistently (local build, CI, release).

## Conventions

- Begin each file with a single-line purpose note; keep files under 500 lines.
- Example templates end with `-example`; copy and rename for your project.
- Use descriptive kebab-case filenames.
- Update `project/` first; add supporting `context/` and `workflows/` as the project evolves.

## Getting Started

Start with [project/setup.md](project/setup.md) for the complete walkthrough.
