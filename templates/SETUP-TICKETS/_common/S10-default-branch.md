# S10: Record default branch + protected branches; protect the default branch

## What
Write each repo's default branch and its protected branches into the repo's stack file, and turn on branch protection for the default branch. There is no release branch: feature branches PR straight to the default branch.

## Why
Agents branch from `<remote>/<pr_base>` into `feature/<ticket-id>-<slug>` and open the PR into `pr_base` — the default branch unless the ticket names a stream branch (`.claude/rules/source-control.md`). They must know which branch that is, and must never commit or push to it. Repos differ (erp-core `master`, erp-fe `main`), so it is recorded per repo, not guessed.

## Steps
For each repo:
1. Find the real default branch: `gh repo view <owner>/<repo> --json defaultBranchRef --jq .defaultBranchRef.name`
2. In the repo's `.claude/stack-*.yml` set:
   ```yaml
   default_branch: <name>
   protected_branches: [master, main]   # plus any other long-lived branch
   ```
3. Protect the default branch on GitHub (Settings → Branches, or a ruleset): require a PR, block force-push and deletion
4. Note the default branch in the repo's `CLAUDE.md` (setup ticket S8)

## Idempotent check
```bash
cat .claude/stack-*.yml 2>/dev/null | grep -qE "^default_branch:[[:space:]]*[A-Za-z0-9._/-]+" && cat .claude/stack-*.yml | grep -qE "^protected_branches:"
```

## Acceptance
- `default_branch` and `protected_branches` set in every repo's stack file
- Default branch protected on GitHub (direct push and force-push refused)
- Repo `CLAUDE.md` names the default branch as the PR target
