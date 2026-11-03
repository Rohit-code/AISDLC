# S10: Create `release/ai-sdlc-v1` branch on each repo

## What
Create a `release/ai-sdlc-v1` branch on every code repo. This is the integration branch for feature work per the release-branch flow.

## Why
AISDLC uses release-branch flow: feature branches → release branch → master. The release branch must exist before any feature branch can target it.

## Steps
For each repo:
1. Identify the actual default/working branch (might be `main`, `master`, or `dev` — check each repo; they can differ)
2. `git checkout <active-branch> && git pull`
3. `git checkout -b release/ai-sdlc-v1`
4. `git push -u origin release/ai-sdlc-v1`

## Idempotent check
```bash
git -C $MAIN_REPO branch -a | grep -q release/ai-sdlc-v1
```

## Acceptance
- `release/ai-sdlc-v1` exists on every repo (local + remote)
- Branched from the repo's actual active branch (not an empty `main`)
- Repo CLAUDE.md updated to note the release branch target
