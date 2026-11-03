# <Project Name> — Agent Context

This repo holds **agent-operational files** for the <Project Name> project. Indexes and contracts that AI agents read during planning and building. Not documentation — docs live in the code repos.

## What Lives Here

```
<project>-context/
├── CLAUDE.md                        ← You are here
├── contracts/                       ← API contracts (OpenAPI 3.0) — published by @planner
└── indexes/                         ← Codebase indexes — populated by size audits
    ├── Codebase-Index-BE.md         ← BE size audit — every file with LOC, RED/YELLOW status
    └── Codebase-Index-FE.md         ← FE size audit — every component with LOC, RED/YELLOW status
```

## What lives where

| Content | Location | Why |
|---------|----------|-----|
| Product Wiki | `<project>-be/docs/Product-Wiki.md` | Cross-cutting product doc, lives in main repo |
| Tech Architecture BE | `<project>-be/docs/TECH-Architecture-BE.md` | Describes BE code, travels with BE code |
| Tech Architecture FE | `<project>-fe/docs/TECH-Architecture-FE.md` | Describes FE code, travels with main FE repo |
| API Contracts | `<project>-context/contracts/` | Agent-operational, published by @planner |
| Codebase Indexes | `<project>-context/indexes/` | Agent-operational, populated by size audits |

## Board

<!-- Fill in from .claude/board-config.yml -->
Board: [<Project> - AI SDLC Pipeline](<board URL>)

## Repos

| Repo | Location | Git Remote |
|------|----------|-----------|
| <project>-be | `../<project>-be/` | <remote URL> |
| <project>-fe | `../<project>-fe/` | <remote URL> |

## GitHub CLI

Use `/opt/homebrew/bin/gh` for GitHub operations.
