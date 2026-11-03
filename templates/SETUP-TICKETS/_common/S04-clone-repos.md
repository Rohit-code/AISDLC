# S4: Clone code repo(s) into workspace

## What
Clone all code repos for this project into the AISDLC workspace as siblings of the context repo.

## Why
Agents work across multiple repos (BE + FE + infra). They need them all locally for context reading, code editing, and git operations.

## Steps
1. For each repo the project uses:
   ```bash
   git clone <remote-url> <repo-name>
   ```
2. Add to AISDLC `.gitignore` so they stay as independent git repos
3. Update project context's `CLAUDE.md` Repos table with locations and remotes

## Idempotent check
```bash
test -d $MAIN_REPO/.git
```

## Acceptance
- Each declared repo is cloned as sibling directory
- Each has its own `.git` (not nested in AISDLC)
- `.gitignore` at AISDLC root excludes them
