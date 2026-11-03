# S1: Create `<project>-context/` from PROJECT-CONTEXT template

## What
Create the project's context repo from `templates/PROJECT-CONTEXT/`. This holds the project docs (`docs/`), agent-operational files (indexes, contracts) and the project's `board-config.yml`.

## Why
Every AISDLC project needs a context repo so agents have a known location for docs, codebase indexes and API contracts. Without this, agents have no cross-repo memory.

## Steps
1. `cp -r templates/PROJECT-CONTEXT/ <project>-context/`
2. Rename `CLAUDE-TEMPLATE.md` → `CLAUDE.md` inside the copy
3. Fill in project-specific fields: project name, board URL, repo list
4. `cd <project>-context && git init && git add . && git commit -m "Initial context repo"`
5. Create GitHub repo `<owner>/<project>-context` (`gh repo create <owner>/<project>-context --private --source . --push`; `<owner>` is a user login or an org)

## Idempotent check
```bash
test -f "$CONTEXT_DIR/CLAUDE.md"
```

## Acceptance
- `<project>-context/` directory exists at repo level
- `CLAUDE.md` is filled in (no `<Project Name>` placeholders left)
- `docs/`, `contracts/` and `indexes/` directories exist (may be empty)
- Pushed to GitHub as its own repo
- Listed in the workspace `.gitignore` (if the workspace is a repo) so it doesn't nest
