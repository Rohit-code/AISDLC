# S8: Add CLAUDE.md to each code repo

## What
Every code repo needs a `CLAUDE.md` at its root with codebase-specific context — stack, patterns, setup, conventions.

## Why
Agents read `CLAUDE.md` first when they touch a repo. Without it, they guess at conventions. With it, a new agent (or new engineer) knows how the codebase works in minutes.

## Steps
1. Review the repo structure, package files, existing docs
2. Draft CLAUDE.md with sections:
   - **Stack** — languages, frameworks, major libs
   - **Local Setup** — prerequisites, install, run, test commands
   - **Conventions** — code style, testing patterns, default branch (PR target)
   - **Structure** — directory layout at a high level
   - **Gotchas** — non-obvious behavior, known issues
   - **Related repos** — cross-repo dependencies
   - **Environment variables** — what's in `.env.example`
3. Commit and push

## Idempotent check
```bash
test -f "$MAIN_REPO/CLAUDE.md"
```

## Acceptance
- `CLAUDE.md` at repo root
- Covers all 7 sections above
- A new engineer can clone + follow setup without asking questions
- Committed
