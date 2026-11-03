# S4: Clone code repo(s) into workspace

## What
Clone all code repos for this project into the AISDLC workspace as siblings of the context repo.

## Why
Agents work across multiple repos (BE + FE + infra). They need them all locally for context reading, code editing, and git operations.

## Steps
1. For each repo the project uses:
   ```bash
   git clone -o <remote> <remote-url> <repo-name>   # <remote> = the stack file's `remote` key
   ```
   ERP: `git clone -o github git@github-regnus-tech:RegnusTech/erp-core.git erp-core` (`github-regnus-tech` is an SSH host alias on Rohit's Mac; others use `git@github.com:RegnusTech/erp-core.git`).
2. The workspace is the AISDLC clone: add each repo folder to its `.gitignore` so they stay independent git repos
3. Update project context's `CLAUDE.md` Repos table with locations and remotes

## Idempotent check
```bash
test -e "$MAIN_REPO/.git"
```

## Acceptance
- Each declared repo is cloned as sibling directory
- Each has its own `.git` (not nested in AISDLC)
- The workspace `.gitignore` (if any) excludes them
