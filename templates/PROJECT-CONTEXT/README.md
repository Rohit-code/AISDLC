# Project Context Template

Copy this directory to `<project>-context/` when setting up a new project with AISDLC.

## What This Is

Agent-operational files. Not documentation — docs live in the code repos they describe.

## Structure

```
<project>-context/
├── CLAUDE.md          ← Project-specific instructions (fill in from template)
├── contracts/         ← API contracts (OpenAPI 3.0) — published by @planner
└── indexes/           ← Codebase indexes — populated by size audits
```

## What goes where

| Content | Where it lives | Why |
|---------|---------------|-----|
| Product Wiki | `<project>-be/docs/Product-Wiki.md` | Cross-cutting product doc, lives in main code repo |
| Tech Architecture BE | `<project>-be/docs/` | Describes BE code, travels with BE code |
| Tech Architecture FE | `<project>-fe/docs/` | Describes FE code, travels with main FE repo |
| API Contracts | `<project>-context/contracts/` | Agent-operational — @planner publishes, @tester/@builder/@fe-builder consume |
| Codebase Indexes | `<project>-context/indexes/` | Agent-operational — populated by size audits per `.claude/rules/size-audit.md` |

## Why docs live in code repos, not here

- Docs travel with the code they describe — no extra repo to manage
- When you hand off a repo, the docs go with it naturally
- Engineers look in the repo first, not in a separate context repo
- Indexes and contracts are agent plumbing — they don't belong in a docs folder

## Setup steps

1. Copy this directory to `<project>-context/`
2. Rename `CLAUDE-TEMPLATE.md` → `CLAUDE.md` and fill in project details
3. Update `.claude/board-config.yml` with your project's board IDs
4. Add `docs/` directories to your code repos for product documentation
5. Run `@project-wiki` to generate v1 Product Wiki in the main code repo
6. First build ticket will run size audit → populates `indexes/`
7. First planning ticket will publish contracts → populates `contracts/`
