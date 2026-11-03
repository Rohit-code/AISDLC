# <Project Name> — Agent Context

This repo holds the **project docs and agent-operational files** for the <Project Name> project: docs, contracts and indexes that AI agents read during planning and building, plus the project's board config.

## What Lives Here

```
<project>-context/
├── CLAUDE.md                        ← You are here
├── board-config.yml                 ← Project board IDs
├── docs/                            ← Product-Wiki.md, TECH-Architecture-BE.md, TECH-Architecture-FE.md
├── contracts/                       ← API contracts (OpenAPI 3.0) — published by @planner
└── indexes/                         ← Codebase indexes — populated by size audits
    ├── Codebase-Index-BE.md         ← BE size audit — every file with LOC, RED/YELLOW status
    └── Codebase-Index-FE.md         ← FE size audit — every component with LOC, RED/YELLOW status
```

## Board

<!-- Fill in from board-config.yml in this repo -->
Board: [<Project> - AI SDLC Pipeline](<board URL>)

## Repos

| Repo | Location | Git Remote |
|------|----------|-----------|
| <project>-be | `../<project>-be/` | <remote URL> |
| <project>-fe | `../<project>-fe/` | <remote URL> |

## GitHub CLI

Use plain `gh` for GitHub operations (recipes: `.claude/rules/gh-recipes.md` in the workspace (the AISDLC clone)). The board owner is a user login or an org: `--owner <owner>`.
