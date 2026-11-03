# ERP guardrails (erp-core + erp-fe)

Hard rules for any agent working on the ERP project. `erp-core/CLAUDE.md` and `erp-fe/CLAUDE.md` (in the cloned repos) are stricter and more detailed — where they differ from this file, they win. Project facts (branches, test commands, attribution) are in `.claude/stack-be.yml` and `.claude/stack-fe.yml`.

## Tickets and commits
- Tickets are split between Rohit and Vijay. Never take a ticket assigned to the other person.
- ERP plan tickets are tracked in the owner's Google Sheet tracker ("erp_plan_tracker", per the erp_code rules). The AISDLC project board (`erp-context/board-config.yml`) is used only once the owner sets it up; if that file does not exist, do not invent board IDs — stop and ask the user to run `/aisdlc-init`.
- A ticket that depends on another (`Depends on: #N`, or the dependency named in the tracker) starts only once the dependency's PR is merged.
- Plan tickets name a stream (`plan/local`, `plan/finance`, `plan/access`, `plan/portal`, `plan/masters`). Branch from `github/plan/<stream>` and open the PR into `plan/<stream>` (stack key `pr_base`). Wave merges of stream branches into `master` / `main` are done by a human with the owner's OK.
- One commit per ticket per repo: the human squash-merges the ticket PR. Agents may push several commits to the feature branch; never rewrite pushed history. Message starts with the ticket id (`P2-35: ...`). No attribution lines (`commit_attribution: none`, see `.claude/rules/source-control.md`).
- Flyway version numbers are claimed in `docs/db/flyway-number-register.md` (erp-core) in the same commit as the migration. Each stream has its own number block; never use a number outside yours.

## Where to work
- The ERP remote is named `github` (stack key `remote: github`; clone with `git clone -o github ...`).
- Only in fresh worktrees `../wt-<repo>-<ticket-id>` branched from `github/plan/<stream>` for plan tickets, else `github/master` (erp-core) / `github/main` (erp-fe). Never switch the main checkout's branch. Recipes: `.claude/rules/source-control.md`.
- Never point tests or a Flyway run at the local demo database `core_erp_db`.
- Never touch ports 5432, 5433, 6379, 9092.

## Machine limits (shared Mac)
- At most 2 test runs at the same time across all agents.
- Start a Maven run only when `ps -eo command | grep -c '[s]urefirebooter'` prints less than 6.
- Vitest only with `--maxWorkers=2` on specific files, never a wide sweep.
- Check `uptime` before heavy work; the full backend suite runs only in cloud shards (wave merge or release).
- Never `pkill` / `killall` shared process names (e.g. surefire). Kill only your own PID.

## Quality
- Mutation-prove every new behaviour: apply a mutation, watch the test turn red, restore.
- No placeholder or TODO tests, no weakened assertions.
- Security-sensitive changes (auth, permissions, RLS, tenant context, money, KYC, data exposure) are listed under "Security review" in the PR.
- Screens follow the ERP design boards: layout and wording from the board, data from the API, rem only (no px), no sample data.
