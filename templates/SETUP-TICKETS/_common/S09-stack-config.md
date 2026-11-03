# S9: Declare stack + operating mode in `.claude/stack-*.yml`

## What
Create one stack file per code repo (`.claude/stack-be.yml`, `.claude/stack-fe.yml`, ...) declaring the repo's facts: operating mode, branches, commit attribution, staging, stack and test commands.

## Why
Agents read `stack-*.yml` before working on a repo. Rules link to it instead of restating project facts. Mode (solo vs team) decides whether AI may move tickets into AI-active columns (`.claude/rules/solo-vs-team-mode.md`).

## Steps
1. Create `.claude/stack-<be|fe|...>.yml` per repo. Worked examples: `.claude/stack-be.yml` (erp-core) and `.claude/stack-fe.yml` (erp-fe) in the workspace (the AISDLC clone). Minimum keys:
   ```yaml
   framework:
     mode: team                     # solo | team (missing = team)
   project: <project-slug>
   repo: <owner>/<repo>
   local_path: <repo-dir>/
   remote: <origin | github>        # git remote name; clone with `git clone -o <remote> ...`
   default_branch: <master | main>  # S10
   pr_base: <default_branch | the stream branch the ticket names>
   protected_branches: [master, main]
   commit_attribution: none         # none | co-author
   staging: none                    # none, or the staging URL / deploy command
   language: <java | typescript | python | ...>
   framework_stack:
     name: <spring-boot | nextjs | django | ...>
     version: "<x.y>"
   test:
     per_ticket: "<command for the touched tests>"
     guard_set: "<tests that run with every ticket>"
     full_suite: "<when and where the full suite runs>"
   board_config: <project>-context/board-config.yml
   ```
2. Commit to the workspace repo that holds `.claude/`

## Idempotent check
```bash
ls .claude/stack-*.yml >/dev/null 2>&1 && cat .claude/stack-*.yml | grep -qE "^[[:space:]]+mode:[[:space:]]*(solo|team)"
```

## Acceptance
- One `.claude/stack-*.yml` per code repo
- `framework.mode` declared (solo or team)
- `default_branch`, `protected_branches`, `commit_attribution`, `staging` and test commands filled in
- `board_config` points at the project's board config
