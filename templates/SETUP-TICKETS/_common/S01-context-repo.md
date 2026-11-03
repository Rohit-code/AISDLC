# S1: Create `<project>-context/` from PROJECT-CONTEXT template

## What
Create the project's context repo from `templates/PROJECT-CONTEXT/`. This holds agent-operational files (indexes, contracts). Docs live in code repos, not here.

## Why
Every AISDLC project needs a context repo so agents have a known location for codebase indexes and API contracts. Without this, agents have no cross-repo memory.

## Steps
1. `cp -r templates/PROJECT-CONTEXT/ <project>-context/`
2. Rename `CLAUDE-TEMPLATE.md` → `CLAUDE.md` inside the copy
3. Fill in project-specific fields: project name, board URL, repo list
4. `cd <project>-context && git init && git add . && git commit -m "Initial context repo"`
5. Create GitHub repo `<org>/<project>-context` and push

## Idempotent check
```bash
test -f <project>-context/CLAUDE.md
```

## Acceptance
- `<project>-context/` directory exists at repo level
- `CLAUDE.md` is filled in (no `<Project Name>` placeholders left)
- `contracts/` and `indexes/` directories exist (may be empty)
- Pushed to GitHub as its own repo
- Listed in AISDLC `.gitignore` so it doesn't nest
