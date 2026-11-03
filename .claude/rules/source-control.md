# Source Control — branches, PRs, commits

The single source for branch flow, PR rules, commit format, protected branches and commit attribution. Other rules link here instead of restating it. Project-specific values come from the project's stack file (`.claude/stack-be.yml`, `.claude/stack-fe.yml`; framework meta-work: `.claude/stack-framework.yml`):

| Key | Meaning | ERP | AISDLC |
|-----|---------|-----|--------|
| `remote` | git remote name for the host | `github` (clone with `git clone -o github ...`) | `origin` |
| `default_branch` | the repo's main branch | erp-core `master`, erp-fe `main` | `main` |
| `pr_base` | the stream branch the ticket names (ERP plan tickets: `plan/<stream>`, e.g. `plan/finance`); otherwise `default_branch` | `plan/<stream>` | `main` |
| `protected_branches` | extra protected branches | `[master, main, "plan/*"]` | `[main]` |
| `commit_attribution` | `none` or `co-author` | `none` | `none` |

Below, `<remote>`, `<pr_base>` and `<repo>` stand for these values.

## Tools

- Use the official CLI: `gh` for GitHub (plain `gh`, never an absolute path to the binary). For GitLab-hosted clients, `glab` works the same way.
- No raw API calls (`curl` against `api.github.com`) unless the CLI genuinely doesn't cover it; prefer `gh api` then.
- No MCP servers for git hosts — CLI keeps the process portable across AI tools.
- Board and GraphQL command recipes: `.claude/rules/gh-recipes.md`.

## Protected branches

`master`, `main`, plus any branch listed in the stack file's `protected_branches`.

AI never commits to, pushes to, force-pushes, or merges into a protected branch. AI never force-pushes any branch. AI never merges a PR — a human merges (in ERP, only with the owner's OK). `.claude/settings.json` denies these commands; the rule holds even where settings don't.

## Branch flow (no release branch)

Work only in a fresh git worktree at `../wt-<repo>-<ticket-id>` (e.g. `../wt-erp-core-214`); never switch an existing checkout's branch.

1. **Create the branch** — `@tester` does this (or, for tickets with no test step such as doc-only tickets, the agent doing the work). Branch from `<remote>/<pr_base>`:
   ```bash
   git fetch <remote>
   git worktree add ../wt-<repo>-<ticket-id> -b feature/<ticket-id>-<slug> <remote>/<pr_base>
   ```
   Branch name: `feature/<ticket-id>-<slug>` (e.g. `feature/214-invoice-credit-note`). Hotfixes: `hotfix/<ticket-id>-<slug>` from `<remote>/<default_branch>`, owned by `@shipper`.
2. **One branch per ticket per repo.** `@tester` commits the failing tests, pushes, and removes its worktree so the branch is free:
   ```bash
   git push -u <remote> feature/<ticket-id>-<slug>
   git worktree remove ../wt-<repo>-<ticket-id>
   ```
   `@builder` / `@fe-builder` then create their own worktree on that SAME existing branch — never a second branch for the same ticket in the same repo:
   ```bash
   git fetch <remote> && git worktree add ../wt-<repo>-<ticket-id> feature/<ticket-id>-<slug>
   ```
   A feature touching BE and FE has one branch in each repo.
3. Commit, verify (Verification Gate — `.claude/agents/builder.md`), push: `git push <remote> feature/<ticket-id>-<slug>`.
4. Open the PR **into `<pr_base>`**:
   ```bash
   gh pr create --repo <owner>/<repo> --base <pr_base> \
     --head feature/<ticket-id>-<slug> \
     --title "<ticket-id>: <what changed>" --body "..."
   ```
5. A human reviews and **squash-merges** the PR. ✅ Done is set by a human after merge (see `.claude/rules/kanban-workflow.md`).
6. Integrating stream branches into the default branch (ERP wave merges of `plan/<stream>` into `master` / `main`) is a human step, never an agent step.

Never open a PR from a default branch. Never rewrite pushed history (no `--force`, no `--force-with-lease`, no rebase of pushed commits).

## Commits

- Message starts with the ticket id: `<ticket-id>: <what changed>`.
- **One commit per ticket per repo** is achieved by the human's squash-merge. Agents may push several commits to the feature branch; never rewrite pushed history to squash them.
- Add specific files (`git add <path>`), never `git add .` / `git add -A` (see `.claude/rules/secrets-management.md`).
- **Attribution** follows `commit_attribution` in the stack file:
  - `none` — never add `Co-Authored-By`, "Generated with", or `Claude-Session` lines to commits or PR bodies. ERP is `none` (its repos also strip them with a `commit-msg` hook).
  - `co-author` — a standard co-author trailer naming the AI is allowed.
  - If the stack file is silent, use `none`.

## PRs

- Title: `<ticket-id>: <what changed>`.
- Body links the ticket, summarizes the change, and includes the verification output. Client-visible PRs go through the sanitization pass in `.claude/rules/client-facing-boundary.md`.
- Security-sensitive changes (auth, permissions, tenant context, money, data exposure) are listed under a "Security review" heading.

## Pre-flight checklist before opening a PR

- [ ] Tests green — Verification Gate passed (`.claude/agents/builder.md`).
- [ ] Lints / type checks clean.
- [ ] No secrets in the diff (`.claude/rules/secrets-management.md`).
- [ ] Ticket in the correct column (`.claude/rules/kanban-workflow.md`).
- [ ] Size within budget (`.claude/rules/size-audit.md`).
- [ ] Base branch = `<pr_base>` from the stack file; head = `feature/<id>-<slug>` or `hotfix/<id>-<slug>`.
