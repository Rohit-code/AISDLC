# Project Context Template

Copy this directory to `<project>-context/` when setting up a new project with AISDLC (setup ticket S1).

## What This Is

The per-project context repo: project docs plus agent-operational files (contracts, indexes) and the project's board config. Code repos keep only their own `README.md` and `CLAUDE.md`.

## Structure

```
<project>-context/
├── CLAUDE.md          ← Project-specific instructions (fill in from template)
├── board-config.yml   ← Project board IDs (setup ticket S3)
├── docs/              ← Product Wiki + Tech Architecture docs — @project-wiki / @planner
├── contracts/         ← API contracts (OpenAPI 3.0) — published by @planner
└── indexes/           ← Codebase indexes — populated by size audits
```

## What goes where

| Content | Where it lives | Why |
|---------|---------------|-----|
| Product Wiki | `<project>-context/docs/Product-Wiki.md` | Cross-cutting product doc, one place for all repos |
| Tech Architecture BE / FE | `<project>-context/docs/TECH-Architecture-<scope>.md` | Next to the contracts and indexes agents read with it |
| API Contracts | `<project>-context/contracts/` | Agent-operational — @planner publishes, @tester/@builder/@fe-builder consume |
| Codebase Indexes | `<project>-context/indexes/` | Agent-operational — populated by size audits per `.claude/rules/size-audit.md` |
| Board IDs | `<project>-context/board-config.yml` | Same shape as the framework's `.claude/board-config.yml` |

## Setup steps

`/aisdlc-init` (`.claude/skills/aisdlc-init/SKILL.md`) files a setup ticket for each of these that is missing:

1. Copy this directory to `<project>-context/`
2. Rename `CLAUDE-TEMPLATE.md` → `CLAUDE.md` and fill in project details
3. Create `board-config.yml` with your project's board IDs
4. Run `@project-wiki` to generate v1 Product Wiki in `docs/`
5. First build ticket will run size audit → populates `indexes/`
6. First planning ticket will publish contracts → populates `contracts/`
